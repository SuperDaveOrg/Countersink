import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart' show Color;

import 'package:countersink/data/backup.dart';
import 'package:countersink/data/counter_repository.dart';
import 'package:countersink/data/ids.dart';
import 'package:countersink/data/importers.dart';
import 'package:countersink/domain/dates.dart';
import 'package:countersink/models/counter.dart';
import 'package:countersink/models/counter_group.dart';
import 'package:countersink/models/counters_snapshot.dart';
import 'package:countersink/models/tap_event.dart';
import 'package:countersink/ui/theme.dart';

/// A counter that was just deleted, kept so the deletion can be undone.
typedef DeletedCounter = ({Counter counter, List<TapEvent> events});

/// What a count is worth marking with, beyond the tick every count gets:
/// reaching the goal, or passing a multiple the counter buzzes on.
enum CountMark { none, multiple, goal }

/// A group that was just deleted, with everything that was in it.
typedef DeletedGroup = ({CounterGroup group, List<DeletedCounter> counters});

/// What every screen reads, and the one way anything gets changed.
///
/// A plain [ChangeNotifier] from Flutter itself, not a state package: it
/// holds the current [CountersSnapshot], and [change] runs an edit and then
/// reloads, so no screen can show a stale count.
class CounterStore extends ChangeNotifier {
  CounterStore({
    required this.repository,
    DateTime Function()? clock,
    this.dayStartHour = 0,
    this.weekStart = DateTime.monday,
  }) : _clock = clock ?? DateTime.now;

  final CounterRepository repository;
  final DateTime Function() _clock;

  /// The hour a counting day begins; 0 is midnight. Chosen in Settings.
  int dayStartHour;

  /// The day a week begins on, as [DateTime.weekday] numbers them: 1 for
  /// Monday through 7 for Sunday. Chosen in Settings.
  int weekStart;

  /// Changes the day a week begins on and works the week's totals out
  /// again. Remembering the choice is the caller's job.
  Future<void> setWeekStart(int weekday) {
    weekStart = weekday;
    _changedSinceBackup = true;
    return load();
  }

  /// Changes when a counting day begins and re-sorts today's totals to
  /// match. Remembering the choice is the caller's job.
  Future<void> setDayStartHour(int hour) {
    dayStartHour = hour;
    _changedSinceBackup = true;
    return load();
  }

  /// Everything there is, as a backup holds it.
  Future<BackupData> exportData() async => BackupData(
    groups: _counters.groups,
    counters: _counters.counters,
    events: await repository.allEvents(),
    dayStartHour: dayStartHour,
    weekStart: weekStart,
  );

  /// Replaces everything with what [backup] holds, the day-start hour and
  /// the week's first day included if the file gave them. Remembering those
  /// two is the caller's job.
  Future<void> restore(BackupData backup) {
    dayStartHour = backup.dayStartHour ?? dayStartHour;
    weekStart = backup.weekStart ?? weekStart;
    return change(
      (repo) => repo.replaceAll(backup.groups, backup.counters, backup.events),
    );
  }

  /// The moment everything on screen is worked out for.
  DateTime get now => _clock();

  CountersSnapshot _counters = const CountersSnapshot();
  bool _loaded = false;

  CountersSnapshot get counters => _counters;
  bool get loaded => _loaded;

  /// Rereads everything. Also what moves "today" on: call it when the app
  /// comes back to the front.
  Future<void> load() async {
    _counters = await repository.snapshot(
      now: _clock(),
      dayStartHour: dayStartHour,
      weekStart: weekStart,
    );
    _loaded = true;
    notifyListeners();
  }

  /// Whether anything has changed since the last automatic backup, or since
  /// the app started. Day-start counts: it changes what a backup says.
  bool get changedSinceBackup => _changedSinceBackup;
  bool _changedSinceBackup = false;

  void markBackedUp() => _changedSinceBackup = false;

  /// Something changed that didn't go through [change]: a count made on a
  /// home-screen widget while the app was away.
  void markChanged() => _changedSinceBackup = true;

  /// Runs [edit], then brings every screen up to date.
  Future<T> change<T>(Future<T> Function(CounterRepository repo) edit) async {
    final result = await edit(repository);
    _changedSinceBackup = true;
    await load();
    return result;
  }

  /// One press of plus ([direction] 1) or minus (-1): the counter's step.
  Future<void> tap(Counter counter, int direction) =>
      addAmount(counter, direction * counter.step);

