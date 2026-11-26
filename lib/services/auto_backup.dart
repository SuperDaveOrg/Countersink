import 'package:countersink/data/backup.dart';
import 'package:countersink/services/document_service.dart';
import 'package:countersink/services/preferences.dart';
import 'package:countersink/ui/counter_store.dart';

/// Keeps a backup in a folder the user chose, without being asked each
/// time: written when the app is left, if anything has changed since the
/// last one. One file a day, the newest [keepDays] kept.
///
/// The folder is on the phone like any other. Whether a sync app copies it
/// somewhere else is the user's own arrangement; Countersink still has no
/// way to send anything anywhere.
class AutoBackup {
  AutoBackup({DocumentService? documents})
    : _documents = documents ?? DocumentService();

  final DocumentService _documents;

  /// How many days' files are kept in the folder.
  static const keepDays = 7;

  /// What every automatic backup's file name starts with. Only files with
  /// this prefix are ever replaced or deleted.
  static const prefix = 'countersink-auto-';

  /// "countersink-auto-2026-11-22.json"
  static String fileName(DateTime day) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '$prefix${day.year}-${two(day.month)}-${two(day.day)}.json';
  }

  /// Writes a backup now if a folder is set and [store] has changed since
  /// the last one, or regardless when [evenIfUnchanged]. True if one was
  /// written. A failure is remembered for Settings to show, not thrown:
  /// this runs as the app is being left, with nobody to tell.
  Future<bool> run(CounterStore store, {bool evenIfUnchanged = false}) async {
    final folder = await Preferences.autoBackupFolder();
    if (folder == null) return false;
    if (!store.changedSinceBackup && !evenIfUnchanged) return false;
    final now = store.now;
    try {
      await _documents.writeToFolder(
        folder.uri,
        name: fileName(now),
        text: encodeBackup(await store.exportData(), exportedAt: now),
        prefix: prefix,
        keep: keepDays,
      );
      store.markBackedUp();
      await Preferences.setAutoBackupFailed(false);
      return true;
    } catch (_) {
      await Preferences.setAutoBackupFailed(true);
      return false;
    }
  }

  /// Asks for a folder and remembers it. Null if the user backed out.
  Future<({String uri, String name})?> chooseFolder() async {
    final picked = await _documents.pickFolder();
    if (picked == null) return null;
    final old = await Preferences.autoBackupFolder();
    if (old != null && old.uri != picked.uri) {
      await _documents.releaseFolder(old.uri);
    }
    await Preferences.setAutoBackupFolder(picked);
    await Preferences.setAutoBackupFailed(false);
    return picked;
  }

  /// Stops automatic backups and gives the folder back. The files already
  /// in it stay.
  Future<void> turnOff() async {
    final folder = await Preferences.autoBackupFolder();
    if (folder == null) return;
    await _documents.releaseFolder(folder.uri);
    await Preferences.setAutoBackupFolder(null);
    await Preferences.setAutoBackupFailed(false);
  }
}
