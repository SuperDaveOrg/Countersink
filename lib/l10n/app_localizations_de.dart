// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Countersink';

  @override
  String get addCounter => 'Zähler hinzufügen';

  @override
  String get counterName => 'Name';

  @override
  String get counterDescription => 'Beschreibung (optional)';

  @override
  String get countPerDay => 'Pro Tag zählen';

  @override
  String get countPerDayHint =>
      'Zeigt die Summe von heute und beginnt jeden Tag bei null. Vergangene Tage bleiben erhalten.';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get add => 'Hinzufügen';

  @override
  String get today => 'heute';

  @override
  String get noCounters => 'Hier gibt es noch keine Zähler.';

  @override
  String increment(int step, String name) {
    return '$step zu $name hinzufügen';
  }

  @override
  String decrement(int step, String name) {
    return '$step von $name abziehen';
  }

  @override
  String get firstGroupName => 'Zähler';

  @override
  String get firstCounterName => 'Mein erster Zähler';

  @override
  String get firstCounterDescription =>
      'Zum Zählen auf + tippen. Zum Bearbeiten gedrückt halten.';

  @override
  String get settings => 'Einstellungen';

  @override
  String get about => 'Info';

  @override
  String get aboutCountersink => 'Über Countersink';

  @override
  String get aboutCountersinkHint =>
      'Wo deine Zählungen liegen und warum es kostenlos ist';

  @override
  String get aboutHeadline => 'Deine Zählungen bleiben bei dir.';

  @override
  String get aboutIntro =>
      'Countersink zählt alles mit: Wiederholungen, Reihen, Punkte, Bestände.';

  @override
  String get aboutStaysTitle => 'Alles bleibt auf deinem Telefon';

  @override
  String get aboutStaysBody =>
      'Jede Zählung wird in einer Datenbank auf diesem Gerät gespeichert. Es gibt kein Konto und keinen Server. Woandershin gelangt sie nur, wenn du sie selbst als Sicherungsdatei weitergibst.';

  @override
  String get aboutCannotSeeTitle => 'Wir können es nicht sehen';

  @override
  String get aboutCannotSeeBody =>
      'Countersink wird ganz ohne die Berechtigung gebaut, das Internet zu nutzen. Android setzt das durch, und du kannst es in der Berechtigungsliste der App prüfen.';

  @override
  String get aboutNoAdsTitle => 'Keine Werbung, niemals';

  @override
  String get aboutNoAdsBody =>
      'Zählen sollte nie unterbrochen werden. Countersink bleibt immer kostenlos und quelloffen: keine Werbung, kein Preis, keine Premium-Stufe.';

  @override
  String get aboutCheckTitle => 'Du kannst unsere Arbeit prüfen';

  @override
  String get aboutCheckBody =>
      'Countersink ist Open Source unter der GNU General Public License. Alle können genau nachlesen, was es tut.';

  @override
  String get aboutTradeOff =>
      'Ein Kompromiss, den du kennen solltest: Es gibt keine Kopie in der Cloud. Geht das Telefon verloren oder wird es zurückgesetzt, sind die Zählungen weg. Speichere ab und zu in den Einstellungen eine Sicherungsdatei und bewahre sie woanders als auf diesem Telefon auf.';

  @override
  String get version => 'Version';

  @override
  String get website => 'Website';

  @override
  String get sendFeedback => 'Feedback senden';

  @override
  String get sendFeedbackHint =>
      'Ein Formular auf der Website, in deinem Browser.';

  @override
  String noBrowser(String website) {
    return 'Kein Browser zum Öffnen vorhanden. Besuche stattdessen $website.';
  }

  @override
  String versionNumber(String version) {
    return 'Version $version';
  }

  @override
  String get editCounter => 'Zähler bearbeiten';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get save => 'Speichern';

  @override
  String get delete => 'Löschen';

  @override
  String get undo => 'Rückgängig';

  @override
  String counterDeleted(String name) {
    return '$name gelöscht';
  }

  @override
  String get counterColor => 'Farbe';

  @override
  String get colorClay => 'Ton';

  @override
  String get colorTeal => 'Petrol';

  @override
  String get colorNavy => 'Marineblau';

  @override
  String get colorLavender => 'Lavendel';

  @override
  String get colorGreen => 'Grün';

  @override
  String get colorCustom => 'Eigene';

  @override
  String get groups => 'Gruppen';

  @override
  String get addGroup => 'Gruppe hinzufügen';

  @override
  String get renameGroup => 'Gruppe umbenennen';

  @override
  String get groupName => 'Name';

  @override
  String countersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Zähler',
      one: '1 Zähler',
      zero: 'Keine Zähler',
    );
    return '$_temp0';
  }

  @override
  String deleteNamed(String name) {
    return '$name löschen';
  }

  @override
  String groupDeleted(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$name mit $count Zählern gelöscht',
      one: '$name mit einem Zähler gelöscht',
      zero: '$name gelöscht',
    );
    return '$_temp0';
  }

  @override
  String get lastGroupHint => 'Die letzte Gruppe kann nicht gelöscht werden.';

  @override
  String get counterStep => 'Schritt';

  @override
  String get counterStepHint => 'Wie viel jeder Druck auf + oder − zählt.';

  @override
  String get addAmount => 'Menge hinzufügen';

  @override
  String addAmountTitle(String name) {
    return 'Zu $name hinzufügen';
  }

  @override
  String takeAmountTitle(String name) {
    return 'Von $name abziehen';
  }

  @override
  String get amount => 'Menge';

  @override
  String get takeAway => 'Abziehen';

  @override
  String get setValue => 'Wert festlegen';

  @override
  String get value => 'Wert';

  @override
  String get set => 'Festlegen';

  @override
  String get resetToZero => 'Auf null zurücksetzen';

  @override
  String counterReset(String name) {
    return '$name auf null zurückgesetzt';
  }

  @override
  String get history => 'Verlauf';

  @override
  String get historyEmpty => 'Noch nichts gezählt.';

  @override
  String get dayToday => 'Heute';

  @override
  String get dayYesterday => 'Gestern';

  @override
  String entriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Einträge',
      one: '1 Eintrag',
    );
    return '$_temp0';
  }

  @override
  String get allTime => 'Insgesamt';

  @override
  String get sectionCounting => 'Zählen';

  @override
  String get dayStartsAt => 'Der Tag beginnt um';

  @override
  String get dayStartsAtHint =>
      'Was vor dieser Uhrzeit gezählt wird, gehört zum Vortag.';

  @override
  String get midnight => 'Mitternacht';

  @override
  String get yourData => 'Deine Daten';

  @override
  String get backUp => 'In einer Datei sichern';

  @override
  String get backUpHint => 'Alles, gespeichert, wo du möchtest.';

  @override
  String get restore => 'Aus einer Sicherung wiederherstellen';

  @override
  String get restoreHint => 'Ersetzt, was auf diesem Telefon ist.';

  @override
  String get backupSaved => 'Sicherung gespeichert';

  @override
  String get couldNotSave => 'Die Datei konnte nicht gespeichert werden.';

  @override
  String get couldNotOpen => 'Die Datei konnte nicht geöffnet werden.';

  @override
  String get cantRestore => 'Diese Datei kann nicht wiederhergestellt werden';

  @override
  String get ok => 'OK';

  @override
  String get restoreTitle => 'Alles durch diese Sicherung ersetzen?';

  @override
  String restoreMessage(String groups, String counters, String entries) {
    return 'Sie enthält $groups, $counters und $entries. Alles, was jetzt auf diesem Telefon ist, wird dadurch ersetzt.';
  }

  @override
  String groupsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Gruppen',
      one: '1 Gruppe',
    );
    return '$_temp0';
  }

  @override
  String get replace => 'Ersetzen';

  @override
  String get restored => 'Wiederhergestellt';

  @override
  String get backupNotCountersink => 'Das ist keine Countersink-Sicherung.';

  @override
  String get backupTooNew =>
      'Diese Sicherung stammt von einer neueren Version von Countersink. Aktualisiere die App und versuche es dann erneut.';

  @override
  String backupDamaged(String detail) {
    return 'In dieser Sicherung stimmt etwas nicht, sie wurde nicht wiederhergestellt. Auf diesem Telefon wurde nichts geändert.\n\n$detail';
  }

  @override
  String get colorBrick => 'Ziegelrot';

  @override
  String get colorOchre => 'Ocker';

  @override
  String get colorSand => 'Sand';

  @override
  String get colorOlive => 'Oliv';

  @override
  String get colorSage => 'Salbei';

  @override
  String get colorMoss => 'Moos';

  @override
  String get colorSlate => 'Schiefer';

  @override
  String get colorStorm => 'Sturmblau';

  @override
  String get colorSky => 'Himmelblau';

  @override
  String get colorPlum => 'Pflaume';

  @override
  String get colorRose => 'Altrosa';

  @override
  String get colorCocoa => 'Kakao';

  @override
  String get colorCharcoal => 'Anthrazit';

  @override
  String get colorAubergine => 'Aubergine';

  @override
  String get colorLinen => 'Leinen';

  @override
  String get moreColors => 'Mehr Farben und Muster';

  @override
  String get appearanceTitle => 'Farbe und Muster';

  @override
  String get secondColor => 'Zweite Farbe';

  @override
  String get secondColorHint => 'Geht von Ecke zu Ecke in die erste über.';

  @override
  String get noSecondColor => 'Keine';

  @override
  String get pattern => 'Muster';

  @override
  String get patternNone => 'Ohne';

  @override
  String get patternStripes => 'Streifen';

  @override
  String get patternDots => 'Punkte';

  @override
  String get patternGrid => 'Raster';

  @override
  String get customColor => 'Eigene Farbe';

  @override
  String get hue => 'Farbton';

  @override
  String get saturation => 'Sättigung';

  @override
  String get brightness => 'Helligkeit';

  @override
  String get hexCode => 'Hex-Code';

  @override
  String get useColor => 'Verwenden';

  @override
  String get done => 'Fertig';

  @override
  String get sampleCount => '12';

  @override
  String get reorderCounters => 'Zähler neu anordnen';

  @override
  String get moveToGroup => 'In eine andere Gruppe verschieben';

  @override
  String moveToGroupTitle(String name) {
    return '$name verschieben nach';
  }

  @override
  String movedToGroup(String group) {
    return 'Nach $group verschoben';
  }

  @override
  String get exportCsv => 'Als Tabelle exportieren';

  @override
  String get exportCsvHint => 'Jeder Eintrag als CSV-Datei, je eine Zeile.';

  @override
  String get csvSaved => 'Tabelle gespeichert';

  @override
  String get keepScreenOn => 'Bildschirm eingeschaltet lassen';

  @override
  String get keepScreenOnHint =>
      'Solange Countersink geöffnet ist, wird der Bildschirm nicht gedimmt oder gesperrt.';

  @override
  String get sectionAppearance => 'Darstellung';

  @override
  String get theme => 'Design';

  @override
  String get themeSystem => 'Wie auf dem Telefon';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get counterGoal => 'Ziel (optional)';

  @override
  String get counterGoalHint =>
      'Eine Zahl, die erreicht werden soll. Bei einem Zähler pro Tag: jeden Tag oder in der Woche.';

  @override
  String goalOf(int goal) {
    return 'von $goal';
  }

  @override
  String get goalReached => 'Ziel erreicht';

  @override
  String get dayStreak => 'Tage in Folge';

  @override
  String get bestStreak => 'Beste Serie';

  @override
  String get previousMonth => 'Vorheriger Monat';

  @override
  String get nextMonth => 'Nächster Monat';

  @override
  String daysCount(int count) {
    return '$count Tage';
  }

  @override
  String get averagePerDay => 'Durchschnitt pro Tag';

  @override
  String get totalInRange => 'Summe';

  @override
  String get addEntry => 'Eintrag hinzufügen';

  @override
  String get editEntry => 'Eintrag bearbeiten';

  @override
  String get entryAdded => 'Hinzugefügt';

  @override
  String get entryTaken => 'Abgezogen';

  @override
  String get entryTime => 'Uhrzeit';

  @override
  String get entryDeleted => 'Eintrag gelöscht';

  @override
  String get belowZero => 'Damit würde der Zähler unter null fallen.';

  @override
  String get perDayRefused =>
      'Dieser Zähler kann noch nicht pro Tag zählen. An mindestens einem Tag im Verlauf wurde mehr abgezogen als gezählt, dieser Tag läge also unter null. Korrigiere ihn zuerst im Verlauf.';

  @override
  String get noEntries => 'An diesem Tag wurde nichts gezählt.';

  @override
  String get dayTotal => 'Tagessumme';

  @override
  String get fullScreen => 'Vollbild';

  @override
  String get tapAnywhere => 'Zum Zählen irgendwo tippen';

  @override
  String get closeFullScreen => 'Vollbild schließen';

  @override
  String get volumeKeys => 'Lautstärketasten';

  @override
  String get volumeKeysHint =>
      'Mit den Lautstärketasten des Telefons zählen, solange ein Zähler im Vollbild ist.';

  @override
  String get volumeOff => 'Aus';

  @override
  String get volumeUp => 'Lauter zählt hoch';

  @override
  String get volumeBoth => 'Lauter zählt hoch, leiser zieht ab';

  @override
  String get lockTouch => 'Berührung sperren';

  @override
  String get unlockTouch => 'Zum Entsperren gedrückt halten';

  @override
  String get touchLocked =>
      'Berührung ist gesperrt. Zähle mit den Lautstärketasten.';

  @override
  String get volumeCounts =>
      'Zum Zählen irgendwo tippen oder eine Lautstärketaste drücken';

  @override
  String get language => 'Sprache';

  @override
  String get sameAsPhone => 'Wie auf dem Telefon';

  @override
  String sameAsPhoneNow(String language) {
    return 'Wie auf dem Telefon: $language';
  }

  @override
  String get archive => 'Archivieren';

  @override
  String get unarchive => 'Zurück in die Gruppe';

  @override
  String counterArchived(String name) {
    return '$name archiviert';
  }

  @override
  String get archivedCounters => 'Archivierte Zähler';

  @override
  String get noArchived => 'Nichts archiviert.';

  @override
  String get search => 'Suchen';

  @override
  String get searchHint => 'Zähler suchen';

  @override
  String get noResults => 'Kein Zähler passt dazu.';

  @override
  String get searchPrompt =>
      'Gib den Namen, die Beschreibung oder die Gruppe eines Zählers ein.';

  @override
  String get autoBackup => 'Automatische Sicherung';

  @override
  String get autoBackupHint =>
      'Aus. Wähle einen Ordner, in dem bei jedem Verlassen der App eine Sicherung gespeichert wird.';

  @override
  String autoBackupTo(String folder) {
    return 'In $folder, bei jedem Verlassen der App. Die letzten 7 Tage bleiben erhalten.';
  }

  @override
  String autoBackupFailed(String folder) {
    return 'Die letzte Sicherung konnte nicht in $folder gespeichert werden. Wähle den Ordner erneut.';
  }

  @override
  String get backUpNow => 'Jetzt sichern';

  @override
  String get chooseAnotherFolder => 'Anderen Ordner wählen';

  @override
  String get turnOff => 'Ausschalten';

  @override
  String backedUpTo(String folder) {
    return 'In $folder gesichert';
  }

  @override
  String get goalForEach => 'Das Ziel gilt pro';

  @override
  String get periodDay => 'Tag';

  @override
  String get periodWeek => 'Woche';

  @override
  String goalThisWeek(int done, int goal) {
    return '$done von $goal diese Woche';
  }

  @override
  String get weekStreak => 'Wochen in Folge';

  @override
  String get buzzEvery => 'Vibrieren alle (optional)';

  @override
  String get buzzEveryHint =>
      'Eine doppelte Vibration, sobald der Zähler ein Vielfaches davon erreicht, etwa alle 10.';

  @override
  String get weekStartsOn => 'Wochenbeginn';

  @override
  String get weekStartsOnHint => 'Für Wochenziele und den Kalender.';

  @override
  String get addToHomeScreen => 'Zum Startbildschirm hinzufügen';

  @override
  String get quickTile => 'Kachel in den Schnelleinstellungen';

  @override
  String get quickTileHint =>
      'Aus. Einen Zähler auswählen, zu dem aus den Schnelleinstellungen des Telefons hinzugezählt wird, ohne die App zu öffnen.';

  @override
  String quickTileOn(String name) {
    return 'Zählt zu $name hinzu, aus den Schnelleinstellungen des Telefons.';
  }

  @override
  String get chooseCounter => 'Zähler auswählen';

  @override
  String get chooseAnotherCounter => 'Anderen Zähler auswählen';

  @override
  String get quickTileHowTo =>
      'So wird die Kachel hinzugefügt: Schnelleinstellungen des Telefons öffnen, auf den Stift tippen und die Countersink-Kachel hineinziehen.';

  @override
  String get calculated => 'Aus anderen Zählern berechnet';

  @override
  String get calculatedOff => 'Aus. Wird von Hand gezählt, mit Plus und Minus.';

  @override
  String get formulaTitle => 'Berechneter Zähler';

  @override
  String get formulaIntro =>
      'Ein berechneter Zähler wird nicht selbst gezählt. Er zeigt eine Zahl, die sich aus anderen Zählern ergibt, und ändert sich mit ihnen.';

  @override
  String get formulaNone => 'Von Hand gezählt';

  @override
  String get formulaSum => 'Eine Summe';

  @override
  String get formulaSumHint => 'Mehrere Zähler zusammengezählt.';

  @override
  String get formulaDifference => 'Eine Differenz';

  @override
  String get formulaDifferenceHint =>
      'Ein Zähler abzüglich der anderen. Rein, abzüglich raus.';

  @override
  String get formulaPercent => 'Ein Anteil in Prozent';

  @override
  String get formulaPercentHint =>
      'Ein Zähler als Anteil an mehreren zusammen.';

  @override
  String get formulaEvery => 'Volle Runden';

  @override
  String get formulaEveryHint =>
      'Wie oft ein anderer Zähler eine Runde vollendet hat: alle 108 Perlen, alle 8 Reihen.';

  @override
  String get sectionShows => 'Was er zeigt';

  @override
  String get formulaAddUp => 'Zusammenzählen';

  @override
  String get formulaStartWith => 'Ausgehen von';

  @override
  String get formulaTakeAway => 'Abziehen';

  @override
  String get formulaShareOf => 'Der Anteil von';

  @override
  String get formulaTogetherWith => 'An der Summe mit';

  @override
  String get formulaRoundsOf => 'Runden von';

  @override
  String get formulaAllTime => 'Laufende Summe behalten';

  @override
  String get formulaAllTimeHint =>
      'Zähler pro Tag zählen mit allem, was sie je gezählt haben, nicht nur mit heute. Sie beginnen jeden Tag bei null; diese Zahl läuft weiter.';

  @override
  String get formulaStartFrom => 'Beginnen bei (optional)';

  @override
  String get formulaStartFromHint =>
      'Eine Zahl, bei der die Summe schon steht, aus der Zeit, bevor hier gezählt wurde. Was gezählt wird, kommt dazu.';

  @override
  String get roundSize => 'Eine Runde sind';

  @override
  String get roundSizeHint => 'Wie viele eine Runde ergeben.';

  @override
  String lineSum(String names) {
    return 'Summe von $names';
  }

  @override
  String lineDifference(String first, String others) {
    return '$first abzüglich $others';
  }

  @override
  String linePercent(String first, String all) {
    return '$first als Anteil an $all';
  }

  @override
  String lineEvery(int size, String name) {
    return 'Runden zu $size in $name';
  }

  @override
  String lineTowardNext(int count) {
    return '$count zur nächsten';
  }

  @override
  String get lineBroken => 'Der zugrunde liegende Zähler ist nicht mehr da';

  @override
  String get noOrdinaryCounters =>
      'Zuerst einen Zähler zum Zählen von Hand anlegen. Ein berechneter ergibt sich aus diesen.';

  @override
  String get emptyGroup => 'Leere Gruppe';

  @override
  String get emptyGroupHint => 'Benennen und dann eigene Zähler hinzufügen.';

  @override
  String get readyMadeSets => 'Fertige Sets';

  @override
  String copyGroupNamed(String name) {
    return '$name kopieren, ohne die Zählerstände';
  }

  @override
  String groupCopyName(String name) {
    return '$name (Kopie)';
  }

  @override
  String get presetRows => 'Reihen und Rapporte';

  @override
  String get presetRowsHint =>
      'Reihen und die Rapporte zu je 8, die sie ergeben.';

  @override
  String get presetBeads => 'Perlen';

  @override
  String get presetBeadsHint =>
      'Perlen und die Runden zu je 108, die sie ergeben.';

  @override
  String get presetInOut => 'Rein und raus';

  @override
  String get presetInOutHint =>
      'Hineingezählt, hinausgezählt und wie viele drinnen sind.';

  @override
  String get presetScore => 'Spielstand';

  @override
  String get presetScoreHint => 'Zwei Punktestände.';

  @override
  String get presetMade => 'Treffer und Fehlversuche';

  @override
  String get presetMadeHint =>
      'Treffer, Fehlversuche und der Anteil der Treffer.';

  @override
  String get nameRows => 'Reihen';

  @override
  String get nameRepeats => 'Rapporte';

  @override
  String get nameBeads => 'Perlen';

  @override
  String get nameRounds => 'Runden';

  @override
  String get nameIn => 'Rein';

  @override
  String get nameOut => 'Raus';

  @override
  String get nameInside => 'Drinnen';

  @override
  String get nameUs => 'Wir';

  @override
  String get nameThem => 'Die anderen';

  @override
  String get nameMade => 'Treffer';

  @override
  String get nameMissed => 'Fehlversuche';

  @override
  String get nameMadeShare => 'Treffer in Prozent';

  @override
  String get importFromApp => 'Aus einer anderen App importieren';

  @override
  String get importFromAppHint =>
      'Zähler aus BetterCounter, Counter oder Simple Counter, als neue Gruppen hinzugefügt.';

  @override
  String get importChooseApp => 'Aus welcher App stammt die Datei?';

  @override
  String get importBetterCounterHint =>
      'Die exportierte CSV-Datei. Jede Zählung kommt mit ihrer Uhrzeit.';

  @override
  String get importCounterHint =>
      'Die exportierte CSV-Datei. Jeder Zähler kommt mit seinem Stand.';

  @override
  String get importSimpleCounterHint =>
      'Die JSON-Sicherung. Aus Labels werden Gruppen.';

  @override
  String get importedGroupName => 'Importiert';

  @override
  String get cantImport => 'Diese Datei kann nicht importiert werden';

  @override
  String importNotFrom(String app) {
    return 'Das sieht nicht nach einer Datei aus $app aus.';
  }

  @override
  String get importEmpty => 'In dieser Datei sind keine Zähler.';

  @override
  String importIsBackup(String restore) {
    return 'Das ist eine Countersink-Sicherung. Dafür ist „$restore“ da.';
  }

  @override
  String importDone(String counters, String entries) {
    return '$counters und $entries importiert.';
  }

  @override
  String importSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Zeilen konnten nicht gelesen werden.',
      one: '1 Zeile konnte nicht gelesen werden.',
    );
    return '$_temp0';
  }

  @override
  String reachedGoal(String name, int goal) {
    return '$name hat $goal erreicht';
  }

  @override
  String get goalHintCalculated =>
      'Eine Zahl, die erreicht werden soll. Eine Meldung sagt Bescheid, wenn es so weit ist.';

  @override
  String get sendToPhone => 'An ein anderes Telefon senden';

  @override
  String get receiveFromPhone => 'Von einem anderen Telefon empfangen';

  @override
  String get shareWhatToSend => 'Was möchtest du senden?';

  @override
  String get sendEverything => 'Alles';

  @override
  String get sendEverythingHint => 'Umzug auf ein neues Telefon.';

  @override
  String get shareWhatToInclude => 'Was enthalten sein soll';

  @override
  String get shareShowCodes => 'Codes anzeigen';

  @override
  String get shareHowToReceive =>
      'Öffne auf dem anderen Telefon Countersink, geh zu Einstellungen → Von einem anderen Telefon empfangen und richte die Kamera auf diesen Bildschirm.';

  @override
  String shareCodeOf(int index, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: 'Code $index von $total',
    );
    return '$_temp0';
  }

  @override
  String get sharePreviousCode => 'Vorheriger Code';

  @override
  String get sharePause => 'Pause';

  @override
  String get sharePlay => 'Abspielen';

  @override
  String get shareNextCode => 'Nächster Code';

  @override
  String get shareCodesChange =>
      'Die Codes wechseln von selbst. Das andere Telefon sammelt sie in beliebiger Reihenfolge.';

  @override
  String get shareNotCountersink => 'Dieser Code stammt nicht von Countersink.';

  @override
  String get shareNewerVersion =>
      'Das andere Telefon hat eine neuere Version von Countersink. Aktualisiere zuerst dieses hier.';

  @override
  String get shareRestarted =>
      'Das andere Telefon hat neu angefangen. Die neuen Codes werden gesammelt.';

  @override
  String get shareUnreadable =>
      'Einige Codes wurden nicht sauber gelesen. Scannen wir sie noch einmal.';

  @override
  String get shareNeedsCamera =>
      'Countersink braucht die Kamera, um die Codes zu lesen. Du kannst sie in den Systemeinstellungen für Countersink erlauben.';

  @override
  String get sharePointCamera =>
      'Richte die Kamera auf den Code auf dem anderen Telefon.';

  @override
  String get shareReading => 'Wird gelesen…';

  @override
  String shareCodesReceived(int received, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$received von $total Codes empfangen',
    );
    return '$_temp0';
  }

  @override
  String shareStillNeeded(String codes) {
    return 'Noch benötigt: $codes';
  }

  @override
  String get sendToPhoneHint =>
      'Zeigt deine Zähler als Codes, die ein anderes Telefon scannen kann.';

  @override
  String get receiveFromPhoneHint =>
      'Die Codes scannen, die ein anderes Telefon zeigt. Was ankommt, wird als neue Gruppen hinzugefügt.';

  @override
  String get sendSomeCounters => 'Nur einige Zähler';

  @override
  String get sendWithHistory => 'Zähler mit ihrem Verlauf';

  @override
  String get sendWithHistoryHint => 'Jeder Eintrag mit seiner Uhrzeit.';

  @override
  String get sendNumbersOnly => 'Zähler mit ihrem Stand';

  @override
  String get sendNumbersOnlyHint =>
      'Viel weniger Codes. Jeder Zähler kommt mit der Zahl an, die er jetzt zeigt.';

  @override
  String sendSummary(String counters, String entries) {
    return 'Gesendet werden $counters und $entries.';
  }

  @override
  String receivedDone(String counters, String entries) {
    return '$counters und $entries empfangen.';
  }

  @override
  String get sendNothingChosen =>
      'Mindestens einen Zähler zum Senden auswählen.';
}