  /// Changes a counter by [amount], which is negative to take away. A tally
  /// doesn't go below nothing, so taking away stops at zero.
  Future<void> addAmount(Counter counter, int amount) async {
    // A calculated counter has no count of its own to change.
    if (counter.calculated) return;
    final value = _counters.valueOf(counter);
    final delta = amount < 0 ? -min(-amount, max(value, 0)) : amount;
    if (delta == 0) return;
    await change((repo) => repo.record(counter.id, delta, at: _clock()));
  }

  /// Makes the number on the card [value], as one event holding the
  /// difference. For a per-day counter that is today's total.
  Future<void> setValue(Counter counter, int value) async {
    if (counter.calculated) return;
    final delta = value - _counters.valueOf(counter);
    if (delta == 0) return;
    await change(
      (repo) =>
          repo.record(counter.id, delta, at: _clock(), kind: EventKind.set),
    );
  }

  /// Takes the number on the card back to zero, as an event like any other,
  /// so the history still shows what was there. Null if it was zero already.
  /// [undoEvent] takes it back.
  Future<TapEvent?> reset(Counter counter) async {
    if (counter.calculated) return null;
    final value = _counters.valueOf(counter);
    if (value == 0) return null;
    return change(
      (repo) =>
          repo.record(counter.id, -value, at: _clock(), kind: EventKind.reset),
    );
  }

  /// Whether a counter's history, as [after] would leave it, shows a count
  /// below zero: the whole total for an ordinary counter, any one day's for
  /// a per-day counter.
  bool _belowZero(Counter counter, List<TapEvent> after) {
    if (!counter.daily) return after.fold(0, (sum, e) => sum + e.delta) < 0;
    return summarizeDays(
      after,
      dayStartHour: dayStartHour,
    ).any((d) => d.total < 0);
  }

  /// Whether a counter could count per day with the history it has: false
  /// if some day in it takes away more than it counts, which would show a
  /// count below zero for that day.
  Future<bool> canCountPerDay(Counter counter) async {
    final events = await repository.events(counter.id);
    return !summarizeDays(
      events,
      dayStartHour: dayStartHour,
    ).any((d) => d.total < 0);
  }

  /// Adds an entry at a moment of the user's choosing: a count remembered
  /// afterwards. False, with nothing changed, if it would take the count
  /// below zero.
  Future<bool> addEntry(Counter counter, int delta, DateTime at) async {
    if (delta == 0 || counter.calculated) return false;
    final events = await repository.events(counter.id);
    final entry = TapEvent(id: '', counterId: counter.id, at: at, delta: delta);
    if (_belowZero(counter, [...events, entry])) return false;
    await change((repo) => repo.record(counter.id, delta, at: at));
    return true;
  }

  /// Changes an entry's amount or time. False, with nothing changed, if it
  /// would take the count below zero.
  Future<bool> editEntry(
    Counter counter,
    TapEvent entry, {
    required int delta,
    required DateTime at,
  }) async {
    if (delta == 0) return false;
    final edited = TapEvent(
      id: entry.id,
      counterId: entry.counterId,
      at: at,
      delta: delta,
      kind: entry.kind,
    );
    final events = await repository.events(counter.id);
    final after = [for (final e in events) e.id == entry.id ? edited : e];
    if (_belowZero(counter, after)) return false;
    await change((repo) => repo.updateEvent(edited));
    return true;
  }

  /// Deletes an entry. False, with nothing changed, if what is left would
  /// show a count below zero. [restoreEntry] undoes it.
  Future<bool> deleteEntry(Counter counter, TapEvent entry) async {
    final events = await repository.events(counter.id);
    final after = [
      for (final e in events)
        if (e.id != entry.id) e,
    ];
    if (_belowZero(counter, after)) return false;
    await change((repo) => repo.undo(entry.id));
    return true;
  }

  /// Undoes [deleteEntry].
  Future<void> restoreEntry(TapEvent entry) =>
      change((repo) => repo.restoreEvent(entry));

  /// Removes one event, as if it had never happened.
  Future<void> undoEvent(TapEvent event) =>
      change((repo) => repo.undo(event.id));

  /// Adds a group as the last tab.
  Future<CounterGroup> addGroup(String name) {
    final groups = _counters.groups;
    final group = CounterGroup(
      id: newId(),
      name: name,
      // After the last one, not at the count: a deletion leaves a gap.
      position: groups.isEmpty ? 0 : groups.last.position + 1,
    );
    return change((repo) async {
      await repo.saveGroup(group);
      return group;
    });
  }

