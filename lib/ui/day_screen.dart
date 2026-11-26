import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:countersink/domain/dates.dart';
import 'package:countersink/models/counter.dart';
import 'package:countersink/models/tap_event.dart';
import 'package:countersink/ui/counter_store.dart';
import 'package:countersink/ui/language.dart';
import 'package:countersink/ui/layout.dart';
import 'package:countersink/ui/number_dialog.dart';
import 'package:countersink/ui/theme.dart';

/// "Today", "Yesterday", or the date written out in the phone's language.
String dayName(BuildContext context, DateTime day, DateTime today) {
  if (day == today) return context.l.dayToday;
  if (day == DateTime(today.year, today.month, today.day - 1)) {
    return context.l.dayYesterday;
  }
  final locale = Localizations.localeOf(context).toLanguageTag();
  return DateFormat.yMMMEd(locale).format(day);
}

/// One counting day of one counter: every entry with its time, each open
/// to being corrected or removed, and a way to add one that was missed.
class DayScreen extends StatefulWidget {
  const DayScreen({
    super.key,
    required this.store,
    required this.counter,
    required this.day,
  });

  final CounterStore store;
  final Counter counter;

  /// The counting day, as a date with no time.
  final DateTime day;

  @override
  State<DayScreen> createState() => _DayScreenState();
}

class _DayScreenState extends State<DayScreen> {
  List<TapEvent>? _entries;

  CounterStore get _store => widget.store;
  int get _hour => _store.dayStartHour;

  @override
  void initState() {
    super.initState();
    _store.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    _store.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    final all = await _store.repository.events(widget.counter.id);
    if (!mounted) return;
    setState(() {
      _entries = [
        for (final e in all)
          if (countingDay(e.at, dayStartHour: _hour) == widget.day) e,
      ];
    });
  }

  void _say(String message) => ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(SnackBar(content: Text(message)));

  String _time(TimeOfDay time) => MaterialLocalizations.of(context)
      .formatTimeOfDay(
        time,
        alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
      );

  /// What a new entry's time starts as: now if this is today, otherwise
  /// the middle of the day.
  TimeOfDay get _defaultTime {
    final now = _store.now;
    return countingDay(now, dayStartHour: _hour) == widget.day
        ? TimeOfDay.fromDateTime(now)
        : const TimeOfDay(hour: 12, minute: 0);
  }

  DateTime _instant(TimeOfDay time) => instantOnDay(
    widget.day,
    hour: time.hour,
    minute: time.minute,
    dayStartHour: _hour,
  );

  Future<void> _add() async {
    final draft = await showEntryDialog(
      context,
      title: context.l.addEntry,
      action: context.l.add,
      time: _defaultTime,
    );
    if (draft == null || !mounted) return;
    final ok = await _store.addEntry(
      widget.counter,
      draft.delta,
      _instant(draft.time),
    );
    if (!ok && mounted) _say(context.l.belowZero);
  }

  Future<void> _edit(TapEvent entry) async {
    final draft = await showEntryDialog(
      context,
      title: context.l.editEntry,
      action: context.l.save,
      delta: entry.delta,
      time: TimeOfDay.fromDateTime(entry.at.toLocal()),
    );
    if (draft == null || !mounted) return;
    // The seconds it was first counted at are kept unless the time moved.
    final local = entry.at.toLocal();
    final sameMinute =
        draft.time.hour == local.hour && draft.time.minute == local.minute;
    final ok = await _store.editEntry(
      widget.counter,
      entry,
      delta: draft.delta,
      at: sameMinute ? entry.at : _instant(draft.time),
    );
    if (!ok && mounted) _say(context.l.belowZero);
  }

