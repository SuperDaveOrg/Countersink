import 'package:flutter/material.dart';

import 'package:countersink/models/counter.dart';
import 'package:countersink/models/counter_group.dart';
import 'package:countersink/services/app_info.dart';
import 'package:countersink/ui/arrange_screen.dart';
import 'package:countersink/ui/counter_card.dart';
import 'package:countersink/ui/counter_editor.dart';
import 'package:countersink/ui/counter_store.dart';
import 'package:countersink/ui/feel.dart';
import 'package:countersink/ui/focus_screen.dart';
import 'package:countersink/ui/formula_text.dart';
import 'package:countersink/ui/history_screen.dart';
import 'package:countersink/ui/language.dart';
import 'package:countersink/ui/number_dialog.dart';

/// A counter's card, wired up: its buttons count, a press and hold on a
/// button asks for an amount, and a press and hold anywhere else opens its
/// menu. The same wherever a counter is shown.
class LiveCounterCard extends StatelessWidget {
  const LiveCounterCard({
    super.key,
    required this.store,
    required this.counter,
  });

  final CounterStore store;
  final Counter counter;

  @override
  Widget build(BuildContext context) {
    final actions = CounterActions(store);
    return CounterCard(
      counter: counter,
      value: store.counters.valueOf(counter),
      progress: store.counters.progressOf(counter),
      formula: formulaLine(context.l, store.counters, counter),
      towardNext:
          counter.formula == Formula.every && !store.counters.brokenOf(counter)
          ? store.counters.towardNextOf(counter)
          : null,
      onTap: (direction) {
        actions.mark(context, counter, direction * counter.step);
        store.tap(counter, direction);
      },
      onHoldButton: (direction) => actions.amount(context, counter, direction),
      onLongPress: () => actions.menu(context, counter),
    );
  }
}

/// Everything that can be done to a counter besides a plain count, and the
/// dialogs and messages that go with it.
class CounterActions {
  const CounterActions(this.store);

  final CounterStore store;

