import 'package:countersink/domain/dates.dart';
import 'package:countersink/domain/streaks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final today = DateTime(2026, 11, 22);

  /// Days by how many days ago they were, with their totals.
  List<DaySummary> days(Map<int, int> totalsByDaysAgo) => [
    for (final e in totalsByDaysAgo.entries)
      (
        day: DateTime(today.year, today.month, today.day - e.key),
        total: e.value,
        entries: 1,
      ),
  ];

  test('nothing counted is no streak', () {
    expect(streaksOf(const [], today: today), (current: 0, best: 0));
  });

  test('days in a row up to today', () {
    expect(streaksOf(days({0: 5, 1: 3, 2: 8}), today: today), (
      current: 3,
      best: 3,
    ));
  });

  test('today not counted yet does not break the streak', () {
    expect(streaksOf(days({1: 3, 2: 8, 3: 1}), today: today), (
      current: 3,
      best: 3,
    ));
  });

  test('a missed yesterday ends it', () {
    expect(streaksOf(days({2: 8, 3: 1, 4: 2}), today: today), (
      current: 0,
      best: 3,
    ));
    expect(streaksOf(days({0: 4, 2: 8, 3: 1, 4: 2}), today: today), (
      current: 1,
      best: 3,
    ));
  });

  test('the best run can be long ago', () {
    expect(
      streaksOf(days({0: 1, 1: 1, 10: 1, 11: 1, 12: 1, 13: 1}), today: today),
      (current: 2, best: 4),
    );
  });

  test('with a goal, only days that met it count', () {
    final d = days({0: 50, 1: 49, 2: 60, 3: 50});
    expect(streaksOf(d, today: today, goal: 50), (current: 1, best: 2));
    expect(streaksOf(d, today: today), (current: 4, best: 4));
  });

  test('a day that nets to nothing does not count', () {
    expect(streaksOf(days({0: 0, 1: 5}), today: today), (current: 1, best: 1));
  });

  test('runs cross month and year ends', () {
    final newYear = DateTime(2027, 1, 2);
    final d = [
      for (final day in [
        DateTime(2026, 12, 30),
        DateTime(2026, 12, 31),
        DateTime(2027, 1, 1),
        DateTime(2027, 1, 2),
      ])
        (day: day, total: 1, entries: 1),
    ];
    expect(streaksOf(d, today: newYear), (current: 4, best: 4));
  });

  group('weeks, for a goal that is for the week', () {
    // Today is Sunday the 22nd, the last day of a week that began on Monday
    // the 16th: days 0 to 6 ago are this week, 7 to 13 the one before.
    test('no week reached it', () {
      expect(weekStreaksOf(days({0: 5, 9: 60}), today: today, goal: 100), (
        current: 0,
        best: 0,
      ));
    });

    test('a week counts when its days add up to the goal', () {
      expect(
        weekStreaksOf(
          days({
            0: 30,
            3: 80,
            8: 100,
            15: 40,
            22: 120,
            30: 100,
            36: 60,
            40: 40,
          }),
          today: today,
          goal: 100,
        ),
        (current: 2, best: 3),
      );
    });

    test('this week not being there yet does not break the streak', () {
      expect(
        weekStreaksOf(days({0: 10, 8: 100, 15: 100}), today: today, goal: 100),
        (current: 2, best: 2),
      );
    });

    test('a missed week ends it', () {
      expect(weekStreaksOf(days({1: 20, 15: 100}), today: today, goal: 100), (
        current: 0,
        best: 1,
      ));
    });

    test('which days make a week follows the day it starts on', () {
      final d = days({0: 30, 3: 80});
      expect(weekStreaksOf(d, today: today, goal: 100), (current: 1, best: 1));
      // Starting on Sunday, today opens a new week and the 80 was last
      // week's.
      expect(
        weekStreaksOf(d, today: today, goal: 100, weekStart: DateTime.sunday),
        (current: 0, best: 0),
      );
    });
  });
}