  /// Deletes straight away and offers to undo, as everywhere else.
  Future<void> _delete(TapEvent entry) async {
    final l = context.l;
    final messenger = ScaffoldMessenger.of(context);
    if (!await _store.deleteEntry(widget.counter, entry)) {
      if (mounted) _say(l.belowZero);
      return;
    }
    messenger
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          // Goes after its time like any other message. Left to itself, one
          // with a button now stays until it is dismissed.
          persist: false,
          content: Text(l.entryDeleted),
          duration: const Duration(seconds: 8),
          action: SnackBarAction(
            label: l.undo,
            onPressed: () => _store.restoreEntry(entry),
          ),
        ),
      );
  }

  Future<void> _menu(TapEvent entry) async {
    final theme = Theme.of(context);
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: Text(context.l.edit),
              onTap: () => Navigator.pop(context, 'edit'),
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
    );
    if (!mounted) return;
    switch (choice) {
      case 'edit':
        await _edit(entry);
      case 'delete':
        await _delete(entry);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = context.l;
    final entries = _entries;
    final today = countingDay(_store.now, dayStartHour: _hour);
    final total = entries?.fold(0, (sum, e) => sum + e.delta) ?? 0;

    return Scaffold(
      appBar: AppBar(title: Text(dayName(context, widget.day, today))),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _add,
        icon: const Icon(Icons.add),
        label: Text(l.addEntry),
      ),
      body: entries == null
          ? const SizedBox.shrink()
          : ListView(
              // Room at the bottom so the last entry clears the add button.
              padding: readablePadding(
                context,
                base: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              ),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${widget.counter.name} · ${l.dayTotal}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium,
                          ),
                        ),
                        Text('$total', style: theme.textTheme.headlineMedium),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (entries.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 48),
                    child: Center(
                      child: Text(
                        l.noEntries,
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
                        for (final (i, e) in entries.indexed) ...[
                          if (i > 0) const Divider(indent: 16, endIndent: 16),
                          ListTile(
                            title: Text(
                              _time(TimeOfDay.fromDateTime(e.at.toLocal())),
                            ),
                            subtitle: switch (e.kind) {
                              EventKind.tap => null,
                              EventKind.set => Text(l.setValue),
                              EventKind.reset => Text(l.resetToZero),
                            },
                            trailing: Text(
                              e.delta > 0 ? '+${e.delta}' : '−${-e.delta}',
                              style: CountersinkTheme.font(
                                CountersinkTheme.serif,
                                22,
                                560,
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                            onTap: () => _menu(e),
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

/// What the entry dialog hands back: a change, negative to take away, and
/// the time on the clock it happened.
typedef EntryDraft = ({int delta, TimeOfDay time});

/// Asks how much was added or taken away, and when. Null if canceled.
Future<EntryDraft?> showEntryDialog(
  BuildContext context, {
  required String title,
  required String action,
  required TimeOfDay time,
  int? delta,
}) => showDialog<EntryDraft>(
  context: context,
  builder: (_) =>
      _EntryDialog(title: title, action: action, time: time, delta: delta),
);

class _EntryDialog extends StatefulWidget {
  const _EntryDialog({
    required this.title,
    required this.action,
    required this.time,
    this.delta,
  });

  final String title;
  final String action;
  final TimeOfDay time;
  final int? delta;

  @override
  State<_EntryDialog> createState() => _EntryDialogState();
}

class _EntryDialogState extends State<_EntryDialog> {
  late final _amount = TextEditingController(
    text: widget.delta?.abs().toString(),
  );
  late bool _taking = (widget.delta ?? 1) < 0;
  late TimeOfDay _time = widget.time;

  @override
  void initState() {
    super.initState();
    _amount.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  int? get _number {
    final n = parseWholeNumber(_amount.text);
    return n == null || n < 1 ? null : n;
  }

  void _done() {
    final n = _number;
    if (n == null) return;
    Navigator.pop<EntryDraft>(context, (delta: _taking ? -n : n, time: _time));
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null && mounted) setState(() => _time = picked);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SegmentedButton<bool>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(value: false, label: Text(l.entryAdded)),
                ButtonSegment(value: true, label: Text(l.entryTaken)),
              ],
              selected: {_taking},
              onSelectionChanged: (s) => setState(() => _taking = s.single),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _amount,
              autofocus: widget.delta == null,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(maxNumberDigits),
              ],
              decoration: InputDecoration(labelText: l.amount),
              onSubmitted: (_) => _done(),
            ),
            const SizedBox(height: 4),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.schedule),
              title: Text(l.entryTime),
              trailing: Text(
                MaterialLocalizations.of(context).formatTimeOfDay(
                  _time,
                  alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(
                    context,
                  ),
                ),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              onTap: _pickTime,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.cancel),
        ),
        TextButton(
          onPressed: _number == null ? null : _done,
          child: Text(widget.action),
        ),
      ],
    );
  }
}
