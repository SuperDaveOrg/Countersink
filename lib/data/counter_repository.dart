import 'package:sqflite/sqflite.dart';

import 'package:countersink/data/database.dart';
import 'package:countersink/data/ids.dart';
import 'package:countersink/domain/dates.dart';
import 'package:countersink/models/counter.dart';
import 'package:countersink/models/counter_group.dart';
import 'package:countersink/models/counters_snapshot.dart';
import 'package:countersink/models/tap_event.dart';

/// Every read and write of groups, counters and their events.
class CounterRepository {
  CounterRepository({CountersinkDatabase? db})
    : _database = db ?? CountersinkDatabase.instance;

  final CountersinkDatabase _database;

  /// Everything on screen, with each counter's total and its totals for
  /// the counting day and the week [now] falls in.
  Future<CountersSnapshot> snapshot({
    required DateTime now,
    int dayStartHour = 0,
    int weekStart = DateTime.monday,
  }) async {
    final db = await _database.database;
    final today = countingDay(now, dayStartHour: dayStartHour);
    final day = dayBounds(today, dayStartHour: dayStartHour);
    // The week begins when its first counting day does.
    final weekBegins = dayBounds(
      weekOf(today, weekStart: weekStart),
      dayStartHour: dayStartHour,
    ).start;
    return db.transaction((txn) async {
      final groups = await txn.query(
        'counter_groups',
        orderBy: 'position, name',
      );
      final counters = await txn.query('counters', orderBy: 'position, name');
      final totals = await txn.rawQuery(
        'SELECT counter_id, SUM(delta) AS total FROM events GROUP BY counter_id',
      );
      final todays = await txn.rawQuery(
        'SELECT counter_id, SUM(delta) AS total FROM events '
        'WHERE at >= ? AND at < ? GROUP BY counter_id',
        [
          day.start.toUtc().millisecondsSinceEpoch,
          day.end.toUtc().millisecondsSinceEpoch,
        ],
      );
      final week = await txn.rawQuery(
        'SELECT counter_id, SUM(delta) AS total FROM events '
        'WHERE at >= ? AND at < ? GROUP BY counter_id',
        [
          weekBegins.toUtc().millisecondsSinceEpoch,
          day.end.toUtc().millisecondsSinceEpoch,
        ],
      );
      Map<String, int> byCounter(List<Map<String, Object?>> rows) => {
        for (final r in rows) r['counter_id'] as String: r['total'] as int,
      };
      return CountersSnapshot(
        groups: groups.map(CounterGroup.fromRow).toList(),
        counters: counters.map(Counter.fromRow).toList(),
        totals: byCounter(totals),
        today: byCounter(todays),
        week: byCounter(week),
      );
    });
  }

  /// Adds [group], or updates it if its id is already there.
  Future<void> saveGroup(CounterGroup group) async =>
      _save('counter_groups', group.toRow());

  /// Adds [counter], or updates it if its id is already there. Its events
  /// are left alone.
  Future<void> saveCounter(Counter counter) async =>
      _save('counters', counter.toRow());

  /// Update first, insert only if nothing was there: SQLite's "replace"
  /// would delete the old row, and the events hanging off it with it.
  Future<void> _save(String table, Map<String, Object?> row) async {
    final db = await _database.database;
    await db.transaction((txn) async {
      final updated = await txn.update(
        table,
        row,
        where: 'id = ?',
        whereArgs: [row['id']],
      );
      if (updated == 0) await txn.insert(table, row);
    });
  }

  /// Removes a group, its counters and every event they ever had.
  Future<void> deleteGroup(String id) async {
    final db = await _database.database;
    await db.delete('counter_groups', where: 'id = ?', whereArgs: [id]);
  }

  /// Puts back a group that [deleteGroup] removed, with its [counters] and
  /// each one's events, keyed by counter id.
  Future<void> restoreGroup(
    CounterGroup group,
    List<Counter> counters,
    Map<String, List<TapEvent>> events,
  ) async {
    final db = await _database.database;
    await db.transaction((txn) async {
      await txn.insert('counter_groups', group.toRow());
      final batch = txn.batch();
      for (final c in counters) {
        batch.insert('counters', c.toRow());
        for (final e in events[c.id] ?? const <TapEvent>[]) {
          batch.insert('events', e.toRow());
        }
      }
      await batch.commit(noResult: true);
    });
  }

