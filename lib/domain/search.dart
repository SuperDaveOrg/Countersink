import 'package:countersink/models/counter.dart';
import 'package:countersink/models/counters_snapshot.dart';

/// The counters on the tabs that [query] finds, in tab order.
///
/// A counter is found when every word of the query appears somewhere in its
/// name, its description or its group's name, whatever the capitals. Words
/// can match in different places: "fit pull" finds Pull-ups in Fitness.
/// Archived counters aren't looked at; they have a list of their own. An
/// empty query finds nothing.
List<Counter> searchCounters(CountersSnapshot counters, String query) {
  final words = query.toLowerCase().split(RegExp(r'\s+'))
    ..removeWhere((w) => w.isEmpty);
  if (words.isEmpty) return const [];
  return [
    for (final group in counters.groups)
      for (final c in counters.inGroup(group.id))
        if (_matches(words, [c.name, c.description ?? '', group.name])) c,
  ];
}

bool _matches(List<String> words, List<String> texts) {
  final haystack = texts.join('\n').toLowerCase();
  return words.every(haystack.contains);
}
