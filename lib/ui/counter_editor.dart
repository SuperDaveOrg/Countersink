import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:countersink/models/counter.dart';
import 'package:countersink/models/counters_snapshot.dart';
import 'package:countersink/ui/appearance_screen.dart';
import 'package:countersink/ui/counter_look.dart';
import 'package:countersink/ui/formula_screen.dart';
import 'package:countersink/ui/formula_text.dart';
import 'package:countersink/ui/language.dart';
import 'package:countersink/ui/number_dialog.dart';
import 'package:countersink/ui/theme.dart';

/// What the add and edit dialog hands back.
typedef CounterDraft = ({
  String name,
  String? description,
  int step,
  int? goal,
  GoalPeriod goalPeriod,
  int? buzzEvery,
  CounterFormula formula,
  bool daily,
  CounterLook look,
});

/// Asks for a counter's name, description, step, look and whether it counts
/// per day. Editing [existing] starts from what it has; adding starts empty,
/// in [suggested]. Null if canceled.
Future<CounterDraft?> showCounterEditor(
  BuildContext context, {
  required CountersSnapshot counters,
  Counter? existing,
  Color? suggested,
  Future<bool> Function(Counter)? canCountPerDay,
}) => showDialog<CounterDraft>(
  context: context,
  builder: (_) => _CounterEditor(
    counters: counters,
    existing: existing,
    canCountPerDay: canCountPerDay,
    look: existing != null
        ? lookOf(existing)
        : plainLook(suggested ?? counterColors.first),
  ),
);

class _CounterEditor extends StatefulWidget {
  const _CounterEditor({
    required this.counters,
    this.existing,
    this.canCountPerDay,
    required this.look,
  });

  /// Asked before an existing counter is switched to counting per day:
  /// whether its history allows it.
  final Future<bool> Function(Counter)? canCountPerDay;

  /// Every counter there is, for one that is worked out from others.
  final CountersSnapshot counters;
  final Counter? existing;
  final CounterLook look;

  @override
  State<_CounterEditor> createState() => _CounterEditorState();
}

class _CounterEditorState extends State<_CounterEditor> {
  late final _name = TextEditingController(text: widget.existing?.name);
  late final _description = TextEditingController(
    text: widget.existing?.description,
  );
  late final _step = TextEditingController(
    text: '${widget.existing?.step ?? 1}',
  );
  late final _goal = TextEditingController(
    text: widget.existing?.goal?.toString(),
  );
  late final _buzz = TextEditingController(
    text: widget.existing?.buzzEvery?.toString(),
  );
  late bool _daily = widget.existing?.daily ?? false;

  /// Whether counting per day was asked for and refused, because a day in
  /// the counter's history would come to less than zero.
  bool _perDayRefused = false;

  /// Switches counting per day on or off. A counter that already has a
  /// history is asked first whether every day of it stands on its own.
  Future<void> _setDaily(bool on) async {
    final existing = widget.existing;
    final allowed = widget.canCountPerDay;
    if (on && existing != null && !existing.daily && allowed != null) {
      final ok = await allowed(existing);
      if (!mounted) return;
      if (!ok) {
        setState(() => _perDayRefused = true);
        return;
      }
    }
    setState(() {
      _daily = on;
      _perDayRefused = false;
    });
  }

  late GoalPeriod _period = widget.existing?.goalPeriod ?? GoalPeriod.day;
  late CounterLook _look = widget.look;
  late CounterFormula _formula = (
    formula: widget.existing?.formula,
    sources: widget.existing?.sources ?? const [],
    roundSize: widget.existing?.roundSize,
    allTime: widget.existing?.allTime ?? false,
    startFrom: widget.existing?.startFrom,
  );

  /// Worked out from other counters, so with no step, goal or day of its
  /// own to set.
  bool get _calculated => _formula.formula != null;

  /// What the formula is made of, in words.
  String get _formulaLine => formulaLine(
    context.l,
    widget.counters,
    Counter(
      id: widget.existing?.id ?? '',
      groupId: '',
      name: '',
      color: 0,
      formula: _formula.formula,
      sources: _formula.sources,
      roundSize: _formula.roundSize,
      allTime: _formula.allTime,
      startFrom: _formula.startFrom,
    ),
  );

  Future<void> _calculate() async {
    final formula = await showFormula(
      context,
      counters: widget.counters,
      current: _formula,
      selfId: widget.existing?.id,
    );
    if (formula != null && mounted) setState(() => _formula = formula);
  }

  @override
  void initState() {
    super.initState();
    // The action stays off until there's a name.
    _name.addListener(() => setState(() {}));
    _step.addListener(() => setState(() {}));
    _goal.addListener(() => setState(() {}));
    _buzz.addListener(() => setState(() {}));
  }

  /// Empty is fine and means no goal; anything typed must be one or more.
  bool get _goalOk {
    if (_goal.text.trim().isEmpty) return true;
    final n = parseWholeNumber(_goal.text);
    return n != null && n >= 1;
  }

  /// Empty means no buzz; anything typed must be one or more.
  bool get _buzzOk {
    if (_buzz.text.trim().isEmpty) return true;
    final n = parseWholeNumber(_buzz.text);
    return n != null && n >= 1;
  }