  /// Sets the order of the tabs to [ids], first to last.
  Future<void> reorderGroups(List<String> ids) async {
    final db = await _database.database;
    await db.transaction((txn) async {
      for (var i = 0; i < ids.length; i++) {
        await txn.update(
          'counter_groups',
          {'position': i},
          where: 'id = ?',
          whereArgs: [ids[i]],
        );
      }
    });
  }

  /// Sets the order of counters to [ids], first to last. For one group's
  /// counters; the others are left where they are.
  Future<void> reorderCounters(List<String> ids) async {
    final db = await _database.database;
    await db.transaction((txn) async {
      for (var i = 0; i < ids.length; i++) {
        await txn.update(
          'counters',
          {'position': i},
          where: 'id = ?',
          whereArgs: [ids[i]],
        );
      }
    });
  }

  /// Removes a counter and every event it ever had.
  Future<void> deleteCounter(String id) async {
    final db = await _database.database;
    await db.delete('counters', where: 'id = ?', whereArgs: [id]);
  }

  /// Puts back a counter that [deleteCounter] removed, with its [events].
  Future<void> restoreCounter(Counter counter, List<TapEvent> events) async {
    final db = await _database.database;
    await db.transaction((txn) async {
      await txn.insert('counters', counter.toRow());
      final batch = txn.batch();
      for (final e in events) {
        batch.insert('events', e.toRow());
      }
      await batch.commit(noResult: true);
    });
  }

  /// Records one change of [delta] to a counter, at the moment [at].
  Future<TapEvent> record(
    String counterId,
    int delta, {
    required DateTime at,
    EventKind kind = EventKind.tap,
  }) async {
    final event = TapEvent(
      id: newId(),
      counterId: counterId,
      at: at.toUtc(),
      delta: delta,
      kind: kind,
    );
    final db = await _database.database;
    await db.insert(
      'events',
      event.toRow(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
    return event;
  }

  /// Takes back one event, as if it had never been recorded.
  Future<void> undo(String eventId) async {
    final db = await _database.database;
    await db.delete('events', where: 'id = ?', whereArgs: [eventId]);
  }

  /// Every event of every counter, oldest first: what a backup holds.
  Future<List<TapEvent>> allEvents() async {
    final db = await _database.database;
    final rows = await db.query('events', orderBy: 'at, rowid');
    return rows.map(TapEvent.fromRow).toList();
  }

  /// Replaces everything with [groups], [counters] and [events], in one
  /// step: it all goes in, or nothing changes. For restoring a backup.
  Future<void> replaceAll(
    List<CounterGroup> groups,
    List<Counter> counters,
    List<TapEvent> events,
  ) async {
    final db = await _database.database;
    await db.transaction((txn) async {
      // Children first; cascades would do it, but this doesn't rely on them.
      await txn.delete('events');
      await txn.delete('counters');
      await txn.delete('counter_groups');
      final batch = txn.batch();
      for (final g in groups) {
        batch.insert('counter_groups', g.toRow());
      }
      for (final c in counters) {
        batch.insert('counters', c.toRow());
      }
      for (final e in events) {
        batch.insert('events', e.toRow());
      }
      await batch.commit(noResult: true);
    });
  }

  /// Changes when an event happened and by how much; which counter it
  /// belongs to and why it was made stay as they were.
  Future<void> updateEvent(TapEvent event) async {
    final db = await _database.database;
    await db.update(
      'events',
      {'at': event.at.toUtc().millisecondsSinceEpoch, 'delta': event.delta},
      where: 'id = ?',
      whereArgs: [event.id],
    );
  }

  /// Puts back an event that [undo] removed.
  Future<void> restoreEvent(TapEvent event) async {
    final db = await _database.database;
    await db.insert('events', event.toRow());
  }

  /// A counter's whole history, oldest first.
  Future<List<TapEvent>> events(String counterId) async {
    final db = await _database.database;
    final rows = await db.query(
      'events',
      where: 'counter_id = ?',
      whereArgs: [counterId],
      orderBy: 'at, rowid',
    );
    return rows.map(TapEvent.fromRow).toList();
  }
}
