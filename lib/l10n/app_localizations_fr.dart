// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Countersink';

  @override
  String get addCounter => 'Ajouter un compteur';

  @override
  String get counterName => 'Nom';

  @override
  String get counterDescription => 'Description (facultative)';

  @override
  String get countPerDay => 'Compter par jour';

  @override
  String get countPerDayHint =>
      'Affiche le total du jour et repart de zéro chaque jour. Les jours passés sont conservés.';

  @override
  String get cancel => 'Annuler';

  @override
  String get add => 'Ajouter';

  @override
  String get today => 'aujourd’hui';

  @override
  String get noCounters => 'Pas encore de compteur ici.';

  @override
  String increment(int step, String name) {
    return 'Ajouter $step à $name';
  }

  @override
  String decrement(int step, String name) {
    return 'Retirer $step à $name';
  }

  @override
  String get firstGroupName => 'Compteurs';

  @override
  String get firstCounterName => 'Mon premier compteur';

  @override
  String get firstCounterDescription =>
      'Touchez + pour compter. Appuyez longuement pour modifier.';

  @override
  String get settings => 'Paramètres';

  @override
  String get about => 'À propos';

  @override
  String get aboutCountersink => 'À propos de Countersink';

  @override
  String get aboutCountersinkHint =>
      'Où se trouvent vos comptes, et pourquoi c\'est gratuit';

  @override
  String get aboutHeadline => 'Vos comptes restent avec vous.';

  @override
  String get aboutIntro =>
      'Countersink compte tout : répétitions, rangs, points, stocks.';

  @override
  String get aboutStaysTitle => 'Tout reste sur votre téléphone';

  @override
  String get aboutStaysBody =>
      'Chaque compte est enregistré dans une base de données sur cet appareil. Il n\'y a ni compte utilisateur ni serveur. Il ne va ailleurs que si vous le déplacez vous-même, sous forme de fichier de sauvegarde.';

  @override
  String get aboutCannotSeeTitle => 'Nous ne pouvons pas les voir';

  @override
  String get aboutCannotSeeBody =>
      'Countersink est conçu sans aucune autorisation d\'accès à internet. Android le garantit, et vous pouvez le vérifier dans la liste des autorisations de l\'application.';

  @override
  String get aboutNoAdsTitle => 'Pas de publicité, jamais';

  @override
  String get aboutNoAdsBody =>
      'Compter ne devrait jamais être interrompu. Countersink sera toujours gratuit et open source : pas de publicité, pas de prix, pas d\'offre premium.';

  @override
  String get aboutCheckTitle => 'Vous pouvez vérifier notre travail';

  @override
  String get aboutCheckBody =>
      'Countersink est open source, sous licence publique générale GNU. Tout le monde peut lire exactement ce qu\'il fait.';

  @override
  String get aboutTradeOff =>
      'Un compromis à connaître : il n\'y a pas de copie dans le cloud, donc un téléphone perdu ou réinitialisé, ce sont des comptes perdus. Enregistrez de temps en temps un fichier de sauvegarde depuis les Paramètres et conservez-le ailleurs que sur ce téléphone.';

  @override
  String get version => 'Version';

  @override
  String get website => 'Site web';

  @override
  String get sendFeedback => 'Envoyer un commentaire';

  @override
  String get sendFeedbackHint =>
      'Un formulaire sur le site web, dans votre navigateur.';

  @override
  String noBrowser(String website) {
    return 'Aucun navigateur pour l\'ouvrir. Rendez-vous sur $website.';
  }

  @override
  String versionNumber(String version) {
    return 'Version $version';
  }

  @override
  String get editCounter => 'Modifier le compteur';

  @override
  String get edit => 'Modifier';

  @override
  String get save => 'Enregistrer';

  @override
  String get delete => 'Supprimer';

  @override
  String get undo => 'Annuler';

  @override
  String counterDeleted(String name) {
    return 'Supprimé : $name';
  }

  @override
  String get counterColor => 'Couleur';

  @override
  String get colorClay => 'Argile';

  @override
  String get colorTeal => 'Sarcelle';

  @override
  String get colorNavy => 'Bleu marine';

  @override
  String get colorLavender => 'Lavande';

  @override
  String get colorGreen => 'Vert';

  @override
  String get colorCustom => 'Personnalisée';

  @override
  String get groups => 'Groupes';

  @override
  String get addGroup => 'Ajouter un groupe';

  @override
  String get renameGroup => 'Renommer le groupe';

  @override
  String get groupName => 'Nom';

  @override
  String countersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count compteurs',
      one: '$count compteur',
      zero: 'Aucun compteur',
    );
    return '$_temp0';
  }

  @override
  String deleteNamed(String name) {
    return 'Supprimer $name';
  }

  @override
  String groupDeleted(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Supprimé : $name et ses $count compteurs',
      one: 'Supprimé : $name et son compteur',
      zero: 'Supprimé : $name',
    );
    return '$_temp0';
  }

  @override
  String get lastGroupHint => 'Le dernier groupe ne peut pas être supprimé.';

  @override
  String get counterStep => 'Pas';

  @override
  String get counterStepHint => 'Ce que compte chaque appui sur + ou −.';

  @override
  String get addAmount => 'Ajouter une quantité';

  @override
  String addAmountTitle(String name) {
    return 'Ajouter à $name';
  }

  @override
  String takeAmountTitle(String name) {
    return 'Retirer à $name';
  }

  @override
  String get amount => 'Quantité';

  @override
  String get takeAway => 'Retirer';

  @override
  String get setValue => 'Définir la valeur';

  @override
  String get value => 'Valeur';

  @override
  String get set => 'Définir';

  @override
  String get resetToZero => 'Remettre à zéro';

  @override
  String counterReset(String name) {
    return '$name : remis à zéro';
  }

  @override
  String get history => 'Historique';

  @override
  String get historyEmpty => 'Rien n\'a encore été compté.';

  @override
  String get dayToday => 'Aujourd\'hui';

  @override
  String get dayYesterday => 'Hier';

  @override
  String entriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entrées',
      one: '$count entrée',
    );
    return '$_temp0';
  }

  @override
  String get allTime => 'Depuis le début';

  @override
  String get sectionCounting => 'Comptage';

  @override
  String get dayStartsAt => 'La journée commence à';

  @override
  String get dayStartsAtHint =>
      'Ce qui est compté avant cette heure appartient à la veille.';

  @override
  String get midnight => 'Minuit';

  @override
  String get yourData => 'Vos données';

  @override
  String get backUp => 'Sauvegarder dans un fichier';

  @override
  String get backUpHint => 'Tout, enregistré où vous le souhaitez.';

  @override
  String get restore => 'Restaurer une sauvegarde';

  @override
  String get restoreHint => 'Remplace ce qui se trouve sur ce téléphone.';

  @override
  String get backupSaved => 'Sauvegarde enregistrée';

  @override
  String get couldNotSave => 'Impossible d\'enregistrer le fichier.';

  @override
  String get couldNotOpen => 'Impossible d\'ouvrir ce fichier.';

  @override
  String get cantRestore => 'Impossible de restaurer ce fichier';

  @override
  String get ok => 'OK';

  @override
  String get restoreTitle => 'Tout remplacer par cette sauvegarde ?';

  @override
  String restoreMessage(String groups, String counters, String entries) {
    return 'Elle contient $groups, $counters et $entries. Tout ce qui se trouve actuellement sur ce téléphone sera remplacé.';
  }

  @override
  String groupsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count groupes',
      one: '$count groupe',
    );
    return '$_temp0';
  }

  @override
  String get replace => 'Remplacer';

  @override
  String get restored => 'Restauration effectuée';

  @override
  String get backupNotCountersink =>
      'Ce n\'est pas une sauvegarde Countersink.';

  @override
  String get backupTooNew =>
      'Cette sauvegarde a été créée par une version plus récente de Countersink. Mettez l\'application à jour, puis réessayez.';

  @override
  String backupDamaged(String detail) {
    return 'Cette sauvegarde contient une erreur et n\'a pas été restaurée. Rien n\'a été modifié sur ce téléphone.\n\n$detail';
  }

  @override
  String get colorBrick => 'Brique';

  @override
  String get colorOchre => 'Ocre';

  @override
  String get colorSand => 'Sable';

  @override
  String get colorOlive => 'Olive';

  @override
  String get colorSage => 'Sauge';

  @override
  String get colorMoss => 'Mousse';

  @override
  String get colorSlate => 'Ardoise';

  @override
  String get colorStorm => 'Orage';

  @override
  String get colorSky => 'Ciel';

  @override
  String get colorPlum => 'Prune';

  @override
  String get colorRose => 'Rose';

  @override
  String get colorCocoa => 'Cacao';

  @override
  String get colorCharcoal => 'Anthracite';

  @override
  String get colorAubergine => 'Aubergine';

  @override
  String get colorLinen => 'Lin';

  @override
  String get moreColors => 'Plus de couleurs et de motifs';

  @override
  String get appearanceTitle => 'Couleur et motif';

  @override
  String get secondColor => 'Deuxième couleur';

  @override
  String get secondColorHint =>
      'Se fond dans la première, d\'un coin à l\'autre.';

  @override
  String get noSecondColor => 'Aucune';

  @override
  String get pattern => 'Motif';

  @override
  String get patternNone => 'Uni';

  @override
  String get patternStripes => 'Rayures';

  @override
  String get patternDots => 'Pois';

  @override
  String get patternGrid => 'Quadrillage';

  @override
  String get customColor => 'Couleur personnalisée';

  @override
  String get hue => 'Teinte';

  @override
  String get saturation => 'Saturation';

  @override
  String get brightness => 'Luminosité';

  @override
  String get hexCode => 'Code hexadécimal';

  @override
  String get useColor => 'Utiliser';

  @override
  String get done => 'Terminé';

  @override
  String get sampleCount => '12';

  @override
  String get reorderCounters => 'Réorganiser les compteurs';

  @override
  String get moveToGroup => 'Déplacer vers un autre groupe';

  @override
  String moveToGroupTitle(String name) {
    return 'Déplacer $name vers';
  }

  @override
  String movedToGroup(String group) {
    return 'Déplacé vers $group';
  }

  @override
  String get exportCsv => 'Exporter en feuille de calcul';

  @override
  String get exportCsvHint =>
      'Chaque entrée dans un fichier CSV, une ligne chacune.';

  @override
  String get csvSaved => 'Feuille de calcul enregistrée';

  @override
  String get keepScreenOn => 'Garder l\'écran allumé';

  @override
  String get keepScreenOnHint =>
      'Tant que Countersink est ouvert, l\'écran ne s\'assombrit pas et ne se verrouille pas.';

  @override
  String get sectionAppearance => 'Apparence';

  @override
  String get theme => 'Thème';

  @override
  String get themeSystem => 'Comme le téléphone';

  @override
  String get themeLight => 'Clair';

  @override
  String get themeDark => 'Sombre';

  @override
  String get counterGoal => 'Objectif (facultatif)';

  @override
  String get counterGoalHint =>
      'Un nombre à atteindre. Pour un compteur par jour, chaque jour ou sur la semaine.';

  @override
  String goalOf(int goal) {
    return 'sur $goal';
  }

  @override
  String get goalReached => 'Objectif atteint';

  @override
  String get dayStreak => 'Jours d\'affilée';

  @override
  String get bestStreak => 'Meilleure série';

  @override
  String get previousMonth => 'Mois précédent';

  @override
  String get nextMonth => 'Mois suivant';

  @override
  String daysCount(int count) {
    return '$count jours';
  }

  @override
  String get averagePerDay => 'Moyenne par jour';

  @override
  String get totalInRange => 'Total';

  @override
  String get addEntry => 'Ajouter une entrée';

  @override
  String get editEntry => 'Modifier l\'entrée';

  @override
  String get entryAdded => 'Ajouté';

  @override
  String get entryTaken => 'Retiré';

  @override
  String get entryTime => 'Heure';

  @override
  String get entryDeleted => 'Entrée supprimée';

  @override
  String get belowZero => 'Cela ferait passer le compte sous zéro.';

  @override
  String get perDayRefused =>
      'Ce compteur ne peut pas encore compter par jour. Au moins un jour de son historique retire plus qu\'il ne compte : ce jour passerait sous zéro. Corrigez-le d\'abord dans l\'historique.';

  @override
  String get noEntries => 'Rien n\'a été compté ce jour-là.';

  @override
  String get dayTotal => 'Total du jour';

  @override
  String get fullScreen => 'Plein écran';

  @override
  String get tapAnywhere => 'Touchez n\'importe où pour compter';

  @override
  String get closeFullScreen => 'Fermer le plein écran';

  @override
  String get volumeKeys => 'Boutons de volume';

  @override
  String get volumeKeysHint =>
      'Comptez avec les boutons de volume du téléphone lorsqu\'un compteur est en plein écran.';

  @override
  String get volumeOff => 'Désactivés';

  @override
  String get volumeUp => 'Volume + ajoute';

  @override
  String get volumeBoth => '+ ajoute, − retire';

  @override
  String get lockTouch => 'Verrouiller le tactile';

  @override
  String get unlockTouch => 'Appuyez longuement pour déverrouiller';

  @override
  String get touchLocked =>
      'Le tactile est verrouillé. Comptez avec les boutons de volume.';

  @override
  String get volumeCounts =>
      'Touchez n\'importe où ou appuyez sur un bouton de volume pour compter';

  @override
  String get language => 'Langue';

  @override
  String get sameAsPhone => 'Comme le téléphone';

  @override
  String sameAsPhoneNow(String language) {
    return 'Comme le téléphone : $language';
  }

  @override
  String get archive => 'Archiver';

  @override
  String get unarchive => 'Remettre dans son groupe';

  @override
  String counterArchived(String name) {
    return 'Archivé : $name';
  }

  @override
  String get archivedCounters => 'Compteurs archivés';

  @override
  String get noArchived => 'Rien n\'est archivé.';

  @override
  String get search => 'Rechercher';

  @override
  String get searchHint => 'Rechercher des compteurs';

  @override
  String get noResults => 'Aucun compteur ne correspond.';

  @override
  String get searchPrompt =>
      'Saisissez le nom d\'un compteur, sa description ou son groupe.';

  @override
  String get autoBackup => 'Sauvegarde automatique';

  @override
  String get autoBackupHint =>
      'Désactivée. Choisissez un dossier où enregistrer une sauvegarde chaque fois que vous quittez l\'application.';

  @override
  String autoBackupTo(String folder) {
    return 'Dans $folder, chaque fois que vous quittez l\'application. Les 7 derniers jours sont conservés.';
  }

  @override
  String autoBackupFailed(String folder) {
    return 'La dernière sauvegarde n\'a pas pu être enregistrée dans $folder. Choisissez à nouveau le dossier.';
  }

  @override
  String get backUpNow => 'Sauvegarder maintenant';

  @override
  String get chooseAnotherFolder => 'Choisir un autre dossier';

  @override
  String get turnOff => 'Désactiver';

  @override
  String backedUpTo(String folder) {
    return 'Sauvegardé dans $folder';
  }

  @override
  String get goalForEach => 'L\'objectif est par';

  @override
  String get periodDay => 'Jour';

  @override
  String get periodWeek => 'Semaine';

  @override
  String goalThisWeek(int done, int goal) {
    return '$done sur $goal cette semaine';
  }

  @override
  String get weekStreak => 'Semaines d\'affilée';

  @override
  String get buzzEvery => 'Vibrer tous les (facultatif)';

  @override
  String get buzzEveryHint =>
      'Une double vibration chaque fois que le compte passe un multiple de ce nombre, par exemple tous les 10.';

  @override
  String get weekStartsOn => 'Début de la semaine';

  @override
  String get weekStartsOnHint =>
      'Pour les objectifs à la semaine et le calendrier.';

  @override
  String get addToHomeScreen => 'Ajouter à l\'écran d\'accueil';

  @override
  String get quickTile => 'Bloc des réglages rapides';

  @override
  String get quickTileHint =>
      'Désactivé. Choisissez un compteur auquel ajouter depuis les réglages rapides du téléphone, sans ouvrir l\'application.';

  @override
  String quickTileOn(String name) {
    return 'Ajoute à $name, depuis les réglages rapides du téléphone.';
  }

  @override
  String get chooseCounter => 'Choisir un compteur';

  @override
  String get chooseAnotherCounter => 'Choisir un autre compteur';

  @override
  String get quickTileHowTo =>
      'Pour ajouter le bloc : ouvrez les réglages rapides du téléphone, touchez le crayon et faites glisser le bloc Countersink.';

  @override
  String get calculated => 'Calculé à partir d\'autres compteurs';

  @override
  String get calculatedOff =>
      'Désactivé. Compté à la main, avec plus et moins.';

  @override
  String get formulaTitle => 'Compteur calculé';

  @override
  String get formulaIntro =>
      'Un compteur calculé ne se compte pas à la main. Il affiche un nombre obtenu à partir d\'autres compteurs et suit leurs changements.';

  @override
  String get formulaNone => 'Compté à la main';

  @override
  String get formulaSum => 'Un total';

  @override
  String get formulaSumHint => 'Plusieurs compteurs additionnés.';

  @override
  String get formulaDifference => 'Une différence';

  @override
  String get formulaDifferenceHint =>
      'Un compteur moins les autres. Entrées moins sorties.';

  @override
  String get formulaPercent => 'Une part, en pourcentage';

  @override
  String get formulaPercentHint =>
      'Un compteur comme part de plusieurs réunis.';

  @override
  String get formulaEvery => 'Tours complets';

  @override
  String get formulaEveryHint =>
      'Combien de tours un autre compteur a faits : tous les 108 grains, tous les 8 rangs.';

  @override
  String get sectionShows => 'Ce qu\'il affiche';

  @override
  String get formulaAddUp => 'Additionner';

  @override
  String get formulaStartWith => 'Partir de';

  @override
  String get formulaTakeAway => 'Retirer';

  @override
  String get formulaShareOf => 'La part de';

  @override
  String get formulaTogetherWith => 'Dans le total avec';

  @override
  String get formulaRoundsOf => 'Tours de';

  @override
  String get formulaAllTime => 'Garder un total cumulé';

  @override
  String get formulaAllTimeHint =>
      'Les compteurs par jour comptent pour tout ce qu\'ils ont compté, pas seulement aujourd\'hui. Ils repartent de zéro chaque jour ; ce nombre continue.';

  @override
  String get formulaStartFrom => 'Partir de (facultatif)';

  @override
  String get formulaStartFromHint =>
      'Un nombre que le total a déjà atteint, avant d\'être compté ici. Ce qui est compté s\'y ajoute.';

  @override
  String get roundSize => 'Un tour fait';

  @override
  String get roundSizeHint => 'Combien il en faut pour un tour.';

  @override
  String lineSum(String names) {
    return 'Total de $names';
  }

  @override
  String lineDifference(String first, String others) {
    return '$first moins $others';
  }

  @override
  String linePercent(String first, String all) {
    return '$first en part de $all';
  }

  @override
  String lineEvery(int size, String name) {
    return 'Tours de $size dans $name';
  }

  @override
  String lineTowardNext(int count) {
    return '$count vers le suivant';
  }

  @override
  String get lineBroken => 'Le compteur dont il dépendait n\'existe plus';

  @override
  String get noOrdinaryCounters =>
      'Ajoutez d\'abord un compteur à compter à la main. Un compteur calculé s\'obtient à partir de ceux-là.';

  @override
  String get emptyGroup => 'Groupe vide';

  @override
  String get emptyGroupHint => 'Donnez-lui un nom, puis ajoutez vos compteurs.';

  @override
  String get readyMadeSets => 'Ensembles tout prêts';

  @override
  String copyGroupNamed(String name) {
    return 'Copier $name, sans ses comptes';
  }

  @override
  String groupCopyName(String name) {
    return '$name (copie)';
  }

  @override
  String get presetRows => 'Rangs et répétitions';

  @override
  String get presetRowsHint =>
      'Les rangs, et les répétitions de 8 qu\'ils forment.';

  @override
  String get presetBeads => 'Grains';

  @override
  String get presetBeadsHint =>
      'Les grains, et les tours de 108 qu\'ils forment.';

  @override
  String get presetInOut => 'Entrées et sorties';

  @override
  String get presetInOutHint =>
      'Les entrées, les sorties, et combien sont à l\'intérieur.';

  @override
  String get presetScore => 'Tableau des scores';

  @override
  String get presetScoreHint => 'Deux scores à tenir.';

  @override
  String get presetMade => 'Réussis et manqués';

  @override
  String get presetMadeHint => 'Réussis, manqués, et la part de réussis.';

  @override
  String get nameRows => 'Rangs';

  @override
  String get nameRepeats => 'Répétitions';

  @override
  String get nameBeads => 'Grains';

  @override
  String get nameRounds => 'Tours';

  @override
  String get nameIn => 'Entrées';

  @override
  String get nameOut => 'Sorties';

  @override
  String get nameInside => 'À l\'intérieur';

  @override
  String get nameUs => 'Nous';

  @override
  String get nameThem => 'Eux';

  @override
  String get nameMade => 'Réussis';

  @override
  String get nameMissed => 'Manqués';

  @override
  String get nameMadeShare => 'Réussis en pourcentage';

  @override
  String get importFromApp => 'Importer d\'une autre application';

  @override
  String get importFromAppHint =>
      'Compteurs de BetterCounter, Counter ou Simple Counter, ajoutés comme nouveaux groupes.';

  @override
  String get importChooseApp => 'De quelle application vient le fichier ?';

  @override
  String get importBetterCounterHint =>
      'Son fichier CSV exporté. Chaque compte arrive avec son heure.';

  @override
  String get importCounterHint =>
      'Son fichier CSV exporté. Chaque compteur arrive avec son nombre.';

  @override
  String get importSimpleCounterHint =>
      'Sa sauvegarde JSON. Les étiquettes deviennent des groupes.';

  @override
  String get importedGroupName => 'Importés';

  @override
  String get cantImport => 'Impossible d\'importer ce fichier';

  @override
  String importNotFrom(String app) {
    return 'Cela ne ressemble pas à un fichier de $app.';
  }

  @override
  String get importEmpty => 'Il n\'y a aucun compteur dans ce fichier.';

  @override
  String importIsBackup(String restore) {
    return 'C\'est une sauvegarde Countersink. Utilisez « $restore » pour celle-ci.';
  }

  @override
  String importDone(String counters, String entries) {
    return '$counters et $entries importés.';
  }

  @override
  String importSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count lignes n\'ont pas pu être lues.',
      one: '$count ligne n\'a pas pu être lue.',
    );
    return '$_temp0';
  }

  @override
  String reachedGoal(String name, int goal) {
    return '$name a atteint $goal';
  }

  @override
  String get goalHintCalculated =>
      'Un nombre à atteindre. Un message le signale quand il est atteint.';

  @override
  String get sendToPhone => 'Envoyer vers un autre téléphone';

  @override
  String get receiveFromPhone => 'Recevoir d’un autre téléphone';

  @override
  String get shareWhatToSend => 'Que voulez-vous envoyer ?';

  @override
  String get sendEverything => 'Tout';

  @override
  String get sendEverythingHint => 'Pour passer à un nouveau téléphone.';

  @override
  String get shareWhatToInclude => 'Que faut-il inclure';

  @override
  String get shareShowCodes => 'Afficher les codes';

  @override
  String get shareHowToReceive =>
      'Sur l’autre téléphone, ouvrez Countersink, allez dans Paramètres → Recevoir d’un autre téléphone, et pointez l’appareil photo vers cet écran.';

  @override
  String shareCodeOf(int index, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: 'Code $index sur $total',
    );
    return '$_temp0';
  }

  @override
  String get sharePreviousCode => 'Code précédent';

  @override
  String get sharePause => 'Pause';

  @override
  String get sharePlay => 'Lecture';

  @override
  String get shareNextCode => 'Code suivant';

  @override
  String get shareCodesChange =>
      'Les codes changent d’eux-mêmes. L’autre téléphone les récupère dans n’importe quel ordre.';

  @override
  String get shareNotCountersink => 'Ce code ne vient pas d’Countersink.';

  @override
  String get shareNewerVersion =>
      'L’autre téléphone a une version plus récente d’Countersink. Mettez d’abord celui-ci à jour.';

  @override
  String get shareRestarted =>
      'L’autre téléphone a recommencé. Récupération des nouveaux codes.';

  @override
  String get shareUnreadable =>
      'Certains codes n’ont pas été bien lus. Scannons-les de nouveau.';

  @override
  String get shareNeedsCamera =>
      'Countersink a besoin de l’appareil photo pour lire les codes. Vous pouvez l’autoriser dans les paramètres système d’Countersink.';

  @override
  String get sharePointCamera =>
      'Pointez l’appareil photo vers le code sur l’autre téléphone.';

  @override
  String get shareReading => 'Lecture…';

  @override
  String shareCodesReceived(int received, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$received codes reçus sur $total',
    );
    return '$_temp0';
  }

  @override
  String shareStillNeeded(String codes) {
    return 'Encore nécessaires : $codes';
  }

  @override
  String get sendToPhoneHint =>
      'Affichez vos compteurs sous forme de codes à scanner par un autre téléphone.';

  @override
  String get receiveFromPhoneHint =>
      'Scannez les codes affichés par un autre téléphone. Ce qui arrive est ajouté comme nouveaux groupes.';

  @override
  String get sendSomeCounters => 'Seulement certains compteurs';

  @override
  String get sendWithHistory => 'Les compteurs et leur historique';

  @override
  String get sendWithHistoryHint => 'Chaque entrée, avec son heure.';

  @override
  String get sendNumbersOnly => 'Les compteurs et leurs nombres';

  @override
  String get sendNumbersOnlyHint =>
      'Beaucoup moins de codes. Chaque compteur arrive avec le nombre qu’il affiche maintenant.';

  @override
  String sendSummary(String counters, String entries) {
    return 'Envoi de $counters et $entries.';
  }

  @override
  String receivedDone(String counters, String entries) {
    return '$counters et $entries reçus.';
  }

  @override
  String get sendNothingChosen => 'Choisissez au moins un compteur à envoyer.';
}
