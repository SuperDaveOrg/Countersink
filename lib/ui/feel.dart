import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:countersink/models/counter.dart';

import 'package:countersink/ui/counter_store.dart';
import 'package:countersink/ui/language.dart';

/// What a count of [amount] on [counter] is about to do, felt and said: the
/// buzz that marks it, and a message naming every counter whose goal it
/// reaches. That may be a calculated counter on another tab, which there
/// would otherwise be no way to notice. Call it just before the count is
/// made; [plainTick] gives an ordinary count its tick too, where the button
/// pressed hasn't already.
void markCount(
  BuildContext context,
  CounterStore store,
  Counter counter,
  int amount, {
  bool plainTick = false,
}) {
  final mark = store.markOf(counter, amount);
  if (mark == CountMark.none) {
    if (plainTick) HapticFeedback.lightImpact();
    return;
  }
  feelMark(mark);
  final reached = store.reachedBy(counter, amount);
  if (reached.isEmpty) return;
  final l = context.l;
  // Not clearing what is showing: it may be an Undo someone still wants.
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        [for (final c in reached) l.reachedGoal(c.name, c.goal!)].join('\n'),
      ),
    ),
  );
}

/// What a count feels like beyond its tick, so it can be told apart without
/// looking: one long buzz for reaching the goal, two short ones for passing
/// a multiple the counter buzzes on.
///
/// These go through the phone's own touch feedback, which needs no
/// permission and stays quiet if the phone has touch vibration turned off.
void feelMark(CountMark mark) {
  switch (mark) {
    case CountMark.goal:
      HapticFeedback.vibrate();
    case CountMark.multiple:
      HapticFeedback.heavyImpact();
      Future<void>.delayed(
        const Duration(milliseconds: 140),
        HapticFeedback.heavyImpact,
      );
    case CountMark.none:
      break;
  }
}
