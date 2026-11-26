import 'package:countersink/domain/averages.dart';
import 'package:countersink/domain/dates.dart';
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

  test('nothing ever counted has no average', () {
    expect(rangeStats(const [], today: today, window: 7), isNull);
  });

  test('a full week: the total over seven days', () {
    final s = rangeStats(
      days({0: 10, 1: 20, 2: 30, 3: 10, 4: 20, 5: 30, 6: 20}),
      today: today,
      window: 7,
    )!;
    expect(s.perDay, [20, 30, 20, 10, 30, 20, 10], reason: 'oldest first');
    expect((s.days, s.total, s.average), (7, 140, 20.0));
  });

  test('a day with nothing counted is a day of zero', () {
    final s = rangeStats(days({0: 30, 2: 30, 9: 5}), today: today, window: 7)!;
    expect(s.perDay, [0, 0, 0, 0, 30, 0, 30]);
    expect((s.days, s.total), (7, 60));
    expect(s.average, closeTo(60 / 7, 1e-9));
  });

  test('the time before a counter was first used is not held against it', () {
    final s = rangeStats(days({0: 30, 1: 0, 2: 60}), today: today, window: 30)!;
    expect(s.perDay, hasLength(30));
    expect((s.days, s.total, s.average), (3, 90, 30.0));
  });

  test('a counter first used today is averaged over one day', () {
    final s = rangeStats(days({0: 12}), today: today, window: 7)!;
    expect((s.days, s.average), (1, 12.0));
  });

  test('older days fall outside the window but still mark when it began', () {
    final s = rangeStats(days({0: 7, 40: 100}), today: today, window: 7)!;
    expect((s.days, s.total, s.average), (7, 7, 1.0));
  });

  test('a day that nets to less than nothing pulls the average down', () {
    final s = rangeStats(days({0: 10, 1: -4}), today: today, window: 7)!;
    expect((s.days, s.total, s.average), (2, 6, 3.0));
  });

  test('days after today are ignored', () {
    final s = rangeStats(days({-1: 500, 0: 10}), today: today, window: 7)!;
    expect((s.days, s.total), (1, 10));
  });

  test('calendar days are counted on dates, across a clock change', () {
    // The US clocks go back on 1 November 2026: that day is 25 hours long.
    expect(
      calendarDaysBetween(DateTime(2026, 10, 31), DateTime(2026, 11, 2)),
      2,
    );
    expect(
      calendarDaysBetween(DateTime(2026, 12, 31), DateTime(2027, 1, 1)),
      1,
    );
    expect(calendarDaysBetween(today, today), 0);
  });

  test('the window crosses a month end', () {
    final s = rangeStats(
      [
        (day: DateTime(2026, 10, 30), total: 4, entries: 1),
        (day: DateTime(2026, 11, 2), total: 6, entries: 1),
      ],
      today: DateTime(2026, 11, 2),
      window: 7,
    )!;
    expect(s.perDay, [0, 0, 0, 4, 0, 0, 6]);
    expect((s.days, s.average), (4, 2.5));
  });
}
