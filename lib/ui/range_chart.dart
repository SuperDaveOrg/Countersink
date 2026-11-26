import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:countersink/domain/averages.dart';
import 'package:countersink/domain/dates.dart';
import 'package:countersink/ui/language.dart';

/// A counter over the last 7, 30 or 90 days: the total, the average per
/// day, and a bar for each day. A goal is drawn as a line across, and the
/// days that reached it are filled solid.
class RangeChart extends StatefulWidget {
  const RangeChart({
    super.key,
    required this.days,
    required this.today,
    this.goal,
  });

  final List<DaySummary> days;
  final DateTime today;

  /// A daily goal, if the counter has one.
  final int? goal;

  static const windows = [7, 30, 90];

  @override
  State<RangeChart> createState() => _RangeChartState();
}

class _RangeChartState extends State<RangeChart> {
  int _window = 30;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final l = context.l;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final stats = rangeStats(widget.days, today: widget.today, window: _window);
    if (stats == null) return const SizedBox.shrink();

    final average = NumberFormat.decimalPatternDigits(
      locale: locale,
      decimalDigits: 1,
    ).format(stats.average);
    final total = NumberFormat.decimalPattern(locale).format(stats.total);
    final start = DateTime(
      widget.today.year,
      widget.today.month,
      widget.today.day - (_window - 1),
    );
    final dates = DateFormat.MMMd(locale);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<int>(
              showSelectedIcon: false,
              segments: [
                for (final w in RangeChart.windows)
                  ButtonSegment(value: w, label: Text(l.daysCount(w))),
              ],
              selected: {_window},
              onSelectionChanged: (s) => setState(() => _window = s.single),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _Figure(value: average, label: l.averagePerDay),
                ),
                Expanded(
                  child: _Figure(value: total, label: l.totalInRange),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // The bars are a picture of the two figures above; a screen
            // reader gets the figures.
            ExcludeSemantics(
              child: Column(
                children: [
                  SizedBox(
                    height: 120,
                    child: CustomPaint(
                      size: Size.infinite,
                      painter: _BarsPainter(
                        perDay: stats.perDay,
                        goal: widget.goal,
                        met: scheme.primary,
                        counted: scheme.primary.withValues(alpha: 0.45),
                        line: scheme.onSurfaceVariant,
                        base: scheme.outlineVariant,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        dates.format(start),
                        style: theme.textTheme.labelSmall,
                      ),
                      Text(l.dayToday, style: theme.textTheme.labelSmall),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One figure with what it is underneath.
class _Figure extends StatelessWidget {
  const _Figure({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Semantics(
      container: true,
      label: '$label: $value',
      excludeSemantics: true,
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value, style: theme.textTheme.headlineSmall),
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

/// A bar a day, oldest on the left, scaled to the tallest day or the goal,
/// whichever is higher.
class _BarsPainter extends CustomPainter {
  const _BarsPainter({
    required this.perDay,
    required this.goal,
    required this.met,
    required this.counted,
    required this.line,
    required this.base,
  });

  final List<int> perDay;
  final int? goal;

  /// Bars for days that reached the goal, or every bar when there's none.
  final Color met;

  /// Bars for days that fell short of the goal.
  final Color counted;
  final Color line;
  final Color base;

  @override
  void paint(Canvas canvas, Size size) {
    final goal = this.goal;
    final top = math.max(perDay.fold(0, math.max), goal ?? 0);
    final baseline = size.height - 1;
    canvas.drawLine(
      Offset(0, baseline),
      Offset(size.width, baseline),
      Paint()
        ..color = base
        ..strokeWidth = 1,
    );
    if (top <= 0) return;

    final slot = size.width / perDay.length;
    final gap = math.min(4.0, slot * 0.25);
    final width = slot - gap;
    final radius = Radius.circular(math.min(4, width / 2));
    for (final (i, total) in perDay.indexed) {
      if (total <= 0) continue;
      // A day with anything counted gets a bar you can see.
      final height = math.max(3.0, baseline * total / top);
      canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(i * slot + gap / 2, baseline - height, width, height),
          topLeft: radius,
          topRight: radius,
        ),
        Paint()..color = goal == null || total >= goal ? met : counted,
      );
    }

    if (goal != null) {
      // The goal, dashed across the bars.
      final y = baseline - baseline * goal / top;
      final paint = Paint()
        ..color = line
        ..strokeWidth = 1.5;
      for (var x = 0.0; x < size.width; x += 9) {
        canvas.drawLine(
          Offset(x, y),
          Offset(math.min(x + 5, size.width), y),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_BarsPainter old) =>
      old.perDay != perDay ||
      old.goal != goal ||
      old.met != met ||
      old.counted != counted ||
      old.line != line ||
      old.base != base;
}
