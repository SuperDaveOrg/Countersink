import 'package:flutter/material.dart';

import 'package:countersink/domain/dates.dart';
import 'package:countersink/domain/streaks.dart';
import 'package:countersink/models/counter.dart';
import 'package:countersink/models/tap_event.dart';
import 'package:countersink/ui/counter_store.dart';
import 'package:countersink/ui/day_screen.dart';
import 'package:countersink/ui/language.dart';
import 'package:countersink/ui/layout.dart';
import 'package:countersink/ui/month_calendar.dart';
import 'package:countersink/ui/range_chart.dart';
import 'package:countersink/ui/theme.dart';

/// One counter's past, a day at a time, newest first.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key, required this.store, required this.counter});

  final CounterStore store;
  final Counter counter;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<TapEvent>? _events;

  CounterStore get _store => widget.store;

  @override
  void initState() {
    super.initState();
    // The day-start hour or the counts themselves may change underneath.
    _store.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    _store.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    final events = await _store.repository.events(widget.counter.id);
    if (mounted) setState(() => _events = events);
  }

  /// One day's entries, to look at, correct or add to.
  void _openDay(DateTime day) => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) =>
          DayScreen(store: _store, counter: widget.counter, day: day),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = context.l;
    final counter = widget.counter;
    final events = _events;
    final hour = _store.dayStartHour;
    final days = events == null
        ? const <DaySummary>[]
        : summariseDays(events, dayStartHour: hour);
    final today = countingDay(_store.now, dayStartHour: hour);
    final allTime = _store.counters.totals[counter.id] ?? 0;
    // A goal only means something per day or per week on a per-day
    // counter; a week's goal makes the streak one of weeks.
    final dailyGoal = counter.dailyGoal;
    final weeklyGoal = counter.weeklyGoal;
    final weekStart = _store.weekStart;
    final streaks = weeklyGoal != null
        ? weekStreaksOf(
            days,
            today: today,
            goal: weeklyGoal,
            weekStart: weekStart,
          )
        : streaksOf(days, today: today, goal: dailyGoal);
    // The days to mark as having met the goal: each day that reached its
    // own, or every counted day of a week that reached the week's.
    final weeks = weeklyGoal == null
        ? const <DateTime, int>{}
        : totalsByWeek(days, weekStart: weekStart);
    final met = {
      for (final d in days)
        if (d.total > 0 &&
            (weeklyGoal != null
                ? weeks[weekOf(d.day, weekStart: weekStart)]! >= weeklyGoal
                : dailyGoal != null && d.total >= dailyGoal))
          d.day,
    };

    return Scaffold(
      appBar: AppBar(title: Text(counter.name)),
      body: events == null
          ? const SizedBox.shrink()
          : ListView(
              padding: readablePadding(
                context,
                base: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              ),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _Stat(value: allTime, label: l.allTime),
                        ),
                        Expanded(
                          child: _Stat(
                            value: streaks.current,
                            label: weeklyGoal != null
                                ? l.weekStreak
                                : l.dayStreak,
                          ),
                        ),
                        Expanded(
                          child: _Stat(
                            value: streaks.best,
                            label: l.bestStreak,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                RangeChart(days: days, today: today, goal: dailyGoal),
                if (days.isNotEmpty) const SizedBox(height: 16),
                MonthCalendar(
                  totals: {for (final d in days) d.day: d.total},
                  today: today,
                  met: met,
                  weekStart: weekStart,
                  onDay: _openDay,
                ),
                const SizedBox(height: 16),
                if (days.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 48),
                    child: Center(
                      child: Text(
                        l.historyEmpty,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  )
                else
                  Card(
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        for (final (i, d) in days.indexed) ...[
                          if (i > 0) const Divider(indent: 16, endIndent: 16),
                          ListTile(
                            title: Text(dayName(context, d.day, today)),
                            onTap: () => _openDay(d.day),
                            subtitle: Text(l.entriesCount(d.entries)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // A day that met its goal, or was part
                                // of a week that did.
                                if (met.contains(d.day)) ...[
                                  Icon(
                                    Icons.check_circle,
                                    size: 18,
                                    color: theme.colorScheme.onPrimaryContainer,
                                    semanticLabel: l.goalReached,
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Text(
                                  '${d.total}',
                                  style: CountersinkTheme.font(
                                    CountersinkTheme.serif,
                                    24,
                                    560,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}

/// One number with what it is underneath.
class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Its own node, so a screen reader stops on each figure in turn.
    return Semantics(
      container: true,
      label: '$label: $value',
      excludeSemantics: true,
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text('$value', style: theme.textTheme.headlineMedium),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelMedium,
          ),
        ],
      ),
    );
  }
}
