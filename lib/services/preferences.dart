import 'package:shared_preferences/shared_preferences.dart';

import 'package:countersink/services/app_info.dart';

/// Small choices remembered on the phone. Nothing here is a count; those
/// all live in the database.
class Preferences {
  static const _kDayStartHour = 'day_start_hour';
  static const _kWeekStart = 'week_start';
  static const _kKeepScreenOn = 'keep_screen_on';
  static const _kThemeMode = 'theme_mode';
  static const _kVolumeKeys = 'volume_keys';
  static const _kLanguage = 'language';
  static const _kBackupFolder = 'auto_backup_folder';
  static const _kBackupFolderName = 'auto_backup_folder_name';
  static const _kBackupFailed = 'auto_backup_failed';

  /// The folder automatic backups go to, as Android names it and as the
  /// user knows it. Null when automatic backups are off.
  static Future<({String uri, String name})?> autoBackupFolder() async {
    final prefs = await SharedPreferences.getInstance();
    final uri = prefs.getString(_kBackupFolder);
    if (uri == null) return null;
    return (uri: uri, name: prefs.getString(_kBackupFolderName) ?? '');
  }

  static Future<void> setAutoBackupFolder(
    ({String uri, String name})? folder,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    if (folder == null) {
      await prefs.remove(_kBackupFolder);
      await prefs.remove(_kBackupFolderName);
    } else {
      await prefs.setString(_kBackupFolder, folder.uri);
      await prefs.setString(_kBackupFolderName, folder.name);
    }
  }

  /// Whether the last automatic backup couldn't be written.
  static Future<bool> autoBackupFailed() async =>
      (await SharedPreferences.getInstance()).getBool(_kBackupFailed) ?? false;

  static Future<void> setAutoBackupFailed(bool failed) async =>
      (await SharedPreferences.getInstance()).setBool(_kBackupFailed, failed);

  /// The language picked in Settings, or null to follow the phone.
  static Future<String?> language() async =>
      (await SharedPreferences.getInstance()).getString(_kLanguage);

  static Future<void> setLanguage(String? code) async {
    final prefs = await SharedPreferences.getInstance();
    if (code == null) {
      await prefs.remove(_kLanguage);
    } else {
      await prefs.setString(_kLanguage, code);
    }
  }

  /// Which volume buttons count in full screen. Neither, until chosen.
  static Future<VolumeKeys> volumeKeys() async =>
      VolumeKeys.values.asNameMap()[(await SharedPreferences.getInstance())
          .getString(_kVolumeKeys)] ??
      VolumeKeys.off;

  static Future<void> setVolumeKeys(VolumeKeys keys) async =>
      (await SharedPreferences.getInstance()).setString(
        _kVolumeKeys,
        keys.name,
      );

  /// "light", "dark", or "system" to follow the phone, which it does until
  /// one is chosen.
  static Future<String> themeMode() async =>
      (await SharedPreferences.getInstance()).getString(_kThemeMode) ??
      'system';

  static Future<void> setThemeMode(String mode) async =>
      (await SharedPreferences.getInstance()).setString(_kThemeMode, mode);

  /// Whether the screen stays on while the app is in front. Off until
  /// chosen.
  static Future<bool> keepScreenOn() async =>
      (await SharedPreferences.getInstance()).getBool(_kKeepScreenOn) ?? false;

  static Future<void> setKeepScreenOn(bool on) async =>
      (await SharedPreferences.getInstance()).setBool(_kKeepScreenOn, on);

  /// The day a week begins on, 1 for Monday through 7 for Sunday, or null
  /// until one is chosen: the phone's own region then decides.
  static Future<int?> weekStart() async {
    final day = (await SharedPreferences.getInstance()).getInt(_kWeekStart);
    return day != null && day >= 1 && day <= 7 ? day : null;
  }

  static Future<void> setWeekStart(int weekday) async =>
      (await SharedPreferences.getInstance()).setInt(_kWeekStart, weekday);

  /// The hour a counting day begins; 0, midnight, until one is chosen.
  static Future<int> dayStartHour() async =>
      (await SharedPreferences.getInstance()).getInt(_kDayStartHour) ?? 0;

  static Future<void> setDayStartHour(int hour) async =>
      (await SharedPreferences.getInstance()).setInt(_kDayStartHour, hour);
}
