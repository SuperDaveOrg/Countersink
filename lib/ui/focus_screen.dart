import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:countersink/models/counter.dart';
import 'package:countersink/services/app_info.dart';
import 'package:countersink/services/preferences.dart';
import 'package:countersink/ui/counter_look.dart';
import 'package:countersink/ui/counter_store.dart';
import 'package:countersink/ui/feel.dart';
import 'package:countersink/ui/language.dart';
import 'package:countersink/ui/number_dialog.dart';
import 'package:countersink/ui/theme.dart';

/// One counter filling the screen, for counting without looking: a tap
/// anywhere counts, a press and hold anywhere asks for an amount. Minus and
/// the way out are small and in the corners, where a thumb counting in the
/// middle won't find them by accident.
///
/// The screen is kept on for as long as this is open, whatever the setting
/// says, and goes back to the setting on the way out. The phone's own bars
/// stay: hiding them makes Android put up a panel of its own explaining how
/// to get them back, over the very thing being counted.
class FocusScreen extends StatefulWidget {
  const FocusScreen({super.key, required this.store, required this.counterId});

  final CounterStore store;
  final String counterId;

  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
  CounterStore get _store => widget.store;

  /// Which volume buttons count here, from Settings.
  VolumeKeys _keys = VolumeKeys.off;

  /// Touches ignored, so that only the volume buttons count: for a phone in
  /// a pocket or a hand that can't help brushing the screen.
  bool _locked = false;

  @override
  void initState() {
    super.initState();
    keepScreenOn(true);
    Preferences.volumeKeys().then((keys) {
      if (!mounted || keys == VolumeKeys.off) return;
      setState(() => _keys = keys);
      listenForVolumeKeys(keys, _volumeKey);
    });
  }

  @override
  void dispose() {
    Preferences.keepScreenOn().then(keepScreenOn);
    stopListeningForVolumeKeys();
    super.dispose();
  }

  /// A press of volume up (1) or volume down (-1).
  void _volumeKey(int direction) {
    if (!mounted) return;
    final counter = _store.counters.counters
        .where((c) => c.id == widget.counterId)
        .firstOrNull;
    if (counter == null) return;
    if (direction < 0 && _store.counters.valueOf(counter) <= 0) return;
    _count(counter, direction);
  }

  /// A tick for every count, a longer buzz for the one that reaches the
  /// goal, and a double one for passing a multiple the counter buzzes on.
  void _feel(Counter counter, int amount) =>
      markCount(context, _store, counter, amount, plainTick: true);

  void _count(Counter counter, int direction) {
    _feel(counter, direction * counter.step);
    _store.tap(counter, direction);
  }