  /// What can be done to a counter besides counting.
  Future<void> menu(BuildContext context, Counter counter) async {
    // Only offered where the home screen can be asked to add a widget.
    final canPin = homeScreenTakesWidgets;
    // A calculated counter has no count of its own: nothing to add to, set,
    // reset or look back over, and nothing a widget could count on.
    final byHand = !counter.calculated;
    final theme = Theme.of(context);
    final choice = await showModalBottomSheet<String>(
      context: context,
      // As tall as it needs, and scrolling on a short or sideways screen.
      isScrollControlled: true,
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    counter.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleLarge,
                  ),
                ),
              ),
              if (byHand) ...[
                ListTile(
                  leading: const Icon(Icons.fullscreen),
                  title: Text(context.l.fullScreen),
                  onTap: () => Navigator.pop(context, 'full'),
                ),
                ListTile(
                  leading: const Icon(Icons.exposure_plus_1),
                  title: Text(context.l.addAmount),
                  onTap: () => Navigator.pop(context, 'amount'),
                ),
                ListTile(
                  leading: const Icon(Icons.pin_outlined),
                  title: Text(context.l.setValue),
                  onTap: () => Navigator.pop(context, 'set'),
                ),
                ListTile(
                  leading: const Icon(Icons.restart_alt),
                  title: Text(context.l.resetToZero),
                  enabled: store.counters.valueOf(counter) != 0,
                  onTap: () => Navigator.pop(context, 'reset'),
                ),
                ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(context.l.history),
                  onTap: () => Navigator.pop(context, 'history'),
                ),
                if (canPin)
                  ListTile(
                    leading: const Icon(Icons.add_to_home_screen),
                    title: Text(context.l.addToHomeScreen),
                    onTap: () => Navigator.pop(context, 'pin'),
                  ),
                const Divider(indent: 16, endIndent: 16),
              ],
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: Text(context.l.edit),
                onTap: () => Navigator.pop(context, 'edit'),
              ),
              if (store.counters.inGroup(counter.groupId).length > 1)
                ListTile(
                  leading: const Icon(Icons.swap_vert),
                  title: Text(context.l.reorderCounters),
                  onTap: () => Navigator.pop(context, 'reorder'),
                ),
              if (store.counters.groups.length > 1)
                ListTile(
                  leading: const Icon(Icons.drive_file_move_outlined),
                  title: Text(context.l.moveToGroup),
                  onTap: () => Navigator.pop(context, 'move'),
                ),
              if (!counter.archived)
                ListTile(
                  leading: const Icon(Icons.archive_outlined),
                  title: Text(context.l.archive),
                  onTap: () => Navigator.pop(context, 'archive'),
                ),
              ListTile(
                leading: Icon(
                  Icons.delete_outline,
                  color: theme.colorScheme.error,
                ),
                title: Text(
                  context.l.delete,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
                onTap: () => Navigator.pop(context, 'delete'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
    if (!context.mounted) return;
    switch (choice) {
      case 'full':
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FocusScreen(store: store, counterId: counter.id),
          ),
        );
      case 'amount':
        await amount(context, counter, 1);
      case 'set':
        await setValue(context, counter);
      case 'reset':
        await reset(context, counter);
      case 'history':
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HistoryScreen(store: store, counter: counter),
          ),
        );
      case 'edit':
        await edit(context, counter);
      case 'reorder':
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ArrangeScreen(
              store: store,
              group: store.counters.groups.firstWhere(
                (g) => g.id == counter.groupId,
              ),
            ),
          ),
        );
      case 'move':
        await moveToGroup(context, counter);
      case 'pin':
        // The home screen asks for itself; nothing more to say here.
        await pinWidget(counter.id);
      case 'archive':
        await archive(context, counter);
      case 'delete':
        await delete(context, counter);
    }
  }

  /// More than the tick of a count, when this change is the one that
  /// reaches the counter's goal or passes a multiple it buzzes on: felt
  /// without looking.
  void mark(BuildContext context, Counter counter, int amount) =>
      markCount(context, store, counter, amount);

  /// A whole set at once: asks how many to add (or, from minus, take away).
  Future<void> amount(
    BuildContext context,
    Counter counter,
    int direction,
  ) async {
    final l = context.l;
    final amount = await showNumberDialog(
      context,
      title: direction > 0
          ? l.addAmountTitle(counter.name)
          : l.takeAmountTitle(counter.name),
      label: l.amount,
      action: direction > 0 ? l.add : l.takeAway,
      min: 1,
    );
    if (amount == null || !context.mounted) return;
    mark(context, counter, direction * amount);
    await store.addAmount(counter, direction * amount);
  }

  Future<void> setValue(BuildContext context, Counter counter) async {
    final l = context.l;
    final value = await showNumberDialog(
      context,
      title: l.setValue,
      label: l.value,
      action: l.set,
      initial: store.counters.valueOf(counter),
    );
    if (value != null) await store.setValue(counter, value);
  }

  /// Resets straight away and offers to undo, as deleting does.
  Future<void> reset(BuildContext context, Counter counter) async {
    final messenger = ScaffoldMessenger.of(context);
    final l = context.l;
    final event = await store.reset(counter);
    if (event == null) return;
    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          // Goes after its time like any other message. Left to itself, one
          // with a button now stays until it is dismissed.
          persist: false,
          content: Text(l.counterReset(counter.name)),
          duration: const Duration(seconds: 8),
          action: SnackBarAction(
            label: l.undo,
            onPressed: () => store.undoEvent(event),
          ),
        ),
      );
  }

  /// Puts a counter away at once and offers to undo, as deleting does.
  Future<void> archive(BuildContext context, Counter counter) async {
    final messenger = ScaffoldMessenger.of(context);
    final l = context.l;
    await store.archiveCounter(counter);
    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          // Goes after its time like any other message. Left to itself, one
          // with a button now stays until it is dismissed.
          persist: false,
          content: Text(l.counterArchived(counter.name)),
          duration: const Duration(seconds: 8),
          action: SnackBarAction(
            label: l.undo,
            // As it was, in the place it was.
            onPressed: () => store.updateCounter(counter),
          ),
        ),
      );
  }

  /// Asks which other group, then moves the counter to the end of it.
  Future<void> moveToGroup(BuildContext context, Counter counter) async {
    final messenger = ScaffoldMessenger.of(context);
    final l = context.l;
    final target = await showDialog<CounterGroup>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(context.l.moveToGroupTitle(counter.name)),
        children: [
          for (final g in store.counters.groups)
            if (g.id != counter.groupId)
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                leading: const Icon(Icons.folder_outlined),
                title: Text(g.name),
                onTap: () => Navigator.pop(context, g),
              ),
        ],
      ),
    );
    if (target == null) return;
    await store.moveCounterToGroup(counter, target.id);
    messenger
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(l.movedToGroup(target.name))));
  }

  Future<void> edit(BuildContext context, Counter counter) async {
    final draft = await showCounterEditor(
      context,
      counters: store.counters,
      existing: counter,
      canCountPerDay: store.canCountPerDay,
    );
    if (draft == null) return;
    await store.updateCounter(
      Counter(
        id: counter.id,
        groupId: counter.groupId,
        name: draft.name,
        description: draft.description,
        color: draft.look.color.toARGB32(),
        color2: draft.look.color2?.toARGB32(),
        pattern: draft.look.pattern,
        step: draft.step,
        goal: draft.goal,
        goalPeriod: draft.goalPeriod,
        buzzEvery: draft.buzzEvery,
        formula: draft.formula.formula,
        sources: draft.formula.sources,
        roundSize: draft.formula.roundSize,
        allTime: draft.formula.allTime,
        startFrom: draft.formula.startFrom,
        daily: draft.daily,
        archived: counter.archived,
        position: counter.position,
      ),
    );
  }

  /// Deletes straight away and offers to undo, instead of asking first: a
  /// question on every delete is a nag, and Undo brings back the history too.
  Future<void> delete(BuildContext context, Counter counter) async {
    final messenger = ScaffoldMessenger.of(context);
    final l = context.l;
    final deleted = await store.deleteCounter(counter);
    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          // Goes after its time like any other message. Left to itself, one
          // with a button now stays until it is dismissed.
          persist: false,
          content: Text(l.counterDeleted(counter.name)),
          duration: const Duration(seconds: 8),
          action: SnackBarAction(
            label: l.undo,
            onPressed: () => store.restoreCounter(deleted),
          ),
        ),
      );
  }
}
