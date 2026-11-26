import 'dart:convert';

import 'package:countersink/data/backup.dart';
import 'package:countersink/data/ids.dart';
import 'package:countersink/models/counter.dart';
import 'package:countersink/models/counter_group.dart';
import 'package:countersink/models/tap_event.dart';

/// The other counter apps whose files can be brought in. All three are open
/// source, so their formats were read from their code, not guessed:
///
/// - BetterCounter (org.kde.bettercounter), `Exporter.kt`: a line for each
///   counter, its name and then the time of every count in milliseconds.
/// - Counter (me.tsukanov.counter), `CounterCsv.kt`: a CSV of name, value
///   and the time of the last change.
/// - Simple Counter (org.quicksc0p3r.simplecounter), `CountersAndLabels.kt`:
///   a JSON object of counters and the labels they are filed under.
enum ImportSource { betterCounter, counter, simpleCounter }

/// Why a file couldn't be brought in at all.
enum ImportProblem {
  /// Not what the chosen app writes.
  notThatApp,

  /// The right kind of file, with no counters in it.
  empty,

  /// One of Countersink's own backups, which Restore is for.
  countersinkBackup,
}

class ImportException implements Exception {
  const ImportException(this.problem);

  final ImportProblem problem;

  @override
  String toString() => 'ImportException(${problem.name})';
}

/// What a file from another app comes to: new groups with their counters
/// and the history that could be recovered, ready to add beside what is
/// already there. Nothing in it refers to anything on the phone.
class Imported {
  const Imported({
    required this.groups,
    required this.counters,
    required this.events,
    this.skipped = 0,
  });

  /// In order; their places among the tabs are for whoever adds them.
  final List<CounterGroup> groups;
  final List<Counter> counters;
  final List<TapEvent> events;

  /// Lines or records that couldn't be made into a counter and were left
  /// out.
  final int skipped;
}

/// Reads [text] as a file from [source].
///
/// Counters go in one group called [groupName], except that Simple Counter's
/// labels each become a group of their own. [colors] are handed out in turn
/// to counters that bring none. Counts the file gives no time for are dated
/// [now].
///
/// What each app's file can and can't carry over:
///
/// - BetterCounter keeps the time of every count, so the whole history
///   comes across, one entry each. Colors and goals aren't in its file.
/// - Counter keeps only the number and when it last changed, which becomes
///   a single entry of that size at that time.
/// - Simple Counter keeps only the number, which becomes a single entry
///   dated [now]. A label's color becomes its counters' color.
///
/// A count below zero, which the other two allow, comes in as zero: here a
/// tally never goes below nothing.
///
/// Throws [ImportException] if the file isn't that app's or holds nothing.
Imported importFrom(
  ImportSource source,
  String text, {
  required DateTime now,
  required String groupName,
  required List<int> colors,
}) {
  // Spreadsheet apps often start a saved file with one.
  final body = text.startsWith('﻿') ? text.substring(1) : text;
  final builder = _Builder(groupName: groupName, colors: colors, now: now);
  switch (source) {
    case ImportSource.betterCounter:
      _betterCounter(body, builder);
    case ImportSource.counter:
      _counter(body, builder);
    case ImportSource.simpleCounter:
      _simpleCounter(body, builder);
  }
  if (builder.counters.isEmpty) {
    throw const ImportException(ImportProblem.empty);
  }
  return builder.result();
}

