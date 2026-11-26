import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:countersink/ui/language.dart';

/// One month of a counter's days as a grid: each day that has a count shows
/// its total, tinted, and filled solid if it met the goal.
///
/// Starts on the month [today] is in; the arrows step back through earlier
/// months and forward again, never past the current one.
class MonthCalendar extends StatefulWidget {
  const MonthCalendar({
    super.key,
    required this.totals,
    required this.today,
    this.met = const {},
    this.weekStart = DateTime.monday,
    this.onDay,
  });

  /// Each counting day's total, keyed by the day as a date with no time.
  final Map<DateTime, int> totals;
  final DateTime today;

  /// The days that count toward a goal that was met, which are filled
  /// solid: a day that reached its own goal, or any counted day of a week
  /// that reached the week's.
  final Set<DateTime> met;

  /// The day the grid's weeks begin on, as [DateTime.weekday] numbers them:
  /// 1 for Monday through 7 for Sunday.
  final int weekStart;

  /// Called with a day when it is tapped. Days still to come can't be.
  final ValueChanged<DateTime>? onDay;

  @override
  State<MonthCalendar> createState() => _MonthCalendarState();
}

class _MonthCalendarState extends State<MonthCalendar> {
  late DateTime _month = DateTime(widget.today.year, widget.today.month);

  bool get _isCurrent =>
      _month.year == widget.today.year && _month.month == widget.today.month;

  void _step(int months) =>
      setState(() => _month = DateTime(_month.year, _month.month + months));

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = context.l;
    final material = MaterialLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();

    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    // How many blank cells come before the first of the month.
    final lead = (_month.weekday - widget.weekStart) % 7;
    final cells = lead + daysInMonth;
    final rows = (cells / 7).ceil();

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  tooltip: l.previousMonth,
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => _step(-1),
                ),
                Expanded(
                  child: Text(
                    DateFormat.yMMMM(locale).format(_month),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  tooltip: l.nextMonth,
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _isCurrent ? null : () => _step(1),
                ),
              ],
            ),
            Row(
              children: [
                for (var i = 0; i < 7; i++)
                  Expanded(
                    child: Center(
                      child: ExcludeSemantics(
                        child: Text(
                          // That list begins on Sunday.
                          material.narrowWeekdays[(widget.weekStart + i) % 7],
                          style: theme.textTheme.labelSmall,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            for (var r = 0; r < rows; r++)
              Row(
                children: [
                  for (var c = 0; c < 7; c++)
                    Expanded(
                      child: _cell(
                        context,
                        r * 7 + c - lead + 1,
                        daysInMonth,
                        locale,
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _cell(
    BuildContext context,
    int dayOfMonth,
    int daysInMonth,
    String locale,
  ) {
    if (dayOfMonth < 1 || dayOfMonth > daysInMonth) {
      return const SizedBox(height: 52);
    }
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final day = DateTime(_month.year, _month.month, dayOfMonth);
    final total = widget.totals[day];
    final counted = total != null && total > 0;
    final met = counted && widget.met.contains(day);
    final isToday = day == widget.today;

    // Solid for a goal met, a tint for anything counted, nothing otherwise.
    final fill = met
        ? scheme.primary
        : counted
        ? scheme.primaryContainer
        : null;
    final ink = met
        ? scheme.onPrimary
        : counted
        ? scheme.onPrimaryContainer
        : scheme.onSurfaceVariant;

    final onDay = day.isAfter(widget.today) ? null : widget.onDay;
    // Its own node, so each day can be read out with its total.
    return Semantics(
      container: true,
      button: onDay != null,
      label: total == null
          ? DateFormat.MMMd(locale).format(day)
          : '${DateFormat.MMMd(locale).format(day)}: $total',
      excludeSemantics: true,
      onTap: onDay == null ? null : () => onDay(day),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onDay == null ? null : () => onDay(day),
        child: Container(
          height: 48,
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(12),
            border: isToday
                ? Border.all(color: scheme.onSurface, width: 1.5)
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$dayOfMonth',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: ink,
                  letterSpacing: 0,
                ),
              ),
              if (total != null)
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Text(
                      '$total',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: ink,
                        letterSpacing: 0,
                        height: 1.1,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
