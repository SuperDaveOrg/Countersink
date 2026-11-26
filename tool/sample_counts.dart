// Writes a backup file of fictional sample counts, for restoring onto a test
// phone or emulator: screenshots, and trying things out on more than an
// empty screen.
//
// Usage: dart run tool/sample_counts.dart out.json
//
// The file follows docs/backup-format.md. Everything is relative to now, so
// the per-day counters have a today that is part-way to its goal and two
// weeks of days behind it.

import 'dart:convert';
import 'dart:io';
import 'dart:math';

final _random = Random(7);
var _nextId = 0;

String _id() => 'sample-${_nextId++}';

Map<String, Object?> _event(DateTime at, int change) => {
      'id': _id(),
      'at': at.toUtc().toIso8601String(),
      'change': change,
      'kind': 'tap',
    };

/// A few sittings a day for [days] days, ending today, each adding around
/// [typical]. Today gets [today] in total instead.
List<Map<String, Object?>> _daily(
  DateTime now, {
  required int days,
  required int typical,
  required int today,
  int sittings = 3,
}) {
  final events = <Map<String, Object?>>[];
  final morning = DateTime(now.year, now.month, now.day, 7);
  for (var back = days - 1; back >= 1; back--) {
    if (back % 6 == 4) continue; // a day off now and then
    for (var s = 0; s < sittings; s++) {
      final at = morning
          .subtract(Duration(days: back))
          .add(Duration(hours: s * 5, minutes: _random.nextInt(50)));
      final change = (typical / sittings * (0.7 + _random.nextDouble() * 0.7)).round();
      events.add(_event(at, max(1, change)));
    }
  }
  // Today, in two sittings that have already happened.
  final first = today ~/ 2;
  events.add(_event(now.subtract(const Duration(hours: 3)), first));
  events.add(_event(now.subtract(const Duration(minutes: 20)), today - first));
  return events;
}

/// A running count built up over the last [days] days to [total].
List<Map<String, Object?>> _running(DateTime now, {required int days, required int total}) {
  final events = <Map<String, Object?>>[];
  var left = total;
  for (var back = days; back >= 0 && left > 0; back--) {
    final change = back == 0 ? left : min(left, max(1, total ~/ (days + 1)));
    events.add(_event(now.subtract(Duration(days: back, minutes: 35)), change));
    left -= change;
  }
  return events;
}

Map<String, Object?> _counter(
  String name, {
  String? description,
  required String color,
  String? color2,
  String? pattern,
  int? step,
  int? goal,
  bool perDay = false,
  required List<Map<String, Object?>> events,
}) =>
    {
      'id': _id(),
      'name': name,
      'description': ?description,
      'color': color,
      'color2': ?color2,
      'pattern': ?pattern,
      'step': ?step,
      'goal': ?goal,
      if (perDay) 'perDay': true,
      'events': events,
    };

Map<String, Object?> sampleBackup(DateTime now) => {
      'countersinkBackup': 1,
      'exportedAt': now.toUtc().toIso8601String(),
      'dayStartHour': 4,
      'groups': [
        {
          'id': _id(),
          'name': 'Fitness',
          'counters': [
            _counter('Pull-ups',
                description: 'Strict, full hang',
                color: '#C4613F',
                goal: 50,
                perDay: true,
                events: _daily(now, days: 14, typical: 48, today: 34)),
            _counter('Push-ups',
                description: 'Sets of five',
                color: '#1A8783',
                color2: '#14344B',
                step: 5,
                goal: 100,
                perDay: true,
                events: _daily(now, days: 14, typical: 95, today: 100)),
            _counter('Glasses of water',
                color: '#6FA3C0',
                pattern: 'dots',
                goal: 8,
                perDay: true,
                events: _daily(now, days: 14, typical: 7, today: 5)),
            _counter('Kilometers run',
                description: 'Since the first of the month',
                color: '#2F5A45',
                pattern: 'stripes',
                events: _running(now, days: 12, total: 86)),
          ],
        },
        {
          'id': _id(),
          'name': 'Knitting',
          'counters': [
            _counter('Rows',
                description: 'Cardigan, left front',
                color: '#6B3F5B',
                color2: '#C98A8A',
                goal: 120,
                events: _running(now, days: 6, total: 74)),
            _counter('Pattern repeats',
                color: '#C28A2C', pattern: 'grid', events: _running(now, days: 6, total: 9)),
          ],
        },
        {
          'id': _id(),
          'name': 'Game night',
          'counters': [
            _counter('Blue team', color: '#3F5568', events: _running(now, days: 0, total: 17)),
            _counter('Green team', color: '#6B7A3A', events: _running(now, days: 0, total: 21)),
          ],
        },
      ],
    };

void main(List<String> args) {
  if (args.length != 1) {
    stderr.writeln('usage: dart run tool/sample_counts.dart <out.json>');
    exit(64);
  }
  final now = DateTime.now();
  File(args.single)
      .writeAsStringSync(const JsonEncoder.withIndent('  ').convert(sampleBackup(now)));
  stdout.writeln('Wrote ${args.single}: fictional sample counts relative to now.');
}