/// What to send to another phone: the [chosen] counters out of everything in
/// [all], as a backup of their own.
///
/// A calculated counter brings the counters it is worked out from, chosen
/// or not, so it arrives working; a group comes if any counter in it does.
/// With [withHistory] every entry goes. Without it each counter goes with
/// one entry, the number its card shows at [now] ([valueOf] gives that),
/// which is far fewer codes to scan. The phone's own settings stay behind:
/// what arrives is added beside what the other phone has, not put in its
/// place.
BackupData selectForTransfer(
  BackupData all,
  Set<String> chosen, {
  required bool withHistory,
  required int Function(Counter counter) valueOf,
  required DateTime now,
}) {
  final byId = {for (final c in all.counters) c.id: c};
  final going = <String>{};
  for (final id in chosen) {
    final counter = byId[id];
    if (counter == null) continue;
    going.add(id);
    for (final source in counter.sources) {
      // Only ordinary counters can be sources, so one step is the whole way.
      if (byId[source] case final s? when !s.calculated) going.add(s.id);
    }
  }
  final counters = [
    for (final c in all.counters)
      if (going.contains(c.id)) c,
  ];
  final groups = [
    for (final g in all.groups)
      if (counters.any((c) => c.groupId == g.id)) g,
  ];
  final events = withHistory
      ? [
          for (final e in all.events)
            if (going.contains(e.counterId)) e,
        ]
      : [
          for (final c in counters)
            if (!c.calculated && valueOf(c) > 0)
              TapEvent(
                id: '',
                counterId: c.id,
                at: now.toUtc(),
                delta: valueOf(c),
                kind: EventKind.set,
              ),
        ];

  // Short ids in place of the long random ones. The other phone gives
  // everything ids of its own, so these only have to tell things apart
  // within the file, and random ids are the one part of a history that
  // can't be squeezed: this roughly halves the codes to scan.
  final groupIds = {for (final (i, g) in groups.indexed) g.id: 'g$i'};
  final counterIds = {for (final (i, c) in counters.indexed) c.id: 'c$i'};
  return BackupData(
    groups: [
      for (final g in groups)
        CounterGroup(id: groupIds[g.id]!, name: g.name, position: g.position),
    ],
    counters: [
      for (final c in counters)
        c
            .copiedAs(
              id: counterIds[c.id]!,
              groupId: groupIds[c.groupId] ?? c.groupId,
              sources: [for (final id in c.sources) ?counterIds[id]],
              position: c.position,
            )
            .moved(archived: c.archived),
    ],
    events: [
      for (final (i, e) in events.indexed)
        TapEvent(
          id: i.toRadixString(36),
          counterId: counterIds[e.counterId]!,
          at: e.at,
          delta: e.delta,
          kind: e.kind,
        ),
    ],
  );
}

/// What a backup received from another phone comes to here: its groups,
/// counters and entries under new ids, ready to add beside what there is.
/// New ids, because the same counters may be sent twice, or sent back, and
/// must not collide with their earlier selves. Counters put away on the
/// other phone arrive on their tabs.
Imported importBackup(BackupData data) {
  final groupIds = {for (final g in data.groups) g.id: newId()};
  final counterIds = {for (final c in data.counters) c.id: newId()};
  final places = <String, int>{};
  return Imported(
    groups: [
      for (final (i, g) in data.groups.indexed)
        CounterGroup(id: groupIds[g.id]!, name: g.name, position: i),
    ],
    counters: [
      for (final c in data.counters)
        if (groupIds[c.groupId] case final groupId?)
          c.copiedAs(
            id: counterIds[c.id]!,
            groupId: groupId,
            sources: [for (final id in c.sources) ?counterIds[id]],
            position: places.update(groupId, (p) => p + 1, ifAbsent: () => 0),
          ),
    ],
    events: [
      for (final e in data.events)
        if (counterIds[e.counterId] case final counterId?)
          TapEvent(
            id: newId(),
            counterId: counterId,
            at: e.at,
            delta: e.delta,
            kind: e.kind,
          ),
    ],
  );
}

/// Collects what an importer finds, giving out ids, places and colors.
class _Builder {
  _Builder({required this.groupName, required this.colors, required this.now});

  final String groupName;
  final List<int> colors;
  final DateTime now;

  final groups = <CounterGroup>[];
  final counters = <Counter>[];
  final events = <TapEvent>[];
  var skipped = 0;

  CounterGroup? _main;
  final _places = <String, int>{};

  /// The one group for counters that belong nowhere else, made when first
  /// wanted.
  CounterGroup get main => _main ??= group(groupName);

  CounterGroup group(String name) {
    final g = CounterGroup(id: newId(), name: name, position: groups.length);
    groups.add(g);
    return g;
  }