  /// Adds a group as the last tab, with counters made like [counters]: a
  /// ready-made set, or another group's counters. Each gets a new id and
  /// starts with nothing counted. A calculated one among them that is worked
  /// out from others in the list is pointed at their copies; one worked out
  /// from a counter elsewhere keeps looking there.
  Future<CounterGroup> addGroupWith(String name, List<Counter> counters) {
    final groups = _counters.groups;
    final group = CounterGroup(
      id: newId(),
      name: name,
      position: groups.isEmpty ? 0 : groups.last.position + 1,
    );
    final ids = {for (final c in counters) c.id: newId()};
    final copies = [
      for (final (i, c) in counters.indexed)
        c.copiedAs(
          id: ids[c.id]!,
          groupId: group.id,
          sources: [for (final id in c.sources) ids[id] ?? id],
          position: i,
        ),
    ];
    return change((repo) async {
      await repo.saveGroup(group);
      for (final c in copies) {
        await repo.saveCounter(c);
      }
      return group;
    });
  }

  /// Adds a group like [group] under [name]: the counters on its tab, with
  /// their looks and settings, and none of their counts. Archived counters
  /// stay behind.
  Future<CounterGroup> copyGroup(CounterGroup group, String name) =>
      addGroupWith(name, _counters.inGroup(group.id));

  /// Adds what a file from another app held, as new tabs after the ones
  /// there are. Returns the groups as added, which deleting undoes.
  Future<List<CounterGroup>> addImported(Imported imported) {
    final groups = _counters.groups;
    final after = groups.isEmpty ? 0 : groups.last.position + 1;
    final placed = [
      for (final (i, g) in imported.groups.indexed)
        CounterGroup(id: g.id, name: g.name, position: after + i),
    ];
    final events = <String, List<TapEvent>>{};
    for (final e in imported.events) {
      events.putIfAbsent(e.counterId, () => []).add(e);
    }
    return change((repo) async {
      for (final g in placed) {
        await repo.restoreGroup(g, [
          for (final c in imported.counters)
            if (c.groupId == g.id) c,
        ], events);
      }
      return placed;
    });
  }

  Future<void> renameGroup(CounterGroup group, String name) => change(
    (repo) => repo.saveGroup(
      CounterGroup(id: group.id, name: name, position: group.position),
    ),
  );

  /// Moves the tab at [from] to sit at [to], counted among the others.
  Future<void> moveGroup(int from, int to) {
    final ids = [for (final g in _counters.groups) g.id];
    ids.insert(to, ids.removeAt(from));
    return change((repo) => repo.reorderGroups(ids));
  }

  /// Deletes a group with its counters and their history, handing it all
  /// back so that [restoreGroup] can undo it.
  Future<DeletedGroup> deleteGroup(CounterGroup group) => change((repo) async {
    final counters = <DeletedCounter>[
      // Archived ones go with the group too, and come back with it.
      for (final c in _counters.allInGroup(group.id))
        (counter: c, events: await repo.events(c.id)),
    ];
    await repo.deleteGroup(group.id);
    return (group: group, counters: counters);
  });

  /// Undoes [deleteGroup]: the tab returns to its place with its counters
  /// and every event they had.
  Future<void> restoreGroup(DeletedGroup deleted) => change(
    (repo) => repo.restoreGroup(
      deleted.group,
      [for (final d in deleted.counters) d.counter],
      {for (final d in deleted.counters) d.counter.id: d.events},
    ),
  );

  /// The color a new counter is offered: the family colors in turn.
  Color get nextColor =>
      counterColors[_counters.counters.length % counterColors.length];

  /// Adds a counter at the end of its group.
  Future<Counter> addCounter({
    required String groupId,
    required String name,
    String? description,
    Color? color,
    Color? color2,
    CounterPattern pattern = CounterPattern.none,
    int step = 1,
    int? goal,
    GoalPeriod goalPeriod = GoalPeriod.day,
    int? buzzEvery,
    Formula? formula,
    List<String> sources = const [],
    int? roundSize,
    bool allTime = false,
    int? startFrom,
    bool daily = false,
  }) {
    final siblings = _counters.allInGroup(groupId);
    final counter = Counter(
      id: newId(),
      groupId: groupId,
      name: name,
      description: description,
      color: (color ?? nextColor).toARGB32(),
      color2: color2?.toARGB32(),
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
      // After the last one, not at the count: a deletion leaves a gap.
      position: siblings.isEmpty ? 0 : siblings.last.position + 1,
    );
    return change((repo) async {
      await repo.saveCounter(counter);
      return counter;
    });
  }

