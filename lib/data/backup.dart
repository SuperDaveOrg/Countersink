import 'dart:convert';

import 'package:countersink/models/counter.dart';
import 'package:countersink/models/counter_group.dart';
import 'package:countersink/models/tap_event.dart';

/// The backup file format. See docs/backup-format.md, which is the contract;
/// this file is one implementation of it.
///
/// Plain, documented JSON on purpose: a backup should be readable in a text
/// editor and importable by some other app one day, so nobody is locked in.
/// Nothing here needs Flutter, so tools can run it under plain `dart run`.
const backupFormatVersion = 1;

/// The suggested file name for a backup taken on [day].
String backupFileName(DateTime day) {
  String two(int n) => n.toString().padLeft(2, '0');
  return 'countersink-backup-${day.year}-${two(day.month)}-${two(day.day)}.json';
}

/// Everything a backup holds: every group, counter and event, and the
/// setting that decides which day an event counts toward.
class BackupData {
  const BackupData({
    required this.groups,
    required this.counters,
    required this.events,
    this.dayStartHour,
    this.weekStart,
  });

  /// In tab order.
  final List<CounterGroup> groups;

  /// In order within each group.
  final List<Counter> counters;
  final List<TapEvent> events;

  /// Null in a file that doesn't say; the phone's own setting then stays.
  final int? dayStartHour;

  /// The day a week begins on, 1 for Monday through 7 for Sunday. Null in a
  /// file that doesn't say; the phone's own setting then stays.
  final int? weekStart;
}

/// Writes [data] as a backup file's text. Groups and counters are written
/// in order, which is all that records their order; each event takes one
/// line, so a long history stays readable and small.
String encodeBackup(BackupData data, {required DateTime exportedAt}) {
  final countersByGroup = <String, List<Counter>>{};
  for (final c in data.counters) {
    countersByGroup.putIfAbsent(c.groupId, () => []).add(c);
  }
  final eventsByCounter = <String, List<TapEvent>>{};
  for (final e in data.events) {
    eventsByCounter.putIfAbsent(e.counterId, () => []).add(e);
  }

  final counterIds = {for (final c in data.counters) c.id};

  final out = StringBuffer();
  String q(Object? v) => jsonEncode(v);
  out.writeln('{');
  out.writeln('  "countersinkBackup": $backupFormatVersion,');
  out.writeln('  "exportedAt": ${q(_instant(exportedAt))},');
  if (data.dayStartHour != null) {
    out.writeln('  "dayStartHour": ${data.dayStartHour},');
  }
  if (data.weekStart != null) {
    out.writeln('  "weekStartsOn": ${data.weekStart},');
  }
  out.writeln('  "groups": [');
  for (final (gi, g) in data.groups.indexed) {
    final counters = countersByGroup[g.id] ?? const <Counter>[];
    out.writeln('    {');
    out.writeln('      "id": ${q(g.id)},');
    out.writeln('      "name": ${q(g.name)},');
    out.writeln('      "counters": [${counters.isEmpty ? ']' : ''}');
    for (final (ci, c) in counters.indexed) {
      final events = eventsByCounter[c.id] ?? const <TapEvent>[];
      out.writeln('        {');
      out.writeln('          "id": ${q(c.id)},');
      out.writeln('          "name": ${q(c.name)},');
      if (c.description != null) {
        out.writeln('          "description": ${q(c.description)},');
      }
      out.writeln('          "color": ${q(_colorText(c.color))},');
      if (c.color2 != null) {
        out.writeln('          "color2": ${q(_colorText(c.color2!))},');
      }
      if (c.pattern != CounterPattern.none) {
        out.writeln('          "pattern": ${q(c.pattern.name)},');
      }
      out.writeln('          "step": ${c.step},');
      if (c.goal != null) out.writeln('          "goal": ${c.goal},');
      if (c.goalPeriod != GoalPeriod.day) {
        out.writeln('          "goalPeriod": ${q(c.goalPeriod.name)},');
      }
      if (c.buzzEvery != null) {
        out.writeln('          "buzzEvery": ${c.buzzEvery},');
      }
      if (c.formula != null) {
        // Only counters that are in the file: one that has been deleted
        // would leave a link to nothing.
        final of = [
          for (final id in c.sources)
            if (counterIds.contains(id)) q(id),
        ];
        out.writeln('          "formula": ${q(c.formula!.name)},');
        out.writeln('          "of": [${of.join(', ')}],');
        if (c.roundSize != null) {
          out.writeln('          "roundSize": ${c.roundSize},');
        }
        if (c.allTime) out.writeln('          "allTime": true,');
        if (c.startFrom != null) {
          out.writeln('          "startFrom": ${c.startFrom},');
        }
      }
      out.writeln('          "perDay": ${c.daily},');
      if (c.archived) out.writeln('          "archived": true,');
      out.writeln('          "events": [${events.isEmpty ? ']' : ''}');
      for (final (ei, e) in events.indexed) {
        out.writeln(
          '            {"id": ${q(e.id)}, "at": ${q(_instant(e.at))}, '
          '"change": ${e.delta}, "kind": ${q(e.kind.name)}}'
          '${ei == events.length - 1 ? '' : ','}',
        );
      }
      if (events.isNotEmpty) out.writeln('          ]');
      out.writeln('        }${ci == counters.length - 1 ? '' : ','}');
    }
    if (counters.isNotEmpty) out.writeln('      ]');
    out.writeln('    }${gi == data.groups.length - 1 ? '' : ','}');
  }
  out.writeln('  ]');
  out.writeln('}');
  return out.toString();
}

