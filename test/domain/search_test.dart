import 'package:countersink/domain/search.dart';
import 'package:countersink/models/counter.dart';
import 'package:countersink/models/counter_group.dart';
import 'package:countersink/models/counters_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const counters = CountersSnapshot(
    groups: [
      CounterGroup(id: 'fit', name: 'Fitness'),
      CounterGroup(id: 'games', name: 'Game night', position: 1),
    ],
    counters: [
      Counter(
        id: 'pull',
        groupId: 'fit',
        name: 'Pull-ups',
        description: 'Strict, full hang',
        color: 0,
      ),
      Counter(
        id: 'push',
        groupId: 'fit',
        name: 'Push-ups',
        color: 0,
        position: 1,
      ),
      Counter(
        id: 'old',
        groupId: 'fit',
        name: 'Pull-downs',
        color: 0,
        position: 2,
        archived: true,
      ),
      Counter(id: 'score', groupId: 'games', name: 'Score', color: 0),
    ],
  );

  List<String> find(String query) => [
    for (final c in searchCounters(counters, query)) c.id,
  ];

  test('finds by name, whatever the capitals', () {
    expect(find('pull'), ['pull']);
    expect(find('PUSH'), ['push']);
    expect(find('ups'), ['pull', 'push']);
  });

  test('finds by description and by group', () {
    expect(find('strict'), ['pull']);
    expect(find('fitness'), ['pull', 'push']);
    expect(find('night'), ['score']);
  });

  test('every word must be found, in any of the three', () {
    expect(find('fit pull'), ['pull']);
    expect(find('game score'), ['score']);
    expect(find('game pull'), isEmpty);
  });

  test('archived counters are not found', () {
    expect(find('downs'), isEmpty);
  });

  test('nothing typed finds nothing', () {
    expect(find(''), isEmpty);
    expect(find('   '), isEmpty);
  });

  test('results come in tab order', () {
    expect(find('s'), ['pull', 'push', 'score']);
  });
}
