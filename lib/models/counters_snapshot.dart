import 'package:countersink/domain/formulas.dart';
import 'package:countersink/models/counter.dart';
import 'package:countersink/models/counter_group.dart';

/// Everything the screens show, read in one go.
class CountersSnapshot {
  const CountersSnapshot({
    this.groups = const [],
    this.counters = const [],
    this.totals = const {},
    this.today = const {},
    this.week = const {},
  });

  /// In tab order.
  final List<CounterGroup> groups;

  /// In order within each group, archived ones included.
  final List<Counter> counters;

  /// Every counter's all-time total, by counter id; absent means zero.
  final Map<String, int> totals;

  /// Every counter's total for the current counting day, by counter id.
  final Map<String, int> today;

  /// Every counter's total for the current week, today included, by counter
  /// id.
  final Map<String, int> week;

  /// Everything as it would be if the counter with [counterId] had [delta]
  /// more counted now: for seeing what a count is about to do before it is
  /// made.
  CountersSnapshot withAdded(String counterId, int delta) {
    Map<String, int> added(Map<String, int> to) => {
      ...to,
      counterId: (to[counterId] ?? 0) + delta,
    };
    return CountersSnapshot(
      groups: groups,
      counters: counters,
      totals: added(totals),
      today: added(today),
      week: added(week),
    );
  }

  /// A group's counters as its tab shows them: those not archived.
  List<Counter> inGroup(String groupId) => [
    for (final c in counters)
      if (c.groupId == groupId && !c.archived) c,
  ];

  /// Every counter that belongs to a group, archived ones included: what
  /// goes when the group does.
  List<Counter> allInGroup(String groupId) => [
    for (final c in counters)
      if (c.groupId == groupId) c,
  ];

  /// The counters put away, in the order of their groups.
  List<Counter> get archived => [
    for (final g in groups)
      for (final c in counters)
        if (c.groupId == g.id && c.archived) c,
  ];

  /// The number on the card: today's total for a daily counter, the running
  /// total for any other, and for a calculated counter what its formula
  /// makes of the numbers on the cards it is worked out from, or of
  /// everything they have ever counted if it keeps a running total
  /// ([Counter.allTime]).
  int valueOf(Counter counter) {
    final formula = counter.formula;
    if (formula == null) return _counted(counter);
    final first = firstSourceOf(counter);
    final allTime = counter.allTime;
    return calculate(
      formula,
      first: first == null ? null : _counted(first, allTime: allTime),
      others: [
        for (final c in otherSourcesOf(counter)) _counted(c, allTime: allTime),
      ],
      roundSize: counter.roundSize ?? 1,
      startFrom: counter.startFrom ?? 0,
    );
  }

  /// What an ordinary counter's own events come to: today's for a per-day
  /// counter, unless [allTime] asks for every day's.
  int _counted(Counter counter, {bool allTime = false}) =>
      (counter.daily && !allTime ? today[counter.id] : totals[counter.id]) ?? 0;

  /// An ordinary counter by its id; null if it is gone, or is itself
  /// calculated, which a formula can't be built on.
  Counter? _source(String id) {
    for (final c in counters) {
      if (c.id == id) return c.calculated ? null : c;
    }
    return null;
  }

  /// The counter a calculated one starts from, or null if it is gone.
  Counter? firstSourceOf(Counter counter) =>
      counter.sources.isEmpty ? null : _source(counter.sources.first);

  /// The rest of the counters a calculated one is worked out from, leaving
  /// out any that are gone.
  List<Counter> otherSourcesOf(Counter counter) => [
    for (final id in counter.sources.skip(1)) ?_source(id),
  ];

  /// Whether a calculated counter has lost what it is worked out from: every
  /// counter of a total, or the one any other formula starts from.
  bool brokenOf(Counter counter) => switch (counter.formula) {
    null => false,
    Formula.sum =>
      firstSourceOf(counter) == null && otherSourcesOf(counter).isEmpty,
    _ => firstSourceOf(counter) == null,
  };

  /// For a counter of rounds, how far its counter is into the next one.
  int towardNextOf(Counter counter) {
    final first = firstSourceOf(counter);
    if (first == null) return 0;
    return towardNextRound(
      _counted(first, allTime: counter.allTime),
      counter.roundSize ?? 1,
    );
  }

  /// How far a counter is toward its goal: the week so far for a goal that
  /// is for the week, and the number on the card for any other.
  int progressOf(Counter counter) =>
      counter.weeklyGoal != null ? week[counter.id] ?? 0 : valueOf(counter);
}
