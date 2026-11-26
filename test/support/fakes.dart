import 'package:countersink/data/counter_repository.dart';
import 'package:countersink/domain/dates.dart';
import 'package:countersink/models/counter.dart';
import 'package:countersink/models/counter_group.dart';
import 'package:countersink/models/counters_snapshot.dart';
import 'package:countersink/models/tap_event.dart';

/// The repository's behavior without a database, for widget tests.
class InMemoryCounterRepository implements CounterRepository {
  final groups = <String, CounterGroup>{};
  final counters = <String, Counter>{};
  final log = <TapEvent>[];

  @override
  Future<CountersSnapshot> snapshot({
    required DateTime now,
    int dayStartHour = 0,
    int weekStart = DateTime.monday,
  }) async {
    final today = countingDay(now, dayStartHour: dayStartHour);
    final thisWeek = weekOf(today, weekStart: weekStart);
    final totals = <String, int>{};
    final todays = <String, int>{};
    final weeks = <String, int>{};
    for (final e in log) {
      totals[e.counterId] = (totals[e.counterId] ?? 0) + e.delta;
      final day = countingDay(e.at, dayStartHour: dayStartHour);
      if (day == today) {
        todays[e.counterId] = (todays[e.counterId] ?? 0) + e.delta;
      }
      if (!day.isAfter(today) &&
          weekOf(day, weekStart: weekStart) == thisWeek) {
        weeks[e.counterId] = (weeks[e.counterId] ?? 0) + e.delta;
      }
    }
    return CountersSnapshot(
      groups: groups.values.toList()
        ..sort((a, b) => a.position.compareTo(b.position)),
      counters: counters.values.toList()
        ..sort((a, b) => a.position.compareTo(b.position)),
      totals: totals,
      today: todays,
      week: weeks,
    );
  }

  @override
  Future<void> saveGroup(CounterGroup group) async => groups[group.id] = group;

  @override
  Future<void> saveCounter(Counter counter) async =>
      counters[counter.id] = counter;

  @override
  Future<List<TapEvent>> allEvents() async =>
      [...log]..sort((a, b) => a.at.compareTo(b.at));

  @override
  Future<void> replaceAll(
    List<CounterGroup> newGroups,
    List<Counter> newCounters,
    List<TapEvent> events,
  ) async {
    groups
      ..clear()
      ..addAll({for (final g in newGroups) g.id: g});
    counters
      ..clear()
      ..addAll({for (final c in newCounters) c.id: c});
    log
      ..clear()
      ..addAll(events);
  }

  @override
  Future<void> deleteGroup(String id) async {
    groups.remove(id);
    final gone = {
      for (final c in counters.values)
        if (c.groupId == id) c.id,
    };
    counters.removeWhere((id, _) => gone.contains(id));
    log.removeWhere((e) => gone.contains(e.counterId));
  }

  @override
  Future<void> restoreGroup(
    CounterGroup group,
    List<Counter> restored,
    Map<String, List<TapEvent>> events,
  ) async {
    groups[group.id] = group;
    for (final c in restored) {
      counters[c.id] = c;
      log.addAll(events[c.id] ?? const []);
    }
  }

  @override
  Future<void> reorderGroups(List<String> ids) async {
    for (var i = 0; i < ids.length; i++) {
      final g = groups[ids[i]]!;
      groups[g.id] = CounterGroup(id: g.id, name: g.name, position: i);
    }
  }

  @override
  Future<void> reorderCounters(List<String> ids) async {
    for (var i = 0; i < ids.length; i++) {
      final c = counters[ids[i]]!;
      counters[c.id] = c.moved(position: i);
    }
  }

  @override
  Future<void> deleteCounter(String id) async {
    counters.remove(id);
    log.removeWhere((e) => e.counterId == id);
  }

  @override
  Future<void> restoreCounter(Counter counter, List<TapEvent> events) async {
    counters[counter.id] = counter;
    log.addAll(events);
  }

  @override
  Future<TapEvent> record(
    String counterId,
    int delta, {
    required DateTime at,
    EventKind kind = EventKind.tap,
  }) async {
    final event = TapEvent(
      id: '${log.length}',
      counterId: counterId,
      at: at,
      delta: delta,
      kind: kind,
    );
    log.add(event);
    return event;
  }

  @override
  Future<void> updateEvent(TapEvent event) async {
    final i = log.indexWhere((e) => e.id == event.id);
    final old = log[i];
    log[i] = TapEvent(
      id: old.id,
      counterId: old.counterId,
      at: event.at,
      delta: event.delta,
      kind: old.kind,
    );
  }

  @override
  Future<void> restoreEvent(TapEvent event) async => log.add(event);

  @override
  Future<void> undo(String eventId) async =>
      log.removeWhere((e) => e.id == eventId);

  @override
  Future<List<TapEvent>> events(String counterId) async => [
    for (final e in log)
      if (e.counterId == counterId) e,
  ]..sort((a, b) => a.at.compareTo(b.at));
}
