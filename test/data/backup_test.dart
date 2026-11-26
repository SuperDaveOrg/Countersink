import 'dart:convert';

import 'package:countersink/data/backup.dart';
import 'package:countersink/models/counter.dart';
import 'package:countersink/models/counter_group.dart';
import 'package:countersink/models/tap_event.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final sample = BackupData(
    dayStartHour: 4,
    groups: const [
      CounterGroup(id: 'g1', name: 'Fitness', position: 0),
      CounterGroup(id: 'g2', name: 'Empty "group"', position: 1),
    ],
    counters: const [
      Counter(
        id: 'c1',
        groupId: 'g1',
        name: 'Pull-ups',
        description: 'Strict, full hang',
        color: 0xFFC4613F,
        goal: 50,
        daily: true,
        position: 0,
      ),
      Counter(
        id: 'c2',
        groupId: 'g1',
        name: 'Laps',
        color: 0xFF1A8783,
        color2: 0xFF14344B,
        pattern: CounterPattern.dots,
        step: 5,
        position: 1,
      ),
    ],
    events: [
      TapEvent(
        id: 'e1',
        counterId: 'c1',
        at: DateTime.utc(2026, 11, 22, 14, 2, 11),
        delta: 8,
      ),
      TapEvent(
        id: 'e2',
        counterId: 'c1',
        at: DateTime.utc(2026, 11, 22, 18),
        delta: -8,
        kind: EventKind.reset,
      ),
      TapEvent(
        id: 'e3',
        counterId: 'c1',
        at: DateTime.utc(2026, 11, 23, 9),
        delta: 20,
        kind: EventKind.set,
      ),
    ],
  );

  String file(Map<String, Object?> json) => jsonEncode(json);

  /// A minimal valid file, with [counter] and [event] fields overridden.
  String fileWith({
    Map<String, Object?> counter = const {},
    Map<String, Object?> event = const {},
    Map<String, Object?> root = const {},
  }) => file({
    'countersinkBackup': 1,
    'groups': [
      {
        'id': 'g',
        'name': 'Fitness',
        'counters': [
          {
            'id': 'c',
            'name': 'Pull-ups',
            'color': '#C4613F',
            'events': [
              {'id': 'e', 'at': '2026-11-22T14:00:00Z', 'change': 1, ...event},
            ],
            ...counter,
          },
        ],
      },
    ],
    ...root,
  });

  Matcher refused(BackupProblem problem, [String? detailHas]) => throwsA(
    isA<BackupFormatException>()
        .having((e) => e.problem, 'problem', problem)
        .having(
          (e) => e.detail ?? '',
          'detail',
          detailHas == null ? anything : contains(detailHas),
        ),
  );

  test('a backup restores to exactly what was backed up', () {
    final text = encodeBackup(sample, exportedAt: DateTime.utc(2026, 11, 23));
    final back = decodeBackup(text);

    expect(back.dayStartHour, 4);
    expect(
      [for (final g in back.groups) (g.id, g.name, g.position)],
      [('g1', 'Fitness', 0), ('g2', 'Empty "group"', 1)],
    );
    expect(
      [
        for (final c in back.counters)
          (
            c.id,
            c.groupId,
            c.name,
            c.description,
            c.color,
            c.step,
            c.daily,
            c.position,
          ),
      ],
      [
        ('c1', 'g1', 'Pull-ups', 'Strict, full hang', 0xFFC4613F, 1, true, 0),
        ('c2', 'g1', 'Laps', null, 0xFF1A8783, 5, false, 1),
      ],
    );
    expect(
      [for (final e in back.events) (e.id, e.counterId, e.at, e.delta, e.kind)],
      [
        for (final e in sample.events)
          (e.id, e.counterId, e.at, e.delta, e.kind),
      ],
    );
  });

  test(
    'a second colour and a pattern come back, and are left out when plain',
    () {
      final text = encodeBackup(sample, exportedAt: DateTime.utc(2026, 11, 23));
      final back = decodeBackup(text);
      expect(
        [for (final c in back.counters) (c.color2, c.pattern)],
        [(null, CounterPattern.none), (0xFF14344B, CounterPattern.dots)],
      );
      expect('"color2"'.allMatches(text), hasLength(1));
      expect('"pattern"'.allMatches(text), hasLength(1));
    },
  );

  test('a goal comes back, and is left out when there is none', () {
    final text = encodeBackup(sample, exportedAt: DateTime.utc(2026, 11, 23));
    expect([for (final c in decodeBackup(text).counters) c.goal], [50, null]);
    expect('"goal"'.allMatches(text), hasLength(1));
    expect(
      () => decodeBackup(fileWith(counter: {'goal': 0})),
      refused(BackupProblem.damaged, '"goal"'),
    );
  });

  test('a goal for the week and a buzz come back, and are left out when '
      'there are none', () {
    final data = BackupData(
      groups: sample.groups,
      counters: [
        const Counter(
          id: 'c1',
          groupId: 'g1',
          name: 'Pull-ups',
          color: 0xFFC4613F,
          goal: 100,
          goalPeriod: GoalPeriod.week,
          buzzEvery: 10,
          daily: true,
        ),
        sample.counters[1],
      ],
      events: const [],
    );
    final text = encodeBackup(data, exportedAt: DateTime.utc(2026, 11, 23));
    expect(
      [
        for (final c in decodeBackup(text).counters)
          (c.goalPeriod, c.buzzEvery),
      ],
      [(GoalPeriod.week, 10), (GoalPeriod.day, null)],
    );
    expect('"goalPeriod": "week"'.allMatches(text), hasLength(1));
    expect('"buzzEvery": 10'.allMatches(text), hasLength(1));
    expect(
      () => decodeBackup(fileWith(counter: {'goalPeriod': 'month'})),
      refused(BackupProblem.damaged, 'month'),
    );
    expect(
      () => decodeBackup(fileWith(counter: {'buzzEvery': 0})),
      refused(BackupProblem.damaged, '"buzzEvery"'),
    );
  });

  test('the day a week starts on comes back, and may be left out', () {
    final data = BackupData(
      groups: const [],
      counters: const [],
      events: const [],
      weekStart: DateTime.sunday,
    );
    final text = encodeBackup(data, exportedAt: DateTime.utc(2026, 11, 23));
    expect(text, contains('"weekStartsOn": 7'));
    expect(decodeBackup(text).weekStart, DateTime.sunday);
    expect(decodeBackup(fileWith()).weekStart, isNull);
    expect(
      () => decodeBackup(fileWith(root: {'weekStartsOn': 8})),
      refused(BackupProblem.damaged, '"weekStartsOn"'),
    );
  });

  group('a calculated counter', () {
    BackupData withFormula(Counter calculated) => BackupData(
      groups: sample.groups,
      counters: [...sample.counters, calculated],
      events: const [],
    );

    test('comes back with its formula and the counters it is made of', () {
      final text = encodeBackup(
        withFormula(
          const Counter(
            id: 'c3',
            groupId: 'g1',
            name: 'Rounds',
            color: 0xFF14344B,
            formula: Formula.every,
            sources: ['c2'],
            roundSize: 108,
            position: 2,
          ),
        ),
        exportedAt: DateTime.utc(2026, 11, 23),
      );
      final back = decodeBackup(text).counters;
      expect((back.last.formula, back.last.roundSize), (Formula.every, 108));
      expect(back.last.sources, ['c2']);
      expect(back.first.formula, isNull);
      expect('"formula"'.allMatches(text), hasLength(1));
      expect('"of"'.allMatches(text), hasLength(1));
    });

    test('comes back keeping a running total, if it kept one', () {
      Counter total({required bool allTime}) => Counter(
        id: 'c3',
        groupId: 'g1',
        name: 'All',
        color: 0xFF14344B,
        formula: Formula.sum,
        sources: const ['c2'],
        allTime: allTime,
        startFrom: allTime ? 250 : null,
        position: 2,
      );
      final text = encodeBackup(
        withFormula(total(allTime: true)),
        exportedAt: DateTime.utc(2026, 11, 24),
      );
      expect(decodeBackup(text).counters.last.allTime, isTrue);
      expect(decodeBackup(text).counters.last.startFrom, 250);
      expect(decodeBackup(text).counters.first.allTime, isFalse);

      final without = encodeBackup(
        withFormula(total(allTime: false)),
        exportedAt: DateTime.utc(2026, 11, 24),
      );
      expect(without, isNot(contains('"allTime"')));
      expect(without, isNot(contains('"startFrom"')));
      expect(decodeBackup(without).counters.last.startFrom, isNull);
      expect(decodeBackup(without).counters.last.allTime, isFalse);
    });

    test('a counter that was deleted is left out of what it is made of', () {
      final text = encodeBackup(
        withFormula(
          const Counter(
            id: 'c3',
            groupId: 'g1',
            name: 'Both',
            color: 0xFF14344B,
            formula: Formula.sum,
            sources: ['c1', 'long-gone', 'c2'],
            position: 2,
          ),
        ),
        exportedAt: DateTime.utc(2026, 11, 23),
      );
      expect(text, isNot(contains('long-gone')));
      expect(decodeBackup(text).counters.last.sources, ['c1', 'c2']);
    });

    test('is refused if it names a counter that is not in the file', () {
      expect(
        () => decodeBackup(
          fileWith(
            counter: {
              'formula': 'sum',
              'of': ['nobody'],
            },
          ),
        ),
        refused(BackupProblem.damaged, 'nobody'),
      );
      expect(
        () => decodeBackup(
          fileWith(
            counter: {
              'formula': 'sum',
              'of': ['c'],
            },
          ),
        ),
        refused(BackupProblem.damaged, '"of"'),
        reason: 'itself',
      );
    });

    test('is refused with a formula it does not know, or a list of the '
        'wrong things', () {
      expect(
        () => decodeBackup(fileWith(counter: {'formula': 'average'})),
        refused(BackupProblem.damaged, 'average'),
      );
      expect(
        () => decodeBackup(
          fileWith(
            counter: {
              'formula': 'sum',
              'of': [1, 2],
            },
          ),
        ),
        refused(BackupProblem.damaged, '"of"'),
      );
      expect(
        () => decodeBackup(
          fileWith(counter: {'formula': 'every', 'roundSize': 0}),
        ),
        refused(BackupProblem.damaged, '"roundSize"'),
      );
    });
  });

  test('archived comes back, and is left out when it is not', () {
    final data = BackupData(
      groups: sample.groups,
      counters: [
        sample.counters.first.moved(archived: true),
        sample.counters.last,
      ],
      events: sample.events,
    );
    final text = encodeBackup(data, exportedAt: DateTime.utc(2026, 11, 23));
    expect(
      [for (final c in decodeBackup(text).counters) c.archived],
      [true, false],
    );
    expect('"archived"'.allMatches(text), hasLength(1));
  });

  test('the file is plain JSON, marked and dated, one line per event', () {
    final text = encodeBackup(sample, exportedAt: DateTime.utc(2026, 11, 23));
    final json = jsonDecode(text) as Map<String, Object?>;
    expect(json['countersinkBackup'], backupFormatVersion);
    expect(json['exportedAt'], '2026-11-23T00:00:00.000Z');
    expect(
      text.split('\n').where((line) => line.contains('"change"')),
      hasLength(3),
    );
    expect(text, contains('"color": "#C4613F"'));
  });

  test('nothing at all still makes a file that restores', () {
    const empty = BackupData(groups: [], counters: [], events: []);
    final back = decodeBackup(
      encodeBackup(empty, exportedAt: DateTime.utc(2026)),
    );
    expect(back.groups, isEmpty);
    expect(back.dayStartHour, isNull);
  });

  test('the file name carries the day', () {
    expect(
      backupFileName(DateTime(2026, 3, 7)),
      'countersink-backup-2026-03-07.json',
    );
  });

  test('what a file may leave out gets its ordinary value', () {
    final back = decodeBackup(fileWith());
    final c = back.counters.single;
    expect((c.step, c.daily, c.description), (1, false, null));
    expect((c.color2, c.pattern), (null, CounterPattern.none));
    expect(back.events.single.kind, EventKind.tap);
    expect(back.dayStartHour, isNull);
  });

  test('a time is read as the same instant whatever its offset', () {
    final back = decodeBackup(
      fileWith(event: {'at': '2026-11-22T09:00:00-05:00'}),
    );
    expect(back.events.single.at, DateTime.utc(2026, 11, 22, 14));
  });

  group('refused whole', () {
    test('something that is not JSON', () {
      expect(
        () => decodeBackup('pull-ups: 37'),
        refused(BackupProblem.notCountersink),
      );
    });

    test('JSON from somewhere else', () {
      expect(
        () => decodeBackup(file({'nexpillBackup': 7, 'patients': []})),
        refused(BackupProblem.notCountersink),
      );
      expect(
        () => decodeBackup('[1, 2]'),
        refused(BackupProblem.notCountersink),
      );
    });

    test('a backup from a newer version', () {
      expect(
        () => decodeBackup(fileWith(root: {'countersinkBackup': 2})),
        refused(BackupProblem.tooNew),
      );
    });

    test('a counter with no name, saying where', () {
      expect(
        () => decodeBackup(fileWith(counter: {'name': null})),
        refused(BackupProblem.damaged, '"name"'),
      );
    });

    test('an id used twice', () {
      expect(
        () => decodeBackup(fileWith(event: {'id': 'c'})),
        refused(BackupProblem.damaged, '"c" is used twice'),
      );
    });

    test('a time that does not say its offset', () {
      expect(
        () => decodeBackup(fileWith(event: {'at': '2026-11-22T14:00:00'})),
        refused(BackupProblem.damaged, '"Pull-ups"'),
      );
    });

    test('a colour that is not one', () {
      expect(
        () => decodeBackup(fileWith(counter: {'color': 'clay'})),
        refused(BackupProblem.damaged, '"color"'),
      );
    });

    test('a pattern it does not know, a second colour that is not one', () {
      expect(
        () => decodeBackup(fileWith(counter: {'pattern': 'plaid'})),
        refused(BackupProblem.damaged, 'plaid'),
      );
      expect(
        () => decodeBackup(fileWith(counter: {'color2': '#12'})),
        refused(BackupProblem.damaged, '"color2"'),
      );
    });

    test('a kind of change it does not know', () {
      expect(
        () => decodeBackup(fileWith(event: {'kind': 'double'})),
        refused(BackupProblem.damaged, 'double'),
      );
    });

    test('a step of nothing, a change that is not a whole number', () {
      expect(
        () => decodeBackup(fileWith(counter: {'step': 0})),
        refused(BackupProblem.damaged, '"step"'),
      );
      expect(
        () => decodeBackup(fileWith(event: {'change': 1.5})),
        refused(BackupProblem.damaged, '"change"'),
      );
    });

    test('a day-start hour outside the morning', () {
      expect(
        () => decodeBackup(fileWith(root: {'dayStartHour': 12})),
        refused(BackupProblem.damaged, '"dayStartHour"'),
      );
    });
  });
}
