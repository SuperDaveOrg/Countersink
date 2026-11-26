// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Countersink';

  @override
  String get addCounter => 'Adicionar contador';

  @override
  String get counterName => 'Nome';

  @override
  String get counterDescription => 'Descrição (opcional)';

  @override
  String get countPerDay => 'Contar por dia';

  @override
  String get countPerDayHint =>
      'Mostra o total de hoje e começa do zero todos os dias. Os dias anteriores são mantidos.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get add => 'Adicionar';

  @override
  String get today => 'hoje';

  @override
  String get noCounters => 'Ainda não há contadores aqui.';

  @override
  String increment(int step, String name) {
    return 'Somar $step a $name';
  }

  @override
  String decrement(int step, String name) {
    return 'Subtrair $step a $name';
  }

  @override
  String get firstGroupName => 'Contadores';

  @override
  String get firstCounterName => 'O meu primeiro contador';

  @override
  String get firstCounterDescription =>
      'Toque em + para contar. Mantenha premido para editar.';

  @override
  String get settings => 'Definições';

  @override
  String get about => 'Acerca de';

  @override
  String get aboutCountersink => 'Acerca do Countersink';

  @override
  String get aboutCountersinkHint =>
      'Onde ficam as suas contagens e porque é gratuito';

  @override
  String get aboutHeadline => 'As suas contagens ficam consigo.';

  @override
  String get aboutIntro =>
      'O Countersink conta qualquer coisa: repetições, carreiras, pontos, existências.';

  @override
  String get aboutStaysTitle => 'Fica no seu telemóvel';

  @override
  String get aboutStaysBody =>
      'Cada contagem é guardada numa base de dados neste dispositivo. Não há conta nem servidor. Só sai daqui se a mover por si, como ficheiro de cópia de segurança.';

  @override
  String get aboutCannotSeeTitle => 'Não conseguimos vê-lo';

  @override
  String get aboutCannotSeeBody =>
      'O Countersink é feito sem qualquer permissão para usar a internet. O Android garante-o, e pode confirmá-lo na lista de permissões da aplicação.';

  @override
  String get aboutNoAdsTitle => 'Sem anúncios, nunca';

  @override
  String get aboutNoAdsBody =>
      'Contar nunca deve ser interrompido. O Countersink será sempre gratuito e de código aberto: sem anúncios, sem preço, sem versão premium.';

  @override
  String get aboutCheckTitle => 'Pode verificar o nosso trabalho';

  @override
  String get aboutCheckBody =>
      'O Countersink é de código aberto, sob a Licença Pública Geral GNU. Qualquer pessoa pode ler exatamente o que faz.';

  @override
  String get aboutTradeOff =>
      'Um compromisso que convém conhecer: não há cópia na nuvem, por isso um telemóvel perdido ou reposto significa contagens perdidas. Guarde de vez em quando um ficheiro de cópia de segurança nas Definições e mantenha-o noutro local que não este telemóvel.';

  @override
  String get version => 'Versão';

  @override
  String get website => 'Site';

  @override
  String get sendFeedback => 'Enviar comentários';

  @override
  String get sendFeedbackHint => 'Um formulário no site, no seu navegador.';

  @override
  String noBrowser(String website) {
    return 'Não há nenhum navegador para o abrir. Visite $website.';
  }

  @override
  String versionNumber(String version) {
    return 'Versão $version';
  }

  @override
  String get editCounter => 'Editar contador';

  @override
  String get edit => 'Editar';

  @override
  String get save => 'Guardar';

  @override
  String get delete => 'Eliminar';

  @override
  String get undo => 'Anular';

  @override
  String counterDeleted(String name) {
    return 'Eliminado: $name';
  }

  @override
  String get counterColor => 'Cor';

  @override
  String get colorClay => 'Argila';

  @override
  String get colorTeal => 'Azul-petróleo';

  @override
  String get colorNavy => 'Azul-marinho';

  @override
  String get colorLavender => 'Lavanda';

  @override
  String get colorGreen => 'Verde';

  @override
  String get colorCustom => 'Personalizada';

  @override
  String get groups => 'Grupos';

  @override
  String get addGroup => 'Adicionar grupo';

  @override
  String get renameGroup => 'Mudar o nome do grupo';

  @override
  String get groupName => 'Nome';

  @override
  String countersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contadores',
      one: '$count contador',
      zero: 'Sem contadores',
    );
    return '$_temp0';
  }

  @override
  String deleteNamed(String name) {
    return 'Eliminar $name';
  }

  @override
  String groupDeleted(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Eliminado: $name e os seus $count contadores',
      one: 'Eliminado: $name e o seu contador',
      zero: 'Eliminado: $name',
    );
    return '$_temp0';
  }

  @override
  String get lastGroupHint => 'O último grupo não pode ser eliminado.';

  @override
  String get counterStep => 'Passo';

  @override
  String get counterStepHint => 'Quanto conta cada toque em + ou −.';

  @override
  String get addAmount => 'Adicionar uma quantidade';

  @override
  String addAmountTitle(String name) {
    return 'Somar a $name';
  }

  @override
  String takeAmountTitle(String name) {
    return 'Subtrair a $name';
  }

  @override
  String get amount => 'Quantidade';

  @override
  String get takeAway => 'Subtrair';

  @override
  String get setValue => 'Definir o valor';

  @override
  String get value => 'Valor';

  @override
  String get set => 'Definir';

  @override
  String get resetToZero => 'Repor a zero';

  @override
  String counterReset(String name) {
    return '$name: reposto a zero';
  }

  @override
  String get history => 'Histórico';

  @override
  String get historyEmpty => 'Ainda nada foi contado.';

  @override
  String get dayToday => 'Hoje';

  @override
  String get dayYesterday => 'Ontem';

  @override
  String entriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entradas',
      one: '$count entrada',
    );
    return '$_temp0';
  }

  @override
  String get allTime => 'Desde sempre';

  @override
  String get sectionCounting => 'Contagem';

  @override
  String get dayStartsAt => 'O dia começa às';

  @override
  String get dayStartsAtHint =>
      'O que for contado antes desta hora pertence ao dia anterior.';

  @override
  String get midnight => 'Meia-noite';

  @override
  String get yourData => 'Os seus dados';

  @override
  String get backUp => 'Fazer cópia de segurança num ficheiro';

  @override
  String get backUpHint => 'Tudo, guardado onde escolher.';

  @override
  String get restore => 'Restaurar uma cópia de segurança';

  @override
  String get restoreHint => 'Substitui o que está neste telemóvel.';

  @override
  String get backupSaved => 'Cópia de segurança guardada';

  @override
  String get couldNotSave => 'Não foi possível guardar o ficheiro.';

  @override
  String get couldNotOpen => 'Não foi possível abrir esse ficheiro.';

  @override
  String get cantRestore => 'Não é possível restaurar este ficheiro';

  @override
  String get ok => 'OK';

  @override
  String get restoreTitle => 'Substituir tudo por esta cópia de segurança?';

  @override
  String restoreMessage(String groups, String counters, String entries) {
    return 'Contém $groups, $counters e $entries. Tudo o que está agora neste telemóvel será substituído.';
  }

  @override
  String groupsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count grupos',
      one: '$count grupo',
    );
    return '$_temp0';
  }

  @override
  String get replace => 'Substituir';

  @override
  String get restored => 'Restaurado';

  @override
  String get backupNotCountersink =>
      'Isto não é uma cópia de segurança do Countersink.';

  @override
  String get backupTooNew =>
      'Esta cópia de segurança foi feita por uma versão mais recente do Countersink. Atualize a aplicação e tente novamente.';

  @override
  String backupDamaged(String detail) {
    return 'Esta cópia de segurança tem algo errado e não foi restaurada. Nada foi alterado neste telemóvel.\n\n$detail';
  }

  @override
  String get colorBrick => 'Tijolo';

  @override
  String get colorOchre => 'Ocre';

  @override
  String get colorSand => 'Areia';

  @override
  String get colorOlive => 'Azeitona';

  @override
  String get colorSage => 'Salva';

  @override
  String get colorMoss => 'Musgo';

  @override
  String get colorSlate => 'Ardósia';

  @override
  String get colorStorm => 'Tempestade';

  @override
  String get colorSky => 'Céu';

  @override
  String get colorPlum => 'Ameixa';

  @override
  String get colorRose => 'Rosa';

  @override
  String get colorCocoa => 'Cacau';

  @override
  String get colorCharcoal => 'Antracite';

  @override
  String get colorAubergine => 'Beringela';

  @override
  String get colorLinen => 'Linho';

  @override
  String get moreColors => 'Mais cores e padrões';

  @override
  String get appearanceTitle => 'Cor e padrão';

  @override
  String get secondColor => 'Segunda cor';

  @override
  String get secondColorHint => 'Funde-se com a primeira, de canto a canto.';

  @override
  String get noSecondColor => 'Nenhuma';

  @override
  String get pattern => 'Padrão';

  @override
  String get patternNone => 'Liso';

  @override
  String get patternStripes => 'Riscas';

  @override
  String get patternDots => 'Pontos';

  @override
  String get patternGrid => 'Grelha';

  @override
  String get customColor => 'Cor personalizada';

  @override
  String get hue => 'Tom';

  @override
  String get saturation => 'Saturação';

  @override
  String get brightness => 'Brilho';

  @override
  String get hexCode => 'Código hexadecimal';

  @override
  String get useColor => 'Usar';

  @override
  String get done => 'Concluído';

  @override
  String get sampleCount => '12';

  @override
  String get reorderCounters => 'Reordenar contadores';

  @override
  String get moveToGroup => 'Mover para outro grupo';

  @override
  String moveToGroupTitle(String name) {
    return 'Mover $name para';
  }

  @override
  String movedToGroup(String group) {
    return 'Movido para $group';
  }

  @override
  String get exportCsv => 'Exportar como folha de cálculo';

  @override
  String get exportCsvHint =>
      'Todas as entradas num ficheiro CSV, uma linha cada.';

  @override
  String get csvSaved => 'Folha de cálculo guardada';

  @override
  String get keepScreenOn => 'Manter o ecrã ligado';

  @override
  String get keepScreenOnHint =>
      'Enquanto o Countersink estiver aberto, o ecrã não escurece nem bloqueia.';

  @override
  String get sectionAppearance => 'Aspeto';

  @override
  String get theme => 'Tema';

  @override
  String get themeSystem => 'Igual ao telemóvel';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Escuro';

  @override
  String get counterGoal => 'Objetivo (opcional)';

  @override
  String get counterGoalHint =>
      'Um número a atingir. Num contador por dia, todos os dias ou na semana.';

  @override
  String goalOf(int goal) {
    return 'de $goal';
  }

  @override
  String get goalReached => 'Objetivo atingido';

  @override
  String get dayStreak => 'Dias seguidos';

  @override
  String get bestStreak => 'Melhor sequência';

  @override
  String get previousMonth => 'Mês anterior';

  @override
  String get nextMonth => 'Mês seguinte';

  @override
  String daysCount(int count) {
    return '$count dias';
  }

  @override
  String get averagePerDay => 'Média por dia';

  @override
  String get totalInRange => 'Total';

  @override
  String get addEntry => 'Adicionar entrada';

  @override
  String get editEntry => 'Editar entrada';

  @override
  String get entryAdded => 'Somado';

  @override
  String get entryTaken => 'Subtraído';

  @override
  String get entryTime => 'Hora';

  @override
  String get entryDeleted => 'Entrada eliminada';

  @override
  String get belowZero => 'Isso deixaria a contagem abaixo de zero.';

  @override
  String get perDayRefused =>
      'Este contador ainda não pode contar por dia. Em pelo menos um dia do histórico foi retirado mais do que contado, por isso esse dia ficaria abaixo de zero. Corrija-o primeiro no histórico.';

  @override
  String get noEntries => 'Nada foi contado neste dia.';

  @override
  String get dayTotal => 'Total do dia';

  @override
  String get fullScreen => 'Ecrã inteiro';

  @override
  String get tapAnywhere => 'Toque em qualquer lado para contar';

  @override
  String get closeFullScreen => 'Fechar o ecrã inteiro';

  @override
  String get volumeKeys => 'Botões de volume';

  @override
  String get volumeKeysHint =>
      'Conte com os botões de volume do telemóvel enquanto um contador está em ecrã inteiro.';

  @override
  String get volumeOff => 'Desativados';

  @override
  String get volumeUp => 'Aumentar volume soma';

  @override
  String get volumeBoth => 'Aumentar soma, diminuir subtrai';

  @override
  String get lockTouch => 'Bloquear o toque';

  @override
  String get unlockTouch => 'Mantenha premido para desbloquear';

  @override
  String get touchLocked =>
      'O toque está bloqueado. Conte com os botões de volume.';

  @override
  String get volumeCounts =>
      'Toque em qualquer lado ou prima um botão de volume para contar';

  @override
  String get language => 'Idioma';

  @override
  String get sameAsPhone => 'Igual ao telemóvel';

  @override
  String sameAsPhoneNow(String language) {
    return 'Igual ao telemóvel: $language';
  }

  @override
  String get archive => 'Arquivar';

  @override
  String get unarchive => 'Devolver ao grupo';

  @override
  String counterArchived(String name) {
    return 'Arquivado: $name';
  }

  @override
  String get archivedCounters => 'Contadores arquivados';

  @override
  String get noArchived => 'Nada arquivado.';

  @override
  String get search => 'Procurar';

  @override
  String get searchHint => 'Procurar contadores';

  @override
  String get noResults => 'Nenhum contador corresponde.';

  @override
  String get searchPrompt =>
      'Escreva o nome de um contador, a descrição ou o grupo.';

  @override
  String get autoBackup => 'Cópia de segurança automática';

  @override
  String get autoBackupHint =>
      'Desativada. Escolha uma pasta onde guardar uma cópia sempre que sair da aplicação.';

  @override
  String autoBackupTo(String folder) {
    return 'Em $folder, sempre que sai da aplicação. São mantidos os últimos 7 dias.';
  }

  @override
  String autoBackupFailed(String folder) {
    return 'Não foi possível guardar a última cópia em $folder. Escolha a pasta novamente.';
  }

  @override
  String get backUpNow => 'Fazer cópia agora';

  @override
  String get chooseAnotherFolder => 'Escolher outra pasta';

  @override
  String get turnOff => 'Desativar';

  @override
  String backedUpTo(String folder) {
    return 'Cópia guardada em $folder';
  }

  @override
  String get goalForEach => 'O objetivo é por';

  @override
  String get periodDay => 'Dia';

  @override
  String get periodWeek => 'Semana';

  @override
  String goalThisWeek(int done, int goal) {
    return '$done de $goal esta semana';
  }

  @override
  String get weekStreak => 'Semanas seguidas';

  @override
  String get buzzEvery => 'Vibrar a cada (opcional)';

  @override
  String get buzzEveryHint =>
      'Uma vibração dupla sempre que a contagem passa por um múltiplo deste número, por exemplo a cada 10.';

  @override
  String get weekStartsOn => 'Início da semana';

  @override
  String get weekStartsOnHint => 'Para os objetivos semanais e o calendário.';

  @override
  String get addToHomeScreen => 'Adicionar ao ecrã principal';

  @override
  String get quickTile => 'Mosaico das definições rápidas';

  @override
  String get quickTileHint =>
      'Desativado. Escolha um contador ao qual somar a partir das definições rápidas do telemóvel, sem abrir a aplicação.';

  @override
  String quickTileOn(String name) {
    return 'Soma a $name, a partir das definições rápidas do telemóvel.';
  }

  @override
  String get chooseCounter => 'Escolher um contador';

  @override
  String get chooseAnotherCounter => 'Escolher outro contador';

  @override
  String get quickTileHowTo =>
      'Para adicionar o mosaico: abra as definições rápidas do telemóvel, toque no lápis e arraste o mosaico do Countersink.';

  @override
  String get calculated => 'Calculado a partir de outros contadores';

  @override
  String get calculatedOff => 'Desativado. Conta-se à mão, com mais e menos.';

  @override
  String get formulaTitle => 'Contador calculado';

  @override
  String get formulaIntro =>
      'Um contador calculado não se conta à mão. Mostra um número obtido a partir de outros contadores e acompanha as suas alterações.';

  @override
  String get formulaNone => 'Contado à mão';

  @override
  String get formulaSum => 'Um total';

  @override
  String get formulaSumHint => 'Vários contadores somados.';

  @override
  String get formulaDifference => 'Uma diferença';

  @override
  String get formulaDifferenceHint =>
      'Um contador menos os outros. Entradas menos saídas.';

  @override
  String get formulaPercent => 'Uma parte, em percentagem';

  @override
  String get formulaPercentHint =>
      'Um contador como parte de vários em conjunto.';

  @override
  String get formulaEvery => 'Voltas completas';

  @override
  String get formulaEveryHint =>
      'Quantas voltas deu outro contador: a cada 108 contas, a cada 8 carreiras.';

  @override
  String get sectionShows => 'O que mostra';

  @override
  String get formulaAddUp => 'Somar';

  @override
  String get formulaStartWith => 'Partir de';

  @override
  String get formulaTakeAway => 'Subtrair';

  @override
  String get formulaShareOf => 'A parte de';

  @override
  String get formulaTogetherWith => 'No total em conjunto com';

  @override
  String get formulaRoundsOf => 'Voltas de';

  @override
  String get formulaAllTime => 'Manter um total acumulado';

  @override
  String get formulaAllTimeHint =>
      'Os contadores por dia contam com tudo o que já contaram, não só com hoje. Recomeçam do zero todos os dias; este número continua.';

  @override
  String get formulaStartFrom => 'Começar em (opcional)';

  @override
  String get formulaStartFromHint =>
      'Um número em que o total já está, de antes de ser contado aqui. O que se conta soma-se a ele.';

  @override
  String get roundSize => 'Uma volta são';

  @override
  String get roundSizeHint => 'Quantos fazem uma volta.';

  @override
  String lineSum(String names) {
    return 'Total de $names';
  }

  @override
  String lineDifference(String first, String others) {
    return '$first menos $others';
  }

  @override
  String linePercent(String first, String all) {
    return '$first como parte de $all';
  }

  @override
  String lineEvery(int size, String name) {
    return 'Voltas de $size em $name';
  }

  @override
  String lineTowardNext(int count) {
    return '$count para a seguinte';
  }

  @override
  String get lineBroken => 'O contador de que dependia já não existe';

  @override
  String get noOrdinaryCounters =>
      'Adicione primeiro um contador para contar à mão. Um contador calculado obtém-se a partir desses.';

  @override
  String get emptyGroup => 'Grupo vazio';

  @override
  String get emptyGroupHint =>
      'Dê-lhe um nome e depois adicione os seus contadores.';

  @override
  String get readyMadeSets => 'Conjuntos já feitos';

  @override
  String copyGroupNamed(String name) {
    return 'Copiar $name, sem as contagens';
  }

  @override
  String groupCopyName(String name) {
    return '$name (cópia)';
  }

  @override
  String get presetRows => 'Carreiras e repetições';

  @override
  String get presetRowsHint => 'Carreiras, e as repetições de 8 que formam.';

  @override
  String get presetBeads => 'Contas';

  @override
  String get presetBeadsHint => 'Contas, e as voltas de 108 que formam.';

  @override
  String get presetInOut => 'Entradas e saídas';

  @override
  String get presetInOutHint =>
      'Quem entra, quem sai e quantos estão lá dentro.';

  @override
  String get presetScore => 'Marcador';

  @override
  String get presetScoreHint => 'Duas pontuações.';

  @override
  String get presetMade => 'Certos e falhados';

  @override
  String get presetMadeHint => 'Certos, falhados e a parte dos certos.';

  @override
  String get nameRows => 'Carreiras';

  @override
  String get nameRepeats => 'Repetições';

  @override
  String get nameBeads => 'Contas';

  @override
  String get nameRounds => 'Voltas';

  @override
  String get nameIn => 'Entraram';

  @override
  String get nameOut => 'Saíram';

  @override
  String get nameInside => 'Lá dentro';

  @override
  String get nameUs => 'Nós';

  @override
  String get nameThem => 'Eles';

  @override
  String get nameMade => 'Certos';

  @override
  String get nameMissed => 'Falhados';

  @override
  String get nameMadeShare => 'Certos em percentagem';

  @override
  String get importFromApp => 'Importar de outra aplicação';

  @override
  String get importFromAppHint =>
      'Contadores do BetterCounter, Counter ou Simple Counter, adicionados como novos grupos.';

  @override
  String get importChooseApp => 'De que aplicação é o ficheiro?';

  @override
  String get importBetterCounterHint =>
      'O ficheiro CSV exportado. Cada contagem vem com a sua hora.';

  @override
  String get importCounterHint =>
      'O ficheiro CSV exportado. Cada contador vem com o seu número.';

  @override
  String get importSimpleCounterHint =>
      'A cópia de segurança JSON. As etiquetas passam a ser grupos.';

  @override
  String get importedGroupName => 'Importados';

  @override
  String get cantImport => 'Não é possível importar este ficheiro';

  @override
  String importNotFrom(String app) {
    return 'Não parece um ficheiro do $app.';
  }

  @override
  String get importEmpty => 'Não há contadores neste ficheiro.';

  @override
  String importIsBackup(String restore) {
    return 'É uma cópia de segurança do Countersink. Para isso use «$restore».';
  }

  @override
  String importDone(String counters, String entries) {
    return 'Importados $counters e $entries.';
  }

  @override
  String importSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Não foi possível ler $count linhas.',
      one: 'Não foi possível ler $count linha.',
    );
    return '$_temp0';
  }

  @override
  String reachedGoal(String name, int goal) {
    return '$name chegou a $goal';
  }

  @override
  String get goalHintCalculated =>
      'Um número a atingir. Uma mensagem avisa quando lá chega.';

  @override
  String get sendToPhone => 'Enviar para outro telemóvel';

  @override
  String get receiveFromPhone => 'Receber de outro telemóvel';

  @override
  String get shareWhatToSend => 'O que quer enviar?';

  @override
  String get sendEverything => 'Tudo';

  @override
  String get sendEverythingHint => 'Para mudar para um telemóvel novo.';

  @override
  String get shareWhatToInclude => 'O que incluir';

  @override
  String get shareShowCodes => 'Mostrar os códigos';

  @override
  String get shareHowToReceive =>
      'No outro telemóvel, abra o Countersink, vá a Definições → Receber de outro telemóvel e aponte a câmara para este ecrã.';

  @override
  String shareCodeOf(int index, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: 'Código $index de $total',
    );
    return '$_temp0';
  }

  @override
  String get sharePreviousCode => 'Código anterior';

  @override
  String get sharePause => 'Pausa';

  @override
  String get sharePlay => 'Continuar';

  @override
  String get shareNextCode => 'Código seguinte';

  @override
  String get shareCodesChange =>
      'Os códigos mudam sozinhos. O outro telemóvel recolhe-os por qualquer ordem.';

  @override
  String get shareNotCountersink => 'Esse código não é do Countersink.';

  @override
  String get shareNewerVersion =>
      'O outro telemóvel tem uma versão mais recente do Countersink. Atualize primeiro este.';

  @override
  String get shareRestarted =>
      'O outro telemóvel recomeçou. A recolher os novos códigos.';

  @override
  String get shareUnreadable =>
      'Alguns códigos não foram lidos corretamente. Vamos lê-los outra vez.';

  @override
  String get shareNeedsCamera =>
      'O Countersink precisa da câmara para ler os códigos. Pode permiti-lo nas definições do sistema para o Countersink.';

  @override
  String get sharePointCamera =>
      'Aponte a câmara para o código no outro telemóvel.';

  @override
  String get shareReading => 'A ler…';

  @override
  String shareCodesReceived(int received, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$received de $total códigos recebidos',
    );
    return '$_temp0';
  }

  @override
  String shareStillNeeded(String codes) {
    return 'Ainda faltam: $codes';
  }

  @override
  String get sendToPhoneHint =>
      'Mostrar os seus contadores em códigos para outro telemóvel ler.';

  @override
  String get receiveFromPhoneHint =>
      'Ler os códigos que outro telemóvel mostra. O que chega é adicionado como novos grupos.';

  @override
  String get sendSomeCounters => 'Apenas alguns contadores';

  @override
  String get sendWithHistory => 'Contadores e o respetivo histórico';

  @override
  String get sendWithHistoryHint => 'Cada entrada, com a respetiva hora.';

  @override
  String get sendNumbersOnly => 'Contadores e os respetivos números';

  @override
  String get sendNumbersOnlyHint =>
      'Muito menos códigos. Cada contador chega com o número que mostra agora.';

  @override
  String sendSummary(String counters, String entries) {
    return 'A enviar $counters e $entries.';
  }

  @override
  String receivedDone(String counters, String entries) {
    return 'Recebidos $counters e $entries.';
  }

  @override
  String get sendNothingChosen => 'Escolha pelo menos um contador para enviar.';
}
