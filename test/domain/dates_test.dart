import 'package:countersink/domain/dates.dart';
import 'package:countersink/models/tap_event.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TapEvent tap(DateTime at, [int delta = 1]) =>
      TapEvent(id: '$at', counterId: 'c', at: at, delta: delta);

  group('countingDay', () {
    test('is the calendar day when days start at midnight', () {
      expect(countingDay(DateTime(2026, 11, 22, 0, 0)), DateTime(2026, 11, 22));
      expect(
        countingDay(DateTime(2026, 11, 22, 23, 59)),
        DateTime(2026, 11, 22),
      );
    });

    test('before the day-start hour still belongs to the day before', () {
      expect(
        countingDay(DateTime(2026, 11, 22, 3, 59), dayStartHour: 4),
        DateTime(2026, 11, 21),
      );
      expect(
        countingDay(DateTime(2026, 11, 22, 4, 0), dayStartHour: 4),
        DateTime(2026, 11, 22),
      );
    });

    test('steps back over a month and a year', () {
      expect(
        countingDay(DateTime(2027, 1, 1, 1), dayStartHour: 4),
        DateTime(2026, 12, 31),
      );
    });

    test('reads a UTC instant in local time', () {
      final local = DateTime(2026, 11, 22, 12);
      expect(countingDay(local.toUtc()), DateTime(2026, 11, 22));
    });
  });

  test('dayBounds covers one day from its start hour, end not included', () {
    final b = dayBounds(DateTime(2026, 11, 22), dayStartHour: 4);
    expect(b.start, DateTime(2026, 11, 22, 4));
    expect(b.end, DateTime(2026, 11, 23, 4));
  });

  test('totalsByDay sums each day, minuses included', () {
    final totals = totalsByDay([
      tap(DateTime(2026, 11, 21, 9), 8),
      tap(DateTime(2026, 11, 21, 18), 6),
      tap(DateTime(2026, 11, 22, 0, 30), 5), // after midnight, same evening
      tap(DateTime(2026, 11, 22, 9), 7),
      tap(DateTime(2026, 11, 22, 9, 1), -1),
    ], dayStartHour: 4);
    expect(totals, {DateTime(2026, 11, 21): 19, DateTime(2026, 11, 22): 6});
  });

  test('summarizeDays lists days newest first, with totals and entries', () {
    final days = summarizeDays([
      tap(DateTime(2026, 11, 20, 9), 8),
      tap(DateTime(2026, 11, 20, 18), 6),
      tap(DateTime(2026, 11, 22, 9), 7),
      tap(DateTime(2026, 11, 21, 10), 10),
      tap(DateTime(2026, 11, 21, 10, 5), -10),
    ]);
    expect(days, [
      (day: DateTime(2026, 11, 22), total: 7, entries: 1),
      (day: DateTime(2026, 11, 21), total: 0, entries: 2),
      (day: DateTime(2026, 11, 20), total: 14, entries: 2),
    ]);
  });

  test('summarizeDays follows the day-start hour', () {
    final days = summarizeDays([
      tap(DateTime(2026, 11, 22, 23), 5),
      tap(DateTime(2026, 11, 23, 0, 30), 5),
    ], dayStartHour: 4);
    expect(days, [(day: DateTime(2026, 11, 22), total: 10, entries: 2)]);
  });

  test('summarizeDays of nothing is empty', () {
    expect(summarizeDays(const []), isEmpty);
  });

  test('a clock time lands on its counting day', () {
    final day = DateTime(2026, 11, 21);
    expect(
      instantOnDay(day, hour: 9, minute: 30),
      DateTime(2026, 11, 21, 9, 30),
    );
    // With days starting at four, half past midnight is still the 21st,
    // though the calendar says the 22nd.
    final late = instantOnDay(day, hour: 0, minute: 30, dayStartHour: 4);
    expect(late, DateTime(2026, 11, 22, 0, 30));
    expect(countingDay(late, dayStartHour: 4), day);
    expect(
      countingDay(
        instantOnDay(day, hour: 4, minute: 0, dayStartHour: 4),
        dayStartHour: 4,
      ),
      day,
    );
  });

  group('weekOf', () {
    test('is the Monday on or before, when weeks start on Monday', () {
      // 22 November 2026 is a Sunday.
      expect(weekOf(DateTime(2026, 11, 22)), DateTime(2026, 11, 16));
      expect(weekOf(DateTime(2026, 11, 16)), DateTime(2026, 11, 16));
      expect(weekOf(DateTime(2026, 11, 18)), DateTime(2026, 11, 16));
    });

    test('follows the day a week starts on', () {
      expect(
        weekOf(DateTime(2026, 11, 22), weekStart: DateTime.sunday),
        DateTime(2026, 11, 22),
      );
      expect(
        weekOf(DateTime(2026, 11, 21), weekStart: DateTime.sunday),
        DateTime(2026, 11, 15),
      );
      expect(
        weekOf(DateTime(2026, 11, 22), weekStart: DateTime.saturday),
        DateTime(2026, 11, 21),
      );
      expect(
        weekOf(DateTime(2026, 11, 20), weekStart: DateTime.saturday),
        DateTime(2026, 11, 14),
      );
    });

    test('steps back over a month and a year', () {
      // 2 January 2027 is a Saturday; its week began in December.
      expect(weekOf(DateTime(2027, 1, 2)), DateTime(2026, 12, 28));
    });
  });

  test('totalsByWeek adds each week up under its first day', () {
    final days = <DaySummary>[
      (day: DateTime(2026, 11, 22), total: 8, entries: 1),
      (day: DateTime(2026, 11, 16), total: 20, entries: 2),
      (day: DateTime(2026, 11, 15), total: 5, entries: 1),
    ];
    expect(totalsByWeek(days), {
      DateTime(2026, 11, 16): 28,
      DateTime(2026, 11, 9): 5,
    });
    expect(totalsByWeek(days, weekStart: DateTime.sunday), {
      DateTime(2026, 11, 22): 8,
      DateTime(2026, 11, 15): 25,
    });
  });
}