String _instant(DateTime at) => at.toUtc().toIso8601String();

/// "#C4613F": the card color without its alpha, which is always solid.
String _colorText(int argb) =>
    '#${(argb & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';

/// What is wrong with a file that can't be restored.
enum BackupProblem {
  /// Not a Countersink backup at all: not JSON, or without the marker.
  notCountersink,

  /// Written by a later version of the app, in a format this one predates.
  tooNew,

  /// A Countersink backup with something missing or impossible in it.
  damaged,
}

/// A file that can't be restored. [detail] says where a damaged file went
/// wrong, in plain technical English for a bug report.
class BackupFormatException implements Exception {
  const BackupFormatException(this.problem, [this.detail]);

  final BackupProblem problem;
  final String? detail;

  @override
  String toString() =>
      'BackupFormatException: ${problem.name}${detail == null ? '' : ' ($detail)'}';
}

/// Reads a backup, checking all of it before returning anything: a file
/// that is wrong anywhere is refused whole, never half-restored.
BackupData decodeBackup(String text) {
  final Object? json;
  try {
    json = jsonDecode(text);
  } on FormatException {
    throw const BackupFormatException(BackupProblem.notCountersink);
  }
  if (json is! Map<String, Object?> || json['countersinkBackup'] == null) {
    throw const BackupFormatException(BackupProblem.notCountersink);
  }
  final version = json['countersinkBackup'];
  if (version is! int || version < 1) {
    throw const BackupFormatException(
      BackupProblem.damaged,
      '"countersinkBackup" is not a version number',
    );
  }
  if (version > backupFormatVersion) {
    throw const BackupFormatException(BackupProblem.tooNew);
  }

  final root = _Reader(json, 'the file');
  final dayStartHour = root.optionalInt('dayStartHour', min: 0, max: 11);
  final weekStart = root.optionalInt('weekStartsOn', min: 1, max: 7);
  final ids = <String>{};
  final groups = <CounterGroup>[];
  final counters = <Counter>[];
  final events = <TapEvent>[];

  for (final (gi, g) in root.list('groups').indexed) {
    final groupId = g.id(ids);
    groups.add(CounterGroup(id: groupId, name: g.string('name'), position: gi));

    for (final (ci, c) in g.list('counters').indexed) {
      final counterId = c.id(ids);
      counters.add(
        Counter(
          id: counterId,
          groupId: groupId,
          name: c.string('name'),
          description: c.optionalString('description'),
          color: c.color('color'),
          color2: c.optionalColor('color2'),
          pattern: c.pattern('pattern'),
          step: c.optionalInt('step', min: 1, max: 999999999) ?? 1,
          goal: c.optionalInt('goal', min: 1, max: 999999999),
          goalPeriod: c.goalPeriod('goalPeriod'),
          buzzEvery: c.optionalInt('buzzEvery', min: 1, max: 999999999),
          formula: c.formula('formula'),
          sources: c.optionalStrings('of'),
          roundSize: c.optionalInt('roundSize', min: 1, max: 999999999),
          allTime: c.optionalBool('allTime') ?? false,
          startFrom: c.optionalInt('startFrom', min: 1, max: 999999999),
          daily: c.optionalBool('perDay') ?? false,
          archived: c.optionalBool('archived') ?? false,
          position: ci,
        ),
      );

      for (final e in c.optionalList('events')) {
        events.add(
          TapEvent(
            id: e.id(ids),
            counterId: counterId,
            at: e.instant('at'),
            delta: e.value<int>('change'),
            kind: e.kind('kind'),
          ),
        );
      }
    }
  }

  // A calculated counter may only be worked out from counters in the file.
  final counterIds = {for (final c in counters) c.id};
  for (final c in counters) {
    for (final id in c.sources) {
      if (!counterIds.contains(id) || id == c.id) {
        throw BackupFormatException(
          BackupProblem.damaged,
          '"${c.name}": "of" names "$id", which is not another counter '
          'in the file',
        );
      }
    }
  }

  return BackupData(
    groups: groups,
    counters: counters,
    events: events,
    dayStartHour: dayStartHour,
    weekStart: weekStart,
  );
}

