import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:countersink/models/counter.dart';
import 'package:countersink/models/counters_snapshot.dart';
import 'package:countersink/ui/counter_look.dart';
import 'package:countersink/ui/language.dart';
import 'package:countersink/ui/layout.dart';
import 'package:countersink/ui/number_dialog.dart';
import 'package:countersink/ui/section.dart';

/// How a counter is worked out from others: nothing at all for one that is
/// counted by hand.
typedef CounterFormula = ({
  Formula? formula,
  List<String> sources,
  int? roundSize,
  bool allTime,
  int? startFrom,
});

/// An ordinary counter's lack of a formula.
const CounterFormula countedByHand = (
  formula: null,
  sources: <String>[],
  roundSize: null,
  allTime: false,
  startFrom: null,
);

/// Opens the screen where a counter is made calculated, or made ordinary
/// again. [selfId] is the counter being edited, which can't be worked out
/// from itself. Null if backed out of.
Future<CounterFormula?> showFormula(
  BuildContext context, {
  required CountersSnapshot counters,
  required CounterFormula current,
  String? selfId,
}) => Navigator.push<CounterFormula>(
  context,
  MaterialPageRoute(
    builder: (_) =>
        FormulaScreen(counters: counters, current: current, selfId: selfId),
  ),
);

/// Chooses what a calculated counter shows and which counters it is worked
/// out from.
class FormulaScreen extends StatefulWidget {
  const FormulaScreen({
    super.key,
    required this.counters,
    required this.current,
    this.selfId,
  });

  final CountersSnapshot counters;
  final CounterFormula current;
  final String? selfId;

  @override
  State<FormulaScreen> createState() => _FormulaScreenState();
}

class _FormulaScreenState extends State<FormulaScreen> {
  late Formula? _formula = widget.current.formula;

  /// The one a difference, a share or a count of rounds starts from.
  late String? _first = _known(widget.current.sources.firstOrNull);

  /// The rest; for a total, simply every counter in it.
  late final Set<String> _others = {
    for (final id in widget.current.sources.skip(_isSum ? 0 : 1)) ?_known(id),
  };

  late final _round = TextEditingController(
    text: widget.current.roundSize?.toString(),
  );

  late final _start = TextEditingController(
    text: widget.current.startFrom?.toString(),
  );

  /// The number a running total already stands at; null for none, and for
  /// anything but a total that keeps running.
  int? get _startFrom {
    if (!_isSum || !_allTime || !_anyPerDay) return null;
    final n = parseWholeNumber(_start.text);
    return n == null || n < 1 ? null : n;
  }

  /// Whether per-day counters count for every day, not just today.
  late bool _allTime = widget.current.allTime;

  bool get _isSum => _formula == Formula.sum;

  /// Whether any counter chosen so far starts from zero each day: only then
  /// is there a choice between today's count and a running total.
  bool get _anyPerDay => _choices.any(
    (c) =>
        c.counter.daily &&
        (c.counter.id == _first && !_isSum ||
            _others.contains(c.counter.id) && _formula != Formula.every),
  );

  /// The counters there are to choose from: ordinary ones, not archived,
  /// and not the one being edited.
  late final List<({Counter counter, String group})> _choices = [
    for (final g in widget.counters.groups)
      for (final c in widget.counters.inGroup(g.id))
        if (!c.calculated && c.id != widget.selfId) (counter: c, group: g.name),
  ];

  String? _known(String? id) =>
      _choices.any((c) => c.counter.id == id) ? id : null;

  @override
  void initState() {
    super.initState();
    _round.addListener(() => setState(() {}));
    _start.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _round.dispose();
    _start.dispose();
    super.dispose();
  }

  int? get _roundSize {
    final n = parseWholeNumber(_round.text);
    return n == null || n < 1 ? null : n;
  }

  /// What is chosen, in the order the counters are listed, or null while
  /// something is still missing.
  CounterFormula? get _result {
    final formula = _formula;
    if (formula == null) return countedByHand;
    final others = [
      for (final c in _choices)
        if (_others.contains(c.counter.id) && c.counter.id != _first)
          c.counter.id,
    ];
    final first = _first;
    switch (formula) {
      case Formula.sum:
        final all = [
          for (final c in _choices)
            if (_others.contains(c.counter.id)) c.counter.id,
        ];
        return all.isEmpty
            ? null
            : (
                formula: formula,
                sources: all,
                roundSize: null,
                allTime: _allTime,
                startFrom: _startFrom,
              );
      case Formula.difference:
      case Formula.percent:
        return first == null || others.isEmpty
            ? null
            : (
                formula: formula,
                sources: [first, ...others],
                roundSize: null,
                allTime: _allTime,
                startFrom: null,
              );
      case Formula.every:
        final size = _roundSize;
        return first == null || size == null
            ? null
            : (
                formula: formula,
                sources: [first],
                roundSize: size,
                allTime: _allTime,
                startFrom: null,
              );
    }
  }

