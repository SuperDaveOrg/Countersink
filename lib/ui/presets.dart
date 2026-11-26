import 'package:countersink/l10n/app_localizations.dart';
import 'package:countersink/models/counter.dart';
import 'package:countersink/ui/theme.dart';

/// A ready-made set: a group's worth of counters for a common job, offered
/// when a group is added. [counters] are patterns to copy, not counters that
/// exist; their ids only tie a calculated one to the others in the set.
typedef Preset = ({String name, String description, List<Counter> counters});

/// The sets on offer, named in the language on screen. Each is a use that
/// specialized counters are made for, built from nothing but ordinary and
/// calculated counters, so every part of it can be edited afterwards.
List<Preset> presets(AppLocalizations l) {
  // The family's colors, by their place in [counterColors].
  const clay = 0, teal = 1, navy = 2, lavender = 3, green = 4;

  Counter counter(
    String id,
    String name,
    int color, {
    Formula? formula,
    List<String> of = const [],
    int? roundSize,
  }) => Counter(
    id: id,
    groupId: '',
    name: name,
    color: counterColors[color].toARGB32(),
    formula: formula,
    sources: of,
    roundSize: roundSize,
  );

  return [
    (
      name: l.presetRows,
      description: l.presetRowsHint,
      counters: [
        counter('rows', l.nameRows, teal),
        counter(
          'repeats',
          l.nameRepeats,
          navy,
          formula: Formula.every,
          of: ['rows'],
          roundSize: 8,
        ),
      ],
    ),
    (
      name: l.presetBeads,
      description: l.presetBeadsHint,
      counters: [
        counter('beads', l.nameBeads, clay),
        counter(
          'rounds',
          l.nameRounds,
          navy,
          formula: Formula.every,
          of: ['beads'],
          roundSize: 108,
        ),
      ],
    ),
    (
      name: l.presetInOut,
      description: l.presetInOutHint,
      counters: [
        counter('in', l.nameIn, green),
        counter('out', l.nameOut, clay),
        counter(
          'inside',
          l.nameInside,
          navy,
          formula: Formula.difference,
          of: ['in', 'out'],
        ),
      ],
    ),
    (
      name: l.presetScore,
      description: l.presetScoreHint,
      counters: [
        counter('us', l.nameUs, teal),
        counter('them', l.nameThem, clay),
      ],
    ),
    (
      name: l.presetMade,
      description: l.presetMadeHint,
      counters: [
        counter('made', l.nameMade, green),
        counter('missed', l.nameMissed, lavender),
        counter(
          'share',
          l.nameMadeShare,
          navy,
          formula: Formula.percent,
          of: ['made', 'missed'],
        ),
      ],
    ),
  ];
}