  bool get _ready =>
      _name.text.trim().isNotEmpty &&
      _goalOk &&
      (_calculated || (_stepValue != null && _buzzOk));

  /// The step as typed, or null if it isn't a whole number of one or more.
  int? get _stepValue {
    final n = parseWholeNumber(_step.text);
    return n == null || n < 1 ? null : n;
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _step.dispose();
    _goal.dispose();
    _buzz.dispose();
    super.dispose();
  }

  void _done() {
    final name = _name.text.trim();
    if (!_ready) return;
    final description = _description.text.trim();
    // A calculated counter keeps none of what belongs to counting by hand.
    final byHand = !_calculated;
    Navigator.pop<CounterDraft>(context, (
      name: name,
      description: description.isEmpty ? null : description,
      step: byHand ? _stepValue ?? 1 : 1,
      goal: parseWholeNumber(_goal.text),
      // A week only means something for a counter that counts per day.
      goalPeriod: byHand && _daily ? _period : GoalPeriod.day,
      buzzEvery: byHand ? parseWholeNumber(_buzz.text) : null,
      formula: _formula,
      daily: byHand && _daily,
      look: _look,
    ));
  }

  /// Every color, a second color and patterns, on a screen of their own.
  Future<void> _more() async {
    final look = await showAppearance(context, look: _look, name: _name.text);
    if (look != null && mounted) setState(() => _look = look);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final theme = Theme.of(context);
    final editing = widget.existing != null;
    final family = [for (final c in counterColors) plainLook(c)];
    return AlertDialog(
      title: Text(editing ? l.editCounter : l.addCounter),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _name,
              autofocus: !editing,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(labelText: l.counterName),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _description,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(labelText: l.counterDescription),
              textInputAction: TextInputAction.next,
            ),
            if (!_calculated) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _step,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(maxNumberDigits),
                ],
                decoration: InputDecoration(
                  labelText: l.counterStep,
                  helperText: l.counterStepHint,
                  helperMaxLines: 2,
                ),
                textInputAction: TextInputAction.next,
              ),
            ],
            // A goal is for any counter: a calculated one reaches it when
            // the counters it is worked out from bring it there.
            const SizedBox(height: 12),
            TextField(
              controller: _goal,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(maxNumberDigits),
              ],
              decoration: InputDecoration(
                labelText: l.counterGoal,
                helperText: _calculated
                    ? l.goalHintCalculated
                    : l.counterGoalHint,
                helperMaxLines: 3,
              ),
              textInputAction: TextInputAction.next,
            ),
            if (!_calculated) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _buzz,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(maxNumberDigits),
                ],
                decoration: InputDecoration(
                  labelText: l.buzzEvery,
                  helperText: l.buzzEveryHint,
                  helperMaxLines: 3,
                ),
                onSubmitted: (_) => _done(),
              ),
            ],
            const SizedBox(height: 16),
            Text(l.counterColor, style: theme.textTheme.labelMedium),
            const SizedBox(height: 8),
            // The family's five for a one-tap choice; everything else is
            // behind the last button.
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final look in family)
                  ColorSwatchButton(
                    name: colorName(l, look.color),
                    selected: look == _look,
                    onTap: () => setState(() => _look = look),
                    child: LookBox(
                      look: look,
                      circle: true,
                      child: look == _look
                          ? Icon(Icons.check, color: inkOnLook(look))
                          : null,
                    ),
                  ),
                // A look from the fuller choice still shows as the one in use.
                if (!family.contains(_look))
                  ColorSwatchButton(
                    name: colorName(l, _look.color),
                    selected: true,
                    onTap: _more,
                    child: LookBox(
                      look: _look,
                      circle: true,
                      child: Icon(Icons.check, color: inkOnLook(_look)),
                    ),
                  ),
                ColorSwatchButton(
                  name: l.moreColors,
                  selected: false,
                  onTap: _more,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: theme.colorScheme.outline),
                    ),
                    child: Icon(
                      Icons.palette_outlined,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // A counter worked out from others: set up on a screen of its
            // own, and said here in words.
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l.calculated),
              subtitle: Text(_calculated ? _formulaLine : l.calculatedOff),
              trailing: const Icon(Icons.chevron_right),
              onTap: _calculate,
            ),
            if (!_calculated)
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l.countPerDay),
                subtitle: Text(l.countPerDayHint),
                value: _daily,
                onChanged: _setDaily,
              ),
            if (!_calculated && _perDayRefused)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  l.perDayRefused,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            // Only a counter that counts per day, with a goal, has a choice
            // to make here.
            if (!_calculated &&
                _daily &&
                parseWholeNumber(_goal.text) != null) ...[
              const SizedBox(height: 4),
              Text(l.goalForEach, style: theme.textTheme.labelMedium),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<GoalPeriod>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(
                      value: GoalPeriod.day,
                      label: Text(l.periodDay),
                    ),
                    ButtonSegment(
                      value: GoalPeriod.week,
                      label: Text(l.periodWeek),
                    ),
                  ],
                  selected: {_period},
                  onSelectionChanged: (chosen) =>
                      setState(() => _period = chosen.first),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l.cancel),
        ),
        TextButton(
          onPressed: _ready ? _done : null,
          child: Text(editing ? l.save : l.add),
        ),
      ],
    );
  }
}