  Counter counter(String name, {CounterGroup? group, int? color}) {
    final g = group ?? main;
    final place = _places[g.id] ?? 0;
    _places[g.id] = place + 1;
    final c = Counter(
      id: newId(),
      groupId: g.id,
      name: name,
      color: color ?? colors[counters.length % colors.length],
      position: place,
    );
    counters.add(c);
    return c;
  }

  void event(Counter counter, int delta, DateTime at, EventKind kind) {
    events.add(
      TapEvent(
        id: newId(),
        counterId: counter.id,
        at: at.toUtc(),
        delta: delta,
        kind: kind,
      ),
    );
  }

  /// A number that is all the file has, as one entry. Nothing counted, or
  /// less than nothing, leaves no entry at all.
  void value(Counter counter, int value, DateTime? at) {
    if (value > 0) event(counter, value, at ?? now, EventKind.set);
  }

  Imported result() => Imported(
    groups: groups,
    counters: counters,
    events: events,
    skipped: skipped,
  );
}

/// The smallest number BetterCounter itself takes for a time rather than
/// part of a name: 1973, in milliseconds.
const _earliestTime = 100000000000;

/// The largest number the Counter app keeps.
const _largestCount = 2147483647;

/// The latest a time can sensibly be: the year 3000, in milliseconds.
const _latestTime = 32503680000000;

/// One counter a line: `name,time,time,…`, each time one count.
///
/// The name isn't quoted, so a comma in it looks like the start of the
/// times. BetterCounter's own import settles that by taking everything up to
/// the first number big enough to be a time as the name, and so does this.
void _betterCounter(String text, _Builder to) {
  if (_looksLikeJson(text)) {
    throw const ImportException(ImportProblem.notThatApp);
  }
  final lines = [
    for (final line in const LineSplitter().convert(text))
      if (line.trim().isNotEmpty) line,
  ];
  // Counter's file, which quotes everything, would otherwise come in as
  // counters named after whole lines of it.
  if (lines.isNotEmpty && lines.first.startsWith('"Name","Value"')) {
    throw const ImportException(ImportProblem.notThatApp);
  }
  for (final raw in lines) {
    final fields = raw.split(',');
    var nameEnds = fields.length;
    for (var i = 1; i < fields.length; i++) {
      final n = int.tryParse(fields[i].trim());
      if (n != null && n >= _earliestTime) {
        nameEnds = i;
        break;
      }
    }
    final name = fields.sublist(0, nameEnds).join(',').trim();
    final times = <int>[];
    var bad = name.isEmpty;
    for (final field in fields.skip(nameEnds)) {
      final n = int.tryParse(field.trim());
      if (n == null || n < 0 || n > _latestTime) {
        bad = true;
        break;
      }
      times.add(n);
    }
    // A line with anything but times after its name isn't one of these.
    if (bad) {
      to.skipped++;
      continue;
    }
    final counter = to.counter(name);
    for (final t in times) {
      to.event(
        counter,
        1,
        DateTime.fromMillisecondsSinceEpoch(t, isUtc: true),
        EventKind.tap,
      );
    }
  }
  // Not one line that reads as a counter: some other kind of file.
  if (to.counters.isEmpty && to.skipped > 0) {
    throw const ImportException(ImportProblem.notThatApp);
  }
}

/// `"Name","Value","Last Update"` and a row for each counter. A first row
/// with no number for a value is the header. If a name comes twice the last
/// one stands, as in Counter itself.
void _counter(String text, _Builder to) {
  if (_looksLikeJson(text)) {
    throw const ImportException(ImportProblem.notThatApp);
  }
  final found = <String, ({int value, DateTime? at})>{};
  for (final (i, row) in _csvRows(text).indexed) {
    final name = row.isEmpty ? '' : row[0].trim();
    final value = row.length < 2 ? null : int.tryParse(row[1].trim());
    // Counter's own numbers fit in 32 bits; anything bigger is something
    // else, such as one of BetterCounter's times.
    if (name.isEmpty ||
        value == null ||
        value.abs() > _largestCount ||
        row.length > 3) {
      if (i > 0 || row.length > 3) to.skipped++;
      continue;
    }
    final stamp = row.length > 2 ? row[2].trim() : '';
    found[name] = (value: value, at: _counterTime(stamp));
  }
  if (found.isEmpty && to.skipped > 0) {
    throw const ImportException(ImportProblem.notThatApp);
  }
  for (final MapEntry(key: name, value: row) in found.entries) {
    to.value(to.counter(name), row.value, row.at);
  }
}

