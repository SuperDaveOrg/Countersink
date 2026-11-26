import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:countersink/models/counter.dart';
import 'package:countersink/ui/counter_look.dart';
import 'package:countersink/ui/language.dart';
import 'package:countersink/ui/theme.dart';

/// One counter: minus on the left, the number in the middle under its name,
/// plus on the right. The buttons never move; people count without looking.
class CounterCard extends StatelessWidget {
  const CounterCard({
    super.key,
    required this.counter,
    required this.value,
    int? progress,
    required this.onTap,
    this.formula = '',
    this.towardNext,
    this.onHoldButton,
    this.onLongPress,
  }) : progress = progress ?? value;

  final Counter counter;
  final int value;

  /// How far along the goal is. The same as [value] except for a goal that
  /// is for the week, where it is the week so far.
  final int progress;

  /// For a calculated counter, what it is worked out from, in words, and,
  /// for one that counts rounds, how far its counter is into the next. Such
  /// a card has no plus or minus: there is nothing on it to count.
  final String formula;
  final int? towardNext;

  /// Called with 1 for plus and -1 for minus.
  final ValueChanged<int> onTap;

  /// Pressing and holding plus (1) or minus (-1): an amount typed in, for a
  /// whole set at once.
  final ValueChanged<int>? onHoldButton;

  /// Pressing and holding anywhere else on the card: its menu. Never a plain tap,
  /// which is too easy to do by accident in the middle of a count.
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final look = lookOf(counter);
    final ink = inkOnLook(look);
    final description = counter.description;
    final goal = counter.goal;
    final reached = goal != null && progress >= goal;
    final calculated = counter.calculated;
    final under = [
      if (formula.isNotEmpty) formula,
      if (towardNext != null) context.l.lineTowardNext(towardNext!),
      if (goal != null)
        counter.weeklyGoal != null
            ? context.l.goalThisWeek(progress, goal)
            : context.l.goalOf(goal),
      if (counter.daily) context.l.today,
      if (description != null && description.isNotEmpty) description,
    ].join(' · ');

    return Card(
      color: look.color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      // The blend and the pattern sit on the card itself, under the ripple.
      child: Ink(
        decoration: BoxDecoration(gradient: lookGradient(look)),
        child: CustomPaint(
          painter: PatternPainter(look.pattern, ink),
          child: InkWell(
            onLongPress: onLongPress,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              child: Row(
                children: [
                  if (!calculated)
                    _RoundButton(
                      icon: Icons.remove,
                      ink: ink,
                      label: context.l.decrement(counter.step, counter.name),
                      // A tally doesn't go below nothing.
                      onPressed: value > 0 ? () => onTap(-1) : null,
                      onLongPress: value > 0 && onHoldButton != null
                          ? () => onHoldButton!(-1)
                          : null,
                    ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        children: [
                          Text(
                            counter.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: ink,
                            ),
                          ),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              counter.formula == Formula.percent
                                  ? '$value%'
                                  : '$value',
                              style: CountersinkTheme.font(
                                CountersinkTheme.serif,
                                56,
                                560,
                                height: 1.15,
                                color: ink,
                              ),
                            ),
                          ),
                          if (under.isNotEmpty)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (reached) ...[
                                  Icon(
                                    Icons.check_circle,
                                    size: 15,
                                    color: ink,
                                    semanticLabel: context.l.goalReached,
                                  ),
                                  const SizedBox(width: 5),
                                ],
                                Flexible(
                                  child: Text(
                                    under,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: ink.withValues(alpha: 0.86),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          // How far along, for a counter with a goal.
                          if (goal != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: LinearProgressIndicator(
                                  value: (progress / goal).clamp(0.0, 1.0),
                                  minHeight: 6,
                                  color: ink.withValues(alpha: 0.9),
                                  backgroundColor: ink.withValues(alpha: 0.2),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (!calculated)
                    _RoundButton(
                      icon: Icons.add,
                      ink: ink,
                      label: context.l.increment(counter.step, counter.name),
                      onPressed: () => onTap(1),
                      onLongPress: onHoldButton == null
                          ? null
                          : () => onHoldButton!(1),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.ink,
    required this.label,
    required this.onPressed,
    this.onLongPress,
  });

  final IconData icon;
  final Color ink;
  final String label;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final onPressed = this.onPressed;
    // The label is for screen readers only. As a tooltip it would pop up on
    // the same press and hold that asks for an amount.
    return MergeSemantics(
      child: Semantics(
        label: label,
        child: IconButton(
          onLongPress: onLongPress,
          icon: Icon(icon, size: 32),
          style: IconButton.styleFrom(
            fixedSize: const Size.square(64),
            shape: const CircleBorder(),
            foregroundColor: ink,
            backgroundColor: ink.withValues(alpha: 0.16),
            disabledForegroundColor: ink.withValues(alpha: 0.38),
            disabledBackgroundColor: ink.withValues(alpha: 0.07),
          ),
          onPressed: onPressed == null
              ? null
              : () {
                  // A tick for every count, so it can be done without looking.
                  HapticFeedback.lightImpact();
                  onPressed();
                },
        ),
      ),
    );
  }
}
