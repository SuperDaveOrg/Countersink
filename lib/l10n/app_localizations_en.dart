// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Countersink';

  @override
  String get addCounter => 'Add counter';

  @override
  String get counterName => 'Name';

  @override
  String get counterDescription => 'Description (optional)';

  @override
  String get countPerDay => 'Count per day';

  @override
  String get countPerDayHint =>
      'Shows today\'s total and starts from zero each day. Past days are kept.';

  @override
  String get cancel => 'Cancel';

  @override
  String get add => 'Add';

  @override
  String get today => 'today';

  @override
  String get noCounters => 'No counters here yet.';

  @override
  String increment(int step, String name) {
    return 'Add $step to $name';
  }

  @override
  String decrement(int step, String name) {
    return 'Take $step from $name';
  }

  @override
  String get firstGroupName => 'Counters';

  @override
  String get firstCounterName => 'My first counter';

  @override
  String get firstCounterDescription =>
      'Tap + to count. Press and hold to edit.';

  @override
  String get settings => 'Settings';

  @override
  String get about => 'About';

  @override
  String get aboutCountersink => 'About Countersink';

  @override
  String get aboutCountersinkHint =>
      'Where your counts live, and why it\'s free';

  @override
  String get aboutHeadline => 'Your counts stay with you.';

  @override
  String get aboutIntro =>
      'Countersink keeps count of anything: reps, rows, scores, stock.';

  @override
  String get aboutStaysTitle => 'It stays on your phone';

  @override
  String get aboutStaysBody =>
      'Every count is written to a database on this device. There is no account and no server. It only goes anywhere else if you move it yourself, as a backup file.';

  @override
  String get aboutCannotSeeTitle => 'We cannot see it';

  @override
  String get aboutCannotSeeBody =>
      'Countersink is built without permission to use the internet at all. Android enforces that, and you can check it in the app\'s permission list.';

  @override
  String get aboutNoAdsTitle => 'No ads, ever';

  @override
  String get aboutNoAdsBody =>
      'Counting should never be interrupted. Countersink will always be free and open source: no ads, no price, no premium tier.';

  @override
  String get aboutCheckTitle => 'You can check our work';

  @override
  String get aboutCheckBody =>
      'Countersink is open source under the GNU General Public License. Anyone can read exactly what it does.';

  @override
  String get aboutTradeOff =>
      'One trade-off worth knowing: there is no cloud copy, so a lost or wiped phone means lost counts. Save a backup file from Settings now and then, and keep it somewhere other than this phone.';

  @override
  String get version => 'Version';

  @override
  String get website => 'Website';

  @override
  String get sendFeedback => 'Send feedback';

  @override
  String get sendFeedbackHint => 'A form on the website, in your browser.';

  @override
  String noBrowser(String website) {
    return 'No browser to open it with. Visit $website instead.';
  }

  @override
  String versionNumber(String version) {
    return 'Version $version';
  }

  @override
  String get editCounter => 'Edit counter';

  @override
  String get edit => 'Edit';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get undo => 'Undo';

  @override
  String counterDeleted(String name) {
    return 'Deleted $name';
  }

  @override
  String get counterColor => 'Color';

  @override
  String get colorClay => 'Clay';

  @override
  String get colorTeal => 'Teal';

  @override
  String get colorNavy => 'Navy';

  @override
  String get colorLavender => 'Lavender';

  @override
  String get colorGreen => 'Green';

  @override
  String get colorCustom => 'Custom';

  @override
  String get groups => 'Groups';

  @override
  String get addGroup => 'Add group';

  @override
  String get renameGroup => 'Rename group';

  @override
  String get groupName => 'Name';

  @override
  String countersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count counters',
      one: '1 counter',
      zero: 'No counters',
    );
    return '$_temp0';
  }

  @override
  String deleteNamed(String name) {
    return 'Delete $name';
  }

  @override
  String groupDeleted(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Deleted $name and its $count counters',
      one: 'Deleted $name and its counter',
      zero: 'Deleted $name',
    );
    return '$_temp0';
  }

  @override
  String get lastGroupHint => 'The last group can\'t be deleted.';

  @override
  String get counterStep => 'Step';

  @override
  String get counterStepHint => 'How much each press of + or − counts.';

  @override
  String get addAmount => 'Add an amount';

  @override
  String addAmountTitle(String name) {
    return 'Add to $name';
  }

  @override
  String takeAmountTitle(String name) {
    return 'Take from $name';
  }

  @override
  String get amount => 'Amount';

  @override
  String get takeAway => 'Take away';

  @override
  String get setValue => 'Set value';

  @override
  String get value => 'Value';

  @override
  String get set => 'Set';

  @override
  String get resetToZero => 'Reset to zero';

  @override
  String counterReset(String name) {
    return '$name reset to zero';
  }

  @override
  String get history => 'History';

  @override
  String get historyEmpty => 'Nothing counted yet.';

  @override
  String get dayToday => 'Today';

  @override
  String get dayYesterday => 'Yesterday';

  @override
  String entriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entries',
      one: '1 entry',
    );
    return '$_temp0';
  }

  @override
  String get allTime => 'All time';

  @override
  String get sectionCounting => 'Counting';

  @override
  String get dayStartsAt => 'Day starts at';

  @override
  String get dayStartsAtHint =>
      'Anything counted before this hour belongs to the day before.';

  @override
  String get midnight => 'Midnight';

  @override
  String get yourData => 'Your data';

  @override
  String get backUp => 'Back up to a file';

  @override
  String get backUpHint => 'Everything, saved wherever you choose.';

  @override
  String get restore => 'Restore from a backup';

  @override
  String get restoreHint => 'Replaces what\'s on this phone.';

  @override
  String get backupSaved => 'Backup saved';

  @override
  String get couldNotSave => 'Couldn\'t save the file.';

  @override
  String get couldNotOpen => 'Couldn\'t open that file.';

  @override
  String get cantRestore => 'Can\'t restore this file';

  @override
  String get ok => 'OK';

  @override
  String get restoreTitle => 'Replace everything with this backup?';

  @override
  String restoreMessage(String groups, String counters, String entries) {
    return 'It has $groups, $counters and $entries. Everything now on this phone will be replaced by it.';
  }

  @override
  String groupsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count groups',
      one: '1 group',
    );
    return '$_temp0';
  }

  @override
  String get replace => 'Replace';

  @override
  String get restored => 'Restored';

  @override
  String get backupNotCountersink => 'This isn\'t a Countersink backup.';

  @override
  String get backupTooNew =>
      'This backup was made by a newer version of Countersink. Update the app, then try again.';

  @override
  String backupDamaged(String detail) {
    return 'This backup has something wrong in it and wasn\'t restored. Nothing on this phone was changed.\n\n$detail';
  }

  @override
  String get colorBrick => 'Brick';

  @override
  String get colorOchre => 'Ochre';

  @override
  String get colorSand => 'Sand';

  @override
  String get colorOlive => 'Olive';

  @override
  String get colorSage => 'Sage';

  @override
  String get colorMoss => 'Moss';

  @override
  String get colorSlate => 'Slate';

  @override
  String get colorStorm => 'Storm';

  @override
  String get colorSky => 'Sky';

  @override
  String get colorPlum => 'Plum';

  @override
  String get colorRose => 'Rose';

  @override
  String get colorCocoa => 'Cocoa';

  @override
  String get colorCharcoal => 'Charcoal';

  @override
  String get colorAubergine => 'Aubergine';

  @override
  String get colorLinen => 'Linen';

  @override
  String get moreColors => 'More colors and patterns';

  @override
  String get appearanceTitle => 'Color and pattern';

  @override
  String get secondColor => 'Second color';

  @override
  String get secondColorHint => 'Blends into the first, from corner to corner.';

  @override
  String get noSecondColor => 'None';

  @override
  String get pattern => 'Pattern';

  @override
  String get patternNone => 'Plain';

  @override
  String get patternStripes => 'Stripes';

  @override
  String get patternDots => 'Dots';

  @override
  String get patternGrid => 'Grid';

  @override
  String get customColor => 'Custom color';

  @override
  String get hue => 'Hue';

  @override
  String get saturation => 'Saturation';

  @override
  String get brightness => 'Brightness';

  @override
  String get hexCode => 'Hex code';

  @override
  String get useColor => 'Use';

  @override
  String get done => 'Done';

  @override
  String get sampleCount => '12';

  @override
  String get reorderCounters => 'Reorder counters';

  @override
  String get moveToGroup => 'Move to another group';

  @override
  String moveToGroupTitle(String name) {
    return 'Move $name to';
  }

  @override
  String movedToGroup(String group) {
    return 'Moved to $group';
  }

  @override
  String get exportCsv => 'Export as a spreadsheet';

  @override
  String get exportCsvHint => 'Every entry as a CSV file, one row each.';

  @override
  String get csvSaved => 'Spreadsheet saved';

  @override
  String get keepScreenOn => 'Keep the screen on';

  @override
  String get keepScreenOnHint =>
      'While Countersink is open, the screen won\'t dim or lock.';

  @override
  String get sectionAppearance => 'Appearance';

  @override
  String get theme => 'Theme';

  @override
  String get themeSystem => 'Same as the phone';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get counterGoal => 'Goal (optional)';

  @override
  String get counterGoalHint =>
      'A number to reach. A counter that counts per day can aim for each day or for the week.';

  @override
  String goalOf(int goal) {
    return 'of $goal';
  }

  @override
  String get goalReached => 'Goal reached';

  @override
  String get dayStreak => 'Day streak';

  @override
  String get bestStreak => 'Best streak';

  @override
  String get previousMonth => 'Previous month';

  @override
  String get nextMonth => 'Next month';

  @override
  String daysCount(int count) {
    return '$count days';
  }

  @override
  String get averagePerDay => 'Average per day';

  @override
  String get totalInRange => 'Total';

  @override
  String get addEntry => 'Add entry';

  @override
  String get editEntry => 'Edit entry';

  @override
  String get entryAdded => 'Added';

  @override
  String get entryTaken => 'Taken away';

  @override
  String get entryTime => 'Time';

  @override
  String get entryDeleted => 'Entry deleted';

  @override
  String get belowZero => 'That would take the count below zero.';

  @override
  String get perDayRefused =>
      'This counter can\'t count per day yet. On at least one day in its history, more was taken away than was counted, so that day would be below zero. Correct it in History first.';

  @override
  String get noEntries => 'Nothing counted on this day.';

  @override
  String get dayTotal => 'Day\'s total';

  @override
  String get fullScreen => 'Full screen';

  @override
  String get tapAnywhere => 'Tap anywhere to count';

  @override
  String get closeFullScreen => 'Close full screen';

  @override
  String get volumeKeys => 'Volume buttons';

  @override
  String get volumeKeysHint =>
      'Count with the phone\'s volume buttons while a counter is in full screen.';

  @override
  String get volumeOff => 'Off';

  @override
  String get volumeUp => 'Volume up adds';

  @override
  String get volumeBoth => 'Up adds, down takes away';

  @override
  String get lockTouch => 'Lock touch';

  @override
  String get unlockTouch => 'Press and hold to unlock';

  @override
  String get touchLocked => 'Touch is locked. Count with the volume buttons.';

  @override
  String get volumeCounts => 'Tap anywhere or press a volume button to count';

  @override
  String get language => 'Language';

  @override
  String get sameAsPhone => 'Same as the phone';

  @override
  String sameAsPhoneNow(String language) {
    return 'Same as the phone: $language';
  }

  @override
  String get archive => 'Archive';

  @override
  String get unarchive => 'Move back to its group';

  @override
  String counterArchived(String name) {
    return 'Archived $name';
  }

  @override
  String get archivedCounters => 'Archived counters';

  @override
  String get noArchived => 'Nothing archived.';

  @override
  String get search => 'Search';

  @override
  String get searchHint => 'Search counters';

  @override
  String get noResults => 'No counters match.';

  @override
  String get searchPrompt =>
      'Type a counter\'s name, its description or its group.';

  @override
  String get autoBackup => 'Automatic backup';

  @override
  String get autoBackupHint =>
      'Off. Choose a folder to keep a backup in, saved each time you leave the app.';

  @override
  String autoBackupTo(String folder) {
    return 'To $folder, each time you leave the app. The last 7 days are kept.';
  }

  @override
  String autoBackupFailed(String folder) {
    return 'The last backup couldn\'t be saved to $folder. Choose the folder again.';
  }

  @override
  String get backUpNow => 'Back up now';

  @override
  String get chooseAnotherFolder => 'Choose another folder';

  @override
  String get turnOff => 'Turn off';

  @override
  String backedUpTo(String folder) {
    return 'Backed up to $folder';
  }

  @override
  String get goalForEach => 'The goal is for each';

  @override
  String get periodDay => 'Day';

  @override
  String get periodWeek => 'Week';

  @override
  String goalThisWeek(int done, int goal) {
    return '$done of $goal this week';
  }

  @override
  String get weekStreak => 'Week streak';

  @override
  String get buzzEvery => 'Buzz every (optional)';

  @override
  String get buzzEveryHint =>
      'A double buzz each time the count passes a multiple of this, such as every 10.';

  @override
  String get weekStartsOn => 'Week starts on';

  @override
  String get weekStartsOnHint =>
      'For goals that are for the week, and for the calendar.';

  @override
  String get addToHomeScreen => 'Add to home screen';

  @override
  String get quickTile => 'Quick settings tile';

  @override
  String get quickTileHint =>
      'Off. Choose a counter to add to from the phone\'s quick settings, without opening the app.';

  @override
  String quickTileOn(String name) {
    return 'Adds to $name, from the phone\'s quick settings.';
  }

  @override
  String get chooseCounter => 'Choose a counter';

  @override
  String get chooseAnotherCounter => 'Choose another counter';

  @override
  String get quickTileHowTo =>
      'To add the tile: open the phone\'s quick settings, tap the pencil, and drag in the Countersink tile.';

  @override
  String get calculated => 'Calculated from other counters';

  @override
  String get calculatedOff => 'Off. Counted by hand, with plus and minus.';

  @override
  String get formulaTitle => 'Calculated counter';

  @override
  String get formulaIntro =>
      'A calculated counter isn\'t counted on. It shows a number worked out from other counters, and keeps up as they change.';

  @override
  String get formulaNone => 'Counted by hand';

  @override
  String get formulaSum => 'A total';

  @override
  String get formulaSumHint => 'Several counters added up.';

  @override
  String get formulaDifference => 'A difference';

  @override
  String get formulaDifferenceHint =>
      'One counter, less the others. In, less out.';

  @override
  String get formulaPercent => 'A share, in percent';

  @override
  String get formulaPercentHint =>
      'One counter as a share of several together.';

  @override
  String get formulaEvery => 'Completed rounds';

  @override
  String get formulaEveryHint =>
      'How many times another counter has gone round: every 108 beads, every 8 rows.';

  @override
  String get sectionShows => 'What it shows';

  @override
  String get formulaAddUp => 'Add up';

  @override
  String get formulaStartWith => 'Start with';

  @override
  String get formulaTakeAway => 'Take away';

  @override
  String get formulaShareOf => 'The share of';

  @override
  String get formulaTogetherWith => 'In the total of it and';

  @override
  String get formulaRoundsOf => 'Rounds of';

  @override
  String get formulaAllTime => 'Keep a running total';

  @override
  String get formulaAllTimeHint =>
      'Per-day counters count for everything they have ever counted, not just today. They start each day from zero; this number carries on.';

  @override
  String get formulaStartFrom => 'Start from (optional)';

  @override
  String get formulaStartFromHint =>
      'A number the total already stands at, from before it was counted here. What is counted is added to it.';

  @override
  String get roundSize => 'One round is';

  @override
  String get roundSizeHint => 'How many make a round.';

  @override
  String lineSum(String names) {
    return 'Total of $names';
  }

  @override
  String lineDifference(String first, String others) {
    return '$first less $others';
  }

  @override
  String linePercent(String first, String all) {
    return '$first as a share of $all';
  }

  @override
  String lineEvery(int size, String name) {
    return 'Rounds of $size in $name';
  }

  @override
  String lineTowardNext(int count) {
    return '$count toward the next';
  }

  @override
  String get lineBroken => 'The counter it was worked out from is gone';

  @override
  String get noOrdinaryCounters =>
      'Add a counter to count by hand first. A calculated one is worked out from those.';

  @override
  String get emptyGroup => 'Empty group';

  @override
  String get emptyGroupHint => 'Name it, then add your own counters.';

  @override
  String get readyMadeSets => 'Ready-made sets';

  @override
  String copyGroupNamed(String name) {
    return 'Copy $name, without its counts';
  }

  @override
  String groupCopyName(String name) {
    return '$name (copy)';
  }

  @override
  String get presetRows => 'Rows and repeats';

  @override
  String get presetRowsHint => 'Rows, and the repeats of 8 they make.';

  @override
  String get presetBeads => 'Beads';

  @override
  String get presetBeadsHint => 'Beads, and the rounds of 108 they make.';

  @override
  String get presetInOut => 'In and out';

  @override
  String get presetInOutHint =>
      'Counted in, counted out, and how many are inside.';

  @override
  String get presetScore => 'Scoreboard';

  @override
  String get presetScoreHint => 'Two scores to keep.';

  @override
  String get presetMade => 'Made and missed';

  @override
  String get presetMadeHint => 'Made, missed, and the share that were made.';

  @override
  String get nameRows => 'Rows';

  @override
  String get nameRepeats => 'Repeats';

  @override
  String get nameBeads => 'Beads';

  @override
  String get nameRounds => 'Rounds';

  @override
  String get nameIn => 'In';

  @override
  String get nameOut => 'Out';

  @override
  String get nameInside => 'Inside';

  @override
  String get nameUs => 'Us';

  @override
  String get nameThem => 'Them';

  @override
  String get nameMade => 'Made';

  @override
  String get nameMissed => 'Missed';

  @override
  String get nameMadeShare => 'Made, in percent';

  @override
  String get importFromApp => 'Import from another app';

  @override
  String get importFromAppHint =>
      'Counters from BetterCounter, Counter or Simple Counter, added as new groups.';

  @override
  String get importChooseApp => 'Which app is the file from?';

  @override
  String get importBetterCounterHint =>
      'Its exported CSV file. Every count comes with its time.';

  @override
  String get importCounterHint =>
      'Its exported CSV file. Each counter comes with its number.';

  @override
  String get importSimpleCounterHint =>
      'Its JSON backup. Labels become groups.';

  @override
  String get importedGroupName => 'Imported';

  @override
  String get cantImport => 'Can\'t import this file';

  @override
  String importNotFrom(String app) {
    return 'This doesn\'t look like a file from $app.';
  }

  @override
  String get importEmpty => 'There are no counters in this file.';

  @override
  String importIsBackup(String restore) {
    return 'This is a Countersink backup. Use \"$restore\" for it.';
  }

  @override
  String importDone(String counters, String entries) {
    return 'Imported $counters and $entries.';
  }

  @override
  String importSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lines couldn\'t be read.',
      one: '1 line couldn\'t be read.',
    );
    return '$_temp0';
  }

  @override
  String reachedGoal(String name, int goal) {
    return '$name has reached $goal';
  }

  @override
  String get goalHintCalculated =>
      'A number to reach. A message says so when it gets there.';

  @override
  String get sendToPhone => 'Send to another phone';

  @override
  String get receiveFromPhone => 'Receive from another phone';

  @override
  String get shareWhatToSend => 'What would you like to send?';

  @override
  String get sendEverything => 'Everything';

  @override
  String get sendEverythingHint => 'Moving to a new phone.';

  @override
  String get shareWhatToInclude => 'What to include';

  @override
  String get shareShowCodes => 'Show the codes';

  @override
  String get shareHowToReceive =>
      'On the other phone, open Countersink, go to Settings → Receive from another phone, and point the camera at this screen.';

  @override
  String shareCodeOf(int index, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: 'Code $index of $total',
    );
    return '$_temp0';
  }

  @override
  String get sharePreviousCode => 'Previous code';

  @override
  String get sharePause => 'Pause';

  @override
  String get sharePlay => 'Play';

  @override
  String get shareNextCode => 'Next code';

  @override
  String get shareCodesChange =>
      'The codes change on their own. The other phone collects them in any order.';

  @override
  String get shareNotCountersink => 'That code isn\'t from Countersink.';

  @override
  String get shareNewerVersion =>
      'The other phone has a newer version of Countersink. Update this one first.';

  @override
  String get shareRestarted =>
      'The other phone started over. Collecting the new codes.';

  @override
  String get shareUnreadable =>
      'Some codes didn\'t read cleanly. Let\'s scan them again.';

  @override
  String get shareNeedsCamera =>
      'Countersink needs the camera to read the codes. You can allow it in the system settings for Countersink.';

  @override
  String get sharePointCamera =>
      'Point the camera at the code on the other phone.';

  @override
  String get shareReading => 'Reading…';

  @override
  String shareCodesReceived(int received, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$received of $total codes received',
    );
    return '$_temp0';
  }

  @override
  String shareStillNeeded(String codes) {
    return 'Still needed: $codes';
  }

  @override
  String get sendToPhoneHint =>
      'Show your counters as codes for another phone to scan.';

  @override
  String get receiveFromPhoneHint =>
      'Scan the codes another phone shows. What arrives is added as new groups.';

  @override
  String get sendSomeCounters => 'Just some counters';

  @override
  String get sendWithHistory => 'Counters and their history';

  @override
  String get sendWithHistoryHint => 'Every entry, with its time.';

  @override
  String get sendNumbersOnly => 'Counters and their numbers';

  @override
  String get sendNumbersOnlyHint =>
      'Far fewer codes. Each counter arrives with the number it shows now.';

  @override
  String sendSummary(String counters, String entries) {
    return 'Sending $counters and $entries.';
  }

  @override
  String receivedDone(String counters, String entries) {
    return 'Received $counters and $entries.';
  }

  @override
  String get sendNothingChosen => 'Choose at least one counter to send.';
}