/// Counter writes `20261108T142843+0100`; a spreadsheet may have rewritten
/// it. Anything that isn't a time is as good as none.
DateTime? _counterTime(String text) =>
    text.isEmpty ? null : DateTime.tryParse(text);

/// `{"counters": [{id, name, value, defaultValue, labelId, …}],
///   "labels": [{id, name, color}]}`, where a color is a whole number,
/// 0xAARRGGBB.
void _simpleCounter(String text, _Builder to) {
  final Object? json;
  try {
    json = jsonDecode(text);
  } on FormatException {
    throw const ImportException(ImportProblem.notThatApp);
  }
  if (json is! Map<String, Object?>) {
    throw const ImportException(ImportProblem.notThatApp);
  }
  if (json.containsKey('countersinkBackup')) {
    throw const ImportException(ImportProblem.countersinkBackup);
  }
  final counters = json['counters'];
  if (counters is! List) {
    throw const ImportException(ImportProblem.notThatApp);
  }

  // A label becomes a group only once a counter turns up under it.
  final labels = <int, ({String name, int? color})>{};
  final rawLabels = json['labels'];
  if (rawLabels is List) {
    for (final l in rawLabels) {
      if (l is! Map) continue;
      final id = l['id'];
      final name = l['name'];
      final color = l['color'];
      if (id is int && name is String && name.trim().isNotEmpty) {
        labels[id] = (
          name: name.trim(),
          color: color is int ? 0xFF000000 | (color & 0xFFFFFF) : null,
        );
      }
    }
  }
  final groups = <int, CounterGroup>{};

  for (final c in counters) {
    final name = c is Map ? c['name'] : null;
    final value = c is Map ? c['value'] : null;
    if (c is! Map || name is! String || name.trim().isEmpty || value is! int) {
      to.skipped++;
      continue;
    }
    final labelId = c['labelId'];
    final label = labelId is int ? labels[labelId] : null;
    final counter = label == null
        ? to.counter(name.trim())
        : to.counter(
            name.trim(),
            group: groups[labelId as int] ??= to.group(label.name),
            color: label.color,
          );
    to.value(counter, value, null);
  }
}

bool _looksLikeJson(String text) {
  final start = text.trimLeft();
  return start.startsWith('{') || start.startsWith('[');
}

/// Splits CSV text into rows of fields: commas between fields, a field
/// optionally in double quotes, a quote inside a quoted field doubled, and
/// rows ended by either kind of line break. Blank rows are left out.
List<List<String>> _csvRows(String text) {
  final rows = <List<String>>[];
  var row = <String>[];
  final field = StringBuffer();
  var quoted = false;
  var any = false;

  void endField() {
    row.add(field.toString());
    field.clear();
  }

  void endRow() {
    endField();
    if (any) rows.add(row);
    row = <String>[];
    any = false;
  }

  for (var i = 0; i < text.length; i++) {
    final ch = text[i];
    if (quoted) {
      if (ch == '"') {
        if (i + 1 < text.length && text[i + 1] == '"') {
          field.write('"');
          i++;
        } else {
          quoted = false;
        }
      } else {
        field.write(ch);
      }
      continue;
    }
    switch (ch) {
      case '"':
        quoted = true;
        any = true;
      case ',':
        endField();
        any = true;
      case '\n':
        endRow();
      case '\r':
        break;
      default:
        field.write(ch);
        if (ch.trim().isNotEmpty) any = true;
    }
  }
  endRow();
  return rows;
}
