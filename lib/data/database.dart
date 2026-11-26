import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// The on-device SQLite database.
///
/// This file is the whole of Countersink's storage. There is no server, no
/// account and no sync: that is a design commitment, not an unfinished
/// feature.
class CountersinkDatabase {
  /// [path] and [factory] exist for tests, which run against SQLite on the
  /// host; the app always uses [instance].
  CountersinkDatabase({this._path, this._factory});

  static final CountersinkDatabase instance = CountersinkDatabase();

  static const _fileName = 'countersink.db';
  static const version = 8;

  final String? _path;
  final DatabaseFactory? _factory;
  Database? _db;

  Future<Database> get database async => _db ??= await _open();

  Future<Database> _open() async {
    final factory = _factory ?? databaseFactory;
    final path = _path ?? p.join(await factory.getDatabasesPath(), _fileName);
    return factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: version,
        onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
        onCreate: _create,
        onUpgrade: _upgrade,
      ),
    );
  }

  /// A fresh install builds the version-1 schema and then replays every
  /// migration, so new and upgraded phones cannot drift apart.
  Future<void> _create(Database db, int version) async {
    await createVersion1(db);
    await _upgrade(db, 1, version);
  }

  /// The schema as version 1 ships it. Once released, never edit this; add a
  /// version to [_upgrade]. Public only so tests can build an old database
  /// to upgrade.
  @visibleForTesting
  static Future<void> createVersion1(Database db) async {
    await db.execute('''
      CREATE TABLE counter_groups (
        id       TEXT PRIMARY KEY,
        name     TEXT NOT NULL,
        position INTEGER NOT NULL
      )
    ''');
    // color is 0xAARRGGBB. A counter has no value column: its value is the
    // sum of its events.
    await db.execute('''
      CREATE TABLE counters (
        id          TEXT PRIMARY KEY,
        group_id    TEXT NOT NULL
                    REFERENCES counter_groups(id) ON DELETE CASCADE,
        name        TEXT NOT NULL,
        description TEXT,
        color       INTEGER NOT NULL,
        step        INTEGER NOT NULL DEFAULT 1,
        daily       INTEGER NOT NULL DEFAULT 0,
        position    INTEGER NOT NULL
      )
    ''');
    // One row per change, and the only record of any count. at is UTC
    // milliseconds; delta is negative for a minus. kind says why: 'tap',
    // 'set' (a value typed in) or 'reset'.
    await db.execute('''
      CREATE TABLE events (
        id         TEXT PRIMARY KEY,
        counter_id TEXT NOT NULL
                   REFERENCES counters(id) ON DELETE CASCADE,
        at         INTEGER NOT NULL,
        delta      INTEGER NOT NULL,
        kind       TEXT NOT NULL DEFAULT 'tap'
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_counters_group ON counters(group_id, position)',
    );
    await db.execute(
      'CREATE INDEX idx_events_counter ON events(counter_id, at)',
    );
  }

  /// Each step brings a database from the previous version to the next, so a
  /// phone that skipped several releases replays them in order.
  Future<void> _upgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // A card's look beyond one color: a second color to blend into, and
      // a pattern drawn over it.
      await db.execute('ALTER TABLE counters ADD COLUMN color2 INTEGER');
      await db.execute(
        "ALTER TABLE counters ADD COLUMN pattern TEXT NOT NULL DEFAULT 'none'",
      );
    }
    if (oldVersion < 3) {
      // A number to reach; null for none.
      await db.execute('ALTER TABLE counters ADD COLUMN goal INTEGER');
    }
    if (oldVersion < 4) {
      // Put away off its tab, but kept.
      await db.execute(
        'ALTER TABLE counters ADD COLUMN archived INTEGER NOT NULL DEFAULT 0',
      );
    }
    if (oldVersion < 5) {
      // Whether a per-day counter's goal is for the day or the week, and a
      // buzz on every so-many counts; null for none.
      await db.execute(
        "ALTER TABLE counters ADD COLUMN goal_period TEXT NOT NULL DEFAULT 'day'",
      );
      await db.execute('ALTER TABLE counters ADD COLUMN buzz_every INTEGER');
    }
    if (oldVersion < 6) {
      // A counter worked out from others: how, from which (a JSON list of
      // ids) and, for rounds, of what size. All null for an ordinary one.
      await db.execute('ALTER TABLE counters ADD COLUMN formula TEXT');
      await db.execute('ALTER TABLE counters ADD COLUMN sources TEXT');
      await db.execute('ALTER TABLE counters ADD COLUMN round_size INTEGER');
    }
    if (oldVersion < 7) {
      // Whether a calculated counter takes everything its per-day counters
      // have ever counted, not just today: a running total.
      await db.execute(
        'ALTER TABLE counters ADD COLUMN all_time INTEGER NOT NULL DEFAULT 0',
      );
    }
    if (oldVersion < 8) {
      // A number a calculated total already stood at; null for none.
      await db.execute('ALTER TABLE counters ADD COLUMN start_from INTEGER');
    }
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
