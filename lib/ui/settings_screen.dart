import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:countersink/data/backup.dart';
import 'package:countersink/data/importers.dart';
import 'package:countersink/export/events_csv.dart';
import 'package:countersink/models/counter.dart';
import 'package:countersink/services/app_info.dart';
import 'package:countersink/services/auto_backup.dart';
import 'package:countersink/services/document_service.dart';
import 'package:countersink/services/preferences.dart';
import 'package:countersink/ui/about_screen.dart';
import 'package:countersink/ui/counter_look.dart';
import 'package:countersink/ui/counter_store.dart';
import 'package:countersink/ui/dialogs.dart';
import 'package:countersink/ui/language.dart';
import 'package:countersink/ui/layout.dart';
import 'package:countersink/ui/receive_screen.dart';
import 'package:countersink/ui/section.dart';
import 'package:countersink/ui/send_screen.dart';
import 'package:countersink/ui/theme.dart';

/// Settings, laid out as the family's apps all do: titled sections of rows
/// on cards.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key, required this.store});

  final CounterStore store;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _documents = DocumentService();
  String? _version;
  String? _tileCounterId;
  bool _keepScreenOn = false;
  VolumeKeys _volumeKeys = VolumeKeys.off;
  final _autoBackup = AutoBackup();
  ({String uri, String name})? _backupFolder;
  bool _backupFailed = false;

  @override
  void initState() {
    super.initState();
    installedVersion().then((v) {
      if (mounted) setState(() => _version = v);
    });
    Preferences.keepScreenOn().then((on) {
      if (mounted) setState(() => _keepScreenOn = on);
    });
    Preferences.volumeKeys().then((keys) {
      if (mounted) setState(() => _volumeKeys = keys);
    });
    _loadAutoBackup();
    tileCounter().then((id) {
      if (mounted) setState(() => _tileCounterId = id);
    });
  }

  /// The counter the quick-settings tile adds to, if one is chosen and it
  /// still exists.
  Counter? get _tileCounter {
    final id = _tileCounterId;
    if (id == null) return null;
    // One that has since been made calculated has nothing to add to.
    return widget.store.counters.counters
        .where((c) => c.id == id && !c.calculated)
        .firstOrNull;
  }

  /// Off: straight to choosing a counter. On: what can be done about it.
  Future<void> _quickTileTapped() async {
    if (_tileCounter == null) return _chooseTileCounter();
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.swap_horiz),
              title: Text(context.l.chooseAnotherCounter),
              onTap: () => Navigator.pop(context, 'choose'),
            ),
            ListTile(
              leading: const Icon(Icons.block),
              title: Text(context.l.turnOff),
              onTap: () => Navigator.pop(context, 'off'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    switch (choice) {
      case 'choose':
        await _chooseTileCounter();
      case 'off':
        await setTileCounter(null);
        if (mounted) setState(() => _tileCounterId = null);
    }
  }

  /// Every counter that isn't archived, under its group, to pick the one
  /// the tile adds to. Then Android is asked to offer the tile; where it
  /// can't be asked, or says no, how to add it by hand is spelled out.
  Future<void> _chooseTileCounter() async {
    final counters = widget.store.counters;
    final current = _tileCounter?.id;
    final picked = await showDialog<Counter>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(context.l.chooseCounter),
        children: [
          for (final g in counters.groups)
            for (final c in counters.inGroup(g.id))
              // Not a calculated one: there is nothing on it to add to.
              if (!c.calculated)
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                  leading: SizedBox.square(
                    dimension: 28,
                    child: LookBox(look: lookOf(c), circle: true),
                  ),
                  title: Text(
                    c.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    g.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  selected: c.id == current,
                  onTap: () => Navigator.pop(context, c),
                ),
        ],
      ),
    );
    if (picked == null) return;
    await setTileCounter(picked.id);
    if (!mounted) return;
    setState(() => _tileCounterId = picked.id);
    final added = await addTile();
    if (!added && mounted) _say(context.l.quickTileHowTo);
  }

  Future<void> _loadAutoBackup() async {
    final folder = await Preferences.autoBackupFolder();
    final failed = await Preferences.autoBackupFailed();
    if (!mounted) return;
    setState(() {
      _backupFolder = folder;
      _backupFailed = failed;
    });
  }

  /// Writes one now, whether or not anything has changed, and says how it
  /// went.
  Future<void> _autoBackupNow() async {
    final ok = await _autoBackup.run(widget.store, evenIfUnchanged: true);
    await _loadAutoBackup();
    final folder = _backupFolder;
    if (!mounted || folder == null) return;
    _say(
      ok
          ? context.l.backedUpTo(folder.name)
          : context.l.autoBackupFailed(folder.name),
    );
  }

  Future<void> _chooseBackupFolder() async {
    final ({String uri, String name})? picked;
    try {
      picked = await _autoBackup.chooseFolder();
    } catch (_) {
      if (mounted) _say(context.l.couldNotOpen);
      return;
    }
    if (picked == null) return;
    // Straight away, so the folder is known to work and holds a backup.
    await _autoBackupNow();
  }

  /// Off: ask for a folder. On: back up now, change the folder, or turn
  /// it off.
  Future<void> _autoBackupTapped() async {
    if (_backupFolder == null) return _chooseBackupFolder();
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.save_alt),
              title: Text(context.l.backUpNow),
              onTap: () => Navigator.pop(context, 'now'),
            ),
            ListTile(
              leading: const Icon(Icons.folder_open),
              title: Text(context.l.chooseAnotherFolder),
              onTap: () => Navigator.pop(context, 'folder'),
            ),
            ListTile(
              leading: const Icon(Icons.block),
              title: Text(context.l.turnOff),
              onTap: () => Navigator.pop(context, 'off'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    switch (choice) {
      case 'now':
        await _autoBackupNow();
      case 'folder':
        await _chooseBackupFolder();
      case 'off':
        await _autoBackup.turnOff();
        await _loadAutoBackup();
    }
  }

  /// Midnight by name, any other hour as the phone writes times.
  String _hourName(BuildContext context, int hour) => hour == 0
      ? context.l.midnight
      : MaterialLocalizations.of(context).formatTimeOfDay(
          TimeOfDay(hour: hour, minute: 0),
          alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
        );

  /// Midnight through 11 in the morning: late enough for any night owl,
  /// and never so late that "the day before" stops making sense.
  Future<void> _chooseDayStart() async {
    final current = widget.store.dayStartHour;
    final hour = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(context.l.dayStartsAt),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text(
              context.l.dayStartsAtHint,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          for (var h = 0; h < 12; h++)
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              leading: Icon(
                h == current
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
              ),
              title: Text(_hourName(context, h)),
              selected: h == current,
              onTap: () => Navigator.pop(context, h),
            ),
        ],
      ),
    );
    if (hour == null || hour == current) return;
    await Preferences.setDayStartHour(hour);
    await widget.store.setDayStartHour(hour);
    if (mounted) setState(() {});
  }

  /// A weekday's name in the language on screen, [weekday] being 1 for
  /// Monday through 7 for Sunday.
  String _weekdayName(BuildContext context, int weekday) {
    final locale = Localizations.localeOf(context).toLanguageTag();
    // The first of January 2024 was a Monday. Many languages write days
    // without a capital, which looks wrong at the start of a row.
    return toBeginningOfSentenceCase(
      DateFormat.EEEE(locale).format(DateTime(2024, 1, weekday)),
    );
  }

  /// The three days a week begins on somewhere in the world.
  Future<void> _chooseWeekStart() async {
    final current = widget.store.weekStart;
    final day = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(context.l.weekStartsOn),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text(
              context.l.weekStartsOnHint,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          for (final d in const [
            DateTime.saturday,
            DateTime.sunday,
            DateTime.monday,
          ])
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              leading: Icon(
                d == current
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
              ),
              title: Text(_weekdayName(context, d)),
              selected: d == current,
              onTap: () => Navigator.pop(context, d),
            ),
        ],
      ),
    );
    if (day == null || day == current) return;
    await Preferences.setWeekStart(day);
    await widget.store.setWeekStart(day);
    if (mounted) setState(() {});
  }

  String _volumeName(BuildContext context, VolumeKeys keys) => switch (keys) {
    VolumeKeys.off => context.l.volumeOff,
    VolumeKeys.up => context.l.volumeUp,
    VolumeKeys.both => context.l.volumeBoth,
  };

  Future<void> _chooseVolumeKeys() async {
    final current = _volumeKeys;
    final keys = await showDialog<VolumeKeys>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(context.l.volumeKeys),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text(
              context.l.volumeKeysHint,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          for (final k in VolumeKeys.values)
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              leading: Icon(
                k == current
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
              ),
              title: Text(_volumeName(context, k)),
              selected: k == current,
              onTap: () => Navigator.pop(context, k),
            ),
        ],
      ),
    );
    if (keys == null || keys == current) return;
    await Preferences.setVolumeKeys(keys);
    if (mounted) setState(() => _volumeKeys = keys);
  }

  Future<void> _chooseLanguage() async {
    final current = chosenLanguage.value;
    final picked = await showDialog<(String?,)>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(context.l.language),
        children: [
          for (final (code, name) in [
            (null, context.l.sameAsPhone),
            for (final MapEntry(:key, :value) in languageNames.entries)
              (key, value),
          ])
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              leading: Icon(
                code == current
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
              ),
              title: Text(name),
              selected: code == current,
              onTap: () => Navigator.pop(context, (code,)),
            ),
        ],
      ),
    );
    if (picked == null) return;
    chosenLanguage.value = picked.$1;
    await Preferences.setLanguage(picked.$1);
  }

  String _themeName(BuildContext context, ThemeMode mode) => switch (mode) {
    ThemeMode.system => context.l.themeSystem,
    ThemeMode.light => context.l.themeLight,
    ThemeMode.dark => context.l.themeDark,
  };

  Future<void> _chooseTheme() async {
    final current = themeChoice.value;
    final mode = await showDialog<ThemeMode>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(context.l.theme),
        children: [
          for (final m in ThemeMode.values)
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              leading: Icon(
                m == current
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
              ),
              title: Text(_themeName(context, m)),
              selected: m == current,
              onTap: () => Navigator.pop(context, m),
            ),
        ],
      ),
    );
    if (mode == null || mode == current) return;
    themeChoice.value = mode;
    await Preferences.setThemeMode(mode.name);
  }

  Future<void> _openLink(String url) async {
    if (!await openInBrowser(url) && mounted) {
      _say(context.l.noBrowser(websiteLabel));
    }
  }

  void _say(String message) =>
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));

  Future<void> _backUp() async {
    final now = widget.store.now;
    final text = encodeBackup(await widget.store.exportData(), exportedAt: now);
    if (!mounted) return;
    await saveToFile(
      context,
      name: backupFileName(now),
      text: text,
      mimeType: 'application/json',
      done: context.l.backupSaved,
    );
  }

  Future<void> _exportCsv() async {
    final now = widget.store.now;
    final text = eventsCsv(
      await widget.store.exportData(),
      dayStartHour: widget.store.dayStartHour,
    );
    if (!mounted) return;
    await saveToFile(
      context,
      name: csvFileName(now),
      text: text,
      mimeType: 'text/csv',
      done: context.l.csvSaved,
    );
  }

  /// The three apps by the names they go by, which aren't translated.
  static const _appNames = {
    ImportSource.betterCounter: 'BetterCounter',
    ImportSource.counter: 'Counter',
    ImportSource.simpleCounter: 'Simple Counter',
  };

  /// Brings in counters from another app's file, as new groups beside what
  /// is here. Nothing is replaced, so it happens at once and offers Undo,
  /// which takes those groups away again.
  Future<void> _importFromApp() async {
    final source = await showDialog<ImportSource>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(context.l.importChooseApp),
        children: [
          for (final (app, hint) in [
            (ImportSource.betterCounter, context.l.importBetterCounterHint),
            (ImportSource.counter, context.l.importCounterHint),
            (ImportSource.simpleCounter, context.l.importSimpleCounterHint),
          ])
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24),
              title: Text(_appNames[app]!),
              subtitle: Text(hint),
              onTap: () => Navigator.pop(context, app),
            ),
        ],
      ),
    );
    if (source == null) return;
    final String? text;
    try {
      text = await _documents.open();
    } catch (_) {
      if (mounted) _say(context.l.couldNotOpen);
      return;
    }
    if (text == null || !mounted) return;
    final l = context.l;
    final Imported imported;
    try {
      imported = importFrom(
        source,
        text,
        now: widget.store.now,
        groupName: l.importedGroupName,
        colors: [for (final c in counterColors) c.toARGB32()],
      );
    } on ImportException catch (e) {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l.cantImport),
          content: Text(switch (e.problem) {
            ImportProblem.notThatApp => l.importNotFrom(_appNames[source]!),
            ImportProblem.empty => l.importEmpty,
            ImportProblem.countersinkBackup => l.importIsBackup(l.restore),
          }),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l.ok),
            ),
          ],
        ),
      );
      return;
    }
    final store = widget.store;
    final added = await store.addImported(imported);
    if (!mounted) return;
    final summary = l.importDone(
      l.countersCount(imported.counters.length),
      l.entriesCount(imported.events.length),
    );
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          // Goes after its time like any other message. Left to itself, one
          // with a button now stays until it is dismissed.
          persist: false,
          content: Text(
            imported.skipped == 0
                ? summary
                : '$summary ${l.importSkipped(imported.skipped)}',
          ),
          duration: const Duration(seconds: 10),
          action: SnackBarAction(
            label: l.undo,
            onPressed: () async {
              for (final g in added) {
                await store.deleteGroup(g);
              }
            },
          ),
        ),
      );
  }

  /// Scans another phone's codes and adds what they hold beside what is
  /// here, as new groups. Like an import it only adds, so it happens at once
  /// and offers Undo.
  Future<void> _receive() async {
    final received = await Navigator.push<BackupData>(
      context,
      MaterialPageRoute(builder: (_) => const ReceiveScreen()),
    );
    if (received == null || !mounted) return;
    final l = context.l;
    final imported = importBackup(received);
    if (imported.counters.isEmpty) {
      _say(l.importEmpty);
      return;
    }
    final store = widget.store;
    final added = await store.addImported(imported);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          // Goes after its time like any other message. Left to itself, one
          // with a button now stays until it is dismissed.
          persist: false,
          content: Text(
            l.receivedDone(
              l.countersCount(imported.counters.length),
              l.entriesCount(imported.events.length),
            ),
          ),
          duration: const Duration(seconds: 10),
          action: SnackBarAction(
            label: l.undo,
            onPressed: () async {
              for (final g in added) {
                await store.deleteGroup(g);
              }
            },
          ),
        ),
      );
  }

  Future<void> _restore() async {
    final String? text;
    try {
      text = await _documents.open();
    } catch (_) {
      if (mounted) _say(context.l.couldNotOpen);
      return;
    }
    if (text == null || !mounted) return;
    final l = context.l;
    final BackupData backup;
    try {
      backup = decodeBackup(text);
    } on BackupFormatException catch (e) {
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l.cantRestore),
          content: Text(switch (e.problem) {
            BackupProblem.notCountersink => l.backupNotCountersink,
            BackupProblem.tooNew => l.backupTooNew,
            BackupProblem.damaged => l.backupDamaged(e.detail ?? ''),
          }),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l.ok),
            ),
          ],
        ),
      );
      return;
    }
    if (!mounted) return;
    // Asked first, unlike a delete: this shows what the file holds before
    // it replaces everything, which Undo could not do.
    final ok = await confirmAction(
      context,
      title: l.restoreTitle,
      message: l.restoreMessage(
        l.groupsCount(backup.groups.length),
        l.countersCount(backup.counters.length),
        l.entriesCount(backup.events.length),
      ),
      action: l.replace,
    );
    if (!ok) return;
    await widget.store.restore(backup);
    await Preferences.setDayStartHour(widget.store.dayStartHour);
    // Only a file that says which day keeps this phone from going by its
    // own region.
    if (backup.weekStart != null) {
      await Preferences.setWeekStart(widget.store.weekStart);
    }
    if (mounted) {
      setState(() {});
      _say(l.restored);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.settings)),
      body: ListView(
        padding: readablePadding(
          context,
          base: const EdgeInsets.only(bottom: 32),
        ),
        children: [
          Section(
            title: l.sectionCounting,
            children: [
              ListTile(
                leading: const Icon(Icons.bedtime_outlined),
                title: Text(l.dayStartsAt),
                subtitle: Text(_hourName(context, widget.store.dayStartHour)),
                onTap: _chooseDayStart,
              ),
              ListTile(
                leading: const Icon(Icons.date_range_outlined),
                title: Text(l.weekStartsOn),
                subtitle: Text(_weekdayName(context, widget.store.weekStart)),
                onTap: _chooseWeekStart,
              ),
              SwitchListTile(
                secondary: const Icon(Icons.light_mode_outlined),
                title: Text(l.keepScreenOn),
                subtitle: Text(l.keepScreenOnHint),
                value: _keepScreenOn,
                onChanged: (on) async {
                  setState(() => _keepScreenOn = on);
                  await Preferences.setKeepScreenOn(on);
                  await keepScreenOn(on);
                },
              ),
              ListTile(
                leading: const Icon(Icons.volume_up_outlined),
                title: Text(l.volumeKeys),
                subtitle: Text(_volumeName(context, _volumeKeys)),
                onTap: _chooseVolumeKeys,
              ),
              ListTile(
                leading: const Icon(Icons.dashboard_customize_outlined),
                title: Text(l.quickTile),
                subtitle: Text(
                  _tileCounter == null
                      ? l.quickTileHint
                      : l.quickTileOn(_tileCounter!.name),
                ),
                onTap: _quickTileTapped,
              ),
            ],
          ),
          Section(
            title: l.sectionAppearance,
            children: [
              ListTile(
                leading: const Icon(Icons.contrast),
                title: Text(l.theme),
                subtitle: Text(_themeName(context, themeChoice.value)),
                onTap: _chooseTheme,
              ),
            ],
          ),
          Section(
            title: l.language,
            children: [
              ListTile(
                leading: const Icon(Icons.translate),
                title: Text(l.language),
                subtitle: Text(
                  chosenLanguage.value == null
                      ? l.sameAsPhoneNow(
                          languageNames[l.localeName] ?? l.localeName,
                        )
                      : languageNames[chosenLanguage.value] ??
                            chosenLanguage.value!,
                ),
                onTap: _chooseLanguage,
              ),
            ],
          ),
          Section(
            title: l.yourData,
            children: [
              ListTile(
                leading: const Icon(Icons.save_alt),
                title: Text(l.backUp),
                subtitle: Text(l.backUpHint),
                onTap: _backUp,
              ),
              ListTile(
                leading: const Icon(Icons.restore),
                title: Text(l.restore),
                subtitle: Text(l.restoreHint),
                onTap: _restore,
              ),
              ListTile(
                leading: const Icon(Icons.table_chart_outlined),
                title: Text(l.exportCsv),
                subtitle: Text(l.exportCsvHint),
                onTap: _exportCsv,
              ),
              ListTile(
                leading: const Icon(Icons.qr_code_2),
                title: Text(l.sendToPhone),
                subtitle: Text(l.sendToPhoneHint),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SendScreen(store: widget.store),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.qr_code_scanner),
                title: Text(l.receiveFromPhone),
                subtitle: Text(l.receiveFromPhoneHint),
                onTap: _receive,
              ),
              ListTile(
                leading: const Icon(Icons.move_to_inbox_outlined),
                title: Text(l.importFromApp),
                subtitle: Text(l.importFromAppHint),
                onTap: _importFromApp,
              ),
              ListTile(
                leading: Icon(
                  Icons.sync,
                  color: _backupFailed ? theme.colorScheme.error : null,
                ),
                title: Text(l.autoBackup),
                subtitle: Text(
                  _backupFolder == null
                      ? l.autoBackupHint
                      : _backupFailed
                      ? l.autoBackupFailed(_backupFolder!.name)
                      : l.autoBackupTo(_backupFolder!.name),
                  style: _backupFailed
                      ? TextStyle(color: theme.colorScheme.error)
                      : null,
                ),
                onTap: _autoBackupTapped,
              ),
            ],
          ),
          Section(
            title: l.about,
            children: [
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(l.aboutCountersink),
                subtitle: Text(l.aboutCountersinkHint),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AboutScreen(version: _version),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.public),
                title: Text(l.website),
                subtitle: const Text(websiteLabel),
                trailing: const Icon(Icons.open_in_new),
                onTap: () => _openLink(websiteUrl),
              ),
              ListTile(
                leading: const Icon(Icons.feedback_outlined),
                title: Text(l.sendFeedback),
                subtitle: Text(l.sendFeedbackHint),
                trailing: const Icon(Icons.open_in_new),
                onTap: () => _openLink(feedbackUrl),
              ),
              if (_version != null)
                ListTile(title: Text(l.version), subtitle: Text(_version!)),
            ],
          ),
        ],
      ),
    );
  }
}
