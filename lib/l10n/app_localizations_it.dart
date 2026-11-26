// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Countersink';

  @override
  String get addCounter => 'Aggiungi contatore';

  @override
  String get counterName => 'Nome';

  @override
  String get counterDescription => 'Descrizione (facoltativa)';

  @override
  String get countPerDay => 'Conta per giorno';

  @override
  String get countPerDayHint =>
      'Mostra il totale di oggi e riparte da zero ogni giorno. I giorni passati vengono conservati.';

  @override
  String get cancel => 'Annulla';

  @override
  String get add => 'Aggiungi';

  @override
  String get today => 'oggi';

  @override
  String get noCounters => 'Qui non ci sono ancora contatori.';

  @override
  String increment(int step, String name) {
    return 'Aggiungi $step a $name';
  }

  @override
  String decrement(int step, String name) {
    return 'Togli $step da $name';
  }

  @override
  String get firstGroupName => 'Contatori';

  @override
  String get firstCounterName => 'Il mio primo contatore';

  @override
  String get firstCounterDescription =>
      'Tocca + per contare. Tieni premuto per modificare.';

  @override
  String get settings => 'Impostazioni';

  @override
  String get about => 'Informazioni';

  @override
  String get aboutCountersink => 'Informazioni su Countersink';

  @override
  String get aboutCountersinkHint =>
      'Dove si trovano i tuoi conteggi e perché è gratis';

  @override
  String get aboutHeadline => 'I tuoi conteggi restano con te.';

  @override
  String get aboutIntro =>
      'Countersink tiene il conto di qualsiasi cosa: ripetizioni, giri, punti, scorte.';

  @override
  String get aboutStaysTitle => 'Resta sul tuo telefono';

  @override
  String get aboutStaysBody =>
      'Ogni conteggio viene scritto in un database su questo dispositivo. Non c\'è nessun account e nessun server. Va altrove solo se lo sposti tu, come file di backup.';

  @override
  String get aboutCannotSeeTitle => 'Noi non possiamo vederlo';

  @override
  String get aboutCannotSeeBody =>
      'Countersink è realizzata senza alcun permesso di usare internet. Lo garantisce Android, e puoi verificarlo nell\'elenco dei permessi dell\'app.';

  @override
  String get aboutNoAdsTitle => 'Niente pubblicità, mai';

  @override
  String get aboutNoAdsBody =>
      'Contare non dovrebbe mai essere interrotto. Countersink sarà sempre gratuito e open source: niente pubblicità, nessun prezzo, nessuna versione premium.';

  @override
  String get aboutCheckTitle => 'Puoi verificare il nostro lavoro';

  @override
  String get aboutCheckBody =>
      'Countersink è open source, con licenza GNU General Public License. Chiunque può leggere esattamente cosa fa.';

  @override
  String get aboutTradeOff =>
      'Un compromesso da conoscere: non esiste una copia nel cloud, quindi se perdi o ripristini il telefono perdi i conteggi. Ogni tanto salva un file di backup dalle Impostazioni e conservalo altrove, non su questo telefono.';

  @override
  String get version => 'Versione';

  @override
  String get website => 'Sito web';

  @override
  String get sendFeedback => 'Invia feedback';

  @override
  String get sendFeedbackHint => 'Un modulo sul sito web, nel tuo browser.';

  @override
  String noBrowser(String website) {
    return 'Nessun browser per aprire il link. Visita $website.';
  }

  @override
  String versionNumber(String version) {
    return 'Versione $version';
  }

  @override
  String get editCounter => 'Modifica contatore';

  @override
  String get edit => 'Modifica';

  @override
  String get save => 'Salva';

  @override
  String get delete => 'Elimina';

  @override
  String get undo => 'Annulla';

  @override
  String counterDeleted(String name) {
    return 'Eliminato: $name';
  }

  @override
  String get counterColor => 'Colore';

  @override
  String get colorClay => 'Argilla';

  @override
  String get colorTeal => 'Verde petrolio';

  @override
  String get colorNavy => 'Blu navy';

  @override
  String get colorLavender => 'Lavanda';

  @override
  String get colorGreen => 'Verde';

  @override
  String get colorCustom => 'Personalizzato';

  @override
  String get groups => 'Gruppi';

  @override
  String get addGroup => 'Aggiungi gruppo';

  @override
  String get renameGroup => 'Rinomina il gruppo';

  @override
  String get groupName => 'Nome';

  @override
  String countersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contatori',
      one: '1 contatore',
      zero: 'Nessun contatore',
    );
    return '$_temp0';
  }

  @override
  String deleteNamed(String name) {
    return 'Elimina $name';
  }

  @override
  String groupDeleted(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Eliminato: $name e i suoi $count contatori',
      one: 'Eliminato: $name e il suo contatore',
      zero: 'Eliminato: $name',
    );
    return '$_temp0';
  }

  @override
  String get lastGroupHint => 'L\'ultimo gruppo non può essere eliminato.';

  @override
  String get counterStep => 'Passo';

  @override
  String get counterStepHint => 'Quanto conta ogni pressione di + o −.';

  @override
  String get addAmount => 'Aggiungi una quantità';

  @override
  String addAmountTitle(String name) {
    return 'Aggiungi a $name';
  }

  @override
  String takeAmountTitle(String name) {
    return 'Togli da $name';
  }

  @override
  String get amount => 'Quantità';

  @override
  String get takeAway => 'Togli';

  @override
  String get setValue => 'Imposta il valore';

  @override
  String get value => 'Valore';

  @override
  String get set => 'Imposta';

  @override
  String get resetToZero => 'Azzera';

  @override
  String counterReset(String name) {
    return '$name: azzerato';
  }

  @override
  String get history => 'Storico';

  @override
  String get historyEmpty => 'Non è stato ancora contato nulla.';

  @override
  String get dayToday => 'Oggi';

  @override
  String get dayYesterday => 'Ieri';

  @override
  String entriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count voci',
      one: '1 voce',
    );
    return '$_temp0';
  }

  @override
  String get allTime => 'Da sempre';

  @override
  String get sectionCounting => 'Conteggio';

  @override
  String get dayStartsAt => 'Il giorno inizia alle';

  @override
  String get dayStartsAtHint =>
      'Ciò che viene contato prima di quest\'ora appartiene al giorno prima.';

  @override
  String get midnight => 'Mezzanotte';

  @override
  String get yourData => 'I tuoi dati';

  @override
  String get backUp => 'Esegui il backup su un file';

  @override
  String get backUpHint => 'Tutto, salvato dove scegli tu.';

  @override
  String get restore => 'Ripristina da un backup';

  @override
  String get restoreHint => 'Sostituisce quello che c\'è su questo telefono.';

  @override
  String get backupSaved => 'Backup salvato';

  @override
  String get couldNotSave => 'Impossibile salvare il file.';

  @override
  String get couldNotOpen => 'Impossibile aprire il file.';

  @override
  String get cantRestore => 'Impossibile ripristinare questo file';

  @override
  String get ok => 'OK';

  @override
  String get restoreTitle => 'Sostituire tutto con questo backup?';

  @override
  String restoreMessage(String groups, String counters, String entries) {
    return 'Contiene $groups, $counters e $entries. Tutto ciò che c\'è ora su questo telefono verrà sostituito.';
  }

  @override
  String groupsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count gruppi',
      one: '1 gruppo',
    );
    return '$_temp0';
  }

  @override
  String get replace => 'Sostituisci';

  @override
  String get restored => 'Ripristinato';

  @override
  String get backupNotCountersink => 'Questo non è un backup di Countersink.';

  @override
  String get backupTooNew =>
      'Questo backup è stato creato da una versione più recente di Countersink. Aggiorna l\'app e riprova.';

  @override
  String backupDamaged(String detail) {
    return 'Questo backup contiene un errore e non è stato ripristinato. Su questo telefono non è stato modificato nulla.\n\n$detail';
  }

  @override
  String get colorBrick => 'Mattone';

  @override
  String get colorOchre => 'Ocra';

  @override
  String get colorSand => 'Sabbia';

  @override
  String get colorOlive => 'Oliva';

  @override
  String get colorSage => 'Salvia';

  @override
  String get colorMoss => 'Muschio';

  @override
  String get colorSlate => 'Ardesia';

  @override
  String get colorStorm => 'Tempesta';

  @override
  String get colorSky => 'Cielo';

  @override
  String get colorPlum => 'Prugna';

  @override
  String get colorRose => 'Rosa';

  @override
  String get colorCocoa => 'Cacao';

  @override
  String get colorCharcoal => 'Antracite';

  @override
  String get colorAubergine => 'Melanzana';

  @override
  String get colorLinen => 'Lino';

  @override
  String get moreColors => 'Altri colori e motivi';

  @override
  String get appearanceTitle => 'Colore e motivo';

  @override
  String get secondColor => 'Secondo colore';

  @override
  String get secondColorHint => 'Sfuma nel primo, da un angolo all\'altro.';

  @override
  String get noSecondColor => 'Nessuno';

  @override
  String get pattern => 'Motivo';

  @override
  String get patternNone => 'Tinta unita';

  @override
  String get patternStripes => 'Righe';

  @override
  String get patternDots => 'Pois';

  @override
  String get patternGrid => 'Griglia';

  @override
  String get customColor => 'Colore personalizzato';

  @override
  String get hue => 'Tonalità';

  @override
  String get saturation => 'Saturazione';

  @override
  String get brightness => 'Luminosità';

  @override
  String get hexCode => 'Codice esadecimale';

  @override
  String get useColor => 'Usa';

  @override
  String get done => 'Fatto';

  @override
  String get sampleCount => '12';

  @override
  String get reorderCounters => 'Riordina i contatori';

  @override
  String get moveToGroup => 'Sposta in un altro gruppo';

  @override
  String moveToGroupTitle(String name) {
    return 'Sposta $name in';
  }

  @override
  String movedToGroup(String group) {
    return 'Spostato in $group';
  }

  @override
  String get exportCsv => 'Esporta come foglio di calcolo';

  @override
  String get exportCsvHint => 'Ogni voce in un file CSV, una riga ciascuna.';

  @override
  String get csvSaved => 'Foglio di calcolo salvato';

  @override
  String get keepScreenOn => 'Mantieni lo schermo acceso';

  @override
  String get keepScreenOnHint =>
      'Finché Countersink è aperto, lo schermo non si attenua e non si blocca.';

  @override
  String get sectionAppearance => 'Aspetto';

  @override
  String get theme => 'Tema';

  @override
  String get themeSystem => 'Come il telefono';

  @override
  String get themeLight => 'Chiaro';

  @override
  String get themeDark => 'Scuro';

  @override
  String get counterGoal => 'Obiettivo (facoltativo)';

  @override
  String get counterGoalHint =>
      'Un numero da raggiungere. Per un contatore giornaliero, ogni giorno o nella settimana.';

  @override
  String goalOf(int goal) {
    return 'di $goal';
  }

  @override
  String get goalReached => 'Obiettivo raggiunto';

  @override
  String get dayStreak => 'Giorni di fila';

  @override
  String get bestStreak => 'Serie migliore';

  @override
  String get previousMonth => 'Mese precedente';

  @override
  String get nextMonth => 'Mese successivo';

  @override
  String daysCount(int count) {
    return '$count giorni';
  }

  @override
  String get averagePerDay => 'Media al giorno';

  @override
  String get totalInRange => 'Totale';

  @override
  String get addEntry => 'Aggiungi voce';

  @override
  String get editEntry => 'Modifica voce';

  @override
  String get entryAdded => 'Aggiunto';

  @override
  String get entryTaken => 'Tolto';

  @override
  String get entryTime => 'Ora';

  @override
  String get entryDeleted => 'Voce eliminata';

  @override
  String get belowZero => 'Così il conteggio scenderebbe sotto zero.';

  @override
  String get perDayRefused =>
      'Questo contatore non può ancora contare per giorno. In almeno un giorno dello storico è stato tolto più di quanto contato, quindi quel giorno scenderebbe sotto zero. Correggilo prima nello storico.';

  @override
  String get noEntries => 'In questo giorno non è stato contato nulla.';

  @override
  String get dayTotal => 'Totale del giorno';

  @override
  String get fullScreen => 'Schermo intero';

  @override
  String get tapAnywhere => 'Tocca ovunque per contare';

  @override
  String get closeFullScreen => 'Chiudi lo schermo intero';

  @override
  String get volumeKeys => 'Pulsanti del volume';

  @override
  String get volumeKeysHint =>
      'Conta con i pulsanti del volume del telefono mentre un contatore è a schermo intero.';

  @override
  String get volumeOff => 'Disattivati';

  @override
  String get volumeUp => 'Volume su aggiunge';

  @override
  String get volumeBoth => 'Su aggiunge, giù toglie';

  @override
  String get lockTouch => 'Blocca il tocco';

  @override
  String get unlockTouch => 'Tieni premuto per sbloccare';

  @override
  String get touchLocked =>
      'Il tocco è bloccato. Conta con i pulsanti del volume.';

  @override
  String get volumeCounts =>
      'Tocca ovunque o premi un pulsante del volume per contare';

  @override
  String get language => 'Lingua';

  @override
  String get sameAsPhone => 'Come il telefono';

  @override
  String sameAsPhoneNow(String language) {
    return 'Come il telefono: $language';
  }

  @override
  String get archive => 'Archivia';

  @override
  String get unarchive => 'Rimetti nel gruppo';

  @override
  String counterArchived(String name) {
    return 'Archiviato: $name';
  }

  @override
  String get archivedCounters => 'Contatori archiviati';

  @override
  String get noArchived => 'Niente in archivio.';

  @override
  String get search => 'Cerca';

  @override
  String get searchHint => 'Cerca contatori';

  @override
  String get noResults => 'Nessun contatore corrisponde.';

  @override
  String get searchPrompt =>
      'Scrivi il nome di un contatore, la sua descrizione o il suo gruppo.';

  @override
  String get autoBackup => 'Backup automatico';

  @override
  String get autoBackupHint =>
      'Disattivato. Scegli una cartella in cui salvare un backup ogni volta che esci dall\'app.';

  @override
  String autoBackupTo(String folder) {
    return 'In $folder, ogni volta che esci dall\'app. Vengono conservati gli ultimi 7 giorni.';
  }

  @override
  String autoBackupFailed(String folder) {
    return 'Non è stato possibile salvare l\'ultimo backup in $folder. Scegli di nuovo la cartella.';
  }

  @override
  String get backUpNow => 'Esegui il backup ora';

  @override
  String get chooseAnotherFolder => 'Scegli un\'altra cartella';

  @override
  String get turnOff => 'Disattiva';

  @override
  String backedUpTo(String folder) {
    return 'Backup salvato in $folder';
  }

  @override
  String get goalForEach => 'L\'obiettivo vale per ogni';

  @override
  String get periodDay => 'Giorno';

  @override
  String get periodWeek => 'Settimana';

  @override
  String goalThisWeek(int done, int goal) {
    return '$done di $goal questa settimana';
  }

  @override
  String get weekStreak => 'Settimane di fila';

  @override
  String get buzzEvery => 'Vibra ogni (facoltativo)';

  @override
  String get buzzEveryHint =>
      'Una doppia vibrazione ogni volta che il conteggio supera un multiplo di questo numero, ad esempio ogni 10.';

  @override
  String get weekStartsOn => 'Inizio della settimana';

  @override
  String get weekStartsOnHint =>
      'Per gli obiettivi settimanali e il calendario.';

  @override
  String get addToHomeScreen => 'Aggiungi alla schermata Home';

  @override
  String get quickTile => 'Riquadro delle impostazioni rapide';

  @override
  String get quickTileHint =>
      'Disattivato. Scegli un contatore a cui aggiungere dalle impostazioni rapide del telefono, senza aprire l\'app.';

  @override
  String quickTileOn(String name) {
    return 'Aggiunge a $name, dalle impostazioni rapide del telefono.';
  }

  @override
  String get chooseCounter => 'Scegli un contatore';

  @override
  String get chooseAnotherCounter => 'Scegli un altro contatore';

  @override
  String get quickTileHowTo =>
      'Per aggiungere il riquadro: apri le impostazioni rapide del telefono, tocca la matita e trascina il riquadro di Countersink.';

  @override
  String get calculated => 'Calcolato da altri contatori';

  @override
  String get calculatedOff => 'Disattivato. Si conta a mano, con più e meno.';

  @override
  String get formulaTitle => 'Contatore calcolato';

  @override
  String get formulaIntro =>
      'Un contatore calcolato non si conta a mano. Mostra un numero ricavato da altri contatori e cambia con loro.';

  @override
  String get formulaNone => 'Contato a mano';

  @override
  String get formulaSum => 'Un totale';

  @override
  String get formulaSumHint => 'Più contatori sommati.';

  @override
  String get formulaDifference => 'Una differenza';

  @override
  String get formulaDifferenceHint =>
      'Un contatore meno gli altri. Entrate meno uscite.';

  @override
  String get formulaPercent => 'Una quota, in percentuale';

  @override
  String get formulaPercentHint =>
      'Un contatore come quota di più contatori insieme.';

  @override
  String get formulaEvery => 'Giri completi';

  @override
  String get formulaEveryHint =>
      'Quanti giri ha fatto un altro contatore: ogni 108 grani, ogni 8 ferri.';

  @override
  String get sectionShows => 'Che cosa mostra';

  @override
  String get formulaAddUp => 'Somma';

  @override
  String get formulaStartWith => 'Parti da';

  @override
  String get formulaTakeAway => 'Togli';

  @override
  String get formulaShareOf => 'La quota di';

  @override
  String get formulaTogetherWith => 'Nel totale insieme a';

  @override
  String get formulaRoundsOf => 'Giri di';

  @override
  String get formulaAllTime => 'Mantieni un totale progressivo';

  @override
  String get formulaAllTimeHint =>
      'I contatori per giorno valgono per tutto ciò che hanno contato, non solo per oggi. Ripartono da zero ogni giorno; questo numero continua.';

  @override
  String get formulaStartFrom => 'Parti da (facoltativo)';

  @override
  String get formulaStartFromHint =>
      'Un numero a cui il totale è già arrivato, prima di essere contato qui. Ciò che si conta si aggiunge.';

  @override
  String get roundSize => 'Un giro è di';

  @override
  String get roundSizeHint => 'Quanti ne servono per un giro.';

  @override
  String lineSum(String names) {
    return 'Totale di $names';
  }

  @override
  String lineDifference(String first, String others) {
    return '$first meno $others';
  }

  @override
  String linePercent(String first, String all) {
    return '$first come quota di $all';
  }

  @override
  String lineEvery(int size, String name) {
    return 'Giri da $size in $name';
  }

  @override
  String lineTowardNext(int count) {
    return '$count verso il prossimo';
  }

  @override
  String get lineBroken => 'Il contatore da cui era calcolato non c\'è più';

  @override
  String get noOrdinaryCounters =>
      'Aggiungi prima un contatore da contare a mano. Uno calcolato si ricava da quelli.';

  @override
  String get emptyGroup => 'Gruppo vuoto';

  @override
  String get emptyGroupHint => 'Dagli un nome, poi aggiungi i tuoi contatori.';

  @override
  String get readyMadeSets => 'Insiemi già pronti';

  @override
  String copyGroupNamed(String name) {
    return 'Copia $name, senza i conteggi';
  }

  @override
  String groupCopyName(String name) {
    return '$name (copia)';
  }

  @override
  String get presetRows => 'Ferri e ripetizioni';

  @override
  String get presetRowsHint => 'I ferri, e le ripetizioni da 8 che formano.';

  @override
  String get presetBeads => 'Grani';

  @override
  String get presetBeadsHint => 'I grani, e i giri da 108 che formano.';

  @override
  String get presetInOut => 'Entrate e uscite';

  @override
  String get presetInOutHint => 'Chi entra, chi esce e quanti sono dentro.';

  @override
  String get presetScore => 'Segnapunti';

  @override
  String get presetScoreHint => 'Due punteggi da tenere.';

  @override
  String get presetMade => 'Riusciti e mancati';

  @override
  String get presetMadeHint => 'Riusciti, mancati e la quota dei riusciti.';

  @override
  String get nameRows => 'Ferri';

  @override
  String get nameRepeats => 'Ripetizioni';

  @override
  String get nameBeads => 'Grani';

  @override
  String get nameRounds => 'Giri';

  @override
  String get nameIn => 'Entrati';

  @override
  String get nameOut => 'Usciti';

  @override
  String get nameInside => 'Dentro';

  @override
  String get nameUs => 'Noi';

  @override
  String get nameThem => 'Loro';

  @override
  String get nameMade => 'Riusciti';

  @override
  String get nameMissed => 'Mancati';

  @override
  String get nameMadeShare => 'Riusciti in percentuale';

  @override
  String get importFromApp => 'Importa da un\'altra app';

  @override
  String get importFromAppHint =>
      'Contatori da BetterCounter, Counter o Simple Counter, aggiunti come nuovi gruppi.';

  @override
  String get importChooseApp => 'Da quale app proviene il file?';

  @override
  String get importBetterCounterHint =>
      'Il suo file CSV esportato. Ogni conteggio arriva con il suo orario.';

  @override
  String get importCounterHint =>
      'Il suo file CSV esportato. Ogni contatore arriva con il suo numero.';

  @override
  String get importSimpleCounterHint =>
      'Il suo backup JSON. Le etichette diventano gruppi.';

  @override
  String get importedGroupName => 'Importati';

  @override
  String get cantImport => 'Impossibile importare questo file';

  @override
  String importNotFrom(String app) {
    return 'Non sembra un file di $app.';
  }

  @override
  String get importEmpty => 'In questo file non ci sono contatori.';

  @override
  String importIsBackup(String restore) {
    return 'È un backup di Countersink. Per questo c\'è «$restore».';
  }

  @override
  String importDone(String counters, String entries) {
    return 'Importati $counters e $entries.';
  }

  @override
  String importSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Non è stato possibile leggere $count righe.',
      one: 'Non è stato possibile leggere 1 riga.',
    );
    return '$_temp0';
  }

  @override
  String reachedGoal(String name, int goal) {
    return '$name ha raggiunto $goal';
  }

  @override
  String get goalHintCalculated =>
      'Un numero da raggiungere. Un messaggio avvisa quando ci si arriva.';

  @override
  String get sendToPhone => 'Invia a un altro telefono';

  @override
  String get receiveFromPhone => 'Ricevi da un altro telefono';

  @override
  String get shareWhatToSend => 'Cosa vuoi inviare?';

  @override
  String get sendEverything => 'Tutto';

  @override
  String get sendEverythingHint => 'Per passare a un nuovo telefono.';

  @override
  String get shareWhatToInclude => 'Cosa includere';

  @override
  String get shareShowCodes => 'Mostra i codici';

  @override
  String get shareHowToReceive =>
      'Sull’altro telefono apri Countersink, vai in Impostazioni → Ricevi da un altro telefono, e inquadra questo schermo con la fotocamera.';

  @override
  String shareCodeOf(int index, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: 'Codice $index di $total',
    );
    return '$_temp0';
  }

  @override
  String get sharePreviousCode => 'Codice precedente';

  @override
  String get sharePause => 'Pausa';

  @override
  String get sharePlay => 'Riprendi';

  @override
  String get shareNextCode => 'Codice successivo';

  @override
  String get shareCodesChange =>
      'I codici cambiano da soli. L’altro telefono li raccoglie in qualsiasi ordine.';

  @override
  String get shareNotCountersink => 'Questo codice non è di Countersink.';

  @override
  String get shareNewerVersion =>
      'L’altro telefono ha una versione più recente di Countersink. Prima aggiorna questo.';

  @override
  String get shareRestarted =>
      'L’altro telefono è ripartito da capo. Raccolgo i nuovi codici.';

  @override
  String get shareUnreadable =>
      'Alcuni codici non sono stati letti bene. Scansioniamoli di nuovo.';

  @override
  String get shareNeedsCamera =>
      'Countersink ha bisogno della fotocamera per leggere i codici. Puoi consentirlo nelle impostazioni di sistema per Countersink.';

  @override
  String get sharePointCamera =>
      'Inquadra il codice sull’altro telefono con la fotocamera.';

  @override
  String get shareReading => 'Lettura…';

  @override
  String shareCodesReceived(int received, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$received codici su $total ricevuti',
    );
    return '$_temp0';
  }

  @override
  String shareStillNeeded(String codes) {
    return 'Mancano ancora: $codes';
  }

  @override
  String get sendToPhoneHint =>
      'Mostra i tuoi contatori come codici da far scansionare a un altro telefono.';

  @override
  String get receiveFromPhoneHint =>
      'Scansiona i codici mostrati da un altro telefono. Ciò che arriva viene aggiunto come nuovi gruppi.';

  @override
  String get sendSomeCounters => 'Solo alcuni contatori';

  @override
  String get sendWithHistory => 'Contatori e il loro storico';

  @override
  String get sendWithHistoryHint => 'Ogni voce, con il suo orario.';

  @override
  String get sendNumbersOnly => 'Contatori e i loro numeri';

  @override
  String get sendNumbersOnlyHint =>
      'Molti meno codici. Ogni contatore arriva con il numero che mostra ora.';

  @override
  String sendSummary(String counters, String entries) {
    return 'Invio di $counters e $entries.';
  }

  @override
  String receivedDone(String counters, String entries) {
    return 'Ricevuti $counters e $entries.';
  }

  @override
  String get sendNothingChosen => 'Scegli almeno un contatore da inviare.';
}
