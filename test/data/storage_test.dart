import 'dart:io';

import 'package:countersink/data/counter_repository.dart';
import 'package:countersink/data/database.dart';
import 'package:countersink/models/counter.dart';
import 'package:countersink/models/counter_group.dart';
import 'package:countersink/models/tap_event.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Runs the real schema against SQLite on the host.
void main() {
  sqfliteFfiInit();

  late Directory dir;
  late CountersinkDatabase db;
  late CounterRepository repo;

  const fitness = CounterGroup(id: 'fitness', name: 'Fitness');
  const pullUps = Counter(
    id: 'pullups',
    groupId: 'fitness',
    name: 'Pull-ups',
    color: 0xFFC4613F,
    daily: true,
  );
  final noon = DateTime(2026, 11, 22, 12);

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('countersink_test');
    db = CountersinkDatabase(
      path: '${dir.path}/countersink.db',
      factory: databaseFactoryFfi,
    );
    repo = CounterRepository(db: db);
    await repo.saveGroup(fitness);
    await repo.saveCounter(pullUps);
  });

  tearDown(() async {
    await db.close();
    await dir.delete(recursive: true);
  });

  test('groups and counters round-trip', () async {
    final s = await repo.snapshot(now: noon);
    expect(s.groups.single.name, 'Fitness');
    final c = s.counters.single;
    expect(
      (c.name, c.color, c.step, c.daily, c.description),
      ('Pull-ups', 0xFFC4613F, 1, true, null),
    );
    expect(s.valueOf(c), 0);
  });

  test('a count is the sum of its events', () async {
    await repo.record('pullups', 8, at: noon);
    await repo.record('pullups', 6, at: noon);
    await repo.record('pullups', -1, at: noon);
    final s = await repo.snapshot(now: noon);
    expect(s.totals['pullups'], 13);
  });

  test(
    'today counts only the current day; the total keeps every day',
    () async {
      await repo.record('pullups', 20, at: DateTime(2026, 11, 21, 18));
      await repo.record('pullups', 8, at: DateTime(2026, 11, 22, 9));
      final s = await repo.snapshot(now: noon);
      expect(s.today['pullups'], 8);
      expect(s.totals['pullups'], 28);
      expect(s.valueOf(pullUps), 8, reason: 'a daily counter shows today');
    },
  );

  test(
    'a late set belongs to the evening before when days start at 4',
    () async {
      await repo.record('pullups', 5, at: DateTime(2026, 11, 22, 0, 30));
      final sameNight = await repo.snapshot(
        now: DateTime(2026, 11, 22, 1),
        dayStartHour: 4,
      );
      expect(sameNight.today['pullups'], 5);
      final nextMorning = await repo.snapshot(
        now: DateTime(2026, 11, 22, 9),
        dayStartHour: 4,
      );
      expect(nextMorning.today['pullups'], isNull);
    },
  );

  test('undo takes one event back', () async {
    await repo.record('pullups', 8, at: noon);
    final slip = await repo.record('pullups', 1, at: noon);
    await repo.undo(slip.id);
    expect((await repo.snapshot(now: noon)).totals['pullups'], 8);
  });

  test('events come back oldest first, as they were recorded', () async {
    await repo.record('pullups', 6, at: DateTime(2026, 11, 22, 18));
    await repo.record('pullups', 8, at: DateTime(2026, 11, 22, 9));
    await repo.record(
      'pullups',
      -14,
      at: DateTime(2026, 11, 22, 19),
      kind: EventKind.reset,
    );
    final events = await repo.events('pullups');
    expect([for (final e in events) e.delta], [8, 6, -14]);
    expect(events.last.kind, EventKind.reset);
    expect(events.first.at, DateTime(2026, 11, 22, 9).toUtc());
  });

  test('editing a counter keeps its history', () async {
    await repo.record('pullups', 8, at: noon);
    await repo.saveCounter(
      const Counter(
        id: 'pullups',
        groupId: 'fitness',
        name: 'Chin-ups',
        color: 0xFF1A8783,
      ),
    );
    final s = await repo.snapshot(now: noon);
    expect(s.counters.single.name, 'Chin-ups');
    expect(s.totals['pullups'], 8);
  });

  test('deleting a counter deletes its events', () async {
    await repo.record('pullups', 8, at: noon);
    await repo.deleteCounter('pullups');
    final s = await repo.snapshot(now: noon);
    expect(s.counters, isEmpty);
    expect(s.totals, isEmpty);
  });

  test('a deleted counter can be put back with its history', () async {
    await repo.record('pullups', 8, at: noon);
    await repo.record('pullups', 6, at: noon);
    final events = await repo.events('pullups');
    await repo.deleteCounter('pullups');
    await repo.restoreCounter(pullUps, events);
    final s = await repo.snapshot(now: noon);
    expect(s.counters.single.name, 'Pull-ups');
    expect(s.totals['pullups'], 14);
    expect(
      (await repo.events('pullups')).map((e) => e.id),
      events.map((e) => e.id),
    );
  });

  test('deleting a group deletes its counters and their events', () async {
    await repo.record('pullups', 8, at: noon);
    await repo.deleteGroup('fitness');
    final s = await repo.snapshot(now: noon);
    expect(s.groups, isEmpty);
    expect(s.counters, isEmpty);
    expect(s.totals, isEmpty);
    expect(await repo.events('pullups'), isEmpty);
  });

  test('a deleted group can be put back with everything in it', () async {
    await repo.record('pullups', 8, at: noon);
    final events = await repo.events('pullups');
    await repo.deleteGroup('fitness');
    await repo.restoreGroup(fitness, [pullUps], {'pullups': events});
    final s = await repo.snapshot(now: noon);
    expect(s.groups.single.name, 'Fitness');
    expect(s.counters.single.name, 'Pull-ups');
    expect(s.totals['pullups'], 8);
  });

  test('groups come back in the order they were put in', () async {
    await repo.saveGroup(
      const CounterGroup(id: 'games', name: 'Games', position: 1),
    );
    await repo.saveGroup(
      const CounterGroup(id: 'shop', name: 'Workshop', position: 2),
    );
    await repo.reorderGroups(['shop', 'fitness', 'games']);
    final s = await repo.snapshot(now: noon);
    expect(
      [for (final g in s.groups) g.name],
      ['Workshop', 'Fitness', 'Games'],
    );
    expect(s.counters.single.groupId, 'fitness', reason: 'counters stay put');
  });

  test('replaceAll swaps everything for what it is given', () async {
    await repo.record('pullups', 8, at: noon);
    const games = CounterGroup(id: 'games', name: 'Games');
    const score = Counter(
      id: 'score',
      groupId: 'games',
      name: 'Score',
      color: 0xFF14344B,
    );
    final events = [
      TapEvent(id: 'a', counterId: 'score', at: noon.toUtc(), delta: 3),
      TapEvent(id: 'b', counterId: 'score', at: noon.toUtc(), delta: 4),
    ];
    await repo.replaceAll([games], [score], events);

    final s = await repo.snapshot(now: noon);
    expect(s.groups.single.name, 'Games');
    expect(s.counters.single.name, 'Score');
    expect(s.totals, {'score': 7});
    expect([for (final e in await repo.allEvents()) e.id], ['a', 'b']);
  });

  test('replaceAll with a broken record changes nothing', () async {
    await repo.record('pullups', 8, at: noon);
    const orphan = Counter(
      id: 'orphan',
      groupId: 'no-such-group',
      name: 'Orphan',
      color: 0xFF14344B,
    );
    await expectLater(repo.replaceAll([], [orphan], []), throwsA(anything));
    final s = await repo.snapshot(now: noon);
    expect(s.counters.single.name, 'Pull-ups');
    expect(s.totals['pullups'], 8);
  });

  test('a second colour and a pattern round-trip', () async {
    await repo.saveCounter(
      const Counter(
        id: 'laps',
        groupId: 'fitness',
        name: 'Laps',
        color: 0xFFC28A2C,
        color2: 0xFF2F5A45,
        pattern: CounterPattern.stripes,
        position: 1,
      ),
    );
    final laps = (await repo.snapshot(now: noon)).counters.last;
    expect(
      (laps.color, laps.color2, laps.pattern),
      (0xFFC28A2C, 0xFF2F5A45, CounterPattern.stripes),
    );
    final plain = (await repo.snapshot(now: noon)).counters.first;
    expect((plain.color2, plain.pattern), (null, CounterPattern.none));
  });

  test('a version 1 database upgrades with its counters and counts', () async {
    final path = '${dir.path}/old.db';
    final old = await databaseFactoryFfi.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
        onCreate: (db, _) => CountersinkDatabase.createVersion1(db),
      ),
    );
    await old.insert('counter_groups', {
      'id': 'g',
      'name': 'Old',
      'position': 0,
    });
    await old.insert('counters', {
      'id': 'c',
      'group_id': 'g',
      'name': 'From before',
      'color': 0xFF14344B,
      'position': 0,
    });
    await old.insert('events', {
      'id': 'e',
      'counter_id': 'c',
      'at': noon.toUtc().millisecondsSinceEpoch,
      'delta': 9,
    });
    await old.close();

    final upgraded = CountersinkDatabase(
      path: path,
      factory: databaseFactoryFfi,
    );
    final s = await CounterRepository(db: upgraded).snapshot(now: noon);
    await upgraded.close();
    final c = s.counters.single;
    expect(
      (c.name, c.color, c.color2, c.pattern, c.step),
      ('From before', 0xFF14344B, null, CounterPattern.none, 1),
    );
    expect(s.totals['c'], 9);
    expect(
      (c.goal, c.goalPeriod, c.buzzEvery, c.archived),
      (null, GoalPeriod.day, null, false),
    );
    expect((c.formula, c.roundSize, c.allTime), (null, null, false));
    expect(c.startFrom, isNull);
    expect(c.sources, isEmpty);
  });

  test('counters come back in the order they were put in', () async {
    for (final (i, id) in ['a', 'b', 'c'].indexed) {
      await repo.saveCounter(
        Counter(
          id: id,
          groupId: 'fitness',
          name: id.toUpperCase(),
          color: 0xFF14344B,
          position: i + 1,
        ),
      );
    }
    await repo.reorderCounters(['c', 'pullups', 'a', 'b']);
    final s = await repo.snapshot(now: noon);
    expect([for (final c in s.counters) c.id], ['c', 'pullups', 'a', 'b']);
  });

  test('a goal round-trips, and is null when there is none', () async {
    expect((await repo.snapshot(now: noon)).counters.single.goal, isNull);
    await repo.saveCounter(
      const Counter(
        id: 'pullups',
        groupId: 'fitness',
        name: 'Pull-ups',
        color: 0xFFC4613F,
        goal: 50,
        daily: true,
      ),
    );
    expect((await repo.snapshot(now: noon)).counters.single.goal, 50);
  });

  test(
    'an event can be given a new time and amount, keeping its kind',
    () async {
      final e = await repo.record('pullups', 8, at: noon, kind: EventKind.set);
      await repo.updateEvent(
        TapEvent(
          id: e.id,
          counterId: 'pullups',
          at: DateTime(2026, 11, 21, 18),
          delta: 6,
        ),
      );
      final after = (await repo.events('pullups')).single;
      expect(
        (after.delta, after.at, after.kind),
        (6, DateTime(2026, 11, 21, 18).toUtc(), EventKind.set),
      );
    },
  );

  test('a deleted event can be put back', () async {
    final e = await repo.record('pullups', 8, at: noon);
    await repo.undo(e.id);
    await repo.restoreEvent(e);
    expect((await repo.snapshot(now: noon)).totals['pullups'], 8);
  });

  test('archived round-trips, and is false until set', () async {
    expect((await repo.snapshot(now: noon)).counters.single.archived, isFalse);
    await repo.saveCounter(pullUps.moved(archived: true));
    final s = await repo.snapshot(now: noon);
    expect(s.counters.single.archived, isTrue);
    expect(s.inGroup('fitness'), isEmpty, reason: 'off its tab');
    expect(s.archived.single.name, 'Pull-ups');
  });

  test('the week runs from its first day up to today', () async {
    await repo.record('pullups', 99, at: DateTime(2026, 11, 15, 18));
    await repo.record('pullups', 20, at: DateTime(2026, 11, 16, 18));
    await repo.record('pullups', 8, at: DateTime(2026, 11, 22, 9));
    // Noon on Sunday the 22nd; the week began on Monday the 16th.
    final s = await repo.snapshot(now: noon);
    expect(s.week['pullups'], 28);
    expect(s.today['pullups'], 8);

    final fromSunday = await repo.snapshot(
      now: noon,
      weekStart: DateTime.sunday,
    );
    expect(fromSunday.week['pullups'], 8, reason: 'today opens the week');
  });

  test('the week begins when its first counting day does', () async {
    // Two in the morning on Monday still belongs to Sunday when days start
    // at four, and so to the week before.
    await repo.record('pullups', 5, at: DateTime(2026, 11, 16, 2));
    await repo.record('pullups', 7, at: DateTime(2026, 11, 16, 9));
    final s = await repo.snapshot(now: noon, dayStartHour: 4);
    expect(s.week['pullups'], 7);
  });

  test('a goal for the week is measured against the week', () async {
    const weekly = Counter(
      id: 'pullups',
      groupId: 'fitness',
      name: 'Pull-ups',
      color: 0xFFC4613F,
      goal: 100,
      goalPeriod: GoalPeriod.week,
      daily: true,
    );
    await repo.saveCounter(weekly);
    await repo.record('pullups', 20, at: DateTime(2026, 11, 16, 18));
    await repo.record('pullups', 8, at: DateTime(2026, 11, 22, 9));
    final s = await repo.snapshot(now: noon);
    expect(s.valueOf(weekly), 8, reason: 'the card still shows today');
    expect(s.progressOf(weekly), 28);
    expect(s.progressOf(pullUps), 8, reason: 'no weekly goal: the card');
  });

  test('a goal period and a buzz round-trip, with ordinary defaults', () async {
    final plain = (await repo.snapshot(now: noon)).counters.single;
    expect((plain.goalPeriod, plain.buzzEvery), (GoalPeriod.day, null));
    await repo.saveCounter(
      const Counter(
        id: 'pullups',
        groupId: 'fitness',
        name: 'Pull-ups',
        color: 0xFFC4613F,
        goal: 100,
        goalPeriod: GoalPeriod.week,
        buzzEvery: 10,
        daily: true,
      ),
    );
    final c = (await repo.snapshot(now: noon)).counters.single;
    expect(
      (c.goalPeriod, c.buzzEvery, c.weeklyGoal, c.dailyGoal),
      (GoalPeriod.week, 10, 100, null),
    );
  });

  test('a week only means something on a per-day counter', () {
    const total = Counter(
      id: 'c',
      groupId: 'g',
      name: 'Laps',
      color: 0,
      goal: 100,
      goalPeriod: GoalPeriod.week,
    );
    expect((total.weeklyGoal, total.dailyGoal), (null, null));
  });

  group('a calculated counter', () {
    const pushUps = Counter(
      id: 'pushups',
      groupId: 'fitness',
      name: 'Push-ups',
      color: 0xFF1A8783,
      position: 1,
    );

    Counter made(Formula formula, List<String> of, {int? roundSize}) => Counter(
      id: 'made',
      groupId: 'fitness',
      name: 'Made',
      color: 0xFF14344B,
      formula: formula,
      sources: of,
      roundSize: roundSize,
      position: 2,
    );

    setUp(() async {
      await repo.saveCounter(pushUps);
      // Pull-ups count per day: 20 yesterday and 8 today. Push-ups: 30.
      await repo.record('pullups', 20, at: DateTime(2026, 11, 21, 18));
      await repo.record('pullups', 8, at: DateTime(2026, 11, 22, 9));
      await repo.record('pushups', 30, at: DateTime(2026, 11, 20, 9));
    });

    test('its formula, counters and round size round-trip', () async {
      await repo.saveCounter(made(Formula.every, ['pullups'], roundSize: 108));
      final back = (await repo.snapshot(now: noon)).counters.last;
      expect(
        (back.formula, back.roundSize, back.calculated),
        (Formula.every, 108, true),
      );
      expect(back.sources, ['pullups']);
      final plain = (await repo.snapshot(now: noon)).counters.first;
      expect(
        (plain.formula, plain.roundSize, plain.calculated),
        (null, null, false),
      );
      expect(plain.sources, isEmpty);
    });

    test('is worked out from the numbers on the other cards', () async {
      Future<int> valueOf(Counter c) async {
        await repo.saveCounter(c);
        final s = await repo.snapshot(now: noon);
        return s.valueOf(s.counters.last);
      }

      // The card for pull-ups shows today's 8, so that is what counts.
      expect(await valueOf(made(Formula.sum, ['pullups', 'pushups'])), 38);
      expect(
        await valueOf(made(Formula.difference, ['pushups', 'pullups'])),
        22,
      );
      expect(await valueOf(made(Formula.percent, ['pushups', 'pullups'])), 79);
      expect(await valueOf(made(Formula.every, ['pushups'], roundSize: 8)), 3);
      final s = await repo.snapshot(now: noon);
      expect(s.towardNextOf(s.counters.last), 6);
    });

    test('keeping a running total, a per-day counter counts for every day '
        'it has counted', () async {
      Future<int> valueOf(Counter c) async {
        await repo.saveCounter(c);
        final s = await repo.snapshot(now: noon);
        expect(s.counters.last.allTime, isTrue, reason: 'kept');
        return s.valueOf(s.counters.last);
      }

      Counter running(Formula formula, List<String> of, {int? roundSize}) =>
          Counter(
            id: 'made',
            groupId: 'fitness',
            name: 'Made',
            color: 0xFF14344B,
            formula: formula,
            sources: of,
            roundSize: roundSize,
            allTime: true,
            position: 2,
          );

      // Pull-ups: 20 yesterday and 8 today, so 28 in all. Push-ups: 30.
      expect(await valueOf(running(Formula.sum, ['pullups'])), 28);
      expect(await valueOf(running(Formula.sum, ['pullups', 'pushups'])), 58);
      expect(
        await valueOf(running(Formula.difference, ['pushups', 'pullups'])),
        2,
      );
      expect(
        await valueOf(running(Formula.every, ['pullups'], roundSize: 8)),
        3,
      );
      var s = await repo.snapshot(now: noon);
      expect(s.towardNextOf(s.counters.last), 4);
      expect(s.valueOf(s.counters.first), 8, reason: 'its own card: today');

      // The next day pull-ups start from zero, and the total carries on.
      final nextDay = noon.add(const Duration(days: 1));
      await repo.saveCounter(running(Formula.sum, ['pullups']));
      s = await repo.snapshot(now: nextDay);
      expect(
        (s.valueOf(s.counters.first), s.valueOf(s.counters.last)),
        (0, 28),
      );
      await repo.record('pullups', 5, at: nextDay);
      s = await repo.snapshot(now: nextDay);
      expect(
        (s.valueOf(s.counters.first), s.valueOf(s.counters.last)),
        (5, 33),
      );
      expect(s.withAdded('pullups', 2).valueOf(s.counters.last), 35);
    });

    test(
      'a running total starts from the number it already stood at',
      () async {
        await repo.saveCounter(
          const Counter(
            id: 'made',
            groupId: 'fitness',
            name: 'Made',
            color: 0xFF14344B,
            formula: Formula.sum,
            sources: ['pullups'],
            allTime: true,
            startFrom: 100,
            position: 2,
          ),
        );
        final s = await repo.snapshot(now: noon);
        expect(s.counters.last.startFrom, 100, reason: 'kept');
        expect(s.counters.first.startFrom, isNull);
        // 100 from before, and the 28 pull-ups counted here.
        expect(s.valueOf(s.counters.last), 128);
        expect(await repo.events('made'), isEmpty, reason: 'nothing recorded');
      },
    );

    test('has no events of its own, whatever it shows', () async {
      await repo.saveCounter(made(Formula.sum, ['pullups', 'pushups']));
      final s = await repo.snapshot(now: noon);
      expect(s.totals['made'], isNull);
      expect(await repo.events('made'), isEmpty);
    });

    test(
      'a counter that is deleted drops out, and comes back if restored',
      () async {
        await repo.saveCounter(made(Formula.sum, ['pullups', 'pushups']));
        await repo.deleteCounter('pushups');
        var s = await repo.snapshot(now: noon);
        expect(s.valueOf(s.counters.last), 8);
        expect(s.brokenOf(s.counters.last), isFalse);
        expect(s.counters.last.sources, ['pullups', 'pushups'], reason: 'kept');

        await repo.restoreCounter(pushUps, [
          TapEvent(
            id: 'back',
            counterId: 'pushups',
            at: DateTime(2026, 11, 20, 9),
            delta: 30,
          ),
        ]);
        s = await repo.snapshot(now: noon);
        expect(s.valueOf(s.counters.last), 38);
      },
    );

    test('is broken when the counter it starts from is gone', () async {
      await repo.saveCounter(made(Formula.difference, ['pushups', 'pullups']));
      await repo.deleteCounter('pushups');
      final s = await repo.snapshot(now: noon);
      expect(s.brokenOf(s.counters.last), isTrue);
      expect(s.valueOf(s.counters.last), 0);
      expect(s.firstSourceOf(s.counters.last), isNull);
    });

    test('cannot be worked out from another calculated counter', () async {
      await repo.saveCounter(made(Formula.sum, ['pullups', 'pushups']));
      await repo.saveCounter(
        const Counter(
          id: 'twice',
          groupId: 'fitness',
          name: 'Twice',
          color: 0,
          formula: Formula.sum,
          sources: ['made', 'pullups'],
          position: 3,
        ),
      );
      final s = await repo.snapshot(now: noon);
      expect(s.valueOf(s.counters.last), 8, reason: 'only the ordinary one');
    });
  });
}
