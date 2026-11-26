import 'package:countersink/data/backup.dart';
import 'package:countersink/data/importers.dart';
import 'package:countersink/models/counter.dart';
import 'package:countersink/models/tap_event.dart';
import 'package:flutter_test/flutter_test.dart';

/// The sample files here are written the way each app's own code writes
/// them (see the links in lib/data/importers.dart), not captured from a
/// phone.
void main() {
  final now = DateTime.utc(2026, 11, 23, 12);
  const colors = [0xFFC4613F, 0xFF1A8783, 0xFF14344B];

  Imported read(ImportSource source, String text) =>
      importFrom(source, text, now: now, groupName: 'Imported', colors: colors);

  Matcher refused(ImportProblem problem) => throwsA(
    isA<ImportException>().having((e) => e.problem, 'problem', problem),
  );

  int total(Imported file, Counter counter) => file.events
      .where((e) => e.counterId == counter.id)
      .fold(0, (sum, e) => sum + e.delta);

  group('BetterCounter', () {
    const file =
        'Push-ups,1700000000000,1700000060000,1700003600000\n'
        'Water\n'
        'Coffee, with milk,1700000000000\n'
        '7,1700000000000\n';

    test('every count comes across with its time', () {
      final got = read(ImportSource.betterCounter, file);
      expect(got.groups.single.name, 'Imported');
      expect(
        [for (final c in got.counters) c.name],
        ['Push-ups', 'Water', 'Coffee, with milk', '7'],
      );
      final pushUps = got.counters.first;
      final entries = got.events.where((e) => e.counterId == pushUps.id);
      expect([for (final e in entries) e.delta], [1, 1, 1]);
      expect(entries.every((e) => e.kind == EventKind.tap), isTrue);
      expect(
        entries.first.at,
        DateTime.fromMillisecondsSinceEpoch(1700000000000, isUtc: true),
      );
      expect(total(got, got.counters[1]), 0, reason: 'nothing counted yet');
      expect(got.skipped, 0);
    });

    test('counters get places in order, and the colours in turn', () {
      final got = read(ImportSource.betterCounter, file);
      expect([for (final c in got.counters) c.position], [0, 1, 2, 3]);
      expect(
        [for (final c in got.counters) c.color],
        [colors[0], colors[1], colors[2], colors[0]],
      );
      expect(
        got.counters.every((c) => c.groupId == got.groups.single.id),
        isTrue,
      );
    });

    test('a line with words after its times is left out and counted', () {
      final got = read(
        ImportSource.betterCounter,
        'Good,1700000000000\nBad,1700000000000,oops\n',
      );
      expect(got.counters.single.name, 'Good');
      expect(got.skipped, 1);
    });

    test('a file that starts with a byte order mark, with blank lines', () {
      final got = read(
        ImportSource.betterCounter,
        '﻿Laps,1700000000000\r\n\r\nMiles\r\n',
      );
      expect([for (final c in got.counters) c.name], ['Laps', 'Miles']);
    });

    test('is not taken in from the other two apps\' files', () {
      expect(
        () => read(
          ImportSource.betterCounter,
          '"Name","Value","Last Update"\n"Laps","42",""\n',
        ),
        refused(ImportProblem.notThatApp),
      );
      expect(
        () => read(ImportSource.betterCounter, '{"counters":[],"labels":[]}'),
        refused(ImportProblem.notThatApp),
      );
    });
  });

  group('Counter', () {
    const file =
        '"Name","Value","Last Update"\n'
        '"Laps","42","20261108T142843+0100"\n'
        '"Push-ups, morning","-3",""\n'
        '"He said ""hi""","7","20200102T030405Z"\n';

    test('each number comes across as one entry, at its last change', () {
      final got = read(ImportSource.counter, file);
      expect(
        [for (final c in got.counters) c.name],
        ['Laps', 'Push-ups, morning', 'He said "hi"'],
      );
      final laps = got.events.singleWhere(
        (e) => e.counterId == got.counters.first.id,
      );
      expect((laps.delta, laps.kind), (42, EventKind.set));
      expect(laps.at, DateTime.utc(2026, 11, 8, 13, 28, 43));
      expect(total(got, got.counters.last), 7);
      expect(got.skipped, 0, reason: 'the header is not a bad row');
    });

    test('a count below zero comes in as nothing counted', () {
      final got = read(ImportSource.counter, file);
      expect(total(got, got.counters[1]), 0);
      expect(
        got.events.where((e) => e.counterId == got.counters[1].id),
        isEmpty,
      );
    });

    test('a file without header, quotes or times, as a spreadsheet may '
        'leave it', () {
      final got = read(ImportSource.counter, 'First,1\r\n\r\nSecond, 2 ,\n');
      expect([for (final c in got.counters) c.name], ['First', 'Second']);
      expect(total(got, got.counters.last), 2);
      expect(got.events.every((e) => e.at == now), isTrue, reason: 'no time');
    });

    test('rows that are not counters are left out and counted', () {
      final got = read(
        ImportSource.counter,
        '"Name","Value","Last Update"\n'
        '"Good","1",""\n'
        '"","2",""\n'
        '"Not a number","x",""\n'
        '"Only a name"\n'
        '"Bad time","3","yesterday"\n',
      );
      expect([for (final c in got.counters) c.name], ['Good', 'Bad time']);
      expect(got.skipped, 3);
      expect(got.events.last.at, now, reason: 'a time that is not one');
    });

    test('a name that comes twice keeps its last number', () {
      final got = read(ImportSource.counter, 'A,1\nA,2\n');
      expect(got.counters.single.name, 'A');
      expect(total(got, got.counters.single), 2);
    });

    test('is not taken in from the other two apps\' files', () {
      expect(
        () => read(
          ImportSource.counter,
          'Push-ups,1700000000000,1700000060000,1700003600000\n'
          'Water,1700000000000\n',
        ),
        refused(ImportProblem.notThatApp),
      );
      expect(
        () => read(ImportSource.counter, '{"counters":[],"labels":[]}'),
        refused(ImportProblem.notThatApp),
      );
    });
  });

  group('Simple Counter', () {
    const file =
        '{"counters":['
        '{"id":1,"name":"Steps","value":12,"defaultValue":0,"labelId":2,'
        '"allowNegativeValues":false},'
        '{"id":2,"name":"Loose","value":3,"defaultValue":0,"labelId":null,'
        '"allowNegativeValues":true},'
        '{"id":3,"name":"Below","value":-4,"defaultValue":0,"labelId":2,'
        '"allowNegativeValues":true}],'
        '"labels":[{"id":2,"name":"Health","color":4292956737},'
        '{"id":3,"name":"Unused","color":4278190080}]}';

    test('labels that hold counters become groups, in their colour', () {
      final got = read(ImportSource.simpleCounter, file);
      expect([for (final g in got.groups) g.name], ['Health', 'Imported']);
      final health = got.groups.first;
      final inHealth = got.counters.where((c) => c.groupId == health.id);
      expect([for (final c in inHealth) c.name], ['Steps', 'Below']);
      expect(inHealth.every((c) => c.color == 0xFFE15241), isTrue);
      expect([for (final c in inHealth) c.position], [0, 1]);
      final loose = got.counters.singleWhere((c) => c.name == 'Loose');
      expect(loose.groupId, got.groups.last.id);
      expect(loose.position, 0);
    });

    test('each number comes across as one entry, dated now', () {
      final got = read(ImportSource.simpleCounter, file);
      expect(total(got, got.counters.first), 12);
      expect(total(got, got.counters.last), 0, reason: 'below zero');
      expect(got.events, hasLength(2));
      expect(got.events.every((e) => e.at == now), isTrue);
    });

    test('a counter with no name or no number is left out and counted', () {
      final got = read(
        ImportSource.simpleCounter,
        '{"counters":[{"id":1,"name":"Ok","value":1},'
        '{"id":2,"name":"","value":1},{"id":3,"name":"No number"}],'
        '"labels":[]}',
      );
      expect(got.counters.single.name, 'Ok');
      expect(got.skipped, 2);
    });

    test('one of Countersink\'s own backups is sent to Restore instead', () {
      final backup = encodeBackup(
        const BackupData(groups: [], counters: [], events: []),
        exportedAt: now,
      );
      expect(
        () => read(ImportSource.simpleCounter, backup),
        refused(ImportProblem.countersinkBackup),
      );
    });

    test('is not taken in from the other two apps\' files, or other JSON', () {
      expect(
        () => read(ImportSource.simpleCounter, 'Laps,1700000000000\n'),
        refused(ImportProblem.notThatApp),
      );
      expect(
        () => read(ImportSource.simpleCounter, '{"some":"thing"}'),
        refused(ImportProblem.notThatApp),
      );
      expect(
        () => read(ImportSource.simpleCounter, '[1, 2, 3]'),
        refused(ImportProblem.notThatApp),
      );
    });
  });

  test('a file with nothing in it says so, whichever app it is from', () {
    expect(
      () => read(ImportSource.betterCounter, '\n\n'),
      refused(ImportProblem.empty),
    );
    expect(() => read(ImportSource.counter, ''), refused(ImportProblem.empty));
    expect(
      () => read(ImportSource.counter, '"Name","Value","Last Update"\n'),
      refused(ImportProblem.empty),
    );
    expect(
      () => read(ImportSource.simpleCounter, '{"counters":[],"labels":[]}'),
      refused(ImportProblem.empty),
    );
  });

  test('ids are new each time, so the same file can be brought in twice', () {
    const file = 'Laps,1700000000000\n';
    final a = read(ImportSource.betterCounter, file);
    final b = read(ImportSource.betterCounter, file);
    expect(a.counters.single.id, isNot(b.counters.single.id));
    expect(a.groups.single.id, isNot(b.groups.single.id));
    expect(a.events.single.id, isNot(b.events.single.id));
  });
}
