// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Countersink';

  @override
  String get addCounter => 'Добавить счётчик';

  @override
  String get counterName => 'Название';

  @override
  String get counterDescription => 'Описание (необязательно)';

  @override
  String get countPerDay => 'Считать по дням';

  @override
  String get countPerDayHint =>
      'Показывает итог за сегодня и каждый день начинает с нуля. Прошлые дни сохраняются.';

  @override
  String get cancel => 'Отмена';

  @override
  String get add => 'Добавить';

  @override
  String get today => 'сегодня';

  @override
  String get noCounters => 'Здесь пока нет счётчиков.';

  @override
  String increment(int step, String name) {
    return 'Прибавить $step: $name';
  }

  @override
  String decrement(int step, String name) {
    return 'Отнять $step: $name';
  }

  @override
  String get firstGroupName => 'Счётчики';

  @override
  String get firstCounterName => 'Мой первый счётчик';

  @override
  String get firstCounterDescription =>
      'Нажмите +, чтобы считать. Удерживайте, чтобы изменить.';

  @override
  String get settings => 'Настройки';

  @override
  String get about => 'О приложении';

  @override
  String get aboutCountersink => 'О Countersink';

  @override
  String get aboutCountersinkHint =>
      'Где хранятся ваши подсчёты и почему это бесплатно';

  @override
  String get aboutHeadline => 'Ваши подсчёты остаются у вас.';

  @override
  String get aboutIntro =>
      'Countersink считает что угодно: повторения, ряды, очки, запасы.';

  @override
  String get aboutStaysTitle => 'Всё остаётся на вашем телефоне';

  @override
  String get aboutStaysBody =>
      'Каждый подсчёт записывается в базу данных на этом устройстве. Нет ни учётной записи, ни сервера. Данные попадут куда-то ещё, только если вы сами перенесёте их в виде файла резервной копии.';

  @override
  String get aboutCannotSeeTitle => 'Мы не можем их видеть';

  @override
  String get aboutCannotSeeBody =>
      'У Countersink вообще нет разрешения на доступ к интернету. Android это гарантирует, и вы можете проверить это в списке разрешений приложения.';

  @override
  String get aboutNoAdsTitle => 'Никакой рекламы, никогда';

  @override
  String get aboutNoAdsBody =>
      'Счёт ничто не должно прерывать. Countersink всегда будет бесплатным и открытым: без рекламы, без цены, без платных версий.';

  @override
  String get aboutCheckTitle => 'Нашу работу можно проверить';

  @override
  String get aboutCheckBody =>
      'Countersink — программа с открытым исходным кодом под лицензией GNU General Public License. Любой может точно прочитать, что она делает.';

  @override
  String get aboutTradeOff =>
      'Об одном компромиссе стоит знать: копии в облаке нет, поэтому при потере или сбросе телефона подсчёты пропадут. Время от времени сохраняйте файл резервной копии в настройках и храните его не на этом телефоне.';

  @override
  String get version => 'Версия';

  @override
  String get website => 'Сайт';

  @override
  String get sendFeedback => 'Отправить отзыв';

  @override
  String get sendFeedbackHint => 'Форма на сайте, в вашем браузере.';

  @override
  String noBrowser(String website) {
    return 'Нет браузера, чтобы открыть ссылку. Откройте $website вручную.';
  }

  @override
  String versionNumber(String version) {
    return 'Версия $version';
  }

  @override
  String get editCounter => 'Изменить счётчик';

  @override
  String get edit => 'Изменить';

  @override
  String get save => 'Сохранить';

  @override
  String get delete => 'Удалить';

  @override
  String get undo => 'Отменить';

  @override
  String counterDeleted(String name) {
    return 'Удалено: $name';
  }

  @override
  String get counterColor => 'Цвет';

  @override
  String get colorClay => 'Глина';

  @override
  String get colorTeal => 'Бирюзовый';

  @override
  String get colorNavy => 'Тёмно-синий';

  @override
  String get colorLavender => 'Лавандовый';

  @override
  String get colorGreen => 'Зелёный';

  @override
  String get colorCustom => 'Свой';

  @override
  String get groups => 'Группы';

  @override
  String get addGroup => 'Добавить группу';

  @override
  String get renameGroup => 'Переименовать группу';

  @override
  String get groupName => 'Название';

  @override
  String countersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count счётчика',
      many: '$count счётчиков',
      few: '$count счётчика',
      one: '$count счётчик',
      zero: 'Нет счётчиков',
    );
    return '$_temp0';
  }

  @override
  String deleteNamed(String name) {
    return 'Удалить: $name';
  }

  @override
  String groupDeleted(String name, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Удалено: $name и $count счётчика в ней',
      many: 'Удалено: $name и $count счётчиков в ней',
      few: 'Удалено: $name и $count счётчика в ней',
      one: 'Удалено: $name и $count счётчик в ней',
      zero: 'Удалено: $name',
    );
    return '$_temp0';
  }

  @override
  String get lastGroupHint => 'Последнюю группу удалить нельзя.';

  @override
  String get counterStep => 'Шаг';

  @override
  String get counterStepHint =>
      'Сколько прибавляет или отнимает каждое нажатие + или −.';

  @override
  String get addAmount => 'Добавить количество';

  @override
  String addAmountTitle(String name) {
    return 'Прибавить: $name';
  }

  @override
  String takeAmountTitle(String name) {
    return 'Отнять: $name';
  }

  @override
  String get amount => 'Количество';

  @override
  String get takeAway => 'Отнять';

  @override
  String get setValue => 'Задать значение';

  @override
  String get value => 'Значение';

  @override
  String get set => 'Задать';

  @override
  String get resetToZero => 'Сбросить до нуля';

  @override
  String counterReset(String name) {
    return '$name: сброшено до нуля';
  }

  @override
  String get history => 'История';

  @override
  String get historyEmpty => 'Пока ничего не посчитано.';

  @override
  String get dayToday => 'Сегодня';

  @override
  String get dayYesterday => 'Вчера';

  @override
  String entriesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count записи',
      many: '$count записей',
      few: '$count записи',
      one: '$count запись',
    );
    return '$_temp0';
  }

  @override
  String get allTime => 'За всё время';

  @override
  String get sectionCounting => 'Счёт';

  @override
  String get dayStartsAt => 'День начинается в';

  @override
  String get dayStartsAtHint =>
      'Всё, что посчитано раньше этого часа, относится к предыдущему дню.';

  @override
  String get midnight => 'Полночь';

  @override
  String get yourData => 'Ваши данные';

  @override
  String get backUp => 'Сохранить резервную копию в файл';

  @override
  String get backUpHint => 'Все данные, в выбранное вами место.';

  @override
  String get restore => 'Восстановить из резервной копии';

  @override
  String get restoreHint => 'Заменяет то, что есть на этом телефоне.';

  @override
  String get backupSaved => 'Резервная копия сохранена';

  @override
  String get couldNotSave => 'Не удалось сохранить файл.';

  @override
  String get couldNotOpen => 'Не удалось открыть этот файл.';

  @override
  String get cantRestore => 'Не удаётся восстановить данные из этого файла';

  @override
  String get ok => 'ОК';

  @override
  String get restoreTitle => 'Заменить всё данными из этой резервной копии?';

  @override
  String restoreMessage(String groups, String counters, String entries) {
    return 'В ней $groups, $counters и $entries. Всё, что сейчас есть на этом телефоне, будет заменено.';
  }

  @override
  String groupsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count группы',
      many: '$count групп',
      few: '$count группы',
      one: '$count группа',
    );
    return '$_temp0';
  }

  @override
  String get replace => 'Заменить';

  @override
  String get restored => 'Восстановлено';

  @override
  String get backupNotCountersink => 'Это не резервная копия Countersink.';

  @override
  String get backupTooNew =>
      'Эта резервная копия создана в более новой версии Countersink. Обновите приложение и повторите попытку.';

  @override
  String backupDamaged(String detail) {
    return 'В этой резервной копии есть ошибка, она не восстановлена. На этом телефоне ничего не изменилось.\n\n$detail';
  }

  @override
  String get colorBrick => 'Кирпичный';

  @override
  String get colorOchre => 'Охра';

  @override
  String get colorSand => 'Песочный';

  @override
  String get colorOlive => 'Оливковый';

  @override
  String get colorSage => 'Шалфей';

  @override
  String get colorMoss => 'Мох';

  @override
  String get colorSlate => 'Сланец';

  @override
  String get colorStorm => 'Грозовой';

  @override
  String get colorSky => 'Небесный';

  @override
  String get colorPlum => 'Сливовый';

  @override
  String get colorRose => 'Розовый';

  @override
  String get colorCocoa => 'Какао';

  @override
  String get colorCharcoal => 'Антрацит';

  @override
  String get colorAubergine => 'Баклажан';

  @override
  String get colorLinen => 'Лён';

  @override
  String get moreColors => 'Другие цвета и узоры';

  @override
  String get appearanceTitle => 'Цвет и узор';

  @override
  String get secondColor => 'Второй цвет';

  @override
  String get secondColorHint => 'Плавно переходит в первый, от угла к углу.';

  @override
  String get noSecondColor => 'Нет';

  @override
  String get pattern => 'Узор';

  @override
  String get patternNone => 'Без узора';

  @override
  String get patternStripes => 'Полосы';

  @override
  String get patternDots => 'Точки';

  @override
  String get patternGrid => 'Сетка';

  @override
  String get customColor => 'Свой цвет';

  @override
  String get hue => 'Тон';

  @override
  String get saturation => 'Насыщенность';

  @override
  String get brightness => 'Яркость';

  @override
  String get hexCode => 'Hex-код';

  @override
  String get useColor => 'Выбрать';

  @override
  String get done => 'Готово';

  @override
  String get sampleCount => '12';

  @override
  String get reorderCounters => 'Изменить порядок счётчиков';

  @override
  String get moveToGroup => 'Переместить в другую группу';

  @override
  String moveToGroupTitle(String name) {
    return 'Переместить «$name» в';
  }

  @override
  String movedToGroup(String group) {
    return 'Перемещено в «$group»';
  }

  @override
  String get exportCsv => 'Экспортировать в таблицу';

  @override
  String get exportCsvHint => 'Все записи в файле CSV, по одной в строке.';

  @override
  String get csvSaved => 'Таблица сохранена';

  @override
  String get keepScreenOn => 'Не выключать экран';

  @override
  String get keepScreenOnHint =>
      'Пока Countersink открыт, экран не гаснет и не блокируется.';

  @override
  String get sectionAppearance => 'Оформление';

  @override
  String get theme => 'Тема';

  @override
  String get themeSystem => 'Как на телефоне';

  @override
  String get themeLight => 'Светлая';

  @override
  String get themeDark => 'Тёмная';

  @override
  String get counterGoal => 'Цель (необязательно)';

  @override
  String get counterGoalHint =>
      'Число, которого нужно достичь. Для счётчика по дням — каждый день или за неделю.';

  @override
  String goalOf(int goal) {
    return 'из $goal';
  }

  @override
  String get goalReached => 'Цель достигнута';

  @override
  String get dayStreak => 'Дней подряд';

  @override
  String get bestStreak => 'Лучшая серия';

  @override
  String get previousMonth => 'Предыдущий месяц';

  @override
  String get nextMonth => 'Следующий месяц';

  @override
  String daysCount(int count) {
    return '$count дней';
  }

  @override
  String get averagePerDay => 'В среднем за день';

  @override
  String get totalInRange => 'Всего';

  @override
  String get addEntry => 'Добавить запись';

  @override
  String get editEntry => 'Изменить запись';

  @override
  String get entryAdded => 'Прибавлено';

  @override
  String get entryTaken => 'Отнято';

  @override
  String get entryTime => 'Время';

  @override
  String get entryDeleted => 'Запись удалена';

  @override
  String get belowZero => 'Так счёт стал бы меньше нуля.';

  @override
  String get perDayRefused =>
      'Этот счётчик пока не может считать по дням. Хотя бы в один день в истории убавлено больше, чем насчитано, и этот день оказался бы меньше нуля. Сначала исправьте его в истории.';

  @override
  String get noEntries => 'В этот день ничего не посчитано.';

  @override
  String get dayTotal => 'Итог за день';

  @override
  String get fullScreen => 'Во весь экран';

  @override
  String get tapAnywhere => 'Нажмите в любом месте, чтобы считать';

  @override
  String get closeFullScreen => 'Закрыть полноэкранный режим';

  @override
  String get volumeKeys => 'Кнопки громкости';

  @override
  String get volumeKeysHint =>
      'Считайте кнопками громкости, пока счётчик открыт во весь экран.';

  @override
  String get volumeOff => 'Выключены';

  @override
  String get volumeUp => 'Громкость + прибавляет';

  @override
  String get volumeBoth => '+ прибавляет, − отнимает';

  @override
  String get lockTouch => 'Заблокировать касания';

  @override
  String get unlockTouch => 'Удерживайте, чтобы разблокировать';

  @override
  String get touchLocked =>
      'Касания заблокированы. Считайте кнопками громкости.';

  @override
  String get volumeCounts =>
      'Нажмите в любом месте или кнопку громкости, чтобы считать';

  @override
  String get language => 'Язык';

  @override
  String get sameAsPhone => 'Как на телефоне';

  @override
  String sameAsPhoneNow(String language) {
    return 'Как на телефоне: $language';
  }

  @override
  String get archive => 'В архив';

  @override
  String get unarchive => 'Вернуть в группу';

  @override
  String counterArchived(String name) {
    return 'В архиве: $name';
  }

  @override
  String get archivedCounters => 'Счётчики в архиве';

  @override
  String get noArchived => 'В архиве ничего нет.';

  @override
  String get search => 'Поиск';

  @override
  String get searchHint => 'Поиск счётчиков';

  @override
  String get noResults => 'Подходящих счётчиков нет.';

  @override
  String get searchPrompt =>
      'Введите название счётчика, его описание или группу.';

  @override
  String get autoBackup => 'Автоматическое резервное копирование';

  @override
  String get autoBackupHint =>
      'Выключено. Выберите папку, куда будет сохраняться копия при каждом выходе из приложения.';

  @override
  String autoBackupTo(String folder) {
    return 'В папку «$folder» при каждом выходе из приложения. Хранятся копии за последние 7 дней.';
  }

  @override
  String autoBackupFailed(String folder) {
    return 'Последнюю копию не удалось сохранить в папку «$folder». Выберите папку ещё раз.';
  }

  @override
  String get backUpNow => 'Создать копию сейчас';

  @override
  String get chooseAnotherFolder => 'Выбрать другую папку';

  @override
  String get turnOff => 'Выключить';

  @override
  String backedUpTo(String folder) {
    return 'Копия сохранена в папку «$folder»';
  }

  @override
  String get goalForEach => 'Цель считается за';

  @override
  String get periodDay => 'День';

  @override
  String get periodWeek => 'Неделю';

  @override
  String goalThisWeek(int done, int goal) {
    return '$done из $goal за эту неделю';
  }

  @override
  String get weekStreak => 'Недель подряд';

  @override
  String get buzzEvery => 'Вибрация через каждые (необязательно)';

  @override
  String get buzzEveryHint =>
      'Двойная вибрация каждый раз, когда счёт проходит число, кратное этому, например каждые 10.';

  @override
  String get weekStartsOn => 'Начало недели';

  @override
  String get weekStartsOnHint => 'Для недельных целей и календаря.';

  @override
  String get addToHomeScreen => 'Добавить на главный экран';

  @override
  String get quickTile => 'Плитка в быстрых настройках';

  @override
  String get quickTileHint =>
      'Выключено. Выберите счётчик, к которому можно прибавлять из быстрых настроек телефона, не открывая приложение.';

  @override
  String quickTileOn(String name) {
    return 'Прибавляет к счётчику «$name» из быстрых настроек телефона.';
  }

  @override
  String get chooseCounter => 'Выберите счётчик';

  @override
  String get chooseAnotherCounter => 'Выбрать другой счётчик';

  @override
  String get quickTileHowTo =>
      'Чтобы добавить плитку, откройте быстрые настройки телефона, нажмите на карандаш и перетащите плитку Countersink.';

  @override
  String get calculated => 'Вычисляется по другим счётчикам';

  @override
  String get calculatedOff => 'Выключено. Считается вручную, плюсом и минусом.';

  @override
  String get formulaTitle => 'Вычисляемый счётчик';

  @override
  String get formulaIntro =>
      'Вычисляемый счётчик не считают вручную. Он показывает число, полученное из других счётчиков, и меняется вместе с ними.';

  @override
  String get formulaNone => 'Считается вручную';

  @override
  String get formulaSum => 'Сумма';

  @override
  String get formulaSumHint => 'Несколько счётчиков, сложенных вместе.';

  @override
  String get formulaDifference => 'Разность';

  @override
  String get formulaDifferenceHint =>
      'Один счётчик минус остальные. Вошло минус вышло.';

  @override
  String get formulaPercent => 'Доля в процентах';

  @override
  String get formulaPercentHint =>
      'Один счётчик как доля от нескольких вместе.';

  @override
  String get formulaEvery => 'Полные круги';

  @override
  String get formulaEveryHint =>
      'Сколько кругов прошёл другой счётчик: каждые 108 бусин, каждые 8 рядов.';

  @override
  String get sectionShows => 'Что он показывает';

  @override
  String get formulaAddUp => 'Сложить';

  @override
  String get formulaStartWith => 'Начать с';

  @override
  String get formulaTakeAway => 'Вычесть';

  @override
  String get formulaShareOf => 'Доля счётчика';

  @override
  String get formulaTogetherWith => 'В сумме вместе с';

  @override
  String get formulaRoundsOf => 'Круги счётчика';

  @override
  String get formulaAllTime => 'Вести нарастающий итог';

  @override
  String get formulaAllTimeHint =>
      'Счётчики по дням учитываются со всем, что они насчитали, а не только за сегодня. Они каждый день начинают с нуля; это число продолжает расти.';

  @override
  String get formulaStartFrom => 'Начать с (необязательно)';

  @override
  String get formulaStartFromHint =>
      'Число, которого итог уже достиг до того, как его стали считать здесь. Всё, что считается, прибавляется к нему.';

  @override
  String get roundSize => 'Один круг — это';

  @override
  String get roundSizeHint => 'Сколько составляет один круг.';

  @override
  String lineSum(String names) {
    return 'Сумма: $names';
  }

  @override
  String lineDifference(String first, String others) {
    return '$first минус $others';
  }

  @override
  String linePercent(String first, String all) {
    return '$first как доля от $all';
  }

  @override
  String lineEvery(int size, String name) {
    return 'Круги по $size в «$name»';
  }

  @override
  String lineTowardNext(int count) {
    return '$count к следующему';
  }

  @override
  String get lineBroken => 'Счётчика, по которому он вычислялся, больше нет';

  @override
  String get noOrdinaryCounters =>
      'Сначала добавьте счётчик для счёта вручную. Вычисляемый получается из таких.';

  @override
  String get emptyGroup => 'Пустая группа';

  @override
  String get emptyGroupHint => 'Назовите её и добавьте свои счётчики.';

  @override
  String get readyMadeSets => 'Готовые наборы';

  @override
  String copyGroupNamed(String name) {
    return 'Скопировать «$name» без счёта';
  }

  @override
  String groupCopyName(String name) {
    return '$name (копия)';
  }

  @override
  String get presetRows => 'Ряды и раппорты';

  @override
  String get presetRowsHint =>
      'Ряды и раппорты по 8, которые из них получаются.';

  @override
  String get presetBeads => 'Бусины';

  @override
  String get presetBeadsHint =>
      'Бусины и круги по 108, которые из них получаются.';

  @override
  String get presetInOut => 'Вход и выход';

  @override
  String get presetInOutHint =>
      'Сколько вошло, сколько вышло и сколько внутри.';

  @override
  String get presetScore => 'Счёт игры';

  @override
  String get presetScoreHint => 'Два счёта.';

  @override
  String get presetMade => 'Попадания и промахи';

  @override
  String get presetMadeHint => 'Попадания, промахи и доля попаданий.';

  @override
  String get nameRows => 'Ряды';

  @override
  String get nameRepeats => 'Раппорты';

  @override
  String get nameBeads => 'Бусины';

  @override
  String get nameRounds => 'Круги';

  @override
  String get nameIn => 'Вошло';

  @override
  String get nameOut => 'Вышло';

  @override
  String get nameInside => 'Внутри';

  @override
  String get nameUs => 'Мы';

  @override
  String get nameThem => 'Они';

  @override
  String get nameMade => 'Попадания';

  @override
  String get nameMissed => 'Промахи';

  @override
  String get nameMadeShare => 'Попадания в процентах';

  @override
  String get importFromApp => 'Импорт из другого приложения';

  @override
  String get importFromAppHint =>
      'Счётчики из BetterCounter, Counter или Simple Counter добавляются новыми группами.';

  @override
  String get importChooseApp => 'Из какого приложения этот файл?';

  @override
  String get importBetterCounterHint =>
      'Его экспортированный файл CSV. Каждый отсчёт переносится со своим временем.';

  @override
  String get importCounterHint =>
      'Его экспортированный файл CSV. Каждый счётчик переносится со своим числом.';

  @override
  String get importSimpleCounterHint =>
      'Его резервная копия JSON. Метки становятся группами.';

  @override
  String get importedGroupName => 'Импорт';

  @override
  String get cantImport => 'Не удаётся импортировать этот файл';

  @override
  String importNotFrom(String app) {
    return 'Это не похоже на файл из $app.';
  }

  @override
  String get importEmpty => 'В этом файле нет счётчиков.';

  @override
  String importIsBackup(String restore) {
    return 'Это резервная копия Countersink. Для неё есть «$restore».';
  }

  @override
  String importDone(String counters, String entries) {
    return 'Импортировано: $counters и $entries.';
  }

  @override
  String importSkipped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Не удалось прочитать $count строки.',
      many: 'Не удалось прочитать $count строк.',
      few: 'Не удалось прочитать $count строки.',
      one: 'Не удалось прочитать $count строку.',
    );
    return '$_temp0';
  }

  @override
  String reachedGoal(String name, int goal) {
    return '«$name»: достигнуто $goal';
  }

  @override
  String get goalHintCalculated =>
      'Число, которого нужно достичь. Когда оно достигнуто, появляется сообщение.';

  @override
  String get sendToPhone => 'Отправить на другой телефон';

  @override
  String get receiveFromPhone => 'Получить с другого телефона';

  @override
  String get shareWhatToSend => 'Что вы хотите отправить?';

  @override
  String get sendEverything => 'Всё';

  @override
  String get sendEverythingHint => 'Переход на новый телефон.';

  @override
  String get shareWhatToInclude => 'Что включить';

  @override
  String get shareShowCodes => 'Показать коды';

  @override
  String get shareHowToReceive =>
      'На другом телефоне откройте Countersink, перейдите в Настройки → Получить с другого телефона и наведите камеру на этот экран.';

  @override
  String shareCodeOf(int index, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: 'Код $index из $total',
      many: 'Код $index из $total',
      few: 'Код $index из $total',
      one: 'Код $index из $total',
    );
    return '$_temp0';
  }

  @override
  String get sharePreviousCode => 'Предыдущий код';

  @override
  String get sharePause => 'Пауза';

  @override
  String get sharePlay => 'Продолжить';

  @override
  String get shareNextCode => 'Следующий код';

  @override
  String get shareCodesChange =>
      'Коды сменяются сами. Другой телефон собирает их в любом порядке.';

  @override
  String get shareNotCountersink => 'Этот код не от Countersink.';

  @override
  String get shareNewerVersion =>
      'На другом телефоне более новая версия Countersink. Сначала обновите приложение на этом.';

  @override
  String get shareRestarted =>
      'Другой телефон начал заново. Собираем новые коды.';

  @override
  String get shareUnreadable =>
      'Некоторые коды не считались как следует. Давайте отсканируем их ещё раз.';

  @override
  String get shareNeedsCamera =>
      'Countersink нужна камера, чтобы считать коды. Разрешить доступ можно в системных настройках для Countersink.';

  @override
  String get sharePointCamera => 'Наведите камеру на код на другом телефоне.';

  @override
  String get shareReading => 'Считывание…';

  @override
  String shareCodesReceived(int received, int total) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: 'Получено кодов: $received из $total',
      many: 'Получено кодов: $received из $total',
      few: 'Получено кодов: $received из $total',
      one: 'Получено кодов: $received из $total',
    );
    return '$_temp0';
  }

  @override
  String shareStillNeeded(String codes) {
    return 'Ещё нужны: $codes';
  }

  @override
  String get sendToPhoneHint =>
      'Показать ваши счётчики в виде кодов, чтобы другой телефон их отсканировал.';

  @override
  String get receiveFromPhoneHint =>
      'Отсканируйте коды с другого телефона. Полученное добавляется новыми группами.';

  @override
  String get sendSomeCounters => 'Только некоторые счётчики';

  @override
  String get sendWithHistory => 'Счётчики с историей';

  @override
  String get sendWithHistoryHint => 'Каждая запись со своим временем.';

  @override
  String get sendNumbersOnly => 'Счётчики с их числами';

  @override
  String get sendNumbersOnlyHint =>
      'Гораздо меньше кодов. Каждый счётчик приходит с числом, которое он показывает сейчас.';

  @override
  String sendSummary(String counters, String entries) {
    return 'Отправляется: $counters и $entries.';
  }

  @override
  String receivedDone(String counters, String entries) {
    return 'Получено: $counters и $entries.';
  }

  @override
  String get sendNothingChosen => 'Выберите хотя бы один счётчик для отправки.';
}
