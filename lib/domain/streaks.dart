import 'package:countersink/domain/dates.dart';

/// Runs of days in a row: the one still going, and the longest ever.
typedef Streaks = ({int current, int best});

/// The streaks in a counter's [days].
///
/// A day counts when its total reaches [goal], or, with no goal, when
/// anything at all was counted on it. The current streak runs back from
/// [today]; if today doesn't count yet it runs back from yesterday instead,
/// because a day isn't missed until it's over.
Streaks streaksOf(
  Iterable<DaySummary> days, {
  required DateTime today,
  int? goal,
}) {
  final counted = {
    for (final d in days)
      if (goal == null ? d.total > 0 : d.total >= goal) d.day,
  };
  if (counted.isEmpty) return (current: 0, best: 0);

  DateTime before(DateTime day) => DateTime(day.year, day.month, day.day - 1);

  var current = 0;
  for (
    var day = counted.contains(today) ? today : before(today);
    counted.contains(day);
    day = before(day)
  ) {
    current++;
  }

  // A run starts on a counted day whose day before wasn't counted.
  var best = 0;
  for (final start in counted) {
    if (counted.contains(before(start))) continue;
    var length = 0;
    for (
      var day = start;
      counted.contains(day);
      day = DateTime(day.year, day.month, day.day + 1)
    ) {
      length++;
    }
    if (length > best) best = length;
  }
  return (current: current, best: best);
}

/// The streaks in a counter's [days] for a goal that is for the week: runs
/// of weeks in a row whose totals reached [goal].
///
/// The current streak runs back from the week [today] is in; if that week
/// hasn't reached the goal yet it runs back from the week before instead,
/// because a week isn't missed until it's over.
Streaks weekStreaksOf(
  Iterable<DaySummary> days, {
  required DateTime today,
  required int goal,
  int weekStart = DateTime.monday,
}) {
  final met = {
    for (final w in totalsByWeek(days, weekStart: weekStart).entries)
      if (w.value >= goal) w.key,
  };
  if (met.isEmpty) return (current: 0, best: 0);

  // By calendar fields, so a week with a clock change in it is still seven
  // days back.
  DateTime step(DateTime week, int weeks) =>
      DateTime(week.year, week.month, week.day + 7 * weeks);

  final thisWeek = weekOf(today, weekStart: weekStart);
  var current = 0;
  for (
    var week = met.contains(thisWeek) ? thisWeek : step(thisWeek, -1);
    met.contains(week);
    week = step(week, -1)
  ) {
    current++;
  }

  var best = 0;
  for (final start in met) {
    if (met.contains(step(start, -1))) continue;
    var length = 0;
    for (var week = start; met.contains(week); week = step(week, 1)) {
      length++;
    }
    if (length > best) best = length;
  }
  return (current: current, best: best);
}
