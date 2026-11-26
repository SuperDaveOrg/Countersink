import 'package:countersink/domain/dates.dart';

/// A counter over the last so-many days.
///
/// [perDay] has one total for every day of the window, oldest first, with a
/// zero for a day on which nothing was counted. [days] is how many of those
/// days the average is taken over, and [average] is [total] divided by it.
typedef RangeStats = ({List<int> perDay, int days, int total, double average});

/// How a counter did over the [window] days ending [today], or null if
/// nothing has ever been counted.
///
/// The average is per calendar day, and a day with nothing counted is a day
/// of zero: skipping a day brings the average down, as it should. The one
/// exception is the time before the counter was first used, which isn't
/// counted against it: a counter started three days ago is averaged over
/// three days, not over the whole window.
RangeStats? rangeStats(
  Iterable<DaySummary> days, {
  required DateTime today,
  required int window,
}) {
  assert(window >= 1);
  final totals = <DateTime, int>{};
  DateTime? first;
  for (final d in days) {
    if (d.day.isAfter(today)) continue;
    totals[d.day] = d.total;
    if (first == null || d.day.isBefore(first)) first = d.day;
  }
  if (first == null) return null;

  final perDay = [
    for (var back = window - 1; back >= 0; back--)
      totals[DateTime(today.year, today.month, today.day - back)] ?? 0,
  ];
  final sinceFirst = calendarDaysBetween(first, today) + 1;
  final counted = sinceFirst < window ? sinceFirst : window;
  final total = perDay.fold(0, (sum, t) => sum + t);
  return (
    perDay: perDay,
    days: counted,
    total: total,
    average: total / counted,
  );
}

/// Whole calendar days from [from] to [to], whatever the clocks did in
/// between: measured on the dates, not on elapsed hours.
int calendarDaysBetween(DateTime from, DateTime to) => DateTime.utc(
  to.year,
  to.month,
  to.day,
).difference(DateTime.utc(from.year, from.month, from.day)).inDays;
