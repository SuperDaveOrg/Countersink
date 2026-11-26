import 'package:countersink/models/counter.dart';

/// What a calculated counter comes to, from the numbers on the cards of the
/// counters it is worked out from.
///
/// [first] is the counter the formula starts from, or null if that counter
/// is gone; [others] are the rest that still exist. Nothing here is stored:
/// a calculated counter has no events of its own, so its number can never
/// drift from the counts it is made of.
///
/// - [Formula.sum]: all of them added up, on top of [startFrom], the number
///   the total already stood at.
/// - [Formula.difference]: the first, less the others.
/// - [Formula.percent]: the first as a share of all of them together, in
///   whole percent. Nothing counted yet is 0, not an error.
/// - [Formula.every]: how many whole rounds of [roundSize] the first holds.
///
/// A difference, share or count of rounds whose first counter is gone has
/// nothing to start from and comes to 0.
int calculate(
  Formula formula, {
  required int? first,
  List<int> others = const [],
  int roundSize = 1,
  int startFrom = 0,
}) {
  final rest = others.fold(0, (a, b) => a + b);
  switch (formula) {
    case Formula.sum:
      return startFrom + (first ?? 0) + rest;
    case Formula.difference:
      return first == null ? 0 : first - rest;
    case Formula.percent:
      if (first == null) return 0;
      final whole = first + rest;
      if (whole <= 0 || first <= 0) return 0;
      return (100 * first / whole).round().clamp(0, 100);
    case Formula.every:
      if (first == null || first <= 0) return 0;
      return first ~/ (roundSize < 1 ? 1 : roundSize);
  }
}

/// How far into the next round of [roundSize] a count of [first] is: the 5
/// in "3 rounds of 8, and 5 toward the next".
int towardNextRound(int first, int roundSize) =>
    first <= 0 ? 0 : first % (roundSize < 1 ? 1 : roundSize);
