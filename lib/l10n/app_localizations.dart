import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('it'),
    Locale('pt'),
    Locale('ru'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Countersink'**
  String get appTitle;

  /// No description provided for @addCounter.
  ///
  /// In en, this message translates to:
  /// **'Add counter'**
  String get addCounter;

  /// No description provided for @counterName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get counterName;

  /// No description provided for @counterDescription.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get counterDescription;

  /// No description provided for @countPerDay.
  ///
  /// In en, this message translates to:
  /// **'Count per day'**
  String get countPerDay;

  /// No description provided for @countPerDayHint.
  ///
  /// In en, this message translates to:
  /// **'Shows today\'s total and starts from zero each day. Past days are kept.'**
  String get countPerDayHint;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'today'**
  String get today;

  /// No description provided for @noCounters.
  ///
  /// In en, this message translates to:
  /// **'No counters here yet.'**
  String get noCounters;

  /// Screen-reader label for a counter's plus button.
  ///
  /// In en, this message translates to:
  /// **'Add {step} to {name}'**
  String increment(int step, String name);

  /// Screen-reader label for a counter's minus button.
  ///
  /// In en, this message translates to:
  /// **'Take {step} from {name}'**
  String decrement(int step, String name);

  /// Name of the group a new install starts with.
  ///
  /// In en, this message translates to:
  /// **'Counters'**
  String get firstGroupName;

  /// No description provided for @firstCounterName.
  ///
  /// In en, this message translates to:
  /// **'My first counter'**
  String get firstCounterName;

  /// No description provided for @firstCounterDescription.
  ///
  /// In en, this message translates to:
  /// **'Tap + to count. Press and hold to edit.'**
  String get firstCounterDescription;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aboutCountersink.
  ///
  /// In en, this message translates to:
  /// **'About Countersink'**
  String get aboutCountersink;

  /// No description provided for @aboutCountersinkHint.
  ///
  /// In en, this message translates to:
  /// **'Where your counts live, and why it\'s free'**
  String get aboutCountersinkHint;

  /// No description provided for @aboutHeadline.
  ///
  /// In en, this message translates to:
  /// **'Your counts stay with you.'**
  String get aboutHeadline;

  /// No description provided for @aboutIntro.
  ///
  /// In en, this message translates to:
  /// **'Countersink keeps count of anything: reps, rows, scores, stock.'**
  String get aboutIntro;

  /// No description provided for @aboutStaysTitle.
  ///
  /// In en, this message translates to:
  /// **'It stays on your phone'**
  String get aboutStaysTitle;

  /// No description provided for @aboutStaysBody.
  ///
  /// In en, this message translates to:
  /// **'Every count is written to a database on this device. There is no account and no server. It only goes anywhere else if you move it yourself, as a backup file.'**
  String get aboutStaysBody;

  /// No description provided for @aboutCannotSeeTitle.
  ///
  /// In en, this message translates to:
  /// **'We cannot see it'**
  String get aboutCannotSeeTitle;

  /// No description provided for @aboutCannotSeeBody.
  ///
  /// In en, this message translates to:
  /// **'Countersink is built without permission to use the internet at all. Android enforces that, and you can check it in the app\'s permission list.'**
  String get aboutCannotSeeBody;

  /// No description provided for @aboutNoAdsTitle.
  ///
  /// In en, this message translates to:
  /// **'No ads, ever'**
  String get aboutNoAdsTitle;

  /// No description provided for @aboutNoAdsBody.
  ///
  /// In en, this message translates to:
  /// **'Counting should never be interrupted. Countersink will always be free and open source: no ads, no price, no premium tier.'**
  String get aboutNoAdsBody;

  /// No description provided for @aboutCheckTitle.
  ///
  /// In en, this message translates to:
  /// **'You can check our work'**
  String get aboutCheckTitle;

  /// No description provided for @aboutCheckBody.
  ///
  /// In en, this message translates to:
  /// **'Countersink is open source under the GNU General Public License. Anyone can read exactly what it does.'**
  String get aboutCheckBody;

  /// No description provided for @aboutTradeOff.
  ///
  /// In en, this message translates to:
  /// **'One trade-off worth knowing: there is no cloud copy, so a lost or wiped phone means lost counts. Save a backup file from Settings now and then, and keep it somewhere other than this phone.'**
  String get aboutTradeOff;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @website.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// No description provided for @sendFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send feedback'**
  String get sendFeedback;

  /// No description provided for @sendFeedbackHint.
  ///
  /// In en, this message translates to:
  /// **'A form on the website, in your browser.'**
  String get sendFeedbackHint;

  /// Message when the Website or Send feedback link can't be opened: {website} is the site's address.
  ///
  /// In en, this message translates to:
  /// **'No browser to open it with. Visit {website} instead.'**
  String noBrowser(String website);

  /// No description provided for @versionNumber.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String versionNumber(String version);

  /// No description provided for @editCounter.
  ///
  /// In en, this message translates to:
  /// **'Edit counter'**
  String get editCounter;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// Shown after a counter is deleted, beside an Undo button.
  ///
  /// In en, this message translates to:
  /// **'Deleted {name}'**
  String counterDeleted(String name);

  /// No description provided for @counterColor.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get counterColor;

  /// No description provided for @colorClay.
  ///
  /// In en, this message translates to:
  /// **'Clay'**
  String get colorClay;

  /// No description provided for @colorTeal.
  ///
  /// In en, this message translates to:
  /// **'Teal'**
  String get colorTeal;

  /// No description provided for @colorNavy.
  ///
  /// In en, this message translates to:
  /// **'Navy'**
  String get colorNavy;

  /// No description provided for @colorLavender.
  ///
  /// In en, this message translates to:
  /// **'Lavender'**
  String get colorLavender;

  /// No description provided for @colorGreen.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get colorGreen;

  /// Screen-reader name for a counter color that isn't one of the named ones.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get colorCustom;

  /// No description provided for @groups.
  ///
  /// In en, this message translates to:
  /// **'Groups'**
  String get groups;

  /// No description provided for @addGroup.
  ///
  /// In en, this message translates to:
  /// **'Add group'**
  String get addGroup;

  /// No description provided for @renameGroup.
  ///
  /// In en, this message translates to:
  /// **'Rename group'**
  String get renameGroup;

  /// No description provided for @groupName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get groupName;

  /// How many counters a group holds.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No counters} =1{1 counter} other{{count} counters}}'**
  String countersCount(int count);

  /// Label for the button that deletes the named group.
  ///
  /// In en, this message translates to:
  /// **'Delete {name}'**
  String deleteNamed(String name);

  /// Shown after a group is deleted, beside an Undo button.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Deleted {name}} =1{Deleted {name} and its counter} other{Deleted {name} and its {count} counters}}'**
  String groupDeleted(String name, int count);

  /// No description provided for @lastGroupHint.
  ///
  /// In en, this message translates to:
  /// **'The last group can\'t be deleted.'**
  String get lastGroupHint;

  /// No description provided for @counterStep.
  ///
  /// In en, this message translates to:
  /// **'Step'**
  String get counterStep;

  /// No description provided for @counterStepHint.
  ///
  /// In en, this message translates to:
  /// **'How much each press of + or − counts.'**
  String get counterStepHint;

  /// No description provided for @addAmount.
  ///
  /// In en, this message translates to:
  /// **'Add an amount'**
  String get addAmount;

  /// No description provided for @addAmountTitle.
  ///
  /// In en, this message translates to:
  /// **'Add to {name}'**
  String addAmountTitle(String name);

  /// No description provided for @takeAmountTitle.
  ///
  /// In en, this message translates to:
  /// **'Take from {name}'**
  String takeAmountTitle(String name);

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @takeAway.
  ///
  /// In en, this message translates to:
  /// **'Take away'**
  String get takeAway;

  /// No description provided for @setValue.
  ///
  /// In en, this message translates to:
  /// **'Set value'**
  String get setValue;

  /// No description provided for @value.
  ///
  /// In en, this message translates to:
  /// **'Value'**
  String get value;

  /// No description provided for @set.
  ///
  /// In en, this message translates to:
  /// **'Set'**
  String get set;

  /// No description provided for @resetToZero.
  ///
  /// In en, this message translates to:
  /// **'Reset to zero'**
  String get resetToZero;

  /// Shown after a counter is reset, beside an Undo button.
  ///
  /// In en, this message translates to:
  /// **'{name} reset to zero'**
  String counterReset(String name);

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @historyEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing counted yet.'**
  String get historyEmpty;

  /// No description provided for @dayToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get dayToday;

  /// No description provided for @dayYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get dayYesterday;

  /// How many times a counter was changed on one day.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 entry} other{{count} entries}}'**
  String entriesCount(int count);

  /// No description provided for @allTime.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get allTime;

  /// No description provided for @sectionCounting.
  ///
  /// In en, this message translates to:
  /// **'Counting'**
  String get sectionCounting;

  /// No description provided for @dayStartsAt.
  ///
  /// In en, this message translates to:
  /// **'Day starts at'**
  String get dayStartsAt;

  /// No description provided for @dayStartsAtHint.
  ///
  /// In en, this message translates to:
  /// **'Anything counted before this hour belongs to the day before.'**
  String get dayStartsAtHint;

  /// No description provided for @midnight.
  ///
  /// In en, this message translates to:
  /// **'Midnight'**
  String get midnight;

  /// No description provided for @yourData.
  ///
  /// In en, this message translates to:
  /// **'Your data'**
  String get yourData;

  /// No description provided for @backUp.
  ///
  /// In en, this message translates to:
  /// **'Back up to a file'**
  String get backUp;

  /// No description provided for @backUpHint.
  ///
  /// In en, this message translates to:
  /// **'Everything, saved wherever you choose.'**
  String get backUpHint;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore from a backup'**
  String get restore;

  /// No description provided for @restoreHint.
  ///
  /// In en, this message translates to:
  /// **'Replaces what\'s on this phone.'**
  String get restoreHint;

  /// No description provided for @backupSaved.
  ///
  /// In en, this message translates to:
  /// **'Backup saved'**
  String get backupSaved;

  /// No description provided for @couldNotSave.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the file.'**
  String get couldNotSave;

  /// No description provided for @couldNotOpen.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open that file.'**
  String get couldNotOpen;

  /// No description provided for @cantRestore.
  ///
  /// In en, this message translates to:
  /// **'Can\'t restore this file'**
  String get cantRestore;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @restoreTitle.
  ///
  /// In en, this message translates to:
  /// **'Replace everything with this backup?'**
  String get restoreTitle;

  /// Asked before a backup replaces what is on the phone. The three placeholders are counts already in words, such as "3 groups", "12 counters" and "4210 entries".
  ///
  /// In en, this message translates to:
  /// **'It has {groups}, {counters} and {entries}. Everything now on this phone will be replaced by it.'**
  String restoreMessage(String groups, String counters, String entries);

  /// No description provided for @groupsCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 group} other{{count} groups}}'**
  String groupsCount(int count);

  /// No description provided for @replace.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get replace;

  /// No description provided for @restored.
  ///
  /// In en, this message translates to:
  /// **'Restored'**
  String get restored;

  /// No description provided for @backupNotCountersink.
  ///
  /// In en, this message translates to:
  /// **'This isn\'t a Countersink backup.'**
  String get backupNotCountersink;

  /// No description provided for @backupTooNew.
  ///
  /// In en, this message translates to:
  /// **'This backup was made by a newer version of Countersink. Update the app, then try again.'**
  String get backupTooNew;

  /// The detail is a technical note in English saying where the file went wrong.
  ///
  /// In en, this message translates to:
  /// **'This backup has something wrong in it and wasn\'t restored. Nothing on this phone was changed.\n\n{detail}'**
  String backupDamaged(String detail);

  /// No description provided for @colorBrick.
  ///
  /// In en, this message translates to:
  /// **'Brick'**
  String get colorBrick;

  /// No description provided for @colorOchre.
  ///
  /// In en, this message translates to:
  /// **'Ochre'**
  String get colorOchre;

  /// No description provided for @colorSand.
  ///
  /// In en, this message translates to:
  /// **'Sand'**
  String get colorSand;

  /// No description provided for @colorOlive.
  ///
  /// In en, this message translates to:
  /// **'Olive'**
  String get colorOlive;

  /// No description provided for @colorSage.
  ///
  /// In en, this message translates to:
  /// **'Sage'**
  String get colorSage;

  /// No description provided for @colorMoss.
  ///
  /// In en, this message translates to:
  /// **'Moss'**
  String get colorMoss;

  /// No description provided for @colorSlate.
  ///
  /// In en, this message translates to:
  /// **'Slate'**
  String get colorSlate;

  /// No description provided for @colorStorm.
  ///
  /// In en, this message translates to:
  /// **'Storm'**
  String get colorStorm;

  /// No description provided for @colorSky.
  ///
  /// In en, this message translates to:
  /// **'Sky'**
  String get colorSky;

  /// No description provided for @colorPlum.
  ///
  /// In en, this message translates to:
  /// **'Plum'**
  String get colorPlum;

  /// No description provided for @colorRose.
  ///
  /// In en, this message translates to:
  /// **'Rose'**
  String get colorRose;

  /// No description provided for @colorCocoa.
  ///
  /// In en, this message translates to:
  /// **'Cocoa'**
  String get colorCocoa;

  /// No description provided for @colorCharcoal.
  ///
  /// In en, this message translates to:
  /// **'Charcoal'**
  String get colorCharcoal;

  /// No description provided for @colorAubergine.
  ///
  /// In en, this message translates to:
  /// **'Aubergine'**
  String get colorAubergine;

  /// No description provided for @colorLinen.
  ///
  /// In en, this message translates to:
  /// **'Linen'**
  String get colorLinen;

  /// No description provided for @moreColors.
  ///
  /// In en, this message translates to:
  /// **'More colors and patterns'**
  String get moreColors;

  /// No description provided for @appearanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Color and pattern'**
  String get appearanceTitle;

  /// No description provided for @secondColor.
  ///
  /// In en, this message translates to:
  /// **'Second color'**
  String get secondColor;

  /// No description provided for @secondColorHint.
  ///
  /// In en, this message translates to:
  /// **'Blends into the first, from corner to corner.'**
  String get secondColorHint;

  /// No description provided for @noSecondColor.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get noSecondColor;

  /// No description provided for @pattern.
  ///
  /// In en, this message translates to:
  /// **'Pattern'**
  String get pattern;

  /// No description provided for @patternNone.
  ///
  /// In en, this message translates to:
  /// **'Plain'**
  String get patternNone;

  /// No description provided for @patternStripes.
  ///
  /// In en, this message translates to:
  /// **'Stripes'**
  String get patternStripes;

  /// No description provided for @patternDots.
  ///
  /// In en, this message translates to:
  /// **'Dots'**
  String get patternDots;

  /// No description provided for @patternGrid.
  ///
  /// In en, this message translates to:
  /// **'Grid'**
  String get patternGrid;

  /// No description provided for @customColor.
  ///
  /// In en, this message translates to:
  /// **'Custom color'**
  String get customColor;

  /// No description provided for @hue.
  ///
  /// In en, this message translates to:
  /// **'Hue'**
  String get hue;

  /// No description provided for @saturation.
  ///
  /// In en, this message translates to:
  /// **'Saturation'**
  String get saturation;

  /// No description provided for @brightness.
  ///
  /// In en, this message translates to:
  /// **'Brightness'**
  String get brightness;

  /// No description provided for @hexCode.
  ///
  /// In en, this message translates to:
  /// **'Hex code'**
  String get hexCode;

  /// No description provided for @useColor.
  ///
  /// In en, this message translates to:
  /// **'Use'**
  String get useColor;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// A sample number shown on the preview card while choosing a counter's colors.
  ///
  /// In en, this message translates to:
  /// **'12'**
  String get sampleCount;

  /// No description provided for @reorderCounters.
  ///
  /// In en, this message translates to:
  /// **'Reorder counters'**
  String get reorderCounters;

  /// No description provided for @moveToGroup.
  ///
  /// In en, this message translates to:
  /// **'Move to another group'**
  String get moveToGroup;

  /// Title of the list of groups a counter can be moved to.
  ///
  /// In en, this message translates to:
  /// **'Move {name} to'**
  String moveToGroupTitle(String name);

  /// No description provided for @movedToGroup.
  ///
  /// In en, this message translates to:
  /// **'Moved to {group}'**
  String movedToGroup(String group);

  /// No description provided for @exportCsv.
  ///
  /// In en, this message translates to:
  /// **'Export as a spreadsheet'**
  String get exportCsv;

  /// No description provided for @exportCsvHint.
  ///
  /// In en, this message translates to:
  /// **'Every entry as a CSV file, one row each.'**
  String get exportCsvHint;

  /// No description provided for @csvSaved.
  ///
  /// In en, this message translates to:
  /// **'Spreadsheet saved'**
  String get csvSaved;

  /// No description provided for @keepScreenOn.
  ///
  /// In en, this message translates to:
  /// **'Keep the screen on'**
  String get keepScreenOn;

  /// No description provided for @keepScreenOnHint.
  ///
  /// In en, this message translates to:
  /// **'While Countersink is open, the screen won\'t dim or lock.'**
  String get keepScreenOnHint;

  /// No description provided for @sectionAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get sectionAppearance;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'Same as the phone'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @counterGoal.
  ///
  /// In en, this message translates to:
  /// **'Goal (optional)'**
  String get counterGoal;

  /// No description provided for @counterGoalHint.
  ///
  /// In en, this message translates to:
  /// **'A number to reach. A counter that counts per day can aim for each day or for the week.'**
  String get counterGoalHint;

  /// Shown under a counter's number when it has a goal, as in "37 of 50".
  ///
  /// In en, this message translates to:
  /// **'of {goal}'**
  String goalOf(int goal);

  /// No description provided for @goalReached.
  ///
  /// In en, this message translates to:
  /// **'Goal reached'**
  String get goalReached;

  /// No description provided for @dayStreak.
  ///
  /// In en, this message translates to:
  /// **'Day streak'**
  String get dayStreak;

  /// No description provided for @bestStreak.
  ///
  /// In en, this message translates to:
  /// **'Best streak'**
  String get bestStreak;

  /// No description provided for @previousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get previousMonth;

  /// No description provided for @nextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get nextMonth;

  /// A choice of how far back a chart looks: 7 days, 30 days, 90 days.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String daysCount(int count);

  /// No description provided for @averagePerDay.
  ///
  /// In en, this message translates to:
  /// **'Average per day'**
  String get averagePerDay;

  /// No description provided for @totalInRange.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get totalInRange;

  /// No description provided for @addEntry.
  ///
  /// In en, this message translates to:
  /// **'Add entry'**
  String get addEntry;

  /// No description provided for @editEntry.
  ///
  /// In en, this message translates to:
  /// **'Edit entry'**
  String get editEntry;

  /// No description provided for @entryAdded.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get entryAdded;

  /// No description provided for @entryTaken.
  ///
  /// In en, this message translates to:
  /// **'Taken away'**
  String get entryTaken;

  /// No description provided for @entryTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get entryTime;

  /// No description provided for @entryDeleted.
  ///
  /// In en, this message translates to:
  /// **'Entry deleted'**
  String get entryDeleted;

  /// No description provided for @belowZero.
  ///
  /// In en, this message translates to:
  /// **'That would take the count below zero.'**
  String get belowZero;

  /// No description provided for @perDayRefused.
  ///
  /// In en, this message translates to:
  /// **'This counter can\'t count per day yet. On at least one day in its history, more was taken away than was counted, so that day would be below zero. Correct it in History first.'**
  String get perDayRefused;

  /// No description provided for @noEntries.
  ///
  /// In en, this message translates to:
  /// **'Nothing counted on this day.'**
  String get noEntries;

  /// No description provided for @dayTotal.
  ///
  /// In en, this message translates to:
  /// **'Day\'s total'**
  String get dayTotal;

  /// No description provided for @fullScreen.
  ///
  /// In en, this message translates to:
  /// **'Full screen'**
  String get fullScreen;

  /// No description provided for @tapAnywhere.
  ///
  /// In en, this message translates to:
  /// **'Tap anywhere to count'**
  String get tapAnywhere;

  /// No description provided for @closeFullScreen.
  ///
  /// In en, this message translates to:
  /// **'Close full screen'**
  String get closeFullScreen;

  /// No description provided for @volumeKeys.
  ///
  /// In en, this message translates to:
  /// **'Volume buttons'**
  String get volumeKeys;

  /// No description provided for @volumeKeysHint.
  ///
  /// In en, this message translates to:
  /// **'Count with the phone\'s volume buttons while a counter is in full screen.'**
  String get volumeKeysHint;

  /// No description provided for @volumeOff.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get volumeOff;

  /// No description provided for @volumeUp.
  ///
  /// In en, this message translates to:
  /// **'Volume up adds'**
  String get volumeUp;

  /// No description provided for @volumeBoth.
  ///
  /// In en, this message translates to:
  /// **'Up adds, down takes away'**
  String get volumeBoth;

  /// No description provided for @lockTouch.
  ///
  /// In en, this message translates to:
  /// **'Lock touch'**
  String get lockTouch;

  /// No description provided for @unlockTouch.
  ///
  /// In en, this message translates to:
  /// **'Press and hold to unlock'**
  String get unlockTouch;

  /// No description provided for @touchLocked.
  ///
  /// In en, this message translates to:
  /// **'Touch is locked. Count with the volume buttons.'**
  String get touchLocked;

  /// No description provided for @volumeCounts.
  ///
  /// In en, this message translates to:
  /// **'Tap anywhere or press a volume button to count'**
  String get volumeCounts;

  /// Heading of the Language section in Settings, its item, and the title of the language dialog.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Choice in the language dialog: follow the phone's language.
  ///
  /// In en, this message translates to:
  /// **'Same as the phone'**
  String get sameAsPhone;

  /// Subtitle of the Language item when following the phone: {language} is the language in use, by its own name.
  ///
  /// In en, this message translates to:
  /// **'Same as the phone: {language}'**
  String sameAsPhoneNow(String language);

  /// No description provided for @archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archive;

  /// No description provided for @unarchive.
  ///
  /// In en, this message translates to:
  /// **'Move back to its group'**
  String get unarchive;

  /// Shown after a counter is archived, beside an Undo button.
  ///
  /// In en, this message translates to:
  /// **'Archived {name}'**
  String counterArchived(String name);

  /// No description provided for @archivedCounters.
  ///
  /// In en, this message translates to:
  /// **'Archived counters'**
  String get archivedCounters;

  /// No description provided for @noArchived.
  ///
  /// In en, this message translates to:
  /// **'Nothing archived.'**
  String get noArchived;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search counters'**
  String get searchHint;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No counters match.'**
  String get noResults;

  /// No description provided for @searchPrompt.
  ///
  /// In en, this message translates to:
  /// **'Type a counter\'s name, its description or its group.'**
  String get searchPrompt;

  /// No description provided for @autoBackup.
  ///
  /// In en, this message translates to:
  /// **'Automatic backup'**
  String get autoBackup;

  /// No description provided for @autoBackupHint.
  ///
  /// In en, this message translates to:
  /// **'Off. Choose a folder to keep a backup in, saved each time you leave the app.'**
  String get autoBackupHint;

  /// Under Automatic backup in Settings when it is on. {folder} is the folder's name.
  ///
  /// In en, this message translates to:
  /// **'To {folder}, each time you leave the app. The last 7 days are kept.'**
  String autoBackupTo(String folder);

  /// No description provided for @autoBackupFailed.
  ///
  /// In en, this message translates to:
  /// **'The last backup couldn\'t be saved to {folder}. Choose the folder again.'**
  String autoBackupFailed(String folder);

  /// No description provided for @backUpNow.
  ///
  /// In en, this message translates to:
  /// **'Back up now'**
  String get backUpNow;

  /// No description provided for @chooseAnotherFolder.
  ///
  /// In en, this message translates to:
  /// **'Choose another folder'**
  String get chooseAnotherFolder;

  /// No description provided for @turnOff.
  ///
  /// In en, this message translates to:
  /// **'Turn off'**
  String get turnOff;

  /// No description provided for @backedUpTo.
  ///
  /// In en, this message translates to:
  /// **'Backed up to {folder}'**
  String backedUpTo(String folder);

  /// Label above a choice of two buttons, Day and Week, which finish the sentence.
  ///
  /// In en, this message translates to:
  /// **'The goal is for each'**
  String get goalForEach;

  /// No description provided for @periodDay.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get periodDay;

  /// No description provided for @periodWeek.
  ///
  /// In en, this message translates to:
  /// **'Week'**
  String get periodWeek;

  /// Shown under a counter's number when its goal is for the week, as in "42 of 100 this week".
  ///
  /// In en, this message translates to:
  /// **'{done} of {goal} this week'**
  String goalThisWeek(int done, int goal);

  /// No description provided for @weekStreak.
  ///
  /// In en, this message translates to:
  /// **'Week streak'**
  String get weekStreak;

  /// No description provided for @buzzEvery.
  ///
  /// In en, this message translates to:
  /// **'Buzz every (optional)'**
  String get buzzEvery;

  /// No description provided for @buzzEveryHint.
  ///
  /// In en, this message translates to:
  /// **'A double buzz each time the count passes a multiple of this, such as every 10.'**
  String get buzzEveryHint;

  /// No description provided for @weekStartsOn.
  ///
  /// In en, this message translates to:
  /// **'Week starts on'**
  String get weekStartsOn;

  /// No description provided for @weekStartsOnHint.
  ///
  /// In en, this message translates to:
  /// **'For goals that are for the week, and for the calendar.'**
  String get weekStartsOnHint;

  /// In a counter's menu: puts a widget for that counter on the phone's home screen.
  ///
  /// In en, this message translates to:
  /// **'Add to home screen'**
  String get addToHomeScreen;

  /// A Settings row. Quick settings are the buttons in the panel pulled down from the top of an Android phone.
  ///
  /// In en, this message translates to:
  /// **'Quick settings tile'**
  String get quickTile;

  /// No description provided for @quickTileHint.
  ///
  /// In en, this message translates to:
  /// **'Off. Choose a counter to add to from the phone\'s quick settings, without opening the app.'**
  String get quickTileHint;

  /// No description provided for @quickTileOn.
  ///
  /// In en, this message translates to:
  /// **'Adds to {name}, from the phone\'s quick settings.'**
  String quickTileOn(String name);

  /// No description provided for @chooseCounter.
  ///
  /// In en, this message translates to:
  /// **'Choose a counter'**
  String get chooseCounter;

  /// No description provided for @chooseAnotherCounter.
  ///
  /// In en, this message translates to:
  /// **'Choose another counter'**
  String get chooseAnotherCounter;

  /// No description provided for @quickTileHowTo.
  ///
  /// In en, this message translates to:
  /// **'To add the tile: open the phone\'s quick settings, tap the pencil, and drag in the Countersink tile.'**
  String get quickTileHowTo;

  /// No description provided for @calculated.
  ///
  /// In en, this message translates to:
  /// **'Calculated from other counters'**
  String get calculated;

  /// No description provided for @calculatedOff.
  ///
  /// In en, this message translates to:
  /// **'Off. Counted by hand, with plus and minus.'**
  String get calculatedOff;

  /// No description provided for @formulaTitle.
  ///
  /// In en, this message translates to:
  /// **'Calculated counter'**
  String get formulaTitle;

  /// No description provided for @formulaIntro.
  ///
  /// In en, this message translates to:
  /// **'A calculated counter isn\'t counted on. It shows a number worked out from other counters, and keeps up as they change.'**
  String get formulaIntro;

  /// No description provided for @formulaNone.
  ///
  /// In en, this message translates to:
  /// **'Counted by hand'**
  String get formulaNone;

  /// No description provided for @formulaSum.
  ///
  /// In en, this message translates to:
  /// **'A total'**
  String get formulaSum;

  /// No description provided for @formulaSumHint.
  ///
  /// In en, this message translates to:
  /// **'Several counters added up.'**
  String get formulaSumHint;

  /// No description provided for @formulaDifference.
  ///
  /// In en, this message translates to:
  /// **'A difference'**
  String get formulaDifference;

  /// No description provided for @formulaDifferenceHint.
  ///
  /// In en, this message translates to:
  /// **'One counter, less the others. In, less out.'**
  String get formulaDifferenceHint;

  /// No description provided for @formulaPercent.
  ///
  /// In en, this message translates to:
  /// **'A share, in percent'**
  String get formulaPercent;

  /// No description provided for @formulaPercentHint.
  ///
  /// In en, this message translates to:
  /// **'One counter as a share of several together.'**
  String get formulaPercentHint;

  /// No description provided for @formulaEvery.
  ///
  /// In en, this message translates to:
  /// **'Completed rounds'**
  String get formulaEvery;

  /// No description provided for @formulaEveryHint.
  ///
  /// In en, this message translates to:
  /// **'How many times another counter has gone round: every 108 beads, every 8 rows.'**
  String get formulaEveryHint;

  /// No description provided for @sectionShows.
  ///
  /// In en, this message translates to:
  /// **'What it shows'**
  String get sectionShows;

  /// No description provided for @formulaAddUp.
  ///
  /// In en, this message translates to:
  /// **'Add up'**
  String get formulaAddUp;

  /// No description provided for @formulaStartWith.
  ///
  /// In en, this message translates to:
  /// **'Start with'**
  String get formulaStartWith;

  /// No description provided for @formulaTakeAway.
  ///
  /// In en, this message translates to:
  /// **'Take away'**
  String get formulaTakeAway;

  /// No description provided for @formulaShareOf.
  ///
  /// In en, this message translates to:
  /// **'The share of'**
  String get formulaShareOf;

  /// No description provided for @formulaTogetherWith.
  ///
  /// In en, this message translates to:
  /// **'In the total of it and'**
  String get formulaTogetherWith;

  /// No description provided for @formulaRoundsOf.
  ///
  /// In en, this message translates to:
  /// **'Rounds of'**
  String get formulaRoundsOf;

  /// No description provided for @formulaAllTime.
  ///
  /// In en, this message translates to:
  /// **'Keep a running total'**
  String get formulaAllTime;

  /// No description provided for @formulaAllTimeHint.
  ///
  /// In en, this message translates to:
  /// **'Per-day counters count for everything they have ever counted, not just today. They start each day from zero; this number carries on.'**
  String get formulaAllTimeHint;

  /// No description provided for @formulaStartFrom.
  ///
  /// In en, this message translates to:
  /// **'Start from (optional)'**
  String get formulaStartFrom;

  /// No description provided for @formulaStartFromHint.
  ///
  /// In en, this message translates to:
  /// **'A number the total already stands at, from before it was counted here. What is counted is added to it.'**
  String get formulaStartFromHint;

  /// No description provided for @roundSize.
  ///
  /// In en, this message translates to:
  /// **'One round is'**
  String get roundSize;

  /// No description provided for @roundSizeHint.
  ///
  /// In en, this message translates to:
  /// **'How many make a round.'**
  String get roundSizeHint;

  /// No description provided for @lineSum.
  ///
  /// In en, this message translates to:
  /// **'Total of {names}'**
  String lineSum(String names);

  /// No description provided for @lineDifference.
  ///
  /// In en, this message translates to:
  /// **'{first} less {others}'**
  String lineDifference(String first, String others);

  /// No description provided for @linePercent.
  ///
  /// In en, this message translates to:
  /// **'{first} as a share of {all}'**
  String linePercent(String first, String all);

  /// No description provided for @lineEvery.
  ///
  /// In en, this message translates to:
  /// **'Rounds of {size} in {name}'**
  String lineEvery(int size, String name);

  /// No description provided for @lineTowardNext.
  ///
  /// In en, this message translates to:
  /// **'{count} toward the next'**
  String lineTowardNext(int count);

  /// No description provided for @lineBroken.
  ///
  /// In en, this message translates to:
  /// **'The counter it was worked out from is gone'**
  String get lineBroken;

  /// No description provided for @noOrdinaryCounters.
  ///
  /// In en, this message translates to:
  /// **'Add a counter to count by hand first. A calculated one is worked out from those.'**
  String get noOrdinaryCounters;

  /// No description provided for @emptyGroup.
  ///
  /// In en, this message translates to:
  /// **'Empty group'**
  String get emptyGroup;

  /// No description provided for @emptyGroupHint.
  ///
  /// In en, this message translates to:
  /// **'Name it, then add your own counters.'**
  String get emptyGroupHint;

  /// No description provided for @readyMadeSets.
  ///
  /// In en, this message translates to:
  /// **'Ready-made sets'**
  String get readyMadeSets;

  /// No description provided for @copyGroupNamed.
  ///
  /// In en, this message translates to:
  /// **'Copy {name}, without its counts'**
  String copyGroupNamed(String name);

  /// No description provided for @groupCopyName.
  ///
  /// In en, this message translates to:
  /// **'{name} (copy)'**
  String groupCopyName(String name);

  /// No description provided for @presetRows.
  ///
  /// In en, this message translates to:
  /// **'Rows and repeats'**
  String get presetRows;

  /// No description provided for @presetRowsHint.
  ///
  /// In en, this message translates to:
  /// **'Rows, and the repeats of 8 they make.'**
  String get presetRowsHint;

  /// No description provided for @presetBeads.
  ///
  /// In en, this message translates to:
  /// **'Beads'**
  String get presetBeads;

  /// No description provided for @presetBeadsHint.
  ///
  /// In en, this message translates to:
  /// **'Beads, and the rounds of 108 they make.'**
  String get presetBeadsHint;

  /// No description provided for @presetInOut.
  ///
  /// In en, this message translates to:
  /// **'In and out'**
  String get presetInOut;

  /// No description provided for @presetInOutHint.
  ///
  /// In en, this message translates to:
  /// **'Counted in, counted out, and how many are inside.'**
  String get presetInOutHint;

  /// No description provided for @presetScore.
  ///
  /// In en, this message translates to:
  /// **'Scoreboard'**
  String get presetScore;

  /// No description provided for @presetScoreHint.
  ///
  /// In en, this message translates to:
  /// **'Two scores to keep.'**
  String get presetScoreHint;

  /// No description provided for @presetMade.
  ///
  /// In en, this message translates to:
  /// **'Made and missed'**
  String get presetMade;

  /// No description provided for @presetMadeHint.
  ///
  /// In en, this message translates to:
  /// **'Made, missed, and the share that were made.'**
  String get presetMadeHint;

  /// No description provided for @nameRows.
  ///
  /// In en, this message translates to:
  /// **'Rows'**
  String get nameRows;

  /// No description provided for @nameRepeats.
  ///
  /// In en, this message translates to:
  /// **'Repeats'**
  String get nameRepeats;

  /// No description provided for @nameBeads.
  ///
  /// In en, this message translates to:
  /// **'Beads'**
  String get nameBeads;

  /// No description provided for @nameRounds.
  ///
  /// In en, this message translates to:
  /// **'Rounds'**
  String get nameRounds;

  /// No description provided for @nameIn.
  ///
  /// In en, this message translates to:
  /// **'In'**
  String get nameIn;

  /// No description provided for @nameOut.
  ///
  /// In en, this message translates to:
  /// **'Out'**
  String get nameOut;

  /// No description provided for @nameInside.
  ///
  /// In en, this message translates to:
  /// **'Inside'**
  String get nameInside;

  /// No description provided for @nameUs.
  ///
  /// In en, this message translates to:
  /// **'Us'**
  String get nameUs;

  /// No description provided for @nameThem.
  ///
  /// In en, this message translates to:
  /// **'Them'**
  String get nameThem;

  /// No description provided for @nameMade.
  ///
  /// In en, this message translates to:
  /// **'Made'**
  String get nameMade;

  /// No description provided for @nameMissed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get nameMissed;

  /// No description provided for @nameMadeShare.
  ///
  /// In en, this message translates to:
  /// **'Made, in percent'**
  String get nameMadeShare;

  /// No description provided for @importFromApp.
  ///
  /// In en, this message translates to:
  /// **'Import from another app'**
  String get importFromApp;

  /// No description provided for @importFromAppHint.
  ///
  /// In en, this message translates to:
  /// **'Counters from BetterCounter, Counter or Simple Counter, added as new groups.'**
  String get importFromAppHint;

  /// No description provided for @importChooseApp.
  ///
  /// In en, this message translates to:
  /// **'Which app is the file from?'**
  String get importChooseApp;

  /// No description provided for @importBetterCounterHint.
  ///
  /// In en, this message translates to:
  /// **'Its exported CSV file. Every count comes with its time.'**
  String get importBetterCounterHint;

  /// No description provided for @importCounterHint.
  ///
  /// In en, this message translates to:
  /// **'Its exported CSV file. Each counter comes with its number.'**
  String get importCounterHint;

  /// No description provided for @importSimpleCounterHint.
  ///
  /// In en, this message translates to:
  /// **'Its JSON backup. Labels become groups.'**
  String get importSimpleCounterHint;

  /// No description provided for @importedGroupName.
  ///
  /// In en, this message translates to:
  /// **'Imported'**
  String get importedGroupName;

  /// No description provided for @cantImport.
  ///
  /// In en, this message translates to:
  /// **'Can\'t import this file'**
  String get cantImport;

  /// No description provided for @importNotFrom.
  ///
  /// In en, this message translates to:
  /// **'This doesn\'t look like a file from {app}.'**
  String importNotFrom(String app);

  /// No description provided for @importEmpty.
  ///
  /// In en, this message translates to:
  /// **'There are no counters in this file.'**
  String get importEmpty;

  /// restore is the name of the Settings row for restoring a backup.
  ///
  /// In en, this message translates to:
  /// **'This is a Countersink backup. Use \"{restore}\" for it.'**
  String importIsBackup(String restore);

  /// No description provided for @importDone.
  ///
  /// In en, this message translates to:
  /// **'Imported {counters} and {entries}.'**
  String importDone(String counters, String entries);

  /// No description provided for @importSkipped.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 line couldn\'t be read.} other{{count} lines couldn\'t be read.}}'**
  String importSkipped(int count);

  /// No description provided for @reachedGoal.
  ///
  /// In en, this message translates to:
  /// **'{name} has reached {goal}'**
  String reachedGoal(String name, int goal);

  /// No description provided for @goalHintCalculated.
  ///
  /// In en, this message translates to:
  /// **'A number to reach. A message says so when it gets there.'**
  String get goalHintCalculated;

  /// Screen title. History is shown as QR codes for another phone running Ebb to scan.
  ///
  /// In en, this message translates to:
  /// **'Send to another phone'**
  String get sendToPhone;

  /// Screen title, and the Settings item that opens it.
  ///
  /// In en, this message translates to:
  /// **'Receive from another phone'**
  String get receiveFromPhone;

  /// Heading of the Send screen's first step: choosing whose history to send.
  ///
  /// In en, this message translates to:
  /// **'What would you like to send?'**
  String get shareWhatToSend;

  /// How far back: all of the history.
  ///
  /// In en, this message translates to:
  /// **'Everything'**
  String get sendEverything;

  /// Under the 'Everyone on this phone' send choice: what it is for.
  ///
  /// In en, this message translates to:
  /// **'Moving to a new phone.'**
  String get sendEverythingHint;

  /// Section heading.
  ///
  /// In en, this message translates to:
  /// **'What to include'**
  String get shareWhatToInclude;

  /// Button at the foot of the 'How much' step: shows the QR codes.
  ///
  /// In en, this message translates to:
  /// **'Show the codes'**
  String get shareShowCodes;

  /// Settings → Receive from another phone must match those screens’ names.
  ///
  /// In en, this message translates to:
  /// **'On the other phone, open Countersink, go to Settings → Receive from another phone, and point the camera at this screen.'**
  String get shareHowToReceive;

  /// Which QR code is showing. total is 2 or more.
  ///
  /// In en, this message translates to:
  /// **'{total, plural, other{Code {index} of {total}}}'**
  String shareCodeOf(int index, int total);

  /// Tooltip.
  ///
  /// In en, this message translates to:
  /// **'Previous code'**
  String get sharePreviousCode;

  /// Tooltip: stop the codes changing.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get sharePause;

  /// Tooltip: let the codes change on their own again.
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get sharePlay;

  /// Tooltip.
  ///
  /// In en, this message translates to:
  /// **'Next code'**
  String get shareNextCode;

  /// Under the codes when there is more than one: they cycle on their own, and scanning order does not matter.
  ///
  /// In en, this message translates to:
  /// **'The codes change on their own. The other phone collects them in any order.'**
  String get shareCodesChange;

  /// On the Receive screen after scanning a QR code that is not Ebb's.
  ///
  /// In en, this message translates to:
  /// **'That code isn\'t from Countersink.'**
  String get shareNotCountersink;

  /// On the Receive screen when the codes come from a newer Ebb than this one.
  ///
  /// In en, this message translates to:
  /// **'The other phone has a newer version of Countersink. Update this one first.'**
  String get shareNewerVersion;

  /// On the Receive screen when the sender started a new transfer part way through, so the codes collected so far are dropped.
  ///
  /// In en, this message translates to:
  /// **'The other phone started over. Collecting the new codes.'**
  String get shareRestarted;

  /// On the Receive screen when the collected codes did not assemble into a readable backup; scanning starts again.
  ///
  /// In en, this message translates to:
  /// **'Some codes didn\'t read cleanly. Let\'s scan them again.'**
  String get shareUnreadable;

  /// On the Receive screen in place of the camera view when camera permission was refused.
  ///
  /// In en, this message translates to:
  /// **'Countersink needs the camera to read the codes. You can allow it in the system settings for Countersink.'**
  String get shareNeedsCamera;

  /// Status at the top of the Receive screen before any code is read.
  ///
  /// In en, this message translates to:
  /// **'Point the camera at the code on the other phone.'**
  String get sharePointCamera;

  /// Status on the Receive screen while a single-code transfer is being read; with more codes a count shows instead.
  ///
  /// In en, this message translates to:
  /// **'Reading…'**
  String get shareReading;

  /// total is 2 or more.
  ///
  /// In en, this message translates to:
  /// **'{total, plural, other{{received} of {total} codes received}}'**
  String shareCodesReceived(int received, int total);

  /// codes is a list of code numbers, like “2, 5”.
  ///
  /// In en, this message translates to:
  /// **'Still needed: {codes}'**
  String shareStillNeeded(String codes);

  /// No description provided for @sendToPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Show your counters as codes for another phone to scan.'**
  String get sendToPhoneHint;

  /// No description provided for @receiveFromPhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Scan the codes another phone shows. What arrives is added as new groups.'**
  String get receiveFromPhoneHint;

  /// No description provided for @sendSomeCounters.
  ///
  /// In en, this message translates to:
  /// **'Just some counters'**
  String get sendSomeCounters;

  /// No description provided for @sendWithHistory.
  ///
  /// In en, this message translates to:
  /// **'Counters and their history'**
  String get sendWithHistory;

  /// No description provided for @sendWithHistoryHint.
  ///
  /// In en, this message translates to:
  /// **'Every entry, with its time.'**
  String get sendWithHistoryHint;

  /// No description provided for @sendNumbersOnly.
  ///
  /// In en, this message translates to:
  /// **'Counters and their numbers'**
  String get sendNumbersOnly;

  /// No description provided for @sendNumbersOnlyHint.
  ///
  /// In en, this message translates to:
  /// **'Far fewer codes. Each counter arrives with the number it shows now.'**
  String get sendNumbersOnlyHint;

  /// No description provided for @sendSummary.
  ///
  /// In en, this message translates to:
  /// **'Sending {counters} and {entries}.'**
  String sendSummary(String counters, String entries);

  /// No description provided for @receivedDone.
  ///
  /// In en, this message translates to:
  /// **'Received {counters} and {entries}.'**
  String receivedDone(String counters, String entries);

  /// No description provided for @sendNothingChosen.
  ///
  /// In en, this message translates to:
  /// **'Choose at least one counter to send.'**
  String get sendNothingChosen;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'de',
    'en',
    'es',
    'fr',
    'it',
    'pt',
    'ru',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