/// Typed access to one JSON object, with errors that say where the problem
/// is.
class _Reader {
  _Reader(Object? json, this.where) {
    if (json is! Map<String, Object?>) {
      throw _damaged('$where is not an object');
    }
    _json = json;
  }

  final String where;
  late final Map<String, Object?> _json;

  static BackupFormatException _damaged(String detail) =>
      BackupFormatException(BackupProblem.damaged, detail);

  T value<T>(String key) {
    final v = _json[key];
    if (v is! T) throw _damaged('$where: "$key" is missing or the wrong kind');
    return v;
  }

  String string(String key) {
    final v = value<String>(key);
    if (v.trim().isEmpty) throw _damaged('$where: "$key" is empty');
    return v;
  }

  String? optionalString(String key) =>
      _json[key] == null ? null : value<String>(key);

  bool? optionalBool(String key) =>
      _json[key] == null ? null : value<bool>(key);

  int? optionalInt(String key, {required int min, required int max}) {
    if (_json[key] == null) return null;
    final v = value<int>(key);
    if (v < min || v > max) throw _damaged('$where: "$key" can\'t be $v');
    return v;
  }

  /// "#RRGGBB", as 0xFFRRGGBB.
  int color(String key) {
    final s = value<String>(key);
    final m = RegExp(r'^#([0-9a-fA-F]{6})$').firstMatch(s);
    if (m == null) {
      throw _damaged('$where: "$key" is not a color like #C4613F');
    }
    return 0xFF000000 | int.parse(m.group(1)!, radix: 16);
  }

  int? optionalColor(String key) => _json[key] == null ? null : color(key);

  /// What is drawn over the color; nothing unless the file says.
  CounterPattern pattern(String key) {
    final s = optionalString(key);
    if (s == null) return CounterPattern.none;
    return CounterPattern.values.asNameMap()[s] ??
        (throw _damaged('$where: "$key" is "$s", which is not a pattern'));
  }

  /// How a calculated counter is worked out; an ordinary one says nothing.
  Formula? formula(String key) {
    final s = optionalString(key);
    if (s == null) return null;
    return Formula.values.asNameMap()[s] ??
        (throw _damaged('$where: "$key" is "$s", which is not a formula'));
  }

  /// A list of ids, or none if the file doesn't say.
  List<String> optionalStrings(String key) {
    if (_json[key] == null) return const [];
    final items = value<List<Object?>>(key);
    return [
      for (final item in items)
        item is String
            ? item
            : throw _damaged(
                '$where: "$key" holds something that is not an id',
              ),
    ];
  }

  /// What a per-day counter's goal is for; each day unless the file says.
  GoalPeriod goalPeriod(String key) {
    final s = optionalString(key);
    if (s == null) return GoalPeriod.day;
    return GoalPeriod.values.asNameMap()[s] ??
        (throw _damaged('$where: "$key" is "$s", which is not day or week'));
  }

  /// An ISO 8601 instant, which must say its offset: a bare local time would
  /// mean different moments on different phones.
  DateTime instant(String key) {
    final s = value<String>(key);
    final parsed = DateTime.tryParse(s);
    final hasOffset = RegExp(r'(Z|[+-]\d{2}:?\d{2})$').hasMatch(s);
    if (parsed == null || !hasOffset) {
      throw _damaged('$where: "$key" is not a time with an offset');
    }
    return parsed.toUtc();
  }

  /// Why the count changed; a plain tap unless the file says otherwise.
  EventKind kind(String key) {
    final s = optionalString(key);
    if (s == null) return EventKind.tap;
    for (final k in EventKind.values) {
      if (k.name == s) return k;
    }
    throw _damaged('$where: "$key" is "$s", which is not a kind of change');
  }

  /// A record id, which must be unique across the whole file.
  String id(Set<String> seen) {
    final id = string('id');
    if (!seen.add(id)) throw _damaged('the id "$id" is used twice');
    return id;
  }

  List<_Reader> list(String key) {
    final items = value<List<Object?>>(key);
    return [
      for (final (i, item) in items.indexed)
        _Reader(item, _describe(key, i, item)),
    ];
  }

  List<_Reader> optionalList(String key) =>
      _json[key] == null ? const [] : list(key);

  String _describe(String key, int i, Object? item) {
    final name = item is Map ? item['name'] : null;
    return name is String ? '"$name"' : '$where, "$key" item ${i + 1}';
  }
}