  /// Moves the counter at [from] in a group to sit at [to], counted among
  /// the group's others.
  Future<void> moveCounter(String groupId, int from, int to) {
    final ids = [for (final c in _counters.inGroup(groupId)) c.id];
    ids.insert(to, ids.removeAt(from));
    return change((repo) => repo.reorderCounters(ids));
  }

  /// Moves a counter to the end of another group, history and all.
  Future<void> moveCounterToGroup(Counter counter, String groupId) {
    final siblings = _counters.allInGroup(groupId);
    return change(
      (repo) => repo.saveCounter(
        counter.moved(
          groupId: groupId,
          position: siblings.isEmpty ? 0 : siblings.last.position + 1,
        ),
      ),
    );
  }

  /// Whether adding [amount] now would take a counter from short of its
  /// goal to it or past it: the moment worth marking. A goal for the week
  /// is measured against the week so far.
  bool reachesGoal(Counter counter, int amount) =>
      reachedBy(counter, amount).any((c) => c.id == counter.id);

  /// Every counter whose goal a change of [amount] to [counter] would reach
  /// now: the counter itself, and any calculated counter worked out from it
  /// that the change brings from short of its goal to it or past it. Taking
  /// away can do that too, to a difference. Worked out before the change is
  /// made, so that it can be felt and said at the moment of the press.
  List<Counter> reachedBy(Counter counter, int amount) {
    if (counter.calculated) return const [];
    // As [addAmount] will have it: taking away stops at zero.
    final value = _counters.valueOf(counter);
    final delta = amount < 0 ? -min(-amount, max(value, 0)) : amount;
    if (delta == 0) return const [];
    final after = _counters.withAdded(counter.id, delta);
    return [
      for (final c in _counters.counters)
        if (c.goal case final goal?)
          // The counter itself whatever its state; others only if they are
          // still on a tab to be told about.
          if ((c.id == counter.id || !c.archived) &&
              _counters.progressOf(c) < goal &&
              after.progressOf(c) >= goal)
            c,
    ];
  }

  /// Whether adding [amount] now would take the number on the card to or
  /// past the next multiple the counter buzzes on: every tenth, say.
  bool passesMultiple(Counter counter, int amount) {
    final every = counter.buzzEvery;
    if (every == null || every < 1 || amount <= 0) return false;
    final value = _counters.valueOf(counter);
    return (value + amount) ~/ every > value ~/ every;
  }

  /// What adding [amount] now should feel like. Reaching the goal comes
  /// first when one count does both.
  CountMark markOf(Counter counter, int amount) {
    if (reachedBy(counter, amount).isNotEmpty) return CountMark.goal;
    if (passesMultiple(counter, amount)) return CountMark.multiple;
    return CountMark.none;
  }

  /// Puts a counter away: off its tab, with its history kept. Saving the
  /// counter as it was undoes it, place and all.
  Future<void> archiveCounter(Counter counter) =>
      change((repo) => repo.saveCounter(counter.moved(archived: true)));

  /// Brings an archived counter back, as the last on its group's tab.
  Future<void> unarchiveCounter(Counter counter) {
    final siblings = _counters.allInGroup(counter.groupId);
    final others = [
      for (final c in siblings)
        if (c.id != counter.id) c,
    ];
    return change(
      (repo) => repo.saveCounter(
        counter.moved(
          archived: false,
          position: others.isEmpty ? 0 : others.last.position + 1,
        ),
      ),
    );
  }

  /// Saves an edited counter. Its history is untouched.
  Future<void> updateCounter(Counter counter) =>
      change((repo) => repo.saveCounter(counter));

  /// Deletes a counter and its history, handing both back so that
  /// [restoreCounter] can undo it.
  Future<DeletedCounter> deleteCounter(Counter counter) => change((repo) async {
    final events = await repo.events(counter.id);
    await repo.deleteCounter(counter.id);
    return (counter: counter, events: events);
  });

  /// Undoes [deleteCounter]: the counter returns to its place with every
  /// event it had.
  Future<void> restoreCounter(DeletedCounter deleted) =>
      change((repo) => repo.restoreCounter(deleted.counter, deleted.events));
}
