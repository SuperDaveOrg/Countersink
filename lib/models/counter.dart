import 'dart:convert';

/// What is drawn over a card's color.
enum CounterPattern { none, stripes, dots, grid }

/// How a calculated counter is worked out from other counters.
enum Formula {
  /// Several counters added up.
  sum,

  /// One counter, less the others: in minus out.
  difference,

  /// One counter as a share of several together, in percent.
  percent,

  /// The whole rounds of a size in another counter: every 108th bead.
  every,
}

/// What a per-day counter's goal is for: each day, or the week as a whole.
enum GoalPeriod { day, week }

/// One thing being counted.
///
/// A counter holds no number of its own: its value is the sum of its
/// [TapEvent]s, so history, daily totals and undo all come from one record.
class Counter {
  const Counter({
    required this.id,
    required this.groupId,
    required this.name,
    this.description,
    required this.color,
    this.color2,
    this.pattern = CounterPattern.none,
    this.step = 1,
    this.goal,
    this.goalPeriod = GoalPeriod.day,
    this.buzzEvery,
    this.formula,
    this.sources = const [],
    this.roundSize,
    this.allTime = false,
    this.startFrom,
    this.daily = false,
    this.archived = false,
    this.position = 0,
  });

  final String id;
  final String groupId;
  final String name;
  final String? description;

  /// The card's color, as 0xAARRGGBB.
  final int color;

  /// A second color the first blends into, corner to corner; null for a
  /// card of one color.
  final int? color2;

  final CounterPattern pattern;

  /// How much one press of plus or minus changes the count.
  final int step;

  /// A number to reach, or null for none. For a per-day counter it is each
  /// day's goal, or the week's if [goalPeriod] says so; for any other, a
  /// total to get to.
  final int? goal;

  /// Whether a per-day counter's goal is for each day or for the week. It
  /// means nothing on a counter that isn't per day.
  final GoalPeriod goalPeriod;

  /// A double buzz each time the count passes a multiple of this, so that
  /// every tenth, say, is felt without looking. Null for none.
  final int? buzzEvery;

  /// How this counter is worked out from others, or null for an ordinary
  /// one that is counted by hand. A calculated counter has no events of its
  /// own and can't be counted on.
  final Formula? formula;

  /// The ids of the counters a calculated one is worked out from. The first
  /// is the one a difference, a share or a count of rounds starts from. An
  /// id whose counter has been deleted is kept, so that undoing the delete
  /// mends the link, and is skipped when the number is worked out.
  final List<String> sources;

  /// How many make a round, for [Formula.every].
  final int? roundSize;

  /// For a calculated counter: whether a per-day counter it is worked out
  /// from counts for everything it has ever counted, not just today, so
  /// that this one keeps a running total while that one starts each day
  /// from zero. It means nothing on an ordinary counter.
  final bool allTime;

  /// For a total ([Formula.sum]): a number it already stood at, added to
  /// what its counters come to, so that a running total can pick up where
  /// a count kept elsewhere left off. Null for none. It is a setting of the
  /// formula, like [roundSize], not a count: nothing is recorded for it.
  final int? startFrom;

  /// Whether this counter is worked out from others.
  bool get calculated => formula != null;

  /// The goal each day must reach, if that is the kind this counter has.
  int? get dailyGoal => daily && goalPeriod == GoalPeriod.day ? goal : null;

  /// The goal each week must reach, if that is the kind this counter has.
  int? get weeklyGoal => daily && goalPeriod == GoalPeriod.week ? goal : null;

  /// Shows today's total and starts from zero each day; past days are kept.
  final bool daily;

  /// Put away: off its group's tab but kept, history and all, until it is
  /// moved back or deleted.
  final bool archived;

  /// Order within the group, lowest first.
  final int position;

  /// The same counter somewhere else: in another group, another place in
  /// its list, or in or out of the archive.
  Counter moved({String? groupId, int? position, bool? archived}) => Counter(
    id: id,
    groupId: groupId ?? this.groupId,
    name: name,
    description: description,
    color: color,
    color2: color2,
    pattern: pattern,
    step: step,
    goal: goal,
    goalPeriod: goalPeriod,
    buzzEvery: buzzEvery,
    formula: formula,
    sources: sources,
    roundSize: roundSize,
    allTime: allTime,
    startFrom: startFrom,
    daily: daily,
    archived: archived ?? this.archived,
    position: position ?? this.position,
  );

  /// A new counter made like this one: the same look and settings under a
  /// new [id], in [groupId] at [position], worked out from [sources] if it
  /// is calculated. It starts with nothing counted and not archived.
  Counter copiedAs({
    required String id,
    required String groupId,
    required List<String> sources,
    required int position,
  }) => Counter(
    id: id,
    groupId: groupId,
    name: name,
    description: description,
    color: color,
    color2: color2,
    pattern: pattern,
    step: step,
    goal: goal,
    goalPeriod: goalPeriod,
    buzzEvery: buzzEvery,
    formula: formula,
    sources: sources,
    roundSize: roundSize,
    allTime: allTime,
    startFrom: startFrom,
    daily: daily,
    position: position,
  );

  Map<String, Object?> toRow() => {
    'id': id,
    'group_id': groupId,
    'name': name,
    'description': description,
    'color': color,
    'color2': color2,
    'pattern': pattern.name,
    'step': step,
    'goal': goal,
    'goal_period': goalPeriod.name,
    'buzz_every': buzzEvery,
    'formula': formula?.name,
    'sources': sources.isEmpty ? null : jsonEncode(sources),
    'round_size': roundSize,
    'all_time': allTime ? 1 : 0,
    'start_from': startFrom,
    'daily': daily ? 1 : 0,
    'archived': archived ? 1 : 0,
    'position': position,
  };

  static Counter fromRow(Map<String, Object?> row) => Counter(
    id: row['id'] as String,
    groupId: row['group_id'] as String,
    name: row['name'] as String,
    description: row['description'] as String?,
    color: row['color'] as int,
    color2: row['color2'] as int?,
    // A pattern from a later version is drawn plain, not refused.
    pattern:
        CounterPattern.values.asNameMap()[row['pattern']] ??
        CounterPattern.none,
    step: row['step'] as int,
    goal: row['goal'] as int?,
    // A period from a later version is read as each day, not refused.
    goalPeriod:
        GoalPeriod.values.asNameMap()[row['goal_period']] ?? GoalPeriod.day,
    buzzEvery: row['buzz_every'] as int?,
    // A formula from a later version leaves an ordinary counter, which at
    // worst shows nothing counted; it is never refused.
    formula: Formula.values.asNameMap()[row['formula']],
    sources: _sources(row['sources']),
    roundSize: row['round_size'] as int?,
    allTime: row['all_time'] == 1,
    startFrom: row['start_from'] as int?,
    daily: row['daily'] == 1,
    archived: row['archived'] == 1,
    position: row['position'] as int,
  );

  /// The ids kept in the row as a JSON list; anything else reads as none.
  static List<String> _sources(Object? stored) {
    if (stored is! String) return const [];
    try {
      final ids = jsonDecode(stored);
      return ids is List
          ? [
              for (final id in ids)
                if (id is String) id,
            ]
          : const [];
    } on FormatException {
      return const [];
    }
  }
}
