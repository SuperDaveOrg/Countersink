import 'package:countersink/models/tap_event.dart';

/// Days, as Countersink counts them.
///
/// A tap is an *instant*; the day it counts toward is a *local calendar day*
/// that begins at [dayStartHour] instead of midnight, so a set of pull-ups at
/// half past midnight can still belong to the evening before. Keep the two
/// apart: store instants, work out days here.

/// The calendar day [at] counts toward, as a local date with no time.
DateTime countingDay(DateTime at, {int dayStartHour = 0}) {
  final local = at.toLocal();
  // By calendar fields, never by subtracting hours: that would slip on the
  // days the clocks change.
  final back = local.hour < dayStartHour ? 1 : 0;
  return DateTime(local.year, local.month, local.day - back);
}

/// The instants [day] covers: from [start] up to, not including, [end].
({DateTime start, DateTime end}) dayBounds(
  DateTime day, {
  int dayStartHour = 0,
}) => (
  start: DateTime(day.year, day.month, day.day, dayStartHour),
  end: DateTime(day.year, day.month, day.day + 1, dayStartHour),
);

/// The instant a clock time falls on within counting [day]. Hours before
/// the day-start hour come after midnight, so they sit on the next calendar
/// date while still belonging to [day].
DateTime instantOnDay(
  DateTime day, {
  required int hour,
  required int minute,
  int dayStartHour = 0,
}) => DateTime(
  day.year,
  day.month,
  day.day + (hour < dayStartHour ? 1 : 0),
  hour,
  minute,
);

/// The first day of the week [day] falls in, for a week that begins on
/// [weekStart]: a weekday as [DateTime.weekday] numbers them, 1 for Monday
/// through 7 for Sunday.
DateTime weekOf(DateTime day, {int weekStart = DateTime.monday}) =>
    DateTime(day.year, day.month, day.day - (day.weekday - weekStart) % 7);

/// Each week's total, by the week's first day, for the weeks that have any
/// counted days.
Map<DateTime, int> totalsByWeek(
  Iterable<DaySummary> days, {
  int weekStart = DateTime.monday,
}) {
  final totals = <DateTime, int>{};
  for (final d in days) {
    final week = weekOf(d.day, weekStart: weekStart);
    totals[week] = (totals[week] ?? 0) + d.total;
  }
  return totals;
}

/// Each counting day's total, for the days that have any events.
Map<DateTime, int> totalsByDay(
  Iterable<TapEvent> events, {
  int dayStartHour = 0,
}) {
  final totals = <DateTime, int>{};
  for (final e in events) {
    final day = countingDay(e.at, dayStartHour: dayStartHour);
    totals[day] = (totals[day] ?? 0) + e.delta;
  }
  return totals;
}

/// One counting day of a counter's history.
typedef DaySummary = ({DateTime day, int total, int entries});

/// A counter's history a day at a time, newest first: each day that has any
/// events, with its total and how many events made it up.
List<DaySummary> summariseDays(
  Iterable<TapEvent> events, {
  int dayStartHour = 0,
}) {
  final totals = <DateTime, int>{};
  final entries = <DateTime, int>{};
  for (final e in events) {
    final day = countingDay(e.at, dayStartHour: dayStartHour);
    totals[day] = (totals[day] ?? 0) + e.delta;
    entries[day] = (entries[day] ?? 0) + 1;
  }
  final days = totals.keys.toList()..sort((a, b) => b.compareTo(a));
  return [
    for (final d in days) (day: d, total: totals[d]!, entries: entries[d]!),
  ];
}
