// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Countersink';

  @override
  String get addCounter => 'Añadir contador';

  @override
  String get counterName => 'Nombre';

  @override
  String get counterDescription => 'Descripción (opcional)';

  @override
  String get countPerDay => 'Contar por día';

  @override
  String get countPerDayHint =>
      'Muestra el total de hoy y empieza de cero cada día. Los días anteriores se conservan.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get add => 'Añadir';

  @override
  String get today => 'hoy';

  @override
  String get noCounters => 'Aquí todavía no hay contadores.';

  @override
  String increment(int step, String name) {
    return 'Sumar $step a $name';
  }

  @override
  String decrement(int step, String name) {
    return 'Restar $step a $name';
  }

  @override
  String get firstGroupName => 'Contadores';

  @override
  String get firstCounterName => 'Mi primer contador';

  @override
  String get firstCounterDescription =>
      'Toca + para contar. Mantén pulsado para editar.';

  @override
  String get settings => 'Ajustes';

  @override
  String get about => 'Acerca de';

  @override
  String get aboutCountersink => 'Acerca de Countersink';

  @override
  String get aboutCountersinkHint =>
      'Dónde están tus recuentos y por qué es gratis';

  @override
  String get aboutHeadline => 'Tus recuentos se quedan contigo.';

  @override
  String get aboutIntro =>
      'Countersink lleva la cuenta de cualquier cosa: repeticiones, vueltas, puntos, existencias.';

  @override
  String get aboutStaysTitle => 'Se queda en tu teléfono';

  @override
  String get aboutStaysBody =>
      'Cada recuento se guarda en una base de datos de este dispositivo. No hay cuenta ni servidor. Solo sale de aquí si lo mueves tú, como archivo de copia de seguridad.';

  @override
  String get aboutCannotSeeTitle => 'No podemos verlo';

  @override
  String get aboutCannotSeeBody =>
      'Countersink está hecho sin permiso para usar internet. Android lo garantiza, y puedes comprobarlo en la lista de permisos de la aplicación.';

  @override
  String get aboutNoAdsTitle => 'Sin anuncios, nunca';

  @override
  String get aboutNoAdsBody =>
      'Contar nunca debería interrumpirse. Countersink siempre será gratuito y de código abierto: sin anuncios, sin precio y sin versión prémium.';

  @override
  String get aboutCheckTitle => 'Puedes revisar nuestro trabajo';

  @override
  String get aboutCheckBody =>
      'Countersink es de código abierto bajo la Licencia Pública General de GNU. Cualquiera puede leer exactamente lo que hace.';

  @override
  String get aboutTradeOff =>
      'Un inconveniente que conviene conocer: no hay copia en la nube, así que si pierdes el teléfono o lo borras, pierdes los recuentos. Guarda de vez en cuando una copia de seguridad desde Ajustes y consérvala en otro lugar que no sea este teléfono.';

  @override
  String get version => 'Versión';

  @override
  String get website => 'Sitio web';

  @override
  String get sendFeedback => 'Enviar comentarios';

  @override
  String get sendFeedbackHint =>
      'Un formulario en el sitio web, en tu navegador.';

  @override
  String noBrowser(String website) {
    return 'No hay ningún navegador para abrirlo. Visita $website.';
  }

  @override
  String versionNumber(String version) {
    return 'Versión $version';
  }

  @override
  String get editCounter => 'Editar contador';

  @override
  String get edit => 'Editar';

  @override
  String get save => 'Guardar';

  @override
  String get delete => 'Borrar';

  @override
  String get undo => 'Deshacer';

  @override
  String counterDeleted(String name) {
    return 'Se ha borrado $name';
  }

  @override
  String get counterColor => 'Color';

  @override
  String get colorClay => 'Arcilla';

  @override
  String get colorTeal => 'Verde azulado';

  @override
  String get colorNavy => 'Azul marino';

  @override
  String get colorLavender => 'Lavanda';

  @override
  String get colorGreen => 'Verde';

  @override
  String get colorCustom => 'Personalizado';

  @override
  String get groups => 'Grupos';

  @override
  String get addGroup => 'Añadir grupo';

  @override
  String get renameGroup => 'Cambiar nombre del grupo';

  @override
  String get groupName => 'Nombre';

  @override
  String countersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count contadores',
      one: '1 contador',
      zero: 'Sin contadores',
    );
    return '$_temp0';
  }

  @override
  String deleteNamed(String name) {
    return 'Borrar $name';
  }

  @override
  String groupDeleted(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se ha borrado $name y sus $count contadores',
      one: 'Se ha borrado $name y su contador',
      zero: 'Se ha borrado $name',
    );
    return '$_temp0';
  }

  @override
  String get lastGroupHint => 'El último grupo no se puede borrar.';

  @override
  String get counterStep => 'Paso';

  @override
  String get counterStepHint => 'Cuánto cuenta cada pulsación de + o −.';

  @override
  String get addAmount => 'Añadir una cantidad';

  @override
  String addAmountTitle(String name) {
    return 'Sumar a $name';
  }

  @override
  String takeAmountTitle(String name) {
    return 'Restar a $name';
  }

  @override
  String get amount => 'Cantidad';

  @override
  String get takeAway => 'Restar';

  @override
  String get setValue => 'Fijar el valor';

  @override
  String get value => 'Valor';

  @override
  String get set => 'Fijar';

  @override
  String get resetToZero => 'Poner a cero';

  @override
  String counterReset(String name) {
    return '$name se ha puesto a cero';
  }

  @override
  String get history => 'Historial';

  @override
  String get historyEmpty => 'Aún no se ha contado nada.';

  @override
  String get dayToday => 'Hoy';

  @override
  String get dayYesterday => 'Ayer';

  @override
  String entriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entradas',
      one: '1 entrada',
    );
    return '$_temp0';
  }

  @override
  String get allTime => 'Desde siempre';

  @override
  String get sectionCounting => 'Recuento';

  @override
  String get dayStartsAt => 'El día empieza a las';

  @override
  String get dayStartsAtHint =>
      'Lo que se cuente antes de esta hora pertenece al día anterior.';

  @override
  String get midnight => 'Medianoche';

  @override
  String get yourData => 'Tus datos';

  @override
  String get backUp => 'Hacer una copia en un archivo';

  @override
  String get backUpHint => 'Todo, guardado donde elijas.';

  @override
  String get restore => 'Restaurar una copia de seguridad';

  @override
  String get restoreHint => 'Sustituye lo que hay en este teléfono.';

  @override
  String get backupSaved => 'Copia de seguridad guardada';

  @override
  String get couldNotSave => 'No se pudo guardar el archivo.';

  @override
  String get couldNotOpen => 'No se pudo abrir ese archivo.';

  @override
  String get cantRestore => 'No se puede restaurar este archivo';

  @override
  String get ok => 'Aceptar';

  @override
  String get restoreTitle => '¿Sustituirlo todo por esta copia de seguridad?';

  @override
  String restoreMessage(String groups, String counters, String entries) {
    return 'Contiene $groups, $counters y $entries. Todo lo que hay ahora en este teléfono se sustituirá.';
  }

  @override
  String groupsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count grupos',
      one: '1 grupo',
    );
    return '$_temp0';
  }

  @override
  String get replace => 'Sustituir';

  @override
  String get restored => 'Restaurado';

  @override
  String get backupNotCountersink =>
      'Esto no es una copia de seguridad de Countersink.';

  @override
  String get backupTooNew =>
      'Esta copia de seguridad se hizo con una versión más reciente de Countersink. Actualiza la aplicación y vuelve a intentarlo.';

  @override
  String backupDamaged(String detail) {
    return 'Esta copia de seguridad tiene algún error y no se ha restaurado. No se ha cambiado nada en este teléfono.\n\n$detail';
  }

  @override
  String get colorBrick => 'Ladrillo';

  @override
  String get colorOchre => 'Ocre';

  @override
  String get colorSand => 'Arena';

  @override
  String get colorOlive => 'Oliva';

  @override
  String get colorSage => 'Salvia';

  @override
  String get colorMoss => 'Musgo';

  @override
  String get colorSlate => 'Pizarra';

  @override
  String get colorStorm => 'Tormenta';

  @override
  String get colorSky => 'Cielo';

  @override
  String get colorPlum => 'Ciruela';

  @override
  String get colorRose => 'Rosa';

  @override
  String get colorCocoa => 'Cacao';

  @override
  String get colorCharcoal => 'Carbón';

  @override
  String get colorAubergine => 'Berenjena';

  @override
  String get colorLinen => 'Lino';

  @override
  String get moreColors => 'Más colores y motivos';

  @override
  String get appearanceTitle => 'Color y motivo';

  @override
  String get secondColor => 'Segundo color';

  @override
  String get secondColorHint =>
      'Se funde con el primero, de esquina a esquina.';

  @override
  String get noSecondColor => 'Ninguno';

  @override
  String get pattern => 'Motivo';

  @override
  String get patternNone => 'Liso';

  @override
  String get patternStripes => 'Rayas';

  @override
  String get patternDots => 'Puntos';

  @override
  String get patternGrid => 'Cuadrícula';

  @override
  String get customColor => 'Color personalizado';

  @override
  String get hue => 'Tono';

  @override
  String get saturation => 'Saturación';

  @override
  String get brightness => 'Brillo';

  @override
  String get hexCode => 'Código hexadecimal';

  @override
  String get useColor => 'Usar';

  @override
  String get done => 'Listo';

  @override
  String get sampleCount => '12';

  @override
  String get reorderCounters => 'Reordenar contadores';

  @override
  String get moveToGroup => 'Mover a otro grupo';

  @override
  String moveToGroupTitle(String name) {
    return 'Mover $name a';
  }

  @override
  String movedToGroup(String group) {
    return 'Movido a $group';
  }

  @override
  String get exportCsv => 'Exportar como hoja de cálculo';

  @override
  String get exportCsvHint =>
      'Todas las entradas en un archivo CSV, una fila cada una.';

  @override
  String get csvSaved => 'Hoja de cálculo guardada';

  @override
  String get keepScreenOn => 'Mantener la pantalla encendida';

  @override
  String get keepScreenOnHint =>
      'Mientras Countersink esté abierto, la pantalla no se atenuará ni se bloqueará.';

  @override
  String get sectionAppearance => 'Apariencia';

  @override
  String get theme => 'Tema';

  @override
  String get themeSystem => 'Igual que el teléfono';

  @override
  String get themeLight => 'Claro';

  @override
  String get themeDark => 'Oscuro';

  @override
  String get counterGoal => 'Objetivo (opcional)';

  @override
  String get counterGoalHint =>
      'Un número que alcanzar. En un contador por día, cada día o en la semana.';

  @override
  String goalOf(int goal) {
    return 'de $goal';
  }

  @override
  String get goalReached => 'Objetivo alcanzado';

  @override
  String get dayStreak => 'Días seguidos';

  @override
  String get bestStreak => 'Mejor racha';

  @override
  String get previousMonth => 'Mes anterior';

  @override
  String get nextMonth => 'Mes siguiente';

  @override
  String daysCount(int count) {
    return '$count días';
  }

  @override
  String get averagePerDay => 'Media por día';

  @override
  String get totalInRange => 'Total';

  @override
  String get addEntry => 'Añadir entrada';

  @override
  String get editEntry => 'Editar entrada';

  @override
  String get entryAdded => 'Sumado';

  @override
  String get entryTaken => 'Restado';

  @override
  String get entryTime => 'Hora';

  @override
  String get entryDeleted => 'Entrada borrada';

  @override
  String get belowZero => 'Eso dejaría el recuento por debajo de cero.';

  @override
  String get perDayRefused =>
      'Este contador aún no puede contar por día. Al menos un día de su historial tiene más quitado que contado, así que ese día quedaría por debajo de cero. Corrígelo primero en el historial.';

  @override
  String get noEntries => 'Este día no se contó nada.';

  @override
  String get dayTotal => 'Total del día';

  @override
  String get fullScreen => 'Pantalla completa';

  @override
  String get tapAnywhere => 'Toca en cualquier sitio para contar';

  @override
  String get closeFullScreen => 'Cerrar la pantalla completa';

  @override
  String get volumeKeys => 'Botones de volumen';

  @override
  String get volumeKeysHint =>
      'Cuenta con los botones de volumen del teléfono mientras un contador está en pantalla completa.';

  @override
  String get volumeOff => 'Desactivados';

  @override
  String get volumeUp => 'Subir volumen suma';

  @override
  String get volumeBoth => 'Subir suma, bajar resta';

  @override
  String get lockTouch => 'Bloquear el toque';

  @override
  String get unlockTouch => 'Mantén pulsado para desbloquear';

  @override
  String get touchLocked =>
      'El toque está bloqueado. Cuenta con los botones de volumen.';

  @override
  String get volumeCounts =>
      'Toca en cualquier sitio o pulsa un botón de volumen para contar';

  @override
  String get language => 'Idioma';

  @override
  String get sameAsPhone => 'Igual que el teléfono';

  @override
  String sameAsPhoneNow(String language) {
    return 'Igual que el teléfono: $language';
  }

  @override
  String get archive => 'Archivar';

  @override
  String get unarchive => 'Devolver a su grupo';

  @override
  String counterArchived(String name) {
    return 'Se ha archivado $name';
  }

  @override
  String get archivedCounters => 'Contadores archivados';

  @override
  String get noArchived => 'No hay nada archivado.';

  @override
  String get search => 'Buscar';

  @override
  String get searchHint => 'Buscar contadores';

  @override
  String get noResults => 'Ningún contador coincide.';

  @override
  String get searchPrompt =>
      'Escribe el nombre de un contador, su descripción o su grupo.';

  @override
  String get autoBackup => 'Copia de seguridad automática';

  @override
  String get autoBackupHint =>
      'Desactivada. Elige una carpeta donde guardar una copia cada vez que salgas de la aplicación.';

  @override
  String autoBackupTo(String folder) {
    return 'En $folder, cada vez que sales de la aplicación. Se conservan los últimos 7 días.';
  }

  @override
  String autoBackupFailed(String folder) {
    return 'La última copia no se pudo guardar en $folder. Vuelve a elegir la carpeta.';
  }

  @override
  String get backUpNow => 'Hacer una copia ahora';

  @override
  String get chooseAnotherFolder => 'Elegir otra carpeta';

  @override
  String get turnOff => 'Desactivar';

  @override
  String backedUpTo(String folder) {
    return 'Copia guardada en $folder';
  }

  @override
  String get goalForEach => 'El objetivo es por';

  @override
  String get periodDay => 'Día';

  @override
  String get periodWeek => 'Semana';

  @override
  String goalThisWeek(int done, int goal) {
    return '$done de $goal esta semana';
  }

  @override
  String get weekStreak => 'Semanas seguidas';

  @override
  String get buzzEvery => 'Vibrar cada (opcional)';

  @override
  String get buzzEveryHint =>
      'Una vibración doble cada vez que la cuenta pasa por un múltiplo de este número, por ejemplo cada 10.';

  @override
  String get weekStartsOn => 'Inicio de la semana';

  @override
  String get weekStartsOnHint =>
      'Para los objetivos semanales y el calendario.';

  @override
  String get addToHomeScreen => 'Añadir a la pantalla de inicio';

  @override
  String get quickTile => 'Mosaico de ajustes rápidos';

  @override
  String get quickTileHint =>
      'Desactivado. Elige un contador al que sumar desde los ajustes rápidos del teléfono, sin abrir la aplicación.';

  @override
  String quickTileOn(String name) {
    return 'Suma a $name, desde los ajustes rápidos del teléfono.';
  }

  @override
  String get chooseCounter => 'Elige un contador';

  @override
  String get chooseAnotherCounter => 'Elegir otro contador';

  @override
  String get quickTileHowTo =>
      'Para añadir el mosaico: abre los ajustes rápidos del teléfono, toca el lápiz y arrastra el mosaico de Countersink.';

  @override
  String get calculated => 'Calculado a partir de otros contadores';

  @override
  String get calculatedOff => 'Desactivado. Se cuenta a mano, con más y menos.';

  @override
  String get formulaTitle => 'Contador calculado';

  @override
  String get formulaIntro =>
      'Un contador calculado no se cuenta a mano. Muestra un número que resulta de otros contadores y cambia con ellos.';

  @override
  String get formulaNone => 'Contado a mano';

  @override
  String get formulaSum => 'Un total';

  @override
  String get formulaSumHint => 'Varios contadores sumados.';

  @override
  String get formulaDifference => 'Una diferencia';

  @override
  String get formulaDifferenceHint =>
      'Un contador menos los demás. Entradas menos salidas.';

  @override
  String get formulaPercent => 'Una parte, en porcentaje';

  @override
  String get formulaPercentHint => 'Un contador como parte de varios juntos.';

  @override
  String get formulaEvery => 'Vueltas completas';

  @override
  String get formulaEveryHint =>
      'Cuántas vueltas ha dado otro contador: cada 108 cuentas, cada 8 filas.';

  @override
  String get sectionShows => 'Qué muestra';

  @override
  String get formulaAddUp => 'Sumar';

  @override
  String get formulaStartWith => 'Partir de';

  @override
  String get formulaTakeAway => 'Restar';

  @override
  String get formulaShareOf => 'La parte de';

  @override
  String get formulaTogetherWith => 'En el total junto con';

  @override
  String get formulaRoundsOf => 'Vueltas de';

  @override
  String get formulaAllTime => 'Mantener un total acumulado';

  @override
  String get formulaAllTimeHint =>
      'Los contadores por día cuentan con todo lo que han contado, no solo lo de hoy. Empiezan cada día desde cero; este número sigue adelante.';

  @override
  String get formulaStartFrom => 'Empezar desde (opcional)';

  @override
  String get formulaStartFromHint =>
      'Un número en el que el total ya está, de antes de contarlo aquí. Lo que se cuenta se suma a él.';

  @override
  String get roundSize => 'Una vuelta son';

  @override
  String get roundSizeHint => 'Cuántos hacen una vuelta.';

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
    return 'Vueltas de $size en $name';
  }

  @override
  String lineTowardNext(int count) {
    return '$count hacia la siguiente';
  }

  @override
  String get lineBroken => 'El contador del que se calculaba ya no existe';

  @override
  String get noOrdinaryCounters =>
      'Añade primero un contador para contar a mano. Uno calculado se obtiene a partir de esos.';

  @override
  String get emptyGroup => 'Grupo vacío';

  @override
  String get emptyGroupHint => 'Ponle nombre y añade tus propios contadores.';

  @override
  String get readyMadeSets => 'Conjuntos ya hechos';

  @override
  String copyGroupNamed(String name) {
    return 'Copiar $name, sin sus cuentas';
  }

  @override
  String groupCopyName(String name) {
    return '$name (copia)';
  }

  @override
  String get presetRows => 'Filas y repeticiones';

  @override
  String get presetRowsHint => 'Filas, y las repeticiones de 8 que forman.';

  @override
  String get presetBeads => 'Cuentas';

  @override
  String get presetBeadsHint => 'Cuentas, y las vueltas de 108 que forman.';

  @override
  String get presetInOut => 'Entradas y salidas';

  @override
  String get presetInOutHint =>
      'Los que entran, los que salen y cuántos hay dentro.';

  @override
  String get presetScore => 'Marcador';

  @override
  String get presetScoreHint => 'Dos puntuaciones.';

  @override
  String get presetMade => 'Aciertos y fallos';

  @override
  String get presetMadeHint => 'Aciertos, fallos y la parte de aciertos.';

  @override
  String get nameRows => 'Filas';

  @override
  String get nameRepeats => 'Repeticiones';

  @override
  String get nameBeads => 'Cuentas';

  @override
  String get nameRounds => 'Vueltas';

  @override
  String get nameIn => 'Entran';

  @override
  String get nameOut => 'Salen';

  @override
  String get nameInside => 'Dentro';

  @override
  String get nameUs => 'Nosotros';

  @override
  String get nameThem => 'Ellos';

  @override
  String get nameMade => 'Aciertos';

  @override
  String get nameMissed => 'Fallos';

  @override
  String get nameMadeShare => 'Aciertos en porcentaje';

  @override
  String get importFromApp => 'Importar de otra aplicación';

  @override
  String get importFromAppHint =>
      'Contadores de BetterCounter, Counter o Simple Counter, añadidos como grupos nuevos.';

  @override
  String get importChooseApp => '¿De qué aplicación es el archivo?';

  @override
  String get importBetterCounterHint =>
      'Su archivo CSV exportado. Cada cuenta llega con su hora.';

  @override
  String get importCounterHint =>
      'Su archivo CSV exportado. Cada contador llega con su número.';

  @override
  String get importSimpleCounterHint =>
      'Su copia de seguridad JSON. Las etiquetas pasan a ser grupos.';

  @override
  String get importedGroupName => 'Importados';

  @override
  String get cantImport => 'No se puede importar este archivo';

  @override
  String importNotFrom(String app) {
    return 'No parece un archivo de $app.';
  }

  @override
  String get importEmpty => 'No hay contadores en este archivo.';

  @override
  String importIsBackup(String restore) {
    return 'Es una copia de seguridad de Countersink. Para eso está «$restore».';
  }

  @override
  String importDone(String counters, String entries) {
    return 'Se importaron $counters y $entries.';
  }

  @override
  String importSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'No se pudieron leer $count líneas.',
      one: 'No se pudo leer 1 línea.',
    );
    return '$_temp0';
  }

  @override
  String reachedGoal(String name, int goal) {
    return '$name ha llegado a $goal';
  }

  @override
  String get goalHintCalculated =>
      'Un número que alcanzar. Un mensaje avisa cuando se llega.';

  @override
  String get sendToPhone => 'Enviar a otro teléfono';

  @override
  String get receiveFromPhone => 'Recibir de otro teléfono';

  @override
  String get shareWhatToSend => '¿Qué quieres enviar?';

  @override
  String get sendEverything => 'Todo';

  @override
  String get sendEverythingHint => 'Para pasar a un teléfono nuevo.';

  @override
  String get shareWhatToInclude => 'Qué incluir';

  @override
  String get shareShowCodes => 'Mostrar los códigos';

  @override
  String get shareHowToReceive =>
      'En el otro teléfono, abre Countersink, ve a Ajustes → Recibir de otro teléfono y apunta la cámara a esta pantalla.';

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
  String get sharePlay => 'Reanudar';

  @override
  String get shareNextCode => 'Código siguiente';

  @override
  String get shareCodesChange =>
      'Los códigos cambian solos. El otro teléfono los recoge en cualquier orden.';

  @override
  String get shareNotCountersink => 'Ese código no es de Countersink.';

  @override
  String get shareNewerVersion =>
      'El otro teléfono tiene una versión más reciente de Countersink. Actualiza primero este.';

  @override
  String get shareRestarted =>
      'El otro teléfono ha vuelto a empezar. Recogiendo los códigos nuevos.';

  @override
  String get shareUnreadable =>
      'Algunos códigos no se leyeron bien. Vamos a escanearlos otra vez.';

  @override
  String get shareNeedsCamera =>
      'Countersink necesita la cámara para leer los códigos. Puedes permitirlo en los ajustes del sistema para Countersink.';

  @override
  String get sharePointCamera =>
      'Apunta la cámara al código del otro teléfono.';

  @override
  String get shareReading => 'Leyendo…';

  @override
  String shareCodesReceived(int received, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$received de $total códigos recibidos',
    );
    return '$_temp0';
  }

  @override
  String shareStillNeeded(String codes) {
    return 'Faltan: $codes';
  }

  @override
  String get sendToPhoneHint =>
      'Muestra tus contadores como códigos para que otro teléfono los escanee.';

  @override
  String get receiveFromPhoneHint =>
      'Escanea los códigos que muestra otro teléfono. Lo que llega se añade como grupos nuevos.';

  @override
  String get sendSomeCounters => 'Solo algunos contadores';

  @override
  String get sendWithHistory => 'Contadores y su historial';

  @override
  String get sendWithHistoryHint => 'Cada entrada, con su hora.';

  @override
  String get sendNumbersOnly => 'Contadores y sus números';

  @override
  String get sendNumbersOnlyHint =>
      'Muchos menos códigos. Cada contador llega con el número que muestra ahora.';

  @override
  String sendSummary(String counters, String entries) {
    return 'Se envían $counters y $entries.';
  }

  @override
  String receivedDone(String counters, String entries) {
    return 'Se recibieron $counters y $entries.';
  }

  @override
  String get sendNothingChosen => 'Elige al menos un contador para enviar.';
}
