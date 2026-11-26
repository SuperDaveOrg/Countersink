import 'package:countersink/l10n/app_localizations.dart';
import 'package:countersink/models/counter.dart';
import 'package:countersink/models/counters_snapshot.dart';

/// In words, what a calculated counter is worked out from: the line under
/// its number, and under "Calculated from other counters" in the editor.
/// Counters that have been deleted are left out; if what is left can't make
/// the number, it says so instead.
String formulaLine(
  AppLocalizations l,
  CountersSnapshot counters,
  Counter counter,
) {
  final formula = counter.formula;
  if (formula == null) return '';
  if (counters.brokenOf(counter)) return l.lineBroken;
  final first = counters.firstSourceOf(counter);
  final others = [for (final c in counters.otherSourcesOf(counter)) c.name];
  final all = [?first?.name, ...others];
  switch (formula) {
    case Formula.sum:
      return l.lineSum(all.join(', '));
    case Formula.difference:
      // With nothing left to take away it is just the one counter.
      return others.isEmpty
          ? first!.name
          : l.lineDifference(first!.name, others.join(', '));
    case Formula.percent:
      return l.linePercent(first!.name, all.join(', '));
    case Formula.every:
      return l.lineEvery(counter.roundSize ?? 1, first!.name);
  }
}