  void _choose(Formula? formula) => setState(() {
    final wasSum = _isSum;
    _formula = formula;
    // A total has no first among equals: going to or from one, what was
    // chosen is kept as far as it still means something.
    if (formula == Formula.sum && !wasSum) {
      _others.addAll([?_first]);
    } else if (formula != Formula.sum && wasSum) {
      _first ??= _others.firstOrNull;
    }
  });

  Widget _kind(Formula? formula, String title, [String? hint]) => ListTile(
    leading: Icon(
      formula == _formula ? Icons.radio_button_checked : Icons.radio_button_off,
    ),
    title: Text(title),
    subtitle: hint == null ? null : Text(hint),
    selected: formula == _formula,
    onTap: () => _choose(formula),
  );

  Widget _dot(Counter counter) => SizedBox.square(
    dimension: 28,
    child: LookBox(look: lookOf(counter), circle: true),
  );

  /// The counters as a choice of one.
  Section _one(String title) => Section(
    title: title,
    children: [
      for (final c in _choices)
        ListTile(
          leading: _dot(c.counter),
          title: Text(
            c.counter.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Text(c.group, maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: Icon(
            c.counter.id == _first
                ? Icons.radio_button_checked
                : Icons.radio_button_off,
          ),
          selected: c.counter.id == _first,
          onTap: () => setState(() => _first = c.counter.id),
        ),
    ],
  );

  /// The counters as a choice of several, leaving out the one a formula
  /// starts from.
  Section _several(String title, {bool withFirst = false}) => Section(
    title: title,
    children: [
      for (final c in _choices)
        if (withFirst || c.counter.id != _first)
          CheckboxListTile(
            secondary: _dot(c.counter),
            title: Text(
              c.counter.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              c.group,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            value: _others.contains(c.counter.id),
            onChanged: (on) => setState(() {
              if (on ?? false) {
                _others.add(c.counter.id);
              } else {
                _others.remove(c.counter.id);
              }
            }),
          ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = context.l;
    final formula = _formula;
    final result = _result;

    return Scaffold(
      appBar: AppBar(title: Text(l.formulaTitle)),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: readablePadding(
            context,
            base: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          ),
          child: FilledButton(
            onPressed: result == null
                ? null
                : () => Navigator.pop(context, result),
            child: Text(l.done),
          ),
        ),
      ),
      body: ListView(
        padding: readablePadding(
          context,
          base: const EdgeInsets.only(bottom: 24),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
            child: Text(
              l.formulaIntro,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Section(
            title: l.sectionShows,
            children: [
              _kind(null, l.formulaNone),
              _kind(Formula.sum, l.formulaSum, l.formulaSumHint),
              _kind(
                Formula.difference,
                l.formulaDifference,
                l.formulaDifferenceHint,
              ),
              _kind(Formula.percent, l.formulaPercent, l.formulaPercentHint),
              _kind(Formula.every, l.formulaEvery, l.formulaEveryHint),
            ],
          ),
          if (formula != null && _choices.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Text(l.noOrdinaryCounters),
            )
          else
            ...switch (formula) {
              null => const <Widget>[],
              Formula.sum => [_several(l.formulaAddUp, withFirst: true)],
              Formula.difference => [
                _one(l.formulaStartWith),
                if (_first != null) _several(l.formulaTakeAway),
              ],
              Formula.percent => [
                _one(l.formulaShareOf),
                if (_first != null) _several(l.formulaTogetherWith),
              ],
              Formula.every => [
                _one(l.formulaRoundsOf),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                  child: TextField(
                    controller: _round,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(maxNumberDigits),
                    ],
                    decoration: InputDecoration(
                      labelText: l.roundSize,
                      helperText: l.roundSizeHint,
                      helperMaxLines: 2,
                    ),
                  ),
                ),
              ],
            },
          if (formula != null && _anyPerDay)
            Section(
              children: [
                SwitchListTile(
                  title: Text(l.formulaAllTime),
                  subtitle: Text(l.formulaAllTimeHint),
                  value: _allTime,
                  onChanged: (on) => setState(() => _allTime = on),
                ),
              ],
            ),
          if (_isSum && _anyPerDay && _allTime)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: TextField(
                controller: _start,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(maxNumberDigits),
                ],
                decoration: InputDecoration(
                  labelText: l.formulaStartFrom,
                  helperText: l.formulaStartFromHint,
                  helperMaxLines: 3,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