  Future<void> _amount(Counter counter) async {
    final l = context.l;
    final amount = await showNumberDialog(
      context,
      title: l.addAmountTitle(counter.name),
      label: l.amount,
      action: l.add,
      min: 1,
    );
    if (amount == null || !mounted) return;
    _feel(counter, amount);
    await _store.addAmount(counter, amount);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _store,
      builder: (context, _) {
        final counter = _store.counters.counters
            .where((c) => c.id == widget.counterId)
            .firstOrNull;
        // Deleted or restored away while this was open.
        if (counter == null) return const Scaffold();

        final theme = Theme.of(context);
        final l = context.l;
        final look = lookOf(counter);
        final ink = inkOnLook(look);
        final value = _store.counters.valueOf(counter);
        final goal = counter.goal;
        final progress = _store.counters.progressOf(counter);
        final reached = goal != null && progress >= goal;
        final under = [
          if (goal != null)
            counter.weeklyGoal != null
                ? l.goalThisWeek(progress, goal)
                : l.goalOf(goal),
          if (counter.daily) l.today,
        ].join(' · ');

        // The clock and battery icons, light or dark to suit the colour
        // they now sit on.
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: ink == Colors.white
              ? SystemUiOverlayStyle.light
              : SystemUiOverlayStyle.dark,
          child: Scaffold(
            body: Material(
              color: look.color,
              child: Ink(
                decoration: BoxDecoration(gradient: lookGradient(look)),
                child: CustomPaint(
                  painter: PatternPainter(look.pattern, ink),
                  child: Semantics(
                    container: true,
                    button: true,
                    label: l.increment(counter.step, counter.name),
                    value: '$value',
                    child: InkWell(
                      onTap: _locked ? null : () => _count(counter, 1),
                      onLongPress: _locked ? null : () => _amount(counter),
                      child: SafeArea(
                        child: Stack(
                          children: [
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      counter.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: theme.textTheme.headlineSmall
                                          ?.copyWith(color: ink),
                                    ),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        '$value',
                                        style: CountersinkTheme.font(
                                          CountersinkTheme.serif,
                                          168,
                                          560,
                                          height: 1.1,
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
                                              size: 20,
                                              color: ink,
                                              semanticLabel: l.goalReached,
                                            ),
                                            const SizedBox(width: 6),
                                          ],
                                          // Free to wrap: in some
                                          // languages, or at a large text
                                          // size, it is wider than a phone.
                                          Flexible(
                                            child: Text(
                                              under,
                                              textAlign: TextAlign.center,
                                              style: theme.textTheme.titleMedium
                                                  ?.copyWith(
                                                    color: ink.withValues(
                                                      alpha: 0.86,
                                                    ),
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    if (goal != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 14),
                                        child: SizedBox(
                                          width: 220,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                            child: LinearProgressIndicator(
                                              value: (progress / goal).clamp(
                                                0.0,
                                                1.0,
                                              ),
                                              minHeight: 8,
                                              color: ink.withValues(alpha: 0.9),
                                              backgroundColor: ink.withValues(
                                                alpha: 0.2,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            // The way out.
                            Positioned(
                              top: 8,
                              left: 8,
                              child: IconButton(
                                tooltip: l.closeFullScreen,
                                icon: const Icon(Icons.close),
                                color: ink,
                                onPressed: _locked
                                    ? null
                                    : () => Navigator.pop(context),
                                disabledColor: ink.withValues(alpha: 0.38),
                              ),
                            ),
                            // The touch lock, only where there is another
                            // way to count. Locking takes a tap; unlocking
                            // takes a press and hold, which a pocket won't
                            // manage.
                            if (_keys != VolumeKeys.off)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {},
                                  child: IconButton(
                                    tooltip: _locked
                                        ? l.unlockTouch
                                        : l.lockTouch,
                                    icon: Icon(
                                      _locked ? Icons.lock : Icons.lock_open,
                                    ),
                                    color: ink,
                                    onPressed: _locked
                                        ? () {}
                                        : () => setState(() => _locked = true),
                                    onLongPress: _locked
                                        ? () => setState(() => _locked = false)
                                        : null,
                                  ),
                                ),
                              ),
                            // Minus, out of the way.
                            Positioned(
                              left: 20,
                              bottom: 20,
                              child: Semantics(
                                label: l.decrement(counter.step, counter.name),
                                excludeSemantics: true,
                                container: true,
                                button: true,
                                // Swallows a tap even when minus is off at zero: otherwise it
                                // would fall through to the screen behind and count one up.
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {},
                                  onLongPress: () {},
                                  child: IconButton(
                                    icon: const Icon(Icons.remove, size: 30),
                                    style: IconButton.styleFrom(
                                      fixedSize: const Size.square(64),
                                      shape: const CircleBorder(),
                                      foregroundColor: ink,
                                      backgroundColor: ink.withValues(
                                        alpha: 0.16,
                                      ),
                                      disabledForegroundColor: ink.withValues(
                                        alpha: 0.38,
                                      ),
                                      disabledBackgroundColor: ink.withValues(
                                        alpha: 0.07,
                                      ),
                                    ),
                                    onPressed: value > 0 && !_locked
                                        ? () => _count(counter, -1)
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              left: 100,
                              right: 100,
                              bottom: 40,
                              child: ExcludeSemantics(
                                child: Text(
                                  _locked
                                      ? l.touchLocked
                                      : _keys == VolumeKeys.off
                                      ? l.tapAnywhere
                                      : l.volumeCounts,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: ink.withValues(alpha: 0.7),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
