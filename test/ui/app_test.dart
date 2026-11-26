import 'dart:convert';
import 'dart:io';

import 'package:countersink/data/backup.dart';
import 'package:countersink/data/qr_transfer.dart';
import 'package:countersink/ui/qr_code_view.dart';
import 'package:countersink/ui/receive_screen.dart';
import 'package:countersink/models/counter.dart';
import 'package:countersink/models/counter_group.dart';
import 'package:countersink/models/tap_event.dart';
import 'package:countersink/services/app_info.dart';
import 'package:countersink/services/auto_backup.dart';
import 'package:countersink/services/preferences.dart';
import 'package:countersink/ui/app.dart';
import 'package:countersink/ui/counter_card.dart';
import 'package:countersink/ui/counter_look.dart';
import 'package:countersink/ui/counter_store.dart';
import 'package:countersink/ui/language.dart';
import 'package:countersink/ui/presets.dart';
import 'package:countersink/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/fakes.dart';

/// Drives the real screens against an in-memory store.
void main() {
  late InMemoryCounterRepository repo;
  late CounterStore store;
  var now = DateTime(2026, 11, 22, 12);

  setUp(() async {
    now = DateTime(2026, 11, 22, 12);
    SharedPreferences.setMockInitialValues({});
    themeChoice.value = ThemeMode.system;
    chosenLanguage.value = null;
    repo = InMemoryCounterRepository();
    store = CounterStore(repository: repo, clock: () => now);
    final group = await store.addGroup('Fitness');
    await store.addCounter(
      groupId: group.id,
      name: 'Pull-ups',
      description: 'Strict',
      daily: true,
    );
  });

  Future<void> start(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.75;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(CountersinkApp(store: store));
    await tester.pumpAndSettle();
  }

  /// Scrolls History down to its list of days, which sits below the chart
  /// and the calendar and isn't built until it's near the screen.
  Future<void> showDayList(WidgetTester tester) async {
    await tester.scrollUntilVisible(
      find.text('Yesterday'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
  }

  /// Taps a row in Settings, scrolling down to it first: the list only
  /// builds the rows near the screen.
  Future<void> tapSetting(WidgetTester tester, String title) async {
    await tester.scrollUntilVisible(
      find.text(title),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    // In view is not yet enough: all of it, so the tap lands on it.
    await tester.ensureVisible(find.text(title));
    await tester.pumpAndSettle();
    await tester.tap(find.text(title));
  }

  testWidgets('shows the group as a tab and the counter on a card', (
    tester,
  ) async {
    await start(tester);
    expect(find.widgetWithText(Tab, 'Fitness'), findsOneWidget);
    expect(find.text('Pull-ups'), findsOneWidget);
    expect(find.text('today · Strict'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
  });

  testWidgets('plus and minus change the count, each tap an event', (
    tester,
  ) async {
    await start(tester);
    for (var i = 0; i < 3; i++) {
      await tester.tap(find.bySemanticsLabel('Add 1 to Pull-ups'));
      await tester.pumpAndSettle();
    }
    expect(find.text('3'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Take 1 from Pull-ups'));
    await tester.pumpAndSettle();
    expect(find.text('2'), findsOneWidget);
    expect([for (final e in repo.log) e.delta], [1, 1, 1, -1]);
    expect(repo.log.every((e) => e.at == now), isTrue);
  });

  testWidgets('minus does nothing at zero', (tester) async {
    await start(tester);
    await tester.tap(find.bySemanticsLabel('Take 1 from Pull-ups'));
    await tester.pumpAndSettle();
    expect(find.text('0'), findsOneWidget);
    expect(repo.log, isEmpty);
  });

  testWidgets('a daily counter starts from zero the next day, history kept', (
    tester,
  ) async {
    await start(tester);
    await tester.tap(find.bySemanticsLabel('Add 1 to Pull-ups'));
    await tester.pumpAndSettle();
    expect(find.text('1'), findsOneWidget);

    now = DateTime(2026, 11, 23, 8);
    await store.load();
    await tester.pumpAndSettle();
    expect(find.text('0'), findsOneWidget);
    expect(repo.log, hasLength(1));
  });

  testWidgets('add a counter to the open group', (tester) async {
    await start(tester);
    await tester.tap(find.text('Add counter'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Name'), 'Push-ups');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    expect(find.text('Push-ups'), findsOneWidget);
    expect(store.counters.counters.last.color, counterColors[1].toARGB32());
  });

  testWidgets('settings open About', (tester) async {
    await start(tester);
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    await tapSetting(tester, 'About Countersink');
    await tester.pumpAndSettle();
    expect(find.text('Your counts stay with you.'), findsOneWidget);
    expect(find.text('No ads, ever'), findsOneWidget);
  });

  testWidgets(
    'settings hand the website and the feedback form to the browser',
    (tester) async {
      const app = MethodChannel('countersink/app');
      final opened = <Object?>[];
      var browser = true;
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(app, (call) async {
        if (call.method != 'openLink') return null;
        opened.add(call.arguments);
        return browser;
      });
      addTearDown(() => messenger.setMockMethodCallHandler(app, null));

      await start(tester);
      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();
      await tapSetting(tester, 'Website');
      await tester.pumpAndSettle();
      await tapSetting(tester, 'Send feedback');
      await tester.pumpAndSettle();
      expect(opened, [websiteUrl, feedbackUrl]);
      expect(find.byType(SnackBar), findsNothing);

      // With no browser on the phone, it says where to go instead.
      browser = false;
      await tapSetting(tester, 'Website');
      await tester.pumpAndSettle();
      expect(find.textContaining(websiteLabel), findsNWidgets(2));
    },
  );

  /// Opens a counter's menu, as a long press on its card does.
  Future<void> hold(WidgetTester tester, String name) async {
    await tester.longPress(find.text(name));
    await tester.pumpAndSettle();
  }

  testWidgets('edit a counter: its name, colour and history', (tester) async {
    await start(tester);
    await tester.tap(find.bySemanticsLabel('Add 1 to Pull-ups'));
    await tester.pumpAndSettle();

    await hold(tester, 'Pull-ups');
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    expect(find.text('Edit counter'), findsOneWidget);
    expect(
      find.widgetWithText(TextField, 'Strict'),
      findsOneWidget,
      reason: 'starts from what the counter has',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Pull-ups'),
      'Chin-ups',
    );
    await tester.tap(find.byTooltip('Teal'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final counter = store.counters.counters.single;
    expect(counter.name, 'Chin-ups');
    expect(counter.color, counterColors[1].toARGB32());
    expect(counter.daily, isTrue);
    expect(find.text('1'), findsOneWidget, reason: 'the count is kept');
  });

  testWidgets('clearing the description removes it', (tester) async {
    await start(tester);
    await hold(tester, 'Pull-ups');
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Strict'), '');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(store.counters.counters.single.description, isNull);
    expect(find.text('today'), findsOneWidget);
  });

  testWidgets('delete a counter, then undo brings it and its count back', (
    tester,
  ) async {
    await start(tester);
    for (var i = 0; i < 5; i++) {
      await tester.tap(find.bySemanticsLabel('Add 1 to Pull-ups'));
      await tester.pumpAndSettle();
    }

    await hold(tester, 'Pull-ups');
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('Pull-ups'), findsNothing);
    expect(find.text('Deleted Pull-ups'), findsOneWidget);
    expect(repo.log, isEmpty, reason: 'its history goes with it');

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(find.text('Pull-ups'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(repo.log, hasLength(5));
  });

  testWidgets('a counter added after a deletion goes last', (tester) async {
    final group = store.counters.groups.single;
    final b = await store.addCounter(groupId: group.id, name: 'B');
    await store.addCounter(groupId: group.id, name: 'C');
    await store.deleteCounter(b);
    await store.addCounter(groupId: group.id, name: 'A');
    expect(
      [for (final c in store.counters.counters) c.name],
      ['Pull-ups', 'C', 'A'],
    );
  });

  testWidgets('a step counts that many per press', (tester) async {
    final group = store.counters.groups.single;
    final laps = await store.addCounter(
      groupId: group.id,
      name: 'Laps',
      step: 5,
    );
    await start(tester);

    await tester.tap(find.bySemanticsLabel('Add 5 to Laps'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Add 5 to Laps'));
    await tester.pumpAndSettle();
    expect(store.counters.valueOf(laps), 10);
    await tester.tap(find.bySemanticsLabel('Take 5 from Laps'));
    await tester.pumpAndSettle();
    expect(store.counters.valueOf(laps), 5);
    expect([for (final e in repo.log) e.delta], [5, 5, -5]);
  });

  testWidgets('taking a step from less than a step stops at zero', (
    tester,
  ) async {
    final group = store.counters.groups.single;
    final laps = await store.addCounter(
      groupId: group.id,
      name: 'Laps',
      step: 5,
    );
    await store.setValue(laps, 3);
    await start(tester);
    await tester.tap(find.bySemanticsLabel('Take 5 from Laps'));
    await tester.pumpAndSettle();
    expect(store.counters.valueOf(laps), 0);
    expect(repo.log.last.delta, -3);
  });

  testWidgets('press and hold plus to add a whole set as one event', (
    tester,
  ) async {
    await start(tester);
    await tester.longPress(find.bySemanticsLabel('Add 1 to Pull-ups'));
    await tester.pumpAndSettle();
    expect(find.text('Add to Pull-ups'), findsOneWidget);
    expect(find.text('Edit'), findsNothing, reason: "not the card's menu");
    await tester.enterText(find.byType(TextField), '8');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    expect(find.text('8'), findsOneWidget);
    expect([for (final e in repo.log) e.delta], [8]);
  });

  testWidgets('press and hold minus to take an amount away', (tester) async {
    await store.addAmount(store.counters.counters.single, 10);
    await start(tester);
    await tester.longPress(find.bySemanticsLabel('Take 1 from Pull-ups'));
    await tester.pumpAndSettle();
    expect(find.text('Take from Pull-ups'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '4');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Take away'));
    await tester.pumpAndSettle();
    expect(find.text('6'), findsOneWidget);
  });

  testWidgets('an amount of nothing cannot be added', (tester) async {
    await start(tester);
    await tester.longPress(find.bySemanticsLabel('Add 1 to Pull-ups'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '0');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    expect(
      find.text('Add to Pull-ups'),
      findsOneWidget,
      reason: 'still asking',
    );
    expect(repo.log, isEmpty);
  });

  testWidgets('set the value from the menu, as one event of the difference', (
    tester,
  ) async {
    await store.addAmount(store.counters.counters.single, 12);
    await start(tester);
    await hold(tester, 'Pull-ups');
    await tester.tap(find.text('Set value'));
    await tester.pumpAndSettle();
    expect(
      find.widgetWithText(TextField, '12'),
      findsOneWidget,
      reason: 'starts from the current value',
    );
    await tester.enterText(find.byType(TextField), '20');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Set'));
    await tester.pumpAndSettle();
    expect(find.text('20'), findsOneWidget);
    expect((repo.log.last.delta, repo.log.last.kind), (8, EventKind.set));
  });

  testWidgets(
    'reset to zero keeps the history, and undo takes the reset back',
    (tester) async {
      await store.addAmount(store.counters.counters.single, 12);
      await start(tester);
      await hold(tester, 'Pull-ups');
      await tester.tap(find.text('Reset to zero'));
      await tester.pumpAndSettle();
      expect(find.text('0'), findsOneWidget);
      expect(find.text('Pull-ups reset to zero'), findsOneWidget);
      expect(
        [for (final e in repo.log) (e.delta, e.kind)],
        [(12, EventKind.tap), (-12, EventKind.reset)],
      );

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(find.text('12'), findsOneWidget);
      expect(repo.log, hasLength(1));
    },
  );

  testWidgets('reset is off for a counter already at zero', (tester) async {
    await start(tester);
    await hold(tester, 'Pull-ups');
    await tester.tap(find.text('Reset to zero'));
    await tester.pumpAndSettle();
    expect(
      find.text('Reset to zero'),
      findsOneWidget,
      reason: 'menu still open',
    );
    expect(repo.log, isEmpty);
  });

  testWidgets('change a counter\'s step in the editor', (tester) async {
    await start(tester);
    await hold(tester, 'Pull-ups');
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    final step = find.widgetWithText(TextField, 'Step');
    await tester.enterText(step, '');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(
      find.text('Edit counter'),
      findsOneWidget,
      reason: 'no step, no save',
    );
    await tester.enterText(step, '5');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(store.counters.counters.single.step, 5);
    expect(find.bySemanticsLabel('Add 5 to Pull-ups'), findsOneWidget);
  });

  Future<void> openGroups(WidgetTester tester) async {
    await tester.tap(find.byTooltip('Groups'));
    await tester.pumpAndSettle();
  }

  testWidgets('add a group: it becomes the last tab', (tester) async {
    await start(tester);
    await openGroups(tester);
    expect(find.text('1 counter'), findsOneWidget);
    await tester.tap(find.text('Add group'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Empty group'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Game night');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    expect(find.text('No counters'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.widgetWithText(Tab, 'Game night'), findsOneWidget);
    expect(
      [for (final g in store.counters.groups) g.name],
      ['Fitness', 'Game night'],
    );
  });

  testWidgets('rename a group', (tester) async {
    await start(tester);
    await openGroups(tester);
    await tester.tap(find.text('Fitness'));
    await tester.pumpAndSettle();
    expect(find.text('Rename group'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Training');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(store.counters.groups.single.name, 'Training');
    expect(
      store.counters.counters.single.name,
      'Pull-ups',
      reason: 'its counters stay',
    );
  });

  testWidgets('the last group cannot be deleted', (tester) async {
    await start(tester);
    await openGroups(tester);
    await tester.tap(find.byTooltip("The last group can't be deleted."));
    await tester.pumpAndSettle();
    expect(store.counters.groups, hasLength(1));
  });

  testWidgets('delete a group, then undo brings back its counters and counts', (
    tester,
  ) async {
    final games = await store.addGroup('Game night');
    final score = await store.addCounter(groupId: games.id, name: 'Score');
    await store.addCounter(groupId: games.id, name: 'Rounds');
    for (var i = 0; i < 3; i++) {
      await store.tap(score, 1);
    }
    await start(tester);
    await openGroups(tester);

    await tester.tap(find.byTooltip('Delete Game night'));
    await tester.pumpAndSettle();
    expect(find.text('Deleted Game night and its 2 counters'), findsOneWidget);
    expect([for (final g in store.counters.groups) g.name], ['Fitness']);
    expect(store.counters.counters.single.name, 'Pull-ups');
    expect(repo.log, isEmpty);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(
      [for (final g in store.counters.groups) g.name],
      ['Fitness', 'Game night'],
    );
    expect(store.counters.totals[score.id], 3);
    expect(store.counters.inGroup(games.id), hasLength(2));
  });

  testWidgets('moving a group changes the order of the tabs', (tester) async {
    await store.addGroup('Game night');
    await store.addGroup('Workshop');
    await start(tester);
    await store.moveGroup(2, 0);
    await tester.pumpAndSettle();
    final tabs = tester.widgetList<Tab>(find.byType(Tab)).map((t) => t.text);
    expect(tabs, ['Workshop', 'Fitness', 'Game night']);
    await store.moveGroup(0, 1);
    expect(
      [for (final g in store.counters.groups) g.name],
      ['Fitness', 'Workshop', 'Game night'],
    );
  });

  testWidgets('drag a group by its handle to reorder', (tester) async {
    await store.addGroup('Game night');
    await store.addGroup('Workshop');
    await start(tester);
    await openGroups(tester);

    final handles = find.byIcon(Icons.drag_handle);
    final rowHeight =
        tester.getCenter(handles.at(1)).dy - tester.getCenter(handles.at(0)).dy;
    final drag = await tester.startGesture(tester.getCenter(handles.first));
    await tester.pump(const Duration(milliseconds: 100));
    // Past the other two rows, in steps, as a finger moves.
    for (var i = 0; i < 10; i++) {
      await drag.moveBy(Offset(0, rowHeight * 2.4 / 10));
      await tester.pump(const Duration(milliseconds: 20));
    }
    await drag.up();
    await tester.pumpAndSettle();

    expect(
      [for (final g in store.counters.groups) g.name],
      ['Game night', 'Workshop', 'Fitness'],
    );
  });

  testWidgets('a group added after a deletion goes last', (tester) async {
    final b = await store.addGroup('B');
    await store.addGroup('C');
    await store.deleteGroup(b);
    await store.addGroup('A');
    expect(
      [for (final g in store.counters.groups) g.name],
      ['Fitness', 'C', 'A'],
    );
  });

  testWidgets('history lists each day with its total, newest first', (
    tester,
  ) async {
    final pullUps = store.counters.counters.single;
    await repo.record(pullUps.id, 8, at: DateTime(2026, 11, 20, 9));
    await repo.record(pullUps.id, 6, at: DateTime(2026, 11, 20, 18));
    await repo.record(pullUps.id, 10, at: DateTime(2026, 11, 21, 10));
    await repo.record(pullUps.id, 7, at: DateTime(2026, 11, 22, 9));
    await store.load();
    await start(tester);

    await hold(tester, 'Pull-ups');
    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();

    await showDayList(tester);
    final rows = tester.widgetList<ListTile>(find.byType(ListTile)).toList();
    expect(
      [for (final r in rows) (r.title as Text).data],
      ['Today', 'Yesterday', 'Fri, Nov 20, 2026'],
    );
    expect(
      [
        for (final r in rows)
          tester
              .widget<Text>(
                find.descendant(
                  of: find.byWidget(r.trailing!),
                  matching: find.byType(Text),
                ),
              )
              .data,
      ],
      ['7', '10', '14'],
    );
    expect(
      [for (final r in rows) (r.subtitle as Text).data],
      ['1 entry', '1 entry', '2 entries'],
    );
    expect(find.text('31'), findsOneWidget, reason: 'all time');
  });

  testWidgets('history of an untouched counter says so', (tester) async {
    await start(tester);
    await hold(tester, 'Pull-ups');
    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();
    expect(find.text('Nothing counted yet.'), findsOneWidget);
  });

  testWidgets(
    'choose when the day starts; it is remembered and changes today',
    (tester) async {
      final pullUps = store.counters.counters.single;
      await repo.record(pullUps.id, 9, at: DateTime(2026, 11, 22, 21));
      await repo.record(pullUps.id, 5, at: DateTime(2026, 11, 23, 0, 30));
      now = DateTime(2026, 11, 23, 1);
      await store.load();
      await start(tester);
      expect(find.text('5'), findsOneWidget, reason: 'a new day at midnight');

      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();
      expect(find.text('Midnight'), findsOneWidget);
      await tapSetting(tester, 'Day starts at');
      await tester.pumpAndSettle();
      await tester.tap(find.text('4:00 AM'));
      await tester.pumpAndSettle();
      expect(find.text('4:00 AM'), findsOneWidget, reason: 'shown in Settings');
      expect(store.dayStartHour, 4);
      expect(
        (await SharedPreferences.getInstance()).getInt('day_start_hour'),
        4,
      );

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(
        find.text('14'),
        findsOneWidget,
        reason: 'one in the morning still belongs to the evening before',
      );
    },
  );

  group('backup and restore', () {
    const documents = MethodChannel('countersink/documents');
    String? savedName;
    String? savedText;
    String? fileToOpen;

    setUp(() {
      savedName = savedText = fileToOpen = null;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(documents, (call) async {
            if (call.method == 'save') {
              final args = call.arguments as Map;
              savedName = args['name'] as String;
              savedText = utf8.decode(args['bytes'] as Uint8List);
              return true;
            }
            final file = fileToOpen;
            return file == null ? null : Uint8List.fromList(utf8.encode(file));
          });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(documents, null);
    });

    Future<void> openSettings(WidgetTester tester) async {
      await start(tester);
      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();
    }

    final other = encodeBackup(
      BackupData(
        dayStartHour: 3,
        groups: const [CounterGroup(id: 'g', name: 'Game night')],
        counters: const [
          Counter(id: 'a', groupId: 'g', name: 'Score', color: 0xFF14344B),
          Counter(id: 'b', groupId: 'g', name: 'Rounds', color: 0xFF196741),
        ],
        events: [
          for (var i = 0; i < 3; i++)
            TapEvent(
              id: 'e$i',
              counterId: 'a',
              at: DateTime.utc(2026, 11, 20, 20, i),
              delta: 10,
            ),
        ],
      ),
      exportedAt: DateTime.utc(2026, 11, 21),
    );

    testWidgets('back up saves everything to a file named for the day', (
      tester,
    ) async {
      await store.addAmount(store.counters.counters.single, 12);
      await openSettings(tester);
      await tapSetting(tester, 'Back up to a file');
      await tester.pumpAndSettle();

      expect(find.text('Backup saved'), findsOneWidget);
      expect(savedName, 'countersink-backup-2026-11-22.json');
      final back = decodeBackup(savedText!);
      expect(back.groups.single.name, 'Fitness');
      expect(back.counters.single.name, 'Pull-ups');
      expect(back.events.single.delta, 12);
      expect(back.dayStartHour, 0);
    });

    testWidgets('export a spreadsheet with a row for every entry', (
      tester,
    ) async {
      final pullUps = store.counters.counters.single;
      await store.addAmount(pullUps, 8);
      await store.addAmount(pullUps, 6);
      await openSettings(tester);
      await tapSetting(tester, 'Export as a spreadsheet');
      await tester.pumpAndSettle();

      expect(find.text('Spreadsheet saved'), findsOneWidget);
      expect(savedName, 'countersink-entries-2026-11-22.csv');
      final rows = savedText!.trim().split('\r\n');
      expect(rows.first, 'group,counter,time,day,change,kind');
      expect(rows, hasLength(3));
      expect(rows[1], startsWith('Fitness,Pull-ups,2026-11-22T12:00:00'));
      expect(rows[1], endsWith(',2026-11-22,8,tap'));
    });

    testWidgets('restore says what the file holds, then replaces everything', (
      tester,
    ) async {
      await store.addAmount(store.counters.counters.single, 12);
      fileToOpen = other;
      await openSettings(tester);
      await tapSetting(tester, 'Restore from a backup');
      await tester.pumpAndSettle();
      expect(
        find.text(
          'It has 1 group, 2 counters and 3 entries. Everything now on this '
          'phone will be replaced by it.',
        ),
        findsOneWidget,
      );
      await tester.tap(find.text('Replace'));
      await tester.pumpAndSettle();

      expect(find.text('Restored'), findsOneWidget);
      expect(store.counters.groups.single.name, 'Game night');
      expect(
        [for (final c in store.counters.counters) c.name],
        ['Score', 'Rounds'],
      );
      expect(store.counters.totals, {'a': 30});
      expect(store.dayStartHour, 3);
      // Back to the top of Settings, where the day-start row is.
      await tester.drag(find.byType(ListView), const Offset(0, 800));
      await tester.pumpAndSettle();
      expect(find.text('3:00 AM'), findsOneWidget, reason: 'the setting too');
      expect(
        (await SharedPreferences.getInstance()).getInt('day_start_hour'),
        3,
      );
    });

    testWidgets('backing out of the question changes nothing', (tester) async {
      fileToOpen = other;
      await openSettings(tester);
      await tapSetting(tester, 'Restore from a backup');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(store.counters.groups.single.name, 'Fitness');
    });

    testWidgets('a file that is not a backup is refused, and nothing changes', (
      tester,
    ) async {
      fileToOpen = '{"patients": []}';
      await openSettings(tester);
      await tapSetting(tester, 'Restore from a backup');
      await tester.pumpAndSettle();
      expect(find.text("Can't restore this file"), findsOneWidget);
      expect(find.text("This isn't a Countersink backup."), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(store.counters.groups.single.name, 'Fitness');
    });

    testWidgets('a damaged backup says where it went wrong', (tester) async {
      fileToOpen = other.replaceFirst('"#14344B"', '"navy"');
      await openSettings(tester);
      await tapSetting(tester, 'Restore from a backup');
      await tester.pumpAndSettle();
      expect(
        find.textContaining('"Score": "color" is not a colour'),
        findsOneWidget,
      );
      expect(store.counters.groups.single.name, 'Fitness');
    });

    testWidgets('backing out of the file picker does nothing', (tester) async {
      await openSettings(tester);
      await tapSetting(tester, 'Restore from a backup');
      await tester.pumpAndSettle();
      expect(find.text('Replace'), findsNothing);
      expect(find.text("Can't restore this file"), findsNothing);
    });
  });

  testWidgets('keep the screen on: asked of Android, and remembered', (
    tester,
  ) async {
    const app = MethodChannel('countersink/app');
    final asked = <Object?>[];
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(app, (call) async {
      if (call.method == 'keepScreenOn') asked.add(call.arguments);
      return null;
    });
    addTearDown(() => messenger.setMockMethodCallHandler(app, null));

    await start(tester);
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    await tapSetting(tester, 'Keep the screen on');
    await tester.pumpAndSettle();
    expect(asked, [true]);
    expect(
      (await SharedPreferences.getInstance()).getBool('keep_screen_on'),
      isTrue,
    );
    expect(
      tester
          .widget<SwitchListTile>(
            find.widgetWithText(SwitchListTile, 'Keep the screen on'),
          )
          .value,
      isTrue,
    );

    await tapSetting(tester, 'Keep the screen on');
    await tester.pumpAndSettle();
    expect(asked, [true, false]);
  });

  group('theme', () {
    Future<void> openSettings(WidgetTester tester) async {
      await start(tester);
      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();
    }

    Color background(WidgetTester tester) =>
        Theme.of(tester.element(find.text('Settings'))).scaffoldBackgroundColor;

    testWidgets('follows the phone until told otherwise', (tester) async {
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      await openSettings(tester);
      expect(find.text('Same as the phone'), findsOneWidget);
      expect(background(tester), CountersinkPalette.clayDark.background);
    });

    testWidgets('choose light on a dark phone; it is remembered', (
      tester,
    ) async {
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      await openSettings(tester);
      await tapSetting(tester, 'Theme');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Light'));
      await tester.pumpAndSettle();
      expect(background(tester), CountersinkPalette.clay.background);
      expect(find.text('Light'), findsOneWidget);
      expect(
        (await SharedPreferences.getInstance()).getString('theme_mode'),
        'light',
      );
    });

    testWidgets('the dark theme sits on true black, with no switch for it', (
      tester,
    ) async {
      await openSettings(tester);
      await tapSetting(tester, 'Theme');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();
      expect(background(tester), const Color(0xFF000000));
      expect(find.text('Black background'), findsNothing);
      expect(
        (await SharedPreferences.getInstance()).getString('theme_mode'),
        'dark',
      );
    });
  });

  group('streaks and the calendar', () {
    late Counter pullUps;

    Future<void> openHistory(WidgetTester tester) async {
      await store.load();
      await start(tester);
      await hold(tester, 'Pull-ups');
      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();
    }

    setUp(() async {
      pullUps = store.counters.counters.single;
      // Today is the 22nd: the 19th to the 22nd in a row, and three days
      // earlier in the month, with a gap between.
      for (final (day, total) in [
        (22, 7),
        (21, 10),
        (20, 14),
        (19, 3),
        (12, 5),
        (11, 5),
        (10, 5),
      ]) {
        await repo.record(pullUps.id, total, at: DateTime(2026, 11, day, 9));
      }
      await repo.record(pullUps.id, 9, at: DateTime(2026, 10, 31, 9));
    });

    testWidgets('history gives the total, the streak and the best streak', (
      tester,
    ) async {
      await openHistory(tester);
      expect(find.bySemanticsLabel('All time: 58'), findsOneWidget);
      expect(find.bySemanticsLabel('Day streak: 4'), findsOneWidget);
      expect(find.bySemanticsLabel('Best streak: 4'), findsOneWidget);
    });

    testWidgets('with a daily goal, only days that met it are in the streak', (
      tester,
    ) async {
      await store.updateCounter(
        Counter(
          id: pullUps.id,
          groupId: pullUps.groupId,
          name: pullUps.name,
          color: pullUps.color,
          goal: 10,
          daily: true,
        ),
      );
      await openHistory(tester);
      // Today's 7 hasn't met it yet, so the run is yesterday and the day before.
      expect(find.bySemanticsLabel('Day streak: 2'), findsOneWidget);
      expect(find.bySemanticsLabel('Best streak: 2'), findsOneWidget);
    });

    testWidgets('the calendar shows the month with each day\'s total', (
      tester,
    ) async {
      await openHistory(tester);
      expect(find.text('November 2026'), findsOneWidget);
      expect(find.bySemanticsLabel('Nov 20: 14'), findsOneWidget);
      expect(find.bySemanticsLabel('Nov 12: 5'), findsOneWidget);
      expect(
        find.bySemanticsLabel('Nov 13'),
        findsOneWidget,
        reason: 'a day with nothing',
      );
      expect(find.bySemanticsLabel(RegExp(r'^Nov \d+')), findsNWidgets(30));
    });

    testWidgets('step back a month and forward again, never past this one', (
      tester,
    ) async {
      await openHistory(tester);
      expect(
        tester
            .widget<IconButton>(
              find.widgetWithIcon(IconButton, Icons.chevron_right),
            )
            .onPressed,
        isNull,
        reason: 'already on the current month',
      );
      await tester.tap(find.byTooltip('Previous month'));
      await tester.pumpAndSettle();
      expect(find.text('October 2026'), findsOneWidget);
      expect(find.bySemanticsLabel('Oct 31: 9'), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp(r'^Oct \d+')), findsNWidgets(31));

      await tester.tap(find.byTooltip('Next month'));
      await tester.pumpAndSettle();
      expect(find.text('November 2026'), findsOneWidget);
    });

    testWidgets('the first of the month sits under its weekday', (
      tester,
    ) async {
      // 1 November 2026 is a Sunday, the first column when weeks start then.
      await store.setWeekStart(DateTime.sunday);
      await openHistory(tester);
      final first = tester.getTopLeft(find.bySemanticsLabel('Nov 1'));
      final eighth = tester.getTopLeft(find.bySemanticsLabel('Nov 8'));
      final second = tester.getTopLeft(find.bySemanticsLabel('Nov 2'));
      expect(first.dx, eighth.dx, reason: 'a week apart, same column');
      expect(second.dx, greaterThan(first.dx));
      expect(second.dy, first.dy);
    });

    testWidgets('the calendar starts its weeks on the day chosen', (
      tester,
    ) async {
      // From Monday, that Sunday the 1st is the last column of the first
      // row and Monday the 2nd opens the next.
      await openHistory(tester);
      final first = tester.getTopLeft(find.bySemanticsLabel('Nov 1'));
      final second = tester.getTopLeft(find.bySemanticsLabel('Nov 2'));
      final ninth = tester.getTopLeft(find.bySemanticsLabel('Nov 9'));
      expect(second.dx, lessThan(first.dx));
      expect(second.dy, greaterThan(first.dy));
      expect(second.dx, ninth.dx);
    });
  });

  group('full screen', () {
    Future<void> openFull(WidgetTester tester) async {
      await start(tester);
      await hold(tester, 'Pull-ups');
      await tester.tap(find.text('Full screen'));
      await tester.pumpAndSettle();
    }

    testWidgets('a tap anywhere counts', (tester) async {
      await openFull(tester);
      expect(find.text('Tap anywhere to count'), findsOneWidget);
      // Three taps in three different places, none of them on a button.
      for (final at in const [
        Offset(200, 300),
        Offset(60, 420),
        Offset(330, 560),
      ]) {
        await tester.tapAt(at);
        await tester.pumpAndSettle();
      }
      expect(find.text('3'), findsOneWidget);
      expect([for (final e in repo.log) e.delta], [1, 1, 1]);
    });

    testWidgets('minus is its own button, and stops at zero', (tester) async {
      await store.addAmount(store.counters.counters.single, 2);
      await openFull(tester);
      final minus = find.bySemanticsLabel('Take 1 from Pull-ups');
      await tester.tap(minus);
      await tester.pumpAndSettle();
      await tester.tap(minus);
      await tester.pumpAndSettle();
      expect(find.text('0'), findsOneWidget);
      await tester.tap(minus, warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(store.counters.valueOf(store.counters.counters.single), 0);
      expect(repo.log, hasLength(3), reason: 'the third press did nothing');
    });

    testWidgets('press and hold anywhere to add an amount', (tester) async {
      await openFull(tester);
      await tester.longPressAt(const Offset(200, 300));
      await tester.pumpAndSettle();
      expect(find.text('Add to Pull-ups'), findsOneWidget);
      await tester.enterText(find.byType(TextField), '8');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();
      expect(find.text('8'), findsOneWidget);
    });

    testWidgets('the goal shows and is marked when reached', (tester) async {
      final c = store.counters.counters.single;
      await store.updateCounter(
        Counter(
          id: c.id,
          groupId: c.groupId,
          name: c.name,
          color: c.color,
          goal: 2,
          daily: true,
        ),
      );
      await openFull(tester);
      expect(find.text('of 2 · today'), findsOneWidget);
      await tester.tapAt(const Offset(200, 300));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.check_circle), findsNothing);
      await tester.tapAt(const Offset(200, 300));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('close goes back to the list, with the count kept', (
      tester,
    ) async {
      await openFull(tester);
      await tester.tapAt(const Offset(200, 300));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Close full screen'));
      await tester.pumpAndSettle();
      expect(find.text('Tap anywhere to count'), findsNothing);
      expect(find.text('1'), findsOneWidget);
      expect(repo.log, hasLength(1), reason: 'closing is not a count');
    });
  });

  group('automatic backup', () {
    const documents = MethodChannel('countersink/documents');
    final writes = <Map<Object?, Object?>>[];
    final released = <Object?>[];
    Map<String, String>? folderToPick;
    var writeFails = false;

    setUp(() {
      writes.clear();
      released.clear();
      folderToPick = {'uri': 'content://tree/backups', 'name': 'Backups'};
      writeFails = false;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(documents, (call) async {
            switch (call.method) {
              case 'pickFolder':
                return folderToPick;
              case 'writeToFolder':
                if (writeFails) throw PlatformException(code: 'io');
                writes.add(call.arguments as Map);
                return true;
              case 'releaseFolder':
                released.add((call.arguments as Map)['folder']);
                return null;
            }
            return null;
          });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(documents, null);
    });

    Future<void> openSettings(WidgetTester tester) async {
      await start(tester);
      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();
    }

    /// The app sent to the background, as when another app is opened.
    Future<void> leaveApp(WidgetTester tester) async {
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pumpAndSettle();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
    }

    Future<void> turnOn(WidgetTester tester) async {
      await openSettings(tester);
      await tapSetting(tester, 'Automatic backup');
      await tester.pumpAndSettle();
    }

    testWidgets('choosing a folder turns it on and backs up there at once', (
      tester,
    ) async {
      await store.addAmount(store.counters.counters.single, 12);
      await turnOn(tester);

      expect(find.text('Backed up to Backups'), findsOneWidget);
      expect(
        find.text(
          'To Backups, each time you leave the app. The last 7 days are kept.',
        ),
        findsOneWidget,
      );
      final write = writes.single;
      expect(write['folder'], 'content://tree/backups');
      expect(write['name'], 'countersink-auto-2026-11-22.json');
      expect(write['prefix'], 'countersink-auto-');
      expect(write['keep'], 7);
      final backup = decodeBackup(utf8.decode(write['bytes'] as Uint8List));
      expect(backup.counters.single.name, 'Pull-ups');
      expect(backup.events.single.delta, 12);
      expect((await Preferences.autoBackupFolder())?.name, 'Backups');
    });

    testWidgets(
      'leaving the app after a change writes a backup; after none, it does not',
      (tester) async {
        await turnOn(tester);
        writes.clear();

        await leaveApp(tester);
        expect(
          writes,
          isEmpty,
          reason: 'nothing has changed since the last one',
        );

        await store.addAmount(store.counters.counters.single, 5);
        await leaveApp(tester);
        expect(writes, hasLength(1));
        final backup = decodeBackup(
          utf8.decode(writes.single['bytes'] as Uint8List),
        );
        expect(backup.events.single.delta, 5);

        await leaveApp(tester);
        expect(
          writes,
          hasLength(1),
          reason: 'and not again until something changes',
        );
      },
    );

    testWidgets('with no folder chosen, leaving the app writes nothing', (
      tester,
    ) async {
      await start(tester);
      await store.addAmount(store.counters.counters.single, 5);
      await leaveApp(tester);
      expect(writes, isEmpty);
    });

    testWidgets(
      'a folder that cannot be written to is said so, until one works',
      (tester) async {
        await turnOn(tester);
        writeFails = true;
        await store.addAmount(store.counters.counters.single, 5);
        await leaveApp(tester);
        expect(await Preferences.autoBackupFailed(), isTrue);

        // Settings says so the next time it is opened.
        await tester.pageBack();
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Settings'));
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          find.text('Automatic backup'),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        expect(
          find.text(
            "The last backup couldn't be saved to Backups. Choose the folder again.",
          ),
          findsOneWidget,
        );

        writeFails = false;
        await tapSetting(tester, 'Automatic backup');
        await tester.pumpAndSettle();
        await tester.tap(find.text('Back up now'));
        await tester.pumpAndSettle();
        expect(await Preferences.autoBackupFailed(), isFalse);
        expect(find.text('Backed up to Backups'), findsOneWidget);
      },
    );

    testWidgets(
      'turn it off: the folder is given back and nothing more is written',
      (tester) async {
        await turnOn(tester);
        writes.clear();
        await tapSetting(tester, 'Automatic backup');
        await tester.pumpAndSettle();
        await tester.tap(find.text('Turn off'));
        await tester.pumpAndSettle();

        expect(released, ['content://tree/backups']);
        expect(await Preferences.autoBackupFolder(), isNull);
        expect(find.textContaining('Off. Choose a folder'), findsOneWidget);

        await store.addAmount(store.counters.counters.single, 5);
        await leaveApp(tester);
        expect(writes, isEmpty);
      },
    );

    testWidgets('choosing another folder gives the first one back', (
      tester,
    ) async {
      await turnOn(tester);
      folderToPick = {'uri': 'content://tree/sync', 'name': 'Sync'};
      await tapSetting(tester, 'Automatic backup');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Choose another folder'));
      await tester.pumpAndSettle();
      expect(released, ['content://tree/backups']);
      expect((await Preferences.autoBackupFolder())?.name, 'Sync');
      expect(writes.last['folder'], 'content://tree/sync');
    });

    testWidgets('backing out of the folder picker leaves it off', (
      tester,
    ) async {
      folderToPick = null;
      await turnOn(tester);
      expect(await Preferences.autoBackupFolder(), isNull);
      expect(writes, isEmpty);
    });

    test('a file a day, named for it', () {
      expect(
        AutoBackup.fileName(DateTime(2026, 3, 7, 23, 59)),
        'countersink-auto-2026-03-07.json',
      );
      expect(
        AutoBackup.fileName(DateTime(2026, 3, 7)),
        startsWith(AutoBackup.prefix),
      );
    });
  });

  group('archive', () {
    late Counter pullUps;

    setUp(() async {
      pullUps = store.counters.counters.single;
      await store.addCounter(groupId: pullUps.groupId, name: 'Push-ups');
      await store.addAmount(pullUps, 12);
    });

    Future<void> archivePullUps(WidgetTester tester) async {
      await start(tester);
      await hold(tester, 'Pull-ups');
      await tester.ensureVisible(find.text('Archive'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Archive'));
      await tester.pumpAndSettle();
    }

    Future<void> openArchived(WidgetTester tester) async {
      await tester.tap(find.byTooltip('Groups'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Archived counters'));
      await tester.pumpAndSettle();
    }

    testWidgets('archiving takes a counter off its tab and keeps its count', (
      tester,
    ) async {
      await archivePullUps(tester);
      expect(find.text('Archived Pull-ups'), findsOneWidget);
      expect(find.byType(CounterCard), findsOneWidget);
      expect(find.text('Pull-ups'), findsNothing);
      expect(store.counters.totals[pullUps.id], 12);
      expect(repo.log, hasLength(1));
    });

    testWidgets('undo puts it back where it was', (tester) async {
      await archivePullUps(tester);
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      final cards = tester
          .widgetList<CounterCard>(find.byType(CounterCard))
          .map((c) => c.counter.name);
      expect(cards, ['Pull-ups', 'Push-ups'], reason: 'first again, not last');
    });

    testWidgets('the archive lists it with its group and total', (
      tester,
    ) async {
      await archivePullUps(tester);
      await openArchived(tester);
      expect(find.widgetWithText(ListTile, 'Pull-ups'), findsOneWidget);
      expect(find.text('Fitness'), findsOneWidget);
      expect(find.text('12'), findsOneWidget);
    });

    testWidgets('move it back: it returns to its tab, last', (tester) async {
      await archivePullUps(tester);
      await openArchived(tester);
      await tester.tap(find.widgetWithText(ListTile, 'Pull-ups'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Move back to its group'));
      await tester.pumpAndSettle();
      expect(find.text('Nothing archived.'), findsOneWidget);
      expect(
        [for (final c in store.counters.inGroup(pullUps.groupId)) c.name],
        ['Push-ups', 'Pull-ups'],
      );
      expect(store.counters.totals[pullUps.id], 12);
    });

    testWidgets('delete it from the archive, and undo', (tester) async {
      await archivePullUps(tester);
      await openArchived(tester);
      await tester.tap(find.widgetWithText(ListTile, 'Pull-ups'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(store.counters.archived, isEmpty);
      expect(repo.log, isEmpty);
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(store.counters.archived.single.name, 'Pull-ups');
      expect(repo.log, hasLength(1));
    });

    testWidgets('an empty archive says so', (tester) async {
      await start(tester);
      await openArchived(tester);
      expect(find.text('Nothing archived.'), findsOneWidget);
    });

    test(
      'deleting a group takes its archived counters, and undo brings them back',
      () async {
        final games = await store.addGroup('Games');
        final score = await store.addCounter(groupId: games.id, name: 'Score');
        await store.addAmount(score, 3);
        await store.archiveCounter(score);
        expect(store.counters.inGroup(games.id), isEmpty);

        final deleted = await store.deleteGroup(games);
        expect(deleted.counters, hasLength(1));
        await store.restoreGroup(deleted);
        expect(store.counters.archived.single.name, 'Score');
        expect(store.counters.totals[score.id], 3);
      },
    );

    test(
      'a counter added while another is archived does not share its place',
      () async {
        await store.archiveCounter(
          store.counters.inGroup(pullUps.groupId).last,
        );
        final squats = await store.addCounter(
          groupId: pullUps.groupId,
          name: 'Squats',
        );
        final places = {
          for (final c in store.counters.allInGroup(pullUps.groupId))
            c.position,
        };
        expect(places, hasLength(3));
        expect(squats.position, 2);
      },
    );
  });

  group('search', () {
    setUp(() async {
      final fitness = store.counters.groups.single;
      await store.addCounter(groupId: fitness.id, name: 'Push-ups');
      final games = await store.addGroup('Game night');
      await store.addCounter(groupId: games.id, name: 'Score');
    });

    Future<void> search(WidgetTester tester, String query) async {
      await start(tester);
      await tester.tap(find.byTooltip('Search'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), query);
      await tester.pumpAndSettle();
    }

    List<String> cards(WidgetTester tester) => [
      for (final c in tester.widgetList<CounterCard>(find.byType(CounterCard)))
        c.counter.name,
    ];

    testWidgets('finds counters across groups as you type', (tester) async {
      await search(tester, 'ups');
      expect(cards(tester), ['Pull-ups', 'Push-ups']);
      expect(
        find.text('FITNESS'),
        findsOneWidget,
        reason: 'named once, above its counters',
      );

      await tester.enterText(find.byType(TextField), 'score');
      await tester.pumpAndSettle();
      expect(cards(tester), ['Score']);
      expect(find.text('GAME NIGHT'), findsOneWidget);
    });

    testWidgets('a found counter can be counted on right there', (
      tester,
    ) async {
      await search(tester, 'score');
      await tester.tap(find.bySemanticsLabel('Add 1 to Score'));
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Add 1 to Score'));
      await tester.pumpAndSettle();
      expect(find.text('2'), findsOneWidget);
      final score = store.counters.counters.firstWhere(
        (c) => c.name == 'Score',
      );
      expect(store.counters.totals[score.id], 2);
    });

    testWidgets('its menu works from the results too', (tester) async {
      await search(tester, 'score');
      await tester.longPress(find.text('Score'));
      await tester.pumpAndSettle();
      expect(find.text('Full screen'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
    });

    testWidgets('nothing typed, and nothing found, each say so', (
      tester,
    ) async {
      await search(tester, '');
      expect(
        find.text("Type a counter's name, its description or its group."),
        findsOneWidget,
      );
      await tester.enterText(find.byType(TextField), 'xyz');
      await tester.pumpAndSettle();
      expect(find.text('No counters match.'), findsOneWidget);
      expect(cards(tester), isEmpty);
    });

    testWidgets('an archived counter is not found', (tester) async {
      await store.archiveCounter(
        store.counters.counters.firstWhere((c) => c.name == 'Score'),
      );
      await search(tester, 'score');
      expect(find.text('No counters match.'), findsOneWidget);
    });
  });

  group('languages', () {
    Future<void> openSettings(WidgetTester tester) async {
      await start(tester);
      // By its icon: its name depends on the language.
      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();
    }

    testWidgets(
      'choose Spanish in Settings: the app speaks it, and remembers',
      (tester) async {
        await openSettings(tester);
        await tapSetting(tester, 'Language');
        await tester.pumpAndSettle();
        expect(find.text('Same as the phone'), findsWidgets);
        await tester.tap(find.text('Español'));
        await tester.pumpAndSettle();

        expect(find.text('Ajustes'), findsOneWidget);
        expect(
          find.text('Español'),
          findsOneWidget,
          reason: 'named on its row',
        );
        expect(await Preferences.language(), 'es');

        await tester.tap(find.byType(BackButton));
        await tester.pumpAndSettle();
        expect(find.text('Añadir contador'), findsOneWidget);
        expect(find.bySemanticsLabel('Sumar 1 a Pull-ups'), findsOneWidget);
      },
    );

    testWidgets('back to the phone\'s language', (tester) async {
      chosenLanguage.value = 'fr';
      await openSettings(tester);
      expect(find.text('Paramètres'), findsOneWidget);
      await tapSetting(tester, 'Langue');
      await tester.pumpAndSettle();
      // The Theme row behind the dialog says the same words.
      await tester.tap(
        find.descendant(
          of: find.byType(SimpleDialog),
          matching: find.text('Comme le téléphone'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsOneWidget);
      // English rows are shorter than French ones, so the row has moved up
      // out of view; bring it back.
      await tester.drag(find.byType(ListView), const Offset(0, 400));
      await tester.pumpAndSettle();
      expect(find.text('Same as the phone: English'), findsOneWidget);
      expect(await Preferences.language(), isNull);
    });

    testWidgets('a phone in a language the app speaks gets it unasked', (
      tester,
    ) async {
      tester.platformDispatcher.localesTestValue = const [Locale('de', 'AT')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);
      await start(tester);
      expect(find.text('Zähler hinzufügen'), findsOneWidget);
    });

    testWidgets('a phone in a language it does not speak gets English', (
      tester,
    ) async {
      tester.platformDispatcher.localesTestValue = const [Locale('ja', 'JP')];
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);
      await start(tester);
      expect(find.text('Add counter'), findsOneWidget);
    });

    testWidgets('dates follow the language', (tester) async {
      chosenLanguage.value = 'de';
      final pullUps = store.counters.counters.single;
      await repo.record(pullUps.id, 5, at: DateTime(2026, 11, 22, 9));
      await store.load();
      await start(tester);
      await hold(tester, 'Pull-ups');
      await tester.tap(find.text('Verlauf'));
      await tester.pumpAndSettle();
      expect(find.text('November 2026'), findsOneWidget);
      expect(find.bySemanticsLabel('Insgesamt: 5'), findsOneWidget);
      expect(find.bySemanticsLabel('22. Nov.: 5'), findsOneWidget);
    });
  });

  group('volume buttons', () {
    const app = MethodChannel('countersink/app');
    final modes = <Object?>[];

    setUp(() {
      modes.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(app, (call) async {
            if (call.method == 'volumeKeys') modes.add(call.arguments);
            return null;
          });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(app, null);
    });

    Future<void> openFull(WidgetTester tester, VolumeKeys keys) async {
      await Preferences.setVolumeKeys(keys);
      await start(tester);
      await hold(tester, 'Pull-ups');
      await tester.tap(find.text('Full screen'));
      await tester.pumpAndSettle();
    }

    /// A press of a volume button, as Android hands it to the app.
    Future<void> press(WidgetTester tester, int direction) async {
      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'countersink/app',
        const StandardMethodCodec().encodeMethodCall(
          MethodCall('volumeKey', direction),
        ),
        (_) {},
      );
      await tester.pumpAndSettle();
    }

    int value() => store.counters.valueOf(store.counters.counters.single);

    testWidgets('up adds and down takes away, in full screen', (tester) async {
      await openFull(tester, VolumeKeys.both);
      expect(modes, [2], reason: 'Android is asked for both buttons');
      await press(tester, 1);
      await press(tester, 1);
      await press(tester, -1);
      expect(value(), 1);
      expect([for (final e in repo.log) e.delta], [1, 1, -1]);

      await tester.tap(find.byTooltip('Close full screen'));
      await tester.pumpAndSettle();
      expect(modes, [2, 0], reason: 'the buttons go back to the volume');
    });

    testWidgets('up only asks Android for just that button', (tester) async {
      await openFull(tester, VolumeKeys.up);
      expect(modes, [1]);
      await press(tester, 1);
      expect(value(), 1);
    });

    testWidgets('volume down at zero does nothing', (tester) async {
      await openFull(tester, VolumeKeys.both);
      await press(tester, -1);
      expect(value(), 0);
      expect(repo.log, isEmpty);
    });

    testWidgets('locked, touches do nothing and the buttons still count', (
      tester,
    ) async {
      await openFull(tester, VolumeKeys.both);
      await tester.tap(find.byTooltip('Lock touch'));
      await tester.pumpAndSettle();
      expect(
        find.text('Touch is locked. Count with the volume buttons.'),
        findsOneWidget,
      );

      await tester.tapAt(const Offset(200, 300));
      await tester.longPressAt(const Offset(200, 300));
      await tester.pumpAndSettle();
      expect(value(), 0, reason: 'touch is locked');
      expect(find.text('Add to Pull-ups'), findsNothing);

      await press(tester, 1);
      expect(value(), 1);

      // A tap on the lock doesn't open it; a press and hold does.
      await tester.tap(find.byTooltip('Press and hold to unlock'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Press and hold to unlock'), findsOneWidget);
      await tester.longPress(find.byTooltip('Press and hold to unlock'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Lock touch'), findsOneWidget);
      await tester.tapAt(const Offset(200, 300));
      await tester.pumpAndSettle();
      expect(value(), 2);
    });

    testWidgets('locked, the way out is off too', (tester) async {
      await openFull(tester, VolumeKeys.both);
      await tester.tap(find.byTooltip('Lock touch'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.byTooltip('Close full screen'),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();
      expect(
        find.byTooltip('Press and hold to unlock'),
        findsOneWidget,
        reason: 'still in full screen',
      );
      expect(value(), 0, reason: 'and the tap did not count');
    });

    testWidgets(
      'with the setting off, nothing is asked of Android and there is no lock',
      (tester) async {
        await openFull(tester, VolumeKeys.off);
        expect(find.byTooltip('Lock touch'), findsNothing);
        expect(find.text('Tap anywhere to count'), findsOneWidget);
        expect(modes.where((m) => m != 0), isEmpty);
      },
    );

    testWidgets('chosen in Settings, and remembered', (tester) async {
      await start(tester);
      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();
      await tapSetting(tester, 'Volume buttons');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Up adds, down takes away'));
      await tester.pumpAndSettle();
      expect(find.text('Up adds, down takes away'), findsOneWidget);
      expect(await Preferences.volumeKeys(), VolumeKeys.both);
    });
  });

  group('a day\'s entries', () {
    late Counter pullUps;

    setUp(() async {
      pullUps = store.counters.counters.single;
      await repo.record(pullUps.id, 8, at: DateTime(2026, 11, 21, 9, 5));
      await repo.record(pullUps.id, 6, at: DateTime(2026, 11, 21, 18, 30));
      await repo.record(pullUps.id, 7, at: DateTime(2026, 11, 22, 8));
    });

    /// History, scrolled to the day list, then into [day].
    Future<void> openDay(WidgetTester tester, String day) async {
      await store.load();
      await start(tester);
      await hold(tester, 'Pull-ups');
      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();
      await showDayList(tester);
      await tester.ensureVisible(find.widgetWithText(ListTile, day));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, day));
      await tester.pumpAndSettle();
    }

    int totalOn(int dayOfMonth) => repo.log
        .where((e) => e.at.toLocal().day == dayOfMonth)
        .fold(0, (sum, e) => sum + e.delta);

    testWidgets('a day lists its entries with their times', (tester) async {
      await openDay(tester, 'Yesterday');
      expect(find.text('9:05 AM'), findsOneWidget);
      expect(find.text('6:30 PM'), findsOneWidget);
      expect(find.text('+8'), findsOneWidget);
      expect(find.text('+6'), findsOneWidget);
      expect(find.text('14'), findsOneWidget, reason: "the day's total");
      expect(find.text('8:00 AM'), findsNothing, reason: "today's entry");
    });

    testWidgets('correct an entry\'s amount; its time stays', (tester) async {
      await openDay(tester, 'Yesterday');
      await tester.tap(find.text('+8'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      expect(find.text('Edit entry'), findsOneWidget);
      await tester.enterText(find.widgetWithText(TextField, 'Amount'), '10');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('+10'), findsOneWidget);
      expect(find.text('16'), findsOneWidget);
      expect(totalOn(21), 16);
      expect(
        repo.log.firstWhere((e) => e.delta == 10).at,
        DateTime(2026, 11, 21, 9, 5),
      );
    });

    testWidgets('delete an entry, and undo', (tester) async {
      await openDay(tester, 'Yesterday');
      await tester.tap(find.text('+6'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(find.text('Entry deleted'), findsOneWidget);
      expect(totalOn(21), 8);
      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(totalOn(21), 14);
      expect(find.text('+6'), findsOneWidget);
    });

    testWidgets('add an entry that was missed, to a day gone by', (
      tester,
    ) async {
      await openDay(tester, 'Yesterday');
      await tester.tap(find.text('Add entry'));
      await tester.pumpAndSettle();
      expect(
        find.text('12:00 PM'),
        findsOneWidget,
        reason: 'a past day starts at noon',
      );
      await tester.enterText(find.widgetWithText(TextField, 'Amount'), '5');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();
      expect(find.text('+5'), findsOneWidget);
      expect(totalOn(21), 19);
      expect(totalOn(22), 7, reason: 'today is untouched');
      expect(store.counters.valueOf(pullUps), 7);
    });

    testWidgets('take some away as its own entry', (tester) async {
      await openDay(tester, 'Yesterday');
      await tester.tap(find.text('Add entry'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Taken away'));
      await tester.enterText(find.widgetWithText(TextField, 'Amount'), '4');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();
      expect(find.text('−4'), findsOneWidget);
      expect(totalOn(21), 10);
    });

    testWidgets('a change that would go below zero is refused', (tester) async {
      await openDay(tester, 'Yesterday');
      await tester.tap(find.text('Add entry'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Taken away'));
      await tester.enterText(find.widgetWithText(TextField, 'Amount'), '15');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();
      expect(
        find.text('That would take the count below zero.'),
        findsOneWidget,
      );
      expect(totalOn(21), 14);
    });

    testWidgets('a day with nothing on it can be opened from the calendar', (
      tester,
    ) async {
      await store.load();
      await start(tester);
      await hold(tester, 'Pull-ups');
      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.bySemanticsLabel('Nov 10'));
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Nov 10'));
      await tester.pumpAndSettle();
      expect(find.text('Nothing counted on this day.'), findsOneWidget);
      await tester.tap(find.text('Add entry'));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, 'Amount'), '9');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();
      expect(totalOn(10), 9);
      expect(repo.log.last.at, DateTime(2026, 11, 10, 12));
    });

    testWidgets('a day still to come cannot be opened', (tester) async {
      await store.load();
      await start(tester);
      await hold(tester, 'Pull-ups');
      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.bySemanticsLabel('Nov 25'));
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Nov 25'));
      await tester.pumpAndSettle();
      expect(find.text('Add entry'), findsNothing);
      expect(find.text('November 2026'), findsOneWidget);
    });

    test(
      'an ordinary counter is held to its whole total, not each day',
      () async {
        final group = store.counters.groups.single;
        final stock = await store.addCounter(groupId: group.id, name: 'Stock');
        expect(
          await store.addEntry(stock, 10, DateTime(2026, 11, 20, 12)),
          isTrue,
        );
        // Ten came in on the 20th; taking four out on the 21st is fine,
        // though that day on its own is below zero.
        expect(
          await store.addEntry(stock, -4, DateTime(2026, 11, 21, 12)),
          isTrue,
        );
        expect(
          await store.addEntry(stock, -7, DateTime(2026, 11, 21, 13)),
          isFalse,
        );
        expect(store.counters.totals[stock.id], 6);
      },
    );
  });

  group('chart and averages', () {
    late Counter pullUps;

    Future<void> openHistory(WidgetTester tester) async {
      await store.load();
      await start(tester);
      await hold(tester, 'Pull-ups');
      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();
    }

    setUp(() async {
      pullUps = store.counters.counters.single;
      // Ten days ending today, the 22nd: 10 a day, but nothing on the 20th.
      for (var day = 13; day <= 22; day++) {
        if (day == 20) continue;
        await repo.record(pullUps.id, 10, at: DateTime(2026, 11, day, 9));
      }
    });

    testWidgets('thirty days by default, averaged from the first day counted', (
      tester,
    ) async {
      await openHistory(tester);
      // 90 over the ten days since it was first used, not over thirty.
      expect(find.bySemanticsLabel('Average per day: 9.0'), findsOneWidget);
      expect(find.bySemanticsLabel('Total: 90'), findsOneWidget);
    });

    testWidgets('seven days: the day with nothing counts as zero', (
      tester,
    ) async {
      await openHistory(tester);
      await tester.tap(find.text('7 days'));
      await tester.pumpAndSettle();
      // The 16th to the 22nd: six days of 10 and one of nothing.
      expect(find.bySemanticsLabel('Total: 60'), findsOneWidget);
      expect(find.bySemanticsLabel('Average per day: 8.6'), findsOneWidget);
    });

    testWidgets('ninety days is still averaged over the ten it has existed', (
      tester,
    ) async {
      await openHistory(tester);
      await tester.tap(find.text('90 days'));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Average per day: 9.0'), findsOneWidget);
    });

    testWidgets('a counter with nothing counted has no chart', (tester) async {
      repo.log.clear();
      await openHistory(tester);
      expect(find.text('Average per day'), findsNothing);
      expect(find.text('30 days'), findsNothing);
      expect(find.text('Nothing counted yet.'), findsOneWidget);
    });
  });

  group('goals', () {
    late Counter pullUps;

    setUp(() async {
      final c = store.counters.counters.single;
      pullUps = Counter(
        id: c.id,
        groupId: c.groupId,
        name: c.name,
        color: c.color,
        goal: 10,
        daily: true,
      );
      await store.updateCounter(pullUps);
    });

    double progress(WidgetTester tester) => tester
        .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
        .value!;

    testWidgets('a card with a goal shows how far along it is', (tester) async {
      await store.addAmount(pullUps, 4);
      await start(tester);
      expect(find.text('of 10 · today'), findsOneWidget);
      expect(progress(tester), closeTo(0.4, 0.001));
      expect(find.bySemanticsLabel('Goal reached'), findsNothing);
    });

    testWidgets('reaching the goal is marked, and going past it stays full', (
      tester,
    ) async {
      await store.addAmount(pullUps, 9);
      await start(tester);
      expect(store.reachesGoal(pullUps, 1), isTrue);
      await tester.tap(find.bySemanticsLabel('Add 1 to Pull-ups'));
      await tester.pumpAndSettle();
      expect(progress(tester), 1.0);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(
        store.reachesGoal(pullUps, 1),
        isFalse,
        reason: 'only the first time',
      );

      await tester.tap(find.bySemanticsLabel('Add 1 to Pull-ups'));
      await tester.pumpAndSettle();
      expect(find.text('11'), findsOneWidget);
      expect(progress(tester), 1.0);
    });

    testWidgets('a card without a goal has no bar', (tester) async {
      await store.updateCounter(
        Counter(
          id: pullUps.id,
          groupId: pullUps.groupId,
          name: pullUps.name,
          color: pullUps.color,
        ),
      );
      await start(tester);
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    testWidgets('set, change and clear the goal in the editor', (tester) async {
      await start(tester);
      await hold(tester, 'Pull-ups');
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      final goal = find.widgetWithText(TextField, 'Goal (optional)');
      expect(tester.widget<TextField>(goal).controller!.text, '10');

      await tester.enterText(goal, '0');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(
        find.text('Edit counter'),
        findsOneWidget,
        reason: 'a goal of nothing is no goal',
      );

      await tester.enterText(goal, '25');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(store.counters.counters.single.goal, 25);

      await hold(tester, 'Pull-ups');
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      await tester.enterText(goal, '');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(store.counters.counters.single.goal, isNull);
    });

    testWidgets('history marks the days that met the goal', (tester) async {
      await repo.record(pullUps.id, 12, at: DateTime(2026, 11, 20, 9));
      await repo.record(pullUps.id, 6, at: DateTime(2026, 11, 21, 9));
      await repo.record(pullUps.id, 10, at: DateTime(2026, 11, 22, 9));
      await store.load();
      await start(tester);
      await hold(tester, 'Pull-ups');
      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();
      await showDayList(tester);
      final rows = tester.widgetList<ListTile>(find.byType(ListTile)).toList();
      final met = [
        for (final r in rows)
          find
              .descendant(
                of: find.byWidget(r),
                matching: find.byIcon(Icons.check_circle),
              )
              .evaluate()
              .isNotEmpty,
      ];
      expect(met, [
        true,
        false,
        true,
      ], reason: 'today, yesterday, the day before');
    });

    test('a goal moves with its counter and survives reordering', () async {
      final games = await store.addGroup('Games');
      await store.moveCounterToGroup(store.counters.counters.single, games.id);
      expect(store.counters.counters.single.goal, 10);
      await store.moveCounter(games.id, 0, 0);
      expect(store.counters.counters.single.goal, 10);
    });
  });

  group('a goal for the week', () {
    late Counter pullUps;

    setUp(() async {
      final c = store.counters.counters.single;
      pullUps = Counter(
        id: c.id,
        groupId: c.groupId,
        name: c.name,
        color: c.color,
        goal: 100,
        goalPeriod: GoalPeriod.week,
        daily: true,
      );
      await store.updateCounter(pullUps);
      // Today is Sunday the 22nd, the end of a week that began on Monday
      // the 16th. Last week reached 100; this one stands at 45.
      await repo.record(pullUps.id, 100, at: DateTime(2026, 11, 11, 9));
      await repo.record(pullUps.id, 40, at: DateTime(2026, 11, 21, 9));
      await repo.record(pullUps.id, 5, at: DateTime(2026, 11, 22, 9));
      await store.load();
    });

    testWidgets('the card shows today, and the week against the goal', (
      tester,
    ) async {
      await start(tester);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('45 of 100 this week · today'), findsOneWidget);
      final bar = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(bar.value, closeTo(0.45, 0.001));
      expect(find.bySemanticsLabel('Goal reached'), findsNothing);
    });

    testWidgets('full screen shows the week too', (tester) async {
      await start(tester);
      await hold(tester, 'Pull-ups');
      await tester.tap(find.text('Full screen'));
      await tester.pumpAndSettle();
      expect(find.text('45 of 100 this week · today'), findsOneWidget);
    });

    testWidgets(
      'the count that brings the week to its goal is the one marked',
      (tester) async {
        expect(store.reachesGoal(pullUps, 54), isFalse);
        expect(store.reachesGoal(pullUps, 55), isTrue);
        await store.addAmount(pullUps, 55);
        await start(tester);
        expect(find.text('100 of 100 this week · today'), findsOneWidget);
        expect(find.byIcon(Icons.check_circle), findsOneWidget);
        expect(store.reachesGoal(pullUps, 1), isFalse, reason: 'only once');
      },
    );

    testWidgets('the week moves with the day it starts on', (tester) async {
      await store.setWeekStart(DateTime.sunday);
      await start(tester);
      // Today, a Sunday, now opens a new week.
      expect(find.text('5 of 100 this week · today'), findsOneWidget);
    });

    testWidgets('history counts weeks in a row, and marks their days', (
      tester,
    ) async {
      await store.addAmount(pullUps, 55);
      await start(tester);
      await hold(tester, 'Pull-ups');
      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Week streak: 2'), findsOneWidget);
      expect(find.bySemanticsLabel('Best streak: 2'), findsOneWidget);
      expect(find.bySemanticsLabel('Day streak: 1'), findsNothing);

      await showDayList(tester);
      // Three days counted, all in weeks that reached the goal.
      expect(find.byIcon(Icons.check_circle), findsNWidgets(3));
    });

    testWidgets('a week that fell short leaves its days unmarked', (
      tester,
    ) async {
      await start(tester);
      await hold(tester, 'Pull-ups');
      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();
      // This week is short so far, so the run is last week's alone.
      expect(find.bySemanticsLabel('Week streak: 1'), findsOneWidget);
      await showDayList(tester);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('choosing day or week in the editor', (tester) async {
      await start(tester);
      await hold(tester, 'Pull-ups');
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Day'));
      await tester.pumpAndSettle();
      expect(find.text('The goal is for each'), findsOneWidget);
      await tester.tap(find.text('Day'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(store.counters.counters.single.goalPeriod, GoalPeriod.day);
      expect(find.text('of 100 · today'), findsOneWidget);

      await hold(tester, 'Pull-ups');
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Week'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Week'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(store.counters.counters.single.goalPeriod, GoalPeriod.week);
    });

    testWidgets('the choice is only there for a per-day counter with a goal', (
      tester,
    ) async {
      await start(tester);
      await hold(tester, 'Pull-ups');
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      final goal = find.widgetWithText(TextField, 'Goal (optional)');
      await tester.enterText(goal, '');
      await tester.pumpAndSettle();
      expect(find.text('The goal is for each'), findsNothing);
      await tester.enterText(goal, '100');
      await tester.pumpAndSettle();
      expect(find.text('The goal is for each'), findsOneWidget);

      // Not counting per day any more: the goal is a total, and saving
      // leaves no week behind.
      await tester.ensureVisible(find.byType(Switch));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(find.text('The goal is for each'), findsNothing);
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      final saved = store.counters.counters.single;
      expect((saved.daily, saved.goalPeriod), (false, GoalPeriod.day));
    });

    testWidgets('Settings chooses the day a week starts on', (tester) async {
      await start(tester);
      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();
      expect(find.text('Monday'), findsOneWidget);
      await tapSetting(tester, 'Week starts on');
      await tester.pumpAndSettle();
      expect(find.text('Saturday'), findsOneWidget);
      await tester.tap(find.text('Sunday'));
      await tester.pumpAndSettle();
      expect(store.weekStart, DateTime.sunday);
      expect(await Preferences.weekStart(), DateTime.sunday);
      expect(find.text('Sunday'), findsOneWidget);
      expect(store.counters.week[pullUps.id], 5);
    });

    test('a backup carries the day a week starts on', () async {
      await store.setWeekStart(DateTime.saturday);
      final backup = await store.exportData();
      expect(backup.weekStart, DateTime.saturday);
      store.weekStart = DateTime.monday;
      await store.restore(backup);
      expect(store.weekStart, DateTime.saturday);
    });

    test('the phone decides the day until one is chosen', () async {
      expect(await Preferences.weekStart(), isNull);
      expect(phoneWeekStart(const [Locale('en', 'US')]), DateTime.sunday);
      expect(phoneWeekStart(const [Locale('en', 'GB')]), DateTime.monday);
      expect(phoneWeekStart(const [Locale('de', 'DE')]), DateTime.monday);
      expect(phoneWeekStart(const [Locale('ar', 'EG')]), DateTime.saturday);
      expect(
        phoneWeekStart(const [Locale('zz'), Locale('en', 'US')]),
        DateTime.sunday,
        reason: 'the first language that is known',
      );
      expect(phoneWeekStart(const [Locale('zz')]), DateTime.monday);
      expect(phoneWeekStart(const []), DateTime.monday);
    });
  });

  group('a buzz on every so many', () {
    late Counter pullUps;
    final felt = <Object?>[];

    setUp(() async {
      final c = store.counters.counters.single;
      pullUps = Counter(
        id: c.id,
        groupId: c.groupId,
        name: c.name,
        color: c.color,
        buzzEvery: 10,
        daily: true,
      );
      await store.updateCounter(pullUps);
      felt.clear();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, (call) async {
            if (call.method == 'HapticFeedback.vibrate') {
              felt.add(call.arguments);
            }
            return null;
          });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null);
    });

    test('passing a multiple is what counts, whatever the amount', () async {
      await store.addAmount(pullUps, 8);
      expect(store.passesMultiple(pullUps, 1), isFalse);
      expect(store.passesMultiple(pullUps, 2), isTrue, reason: 'lands on 10');
      expect(store.passesMultiple(pullUps, 5), isTrue, reason: 'goes past 10');
      expect(store.passesMultiple(pullUps, -8), isFalse, reason: 'going down');
      await store.addAmount(pullUps, 2);
      expect(store.passesMultiple(pullUps, 1), isFalse, reason: 'on 10 now');
      expect(store.passesMultiple(pullUps, 10), isTrue);
    });

    test('a counter with no buzz never passes one', () async {
      await store.updateCounter(
        Counter(
          id: pullUps.id,
          groupId: pullUps.groupId,
          name: pullUps.name,
          color: pullUps.color,
        ),
      );
      final plain = store.counters.counters.single;
      expect(store.passesMultiple(plain, 100), isFalse);
      expect(store.markOf(plain, 100), CountMark.none);
    });

    test('reaching the goal comes first when one count does both', () async {
      final both = Counter(
        id: pullUps.id,
        groupId: pullUps.groupId,
        name: pullUps.name,
        color: pullUps.color,
        goal: 20,
        buzzEvery: 10,
        daily: true,
      );
      await store.updateCounter(both);
      await store.addAmount(both, 9);
      expect(store.markOf(both, 1), CountMark.multiple);
      await store.addAmount(both, 10);
      expect(store.markOf(both, 1), CountMark.goal);
      await store.addAmount(both, 1);
      expect(store.markOf(both, 1), CountMark.none);
    });

    testWidgets('the tenth count is felt twice over, the ninth is not', (
      tester,
    ) async {
      await store.addAmount(pullUps, 8);
      await start(tester);
      await tester.tap(find.bySemanticsLabel('Add 1 to Pull-ups'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(felt, ['HapticFeedbackType.lightImpact'], reason: 'just a tick');

      felt.clear();
      await tester.tap(find.bySemanticsLabel('Add 1 to Pull-ups'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(felt, [
        'HapticFeedbackType.lightImpact',
        'HapticFeedbackType.heavyImpact',
        'HapticFeedbackType.heavyImpact',
      ]);
      await tester.pumpAndSettle();
    });

    testWidgets('full screen feels it too', (tester) async {
      await store.addAmount(pullUps, 9);
      await start(tester);
      await hold(tester, 'Pull-ups');
      await tester.tap(find.text('Full screen'));
      await tester.pumpAndSettle();
      felt.clear();
      await tester.tap(find.text('9'));
      await tester.pump(const Duration(milliseconds: 300));
      expect(felt, [
        'HapticFeedbackType.heavyImpact',
        'HapticFeedbackType.heavyImpact',
      ]);
      await tester.pumpAndSettle();
    });

    testWidgets('set, change and clear it in the editor', (tester) async {
      await start(tester);
      await hold(tester, 'Pull-ups');
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      final buzz = find.widgetWithText(TextField, 'Buzz every (optional)');
      expect(tester.widget<TextField>(buzz).controller!.text, '10');

      await tester.enterText(buzz, '0');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(
        find.text('Edit counter'),
        findsOneWidget,
        reason: 'every nothing is not a number to buzz on',
      );

      await tester.enterText(buzz, '25');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(store.counters.counters.single.buzzEvery, 25);

      await hold(tester, 'Pull-ups');
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      await tester.enterText(buzz, '');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(store.counters.counters.single.buzzEvery, isNull);
    });
  });

  group('home-screen widgets', () {
    final asked = <MethodCall>[];
    var widgetCounted = false;

    setUp(() {
      asked.clear();
      homeScreenTakesWidgets = true;
      widgetCounted = false;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('countersink/app'), (
            call,
          ) async {
            asked.add(call);
            return switch (call.method) {
              'pinWidget' => true,
              'takeWidgetCounts' => widgetCounted,
              _ => null,
            };
          });
    });

    tearDown(() {
      homeScreenTakesWidgets = false;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('countersink/app'),
            null,
          );
    });

    testWidgets('a counter can be added to the home screen from its menu', (
      tester,
    ) async {
      await start(tester);
      await hold(tester, 'Pull-ups');
      await tester.tap(find.text('Add to home screen'));
      await tester.pumpAndSettle();
      final pin = asked.singleWhere((c) => c.method == 'pinWidget');
      expect(pin.arguments, store.counters.counters.single.id);
      expect(find.text('Add to home screen'), findsNothing, reason: 'closed');
    });

    testWidgets('it is not offered where the home screen cannot be asked', (
      tester,
    ) async {
      homeScreenTakesWidgets = false;
      await start(tester);
      await hold(tester, 'Pull-ups');
      expect(find.text('History'), findsOneWidget);
      expect(find.text('Add to home screen'), findsNothing);
    });

    testWidgets('leaving the app redraws the widgets', (tester) async {
      await start(tester);
      await tester.tap(find.bySemanticsLabel('Add 1 to Pull-ups'));
      await tester.pumpAndSettle();
      expect(asked.where((c) => c.method == 'refreshWidgets'), isEmpty);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pumpAndSettle();
      expect(asked.where((c) => c.method == 'refreshWidgets'), hasLength(1));
    });

    testWidgets('a count made on a widget shows when the app comes back, and '
        'puts the automatic backup out of date', (tester) async {
      await start(tester);
      store.markBackedUp();
      // The widget writes an event of its own while the app is away.
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pumpAndSettle();
      await repo.record(store.counters.counters.single.id, 3, at: now);
      widgetCounted = true;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(find.text('3'), findsOneWidget);
      expect(store.changedSinceBackup, isTrue);
    });

    testWidgets('coming back with nothing counted leaves the backup be', (
      tester,
    ) async {
      await start(tester);
      store.markBackedUp();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pumpAndSettle();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(store.changedSinceBackup, isFalse);
    });
  });

  group('quick-settings tile', () {
    final asked = <MethodCall>[];
    String? chosen;
    var tileAdded = false;

    setUp(() {
      asked.clear();
      chosen = null;
      tileAdded = false;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(const MethodChannel('countersink/app'), (
            call,
          ) async {
            asked.add(call);
            switch (call.method) {
              case 'tileCounter':
                return chosen;
              case 'setTileCounter':
                chosen = call.arguments as String?;
                return null;
              case 'addTile':
                return tileAdded;
            }
            return null;
          });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            const MethodChannel('countersink/app'),
            null,
          );
    });

    Future<void> openSettings(WidgetTester tester) async {
      await start(tester);
      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();
    }

    testWidgets('choosing a counter turns the tile on and asks for it to be '
        'added', (tester) async {
      tileAdded = true;
      await openSettings(tester);
      expect(find.textContaining('Off. Choose a counter'), findsOneWidget);
      await tapSetting(tester, 'Quick settings tile');
      await tester.pumpAndSettle();
      expect(find.text('Choose a counter'), findsOneWidget);
      expect(find.text('Fitness'), findsOneWidget, reason: 'its group');
      await tester.tap(find.text('Pull-ups'));
      await tester.pumpAndSettle();

      expect(chosen, store.counters.counters.single.id);
      expect(asked.where((c) => c.method == 'addTile'), hasLength(1));
      expect(
        find.text("Adds to Pull-ups, from the phone's quick settings."),
        findsOneWidget,
      );
      expect(
        find.textContaining('To add the tile'),
        findsNothing,
        reason: 'Android added it',
      );
    });

    testWidgets('where the tile was not added, it says how to add it by hand', (
      tester,
    ) async {
      await openSettings(tester);
      await tapSetting(tester, 'Quick settings tile');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pull-ups'));
      await tester.pumpAndSettle();
      expect(chosen, isNotNull);
      expect(find.textContaining('To add the tile'), findsOneWidget);
    });

    testWidgets('an archived counter is not offered', (tester) async {
      final group = store.counters.groups.single;
      final rows = await store.addCounter(groupId: group.id, name: 'Rows');
      await store.archiveCounter(rows);
      await openSettings(tester);
      await tapSetting(tester, 'Quick settings tile');
      await tester.pumpAndSettle();
      expect(find.text('Pull-ups'), findsOneWidget);
      expect(find.text('Rows'), findsNothing);
    });

    testWidgets('it can be given another counter, or turned off', (
      tester,
    ) async {
      final group = store.counters.groups.single;
      final rows = await store.addCounter(groupId: group.id, name: 'Rows');
      chosen = store.counters.counters.first.id;
      tileAdded = true;
      await openSettings(tester);
      expect(find.textContaining('Adds to Pull-ups'), findsOneWidget);

      await tapSetting(tester, 'Quick settings tile');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Choose another counter'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rows'));
      await tester.pumpAndSettle();
      expect(chosen, rows.id);
      expect(find.textContaining('Adds to Rows'), findsOneWidget);

      await tapSetting(tester, 'Quick settings tile');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Turn off'));
      await tester.pumpAndSettle();
      expect(chosen, isNull);
      expect(find.textContaining('Off. Choose a counter'), findsOneWidget);
    });

    testWidgets('a tile whose counter was deleted shows as off', (
      tester,
    ) async {
      chosen = 'a-counter-that-is-gone';
      await openSettings(tester);
      expect(find.textContaining('Off. Choose a counter'), findsOneWidget);
      await tapSetting(tester, 'Quick settings tile');
      await tester.pumpAndSettle();
      expect(find.text('Choose a counter'), findsOneWidget, reason: 'no sheet');
    });
  });

  testWidgets('a counter is not switched to per day if a day of its history '
      'would be below zero', (tester) async {
    final groupId = store.counters.counters.single.groupId;
    // Nine counted yesterday and three taken away today: 6 in all, but
    // today on its own would be 3 below zero.
    final stock = await store.addCounter(groupId: groupId, name: 'Stock');
    await repo.record(stock.id, 9, at: DateTime(2026, 11, 21, 10));
    await repo.record(stock.id, -3, at: DateTime(2026, 11, 22, 9));
    // Counted only on days that stand on their own.
    final laps = await store.addCounter(groupId: groupId, name: 'Laps');
    await repo.record(laps.id, 4, at: DateTime(2026, 11, 21, 10));
    await store.load();
    expect(await store.canCountPerDay(stock), isFalse);
    expect(await store.canCountPerDay(laps), isTrue);
    await start(tester);

    Future<void> askForPerDay(String name) async {
      await tester.longPress(find.text(name));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Count per day'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Count per day'));
      await tester.pumpAndSettle();
    }

    bool daily(String name) =>
        store.counters.counters.firstWhere((c) => c.name == name).daily;

    await askForPerDay('Stock');
    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
      isFalse,
    );
    expect(find.textContaining("can't count per day yet"), findsOneWidget);
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(daily('Stock'), isFalse);
    expect(find.text('6'), findsOneWidget);

    await askForPerDay('Laps');
    expect(find.textContaining("can't count per day yet"), findsNothing);
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(daily('Laps'), isTrue);
  });

  group('calculated counters', () {
    late Counter pullUps;
    late Counter pushUps;

    setUp(() async {
      pullUps = store.counters.counters.single;
      pushUps = await store.addCounter(
        groupId: pullUps.groupId,
        name: 'Push-ups',
      );
      await store.addAmount(pullUps, 5);
      await store.addAmount(pushUps, 7);
    });

    Future<Counter> calculated(
      String name,
      Formula formula,
      List<Counter> of, {
      int? roundSize,
    }) => store.addCounter(
      groupId: pullUps.groupId,
      name: name,
      formula: formula,
      sources: [for (final c in of) c.id],
      roundSize: roundSize,
    );

    FilledButton done(WidgetTester tester) =>
        tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Done'));

    /// From the home screen to the formula screen of a new counter.
    Future<void> newCalculated(WidgetTester tester, String name) async {
      await tester.tap(find.text('Add counter'));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, 'Name'), name);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Calculated from other counters'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Calculated from other counters'));
      await tester.pumpAndSettle();
      expect(find.text('Calculated counter'), findsOneWidget);
    }

    testWidgets('a total of two counters, made in the editor', (tester) async {
      await start(tester);
      await newCalculated(tester, 'Both');
      expect(done(tester).onPressed, isNotNull, reason: 'counted by hand');

      await tester.tap(find.text('A total'));
      await tester.pumpAndSettle();
      expect(done(tester).onPressed, isNull, reason: 'nothing to add up yet');
      for (final name in ['Pull-ups', 'Push-ups']) {
        await tester.ensureVisible(find.text(name));
        await tester.pumpAndSettle();
        await tester.tap(find.text(name));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      // Back in the editor, said in words, with nothing left that belongs
      // to counting by hand.
      expect(find.text('Total of Pull-ups, Push-ups'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Step'), findsNothing);
      expect(
        find.widgetWithText(TextField, 'Buzz every (optional)'),
        findsNothing,
      );
      expect(find.text('Count per day'), findsNothing);
      expect(
        find.widgetWithText(TextField, 'Goal (optional)'),
        findsOneWidget,
        reason: 'a goal is for any counter',
      );
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      expect(find.text('12'), findsOneWidget);
      expect(find.text('Total of Pull-ups, Push-ups'), findsOneWidget);
      expect(find.bySemanticsLabel('Add 1 to Both'), findsNothing);
      expect(find.bySemanticsLabel('Take 1 from Both'), findsNothing);

      // It keeps up with what it is made of.
      await tester.tap(find.bySemanticsLabel('Add 1 to Pull-ups'));
      await tester.pumpAndSettle();
      expect(find.text('13'), findsOneWidget);
      expect(repo.log.where((e) => e.counterId != pullUps.id), hasLength(1));
    });

    testWidgets('a total of a per-day counter can keep a running total', (
      tester,
    ) async {
      // Pull-ups count per day: 9 yesterday, on top of today's 5.
      await store.updateCounter(
        Counter(
          id: pullUps.id,
          groupId: pullUps.groupId,
          name: pullUps.name,
          color: pullUps.color,
          daily: true,
          position: pullUps.position,
        ),
      );
      await repo.record(pullUps.id, 9, at: DateTime(2026, 11, 21, 10));
      await store.load();
      await start(tester);
      await newCalculated(tester, 'Ever');
      await tester.tap(find.text('A total'));
      await tester.pumpAndSettle();

      Future<void> choose(String name) async {
        await tester.ensureVisible(find.text(name));
        await tester.pumpAndSettle();
        await tester.tap(find.text(name));
        await tester.pumpAndSettle();
      }

      // Only a per-day counter gives the choice.
      await choose('Push-ups');
      expect(find.text('Keep a running total'), findsNothing);
      await choose('Push-ups');
      await choose('Pull-ups');
      await tester.ensureVisible(find.text('Keep a running total'));
      await tester.pumpAndSettle();
      expect(find.text('Start from (optional)'), findsNothing);
      await tester.tap(find.text('Keep a running total'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.widgetWithText(TextField, 'Start from (optional)'),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Start from (optional)'),
        '100',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      final ever = store.counters.counters.last;
      expect((ever.allTime, ever.startFrom), (true, 100));
      expect(store.counters.valueOf(ever), 114);
      expect(find.text('114'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Add 1 to Pull-ups'));
      await tester.pumpAndSettle();
      expect(find.text('115'), findsOneWidget);

      // The switch is where it was left when the counter is edited.
      await tester.longPress(find.text('Ever'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Calculated from other counters'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Calculated from other counters'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byType(SwitchListTile),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      expect(
        tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
        isTrue,
      );
      await tester.scrollUntilVisible(
        find.widgetWithText(TextField, 'Start from (optional)'),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.text('100'), findsOneWidget);
    });

    testWidgets('a difference says what is taken from what', (tester) async {
      final net = await calculated('Net', Formula.difference, [
        pushUps,
        pullUps,
      ]);
      await start(tester);
      expect(store.counters.valueOf(net), 2);
      expect(find.text('Push-ups less Pull-ups'), findsOneWidget);
    });

    testWidgets('a share shows a percent sign', (tester) async {
      await calculated('Share', Formula.percent, [pushUps, pullUps]);
      await start(tester);
      expect(find.text('58%'), findsOneWidget);
      expect(
        find.text('Push-ups as a share of Push-ups, Pull-ups'),
        findsOneWidget,
      );
    });

    testWidgets('rounds show how far along the next one is', (tester) async {
      final rounds = await calculated('Rounds', Formula.every, [
        pushUps,
      ], roundSize: 4);
      await start(tester);
      expect(store.counters.valueOf(rounds), 1);
      expect(
        find.text('Rounds of 4 in Push-ups · 3 toward the next'),
        findsOneWidget,
      );
      await tester.tap(find.bySemanticsLabel('Add 1 to Push-ups'));
      await tester.pumpAndSettle();
      expect(store.counters.valueOf(store.counters.counters.last), 2);
      expect(
        find.text('Rounds of 4 in Push-ups · 0 toward the next'),
        findsOneWidget,
      );
    });

    testWidgets('rounds need a size before they can be saved', (tester) async {
      await start(tester);
      await newCalculated(tester, 'Rounds');
      await tester.tap(find.text('Completed rounds'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Push-ups'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Push-ups'));
      await tester.pumpAndSettle();
      expect(done(tester).onPressed, isNull, reason: 'no round size yet');
      final size = find.widgetWithText(TextField, 'One round is');
      await tester.ensureVisible(size);
      await tester.pumpAndSettle();
      await tester.enterText(size, '8');
      await tester.pumpAndSettle();
      expect(done(tester).onPressed, isNotNull);
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(find.text('Rounds of 8 in Push-ups'), findsOneWidget);
    });

    testWidgets('a difference needs something to start with and something '
        'to take away', (tester) async {
      await start(tester);
      await newCalculated(tester, 'Net');
      await tester.tap(find.text('A difference'));
      await tester.pumpAndSettle();
      expect(find.text('TAKE AWAY'), findsNothing, reason: 'nothing chosen');
      await tester.ensureVisible(find.text('Push-ups'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Push-ups'));
      await tester.pumpAndSettle();
      expect(done(tester).onPressed, isNull);
      // The one it starts with isn't offered again to take away.
      await tester.scrollUntilVisible(
        find.text('TAKE AWAY'),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.text('Push-ups'), findsOneWidget);
      await tester.ensureVisible(find.text('Pull-ups').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pull-ups').last);
      await tester.pumpAndSettle();
      expect(done(tester).onPressed, isNotNull);
    });

    testWidgets('its menu has nothing for counting', (tester) async {
      await calculated('Both', Formula.sum, [pullUps, pushUps]);
      await start(tester);
      await hold(tester, 'Both');
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
      for (final gone in [
        'Full screen',
        'Add an amount',
        'Set value',
        'Reset to zero',
        'History',
      ]) {
        expect(find.text(gone), findsNothing, reason: gone);
      }
    });

    test('it cannot be counted on, set or reset', () async {
      final both = await calculated('Both', Formula.sum, [pullUps, pushUps]);
      final before = repo.log.length;
      await store.tap(both, 1);
      await store.addAmount(both, 5);
      await store.setValue(both, 99);
      expect(await store.reset(both), isNull);
      expect(await store.addEntry(both, 3, now), isFalse);
      expect(repo.log, hasLength(before));
      expect(store.counters.valueOf(both), 12);
    });

    testWidgets('a counter it is made of can be deleted, and brought back', (
      tester,
    ) async {
      await calculated('Both', Formula.sum, [pullUps, pushUps]);
      await start(tester);
      await hold(tester, 'Push-ups');
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(find.text('Total of Pull-ups'), findsOneWidget);
      expect(store.counters.valueOf(store.counters.counters.last), 5);

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(find.text('Total of Pull-ups, Push-ups'), findsOneWidget);
      expect(store.counters.valueOf(store.counters.counters.last), 12);
    });

    testWidgets('it says so when the counter it starts from is gone', (
      tester,
    ) async {
      await calculated('Net', Formula.difference, [pushUps, pullUps]);
      await store.deleteCounter(pushUps);
      await start(tester);
      expect(
        find.text('The counter it was worked out from is gone'),
        findsOneWidget,
      );
    });

    testWidgets('it can be made an ordinary counter again', (tester) async {
      await calculated('Both', Formula.sum, [pullUps, pushUps]);
      await start(tester);
      await hold(tester, 'Both');
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Calculated from other counters'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Calculated from other counters'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Counted by hand'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(TextField, 'Step'), findsOneWidget);
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      final both = store.counters.counters.last;
      expect((both.formula, both.calculated), (null, false));
      expect(find.bySemanticsLabel('Add 1 to Both'), findsOneWidget);
    });

    testWidgets('one calculated counter is not offered to make another, nor '
        'to itself', (tester) async {
      await calculated('Both', Formula.sum, [pullUps, pushUps]);
      await start(tester);
      await newCalculated(tester, 'Twice');
      await tester.tap(find.text('A total'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Push-ups'),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.text('Pull-ups'), findsOneWidget);
      expect(find.text('Both'), findsNothing);
    });

    testWidgets('the quick-settings tile is not offered one', (tester) async {
      await calculated('Both', Formula.sum, [pullUps, pushUps]);
      await start(tester);
      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();
      await tapSetting(tester, 'Quick settings tile');
      await tester.pumpAndSettle();
      expect(find.text('Push-ups'), findsOneWidget);
      expect(find.text('Both'), findsNothing);
    });

    testWidgets('with no counters to work from, it says what to do', (
      tester,
    ) async {
      await store.archiveCounter(pullUps);
      await store.archiveCounter(pushUps);
      await start(tester);
      await newCalculated(tester, 'Both');
      await tester.tap(find.text('A total'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Add a counter to count by hand'), findsOne);
      expect(done(tester).onPressed, isNull);
    });
  });

  group('ready-made sets and copies of groups', () {
    Future<void> openGroupsScreen(WidgetTester tester) async {
      await start(tester);
      await tester.tap(find.byTooltip('Groups'));
      await tester.pumpAndSettle();
    }

    testWidgets('a set arrives as a group with its counters, ready to count', (
      tester,
    ) async {
      await openGroupsScreen(tester);
      await tester.tap(find.text('Add group'));
      await tester.pumpAndSettle();
      expect(find.text('READY-MADE SETS'), findsOneWidget);
      await tester.tap(find.text('In and out'));
      await tester.pumpAndSettle();
      expect(find.text('In and out'), findsOneWidget);
      expect(find.text('3 counters'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(Tab, 'In and out'));
      await tester.pumpAndSettle();
      expect(find.text('In less Out'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Add 1 to In'));
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Add 1 to In'));
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Add 1 to Out'));
      await tester.pumpAndSettle();
      final inside = store.counters.counters.last;
      expect((inside.name, store.counters.valueOf(inside)), ('Inside', 1));
    });

    testWidgets('every set is whole: its calculated counters have what they '
        'are worked out from, in the same group', (tester) async {
      await start(tester);
      final l = stringsFor(const []);
      final sets = presets(l);
      expect(sets, hasLength(5));
      for (final set in sets) {
        final group = await store.addGroupWith(set.name, set.counters);
        final made = store.counters.inGroup(group.id);
        expect(made, hasLength(set.counters.length), reason: set.name);
        final here = {for (final c in made) c.id};
        for (final c in made.where((c) => c.calculated)) {
          expect(store.counters.brokenOf(c), isFalse, reason: c.name);
          expect(here.containsAll(c.sources), isTrue, reason: c.name);
        }
        expect(
          made.where((c) => !c.calculated),
          isNotEmpty,
          reason: 'something to count on',
        );
      }
      expect(repo.log, isEmpty, reason: 'nothing counted by adding them');
    });

    testWidgets('the same set twice gives two groups that count apart', (
      tester,
    ) async {
      await start(tester);
      final beads = presets(stringsFor(const []))[1];
      final first = await store.addGroupWith(beads.name, beads.counters);
      final second = await store.addGroupWith(beads.name, beads.counters);
      await store.addAmount(store.counters.inGroup(first.id).first, 216);
      expect(store.counters.valueOf(store.counters.inGroup(first.id).last), 2);
      expect(store.counters.valueOf(store.counters.inGroup(second.id).last), 0);
    });

    testWidgets('a group is copied with its counters and none of its counts', (
      tester,
    ) async {
      final fitness = store.counters.groups.single;
      final pullUps = store.counters.counters.single;
      final pushUps = await store.addCounter(
        groupId: fitness.id,
        name: 'Push-ups',
        step: 5,
        goal: 50,
      );
      await store.addCounter(
        groupId: fitness.id,
        name: 'Both',
        formula: Formula.sum,
        sources: [pullUps.id, pushUps.id],
      );
      final put = await store.addCounter(groupId: fitness.id, name: 'Old');
      await store.archiveCounter(put);
      await store.addAmount(pullUps, 9);
      final before = repo.log.length;

      await openGroupsScreen(tester);
      await tester.tap(find.byTooltip('Copy Fitness, without its counts'));
      await tester.pumpAndSettle();
      expect(find.text('Fitness (copy)'), findsOneWidget);

      final copy = store.counters.groups.last;
      final copies = store.counters.allInGroup(copy.id);
      expect(
        [for (final c in copies) c.name],
        ['Pull-ups', 'Push-ups', 'Both'],
      );
      expect((copies[1].step, copies[1].goal), (5, 50), reason: 'settings');
      expect(copies.first.daily, isTrue);
      expect(repo.log, hasLength(before), reason: 'no counts came along');
      expect(store.counters.valueOf(copies.last), 0);

      // The copy's total is of the copies, not of the originals.
      expect(copies.last.sources, [copies[0].id, copies[1].id]);
      await store.addAmount(copies[1], 5);
      expect(store.counters.valueOf(copies.last), 5);
      final original = store.counters.inGroup(fitness.id).last;
      expect(store.counters.valueOf(original), 9);
    });

    test('a copy worked out from a counter in another group still looks '
        'there', () async {
      final fitness = store.counters.groups.single;
      final pullUps = store.counters.counters.single;
      final games = await store.addGroup('Games');
      await store.addCounter(
        groupId: games.id,
        name: 'Pull-up rounds',
        formula: Formula.every,
        sources: [pullUps.id],
        roundSize: 5,
      );
      final copy = await store.copyGroup(games, 'Games again');
      expect(store.counters.inGroup(copy.id).single.sources, [pullUps.id]);
      expect(fitness.id, isNot(copy.id));
    });
  });

  group('import from another app', () {
    const documents = MethodChannel('countersink/documents');
    String? fileToOpen;

    setUp(() {
      fileToOpen = null;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(documents, (call) async {
            final file = fileToOpen;
            return file == null ? null : Uint8List.fromList(utf8.encode(file));
          });
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(documents, null);
    });

    /// From the home screen to having picked [app] and been handed the file.
    Future<void> import(WidgetTester tester, String app) async {
      await start(tester);
      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();
      await tapSetting(tester, 'Import from another app');
      await tester.pumpAndSettle();
      expect(find.text('Which app is the file from?'), findsOneWidget);
      await tester.tap(find.text(app));
      await tester.pumpAndSettle();
    }

    testWidgets('a BetterCounter file arrives as a new group, history and all, '
        'beside what was there', (tester) async {
      await store.addAmount(store.counters.counters.single, 4);
      fileToOpen =
          'Push-ups,1700000000000,1700000060000,1700003600000\n'
          'Water\n';
      await import(tester, 'BetterCounter');
      expect(find.text('Imported 2 counters and 3 entries.'), findsOneWidget);

      expect(
        [for (final g in store.counters.groups) g.name],
        ['Fitness', 'Imported'],
      );
      final imported = store.counters.inGroup(store.counters.groups.last.id);
      expect([for (final c in imported) c.name], ['Push-ups', 'Water']);
      expect(store.counters.valueOf(imported.first), 3);
      expect(store.counters.valueOf(imported.last), 0);
      // What was there is untouched.
      final pullUps = store.counters.counters.first;
      expect((pullUps.name, store.counters.valueOf(pullUps)), ('Pull-ups', 4));
      expect(store.changedSinceBackup, isTrue);
    });

    testWidgets('Undo takes the imported groups away again', (tester) async {
      fileToOpen =
          '{"counters":[{"id":1,"name":"Steps","value":12,"labelId":2},'
          '{"id":2,"name":"Loose","value":3,"labelId":null}],'
          '"labels":[{"id":2,"name":"Health","color":4292956737}]}';
      await import(tester, 'Simple Counter');
      expect(
        [for (final g in store.counters.groups) g.name],
        ['Fitness', 'Health', 'Imported'],
      );
      final before = repo.log.length;
      expect(before, 2);

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect([for (final g in store.counters.groups) g.name], ['Fitness']);
      expect(store.counters.counters.single.name, 'Pull-ups');
      expect(repo.log, isEmpty);
    });

    testWidgets('a Counter file brings each number, and says what it could '
        'not read', (tester) async {
      fileToOpen =
          '"Name","Value","Last Update"\n'
          '"Laps","42","20261108T142843+0100"\n'
          '"Not a number","x",""\n';
      await import(tester, 'Counter');
      expect(
        find.text("Imported 1 counter and 1 entry. 1 line couldn't be read."),
        findsOneWidget,
      );
      final laps = store.counters.counters.last;
      expect((laps.name, store.counters.valueOf(laps)), ('Laps', 42));
    });

    testWidgets('a file from the wrong app is refused, and nothing changes', (
      tester,
    ) async {
      fileToOpen = 'Push-ups,1700000000000,1700000060000,1700003600000\n';
      await import(tester, 'Simple Counter');
      expect(find.text("Can't import this file"), findsOneWidget);
      expect(
        find.text("This doesn't look like a file from Simple Counter."),
        findsOneWidget,
      );
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(store.counters.groups, hasLength(1));
      expect(store.counters.counters, hasLength(1));
    });

    testWidgets('one of Countersink\'s own backups is pointed at Restore', (
      tester,
    ) async {
      fileToOpen = encodeBackup(
        await store.exportData(),
        exportedAt: DateTime.utc(2026, 11, 23),
      );
      await import(tester, 'Simple Counter');
      expect(
        find.text(
          'This is a Countersink backup. Use "Restore from a backup" for it.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('an empty file says there is nothing in it', (tester) async {
      fileToOpen = '"Name","Value","Last Update"\n';
      await import(tester, 'Counter');
      expect(find.text('There are no counters in this file.'), findsOneWidget);
    });

    testWidgets('backing out of the file picker does nothing', (tester) async {
      await import(tester, 'BetterCounter');
      expect(find.text("Can't import this file"), findsNothing);
      expect(store.counters.groups, hasLength(1));
    });

    testWidgets('the same file twice gives two groups, not a clash', (
      tester,
    ) async {
      fileToOpen = 'Laps,1700000000000\n';
      await import(tester, 'BetterCounter');
      await tapSetting(tester, 'Import from another app');
      await tester.pumpAndSettle();
      await tester.tap(find.text('BetterCounter'));
      await tester.pumpAndSettle();
      expect(store.counters.groups, hasLength(3));
      expect(repo.log, hasLength(2));
    });
  });

  group('being told when a goal is reached', () {
    late Counter pullUps;
    late Counter pushUps;

    setUp(() async {
      final c = store.counters.counters.single;
      pullUps = Counter(
        id: c.id,
        groupId: c.groupId,
        name: c.name,
        color: c.color,
        goal: 3,
        daily: true,
      );
      await store.updateCounter(pullUps);
      pushUps = await store.addCounter(
        groupId: pullUps.groupId,
        name: 'Push-ups',
      );
    });

    Future<Counter> calculated(
      String name,
      Formula formula,
      List<Counter> of, {
      int? goal,
    }) => store.addCounter(
      groupId: pullUps.groupId,
      name: name,
      formula: formula,
      sources: [for (final c in of) c.id],
      goal: goal,
    );

    testWidgets('the count that reaches a goal says so, and only that one', (
      tester,
    ) async {
      await start(tester);
      await tester.tap(find.bySemanticsLabel('Add 1 to Pull-ups'));
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Add 1 to Pull-ups'));
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsNothing);

      await tester.tap(find.bySemanticsLabel('Add 1 to Pull-ups'));
      await tester.pumpAndSettle();
      expect(find.text('Pull-ups has reached 3'), findsOneWidget);

      // Going on past it says nothing more.
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Add 1 to Pull-ups'));
      await tester.pumpAndSettle();
      expect(find.text('Pull-ups has reached 3'), findsNothing);
    });

    testWidgets('a calculated counter has a goal, shown on its card', (
      tester,
    ) async {
      await store.addAmount(pushUps, 4);
      await calculated('Both', Formula.sum, [pullUps, pushUps], goal: 10);
      await start(tester);
      expect(find.text('Total of Pull-ups, Push-ups · of 10'), findsOneWidget);
      final bars = tester
          .widgetList<LinearProgressIndicator>(
            find.byType(LinearProgressIndicator),
          )
          .toList();
      expect(bars.last.value, closeTo(0.4, 0.001));
    });

    testWidgets('counting on one counter can bring a calculated one to its '
        'goal, and says so', (tester) async {
      await store.addAmount(pushUps, 4);
      final both = await calculated('Both', Formula.sum, [
        pullUps,
        pushUps,
      ], goal: 5);
      expect(store.reachedBy(pushUps, 1).single.id, both.id);
      expect(store.markOf(pushUps, 1), CountMark.goal);
      await start(tester);
      await tester.tap(find.bySemanticsLabel('Add 1 to Push-ups'));
      await tester.pumpAndSettle();
      expect(find.text('Both has reached 5'), findsOneWidget);
      expect(store.counters.valueOf(store.counters.counters.last), 5);
    });

    testWidgets('one count that reaches two goals names both', (tester) async {
      await store.addAmount(pullUps, 2);
      await calculated('Both', Formula.sum, [pullUps, pushUps], goal: 3);
      await start(tester);
      await tester.tap(find.bySemanticsLabel('Add 1 to Pull-ups'));
      await tester.pumpAndSettle();
      expect(
        find.text('Pull-ups has reached 3\nBoth has reached 3'),
        findsOneWidget,
      );
    });

    test('taking away from what is subtracted can reach a difference\'s '
        'goal', () async {
      await store.addAmount(pullUps, 5);
      await store.addAmount(pushUps, 3);
      final net = await calculated('Net', Formula.difference, [
        pullUps,
        pushUps,
      ], goal: 3);
      expect(store.counters.valueOf(net), 2);
      expect(store.reachedBy(pushUps, -1).single.id, net.id);
      expect(store.reachedBy(pushUps, 1), isEmpty);
      // Push-ups can't go below nothing, so no more than 3 can come off.
      expect(store.reachedBy(pushUps, -99).single.id, net.id);
    });

    test('a goal already met, an archived counter and a calculated counter '
        'itself say nothing', () async {
      await store.addAmount(pushUps, 9);
      final both = await calculated('Both', Formula.sum, [
        pullUps,
        pushUps,
      ], goal: 5);
      expect(store.reachedBy(pushUps, 1), isEmpty, reason: 'already past it');
      expect(store.reachedBy(both, 1), isEmpty, reason: 'not counted on');

      final later = await calculated('Later', Formula.sum, [
        pullUps,
        pushUps,
      ], goal: 10);
      expect(store.reachedBy(pushUps, 1).single.id, later.id);
      await store.archiveCounter(later);
      expect(store.reachedBy(pushUps, 1), isEmpty, reason: 'put away');
    });

    testWidgets('the goal of a calculated counter is set in the editor', (
      tester,
    ) async {
      await calculated('Both', Formula.sum, [pullUps, pushUps]);
      await start(tester);
      await hold(tester, 'Both');
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(TextField, 'Step'), findsNothing);
      final goal = find.widgetWithText(TextField, 'Goal (optional)');
      expect(
        find.text('A number to reach. A message says so when it gets there.'),
        findsOneWidget,
      );
      await tester.enterText(goal, '40');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      final both = store.counters.counters.last;
      expect((both.goal, both.calculated), (40, true));
    });

    testWidgets('full screen says it too', (tester) async {
      await store.addAmount(pullUps, 2);
      await start(tester);
      await hold(tester, 'Pull-ups');
      await tester.tap(find.text('Full screen'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('2'));
      await tester.pumpAndSettle();
      expect(find.text('Pull-ups has reached 3'), findsOneWidget);
    });
  });

  group('send to and receive from another phone', () {
    late Counter pullUps;

    setUp(() async {
      pullUps = store.counters.counters.single;
      // Three counts, each an entry of its own.
      for (var i = 0; i < 3; i++) {
        await store.tap(pullUps, 1);
      }
    });

    tearDown(() => ReceiveScreen.readerForTests = null);

    Future<void> openSettings(WidgetTester tester) async {
      await start(tester);
      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();
    }

    Future<void> openSend(WidgetTester tester) async {
      await openSettings(tester);
      await tapSetting(tester, 'Send to another phone');
      await tester.pumpAndSettle();
      expect(find.text('What would you like to send?'), findsOneWidget);
    }

    Future<void> showCodes(WidgetTester tester) async {
      await tester.ensureVisible(find.text('Show the codes'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Show the codes'));
      await tester.pumpAndSettle();
    }

    /// Every code the Send screen is showing, stepped through by hand.
    Future<List<String>> codes(WidgetTester tester) async {
      String showing() =>
          tester.widget<QrCodeView>(find.byType(QrCodeView)).data;
      final seen = <String>[showing()];
      while (find.byTooltip('Next code').evaluate().isNotEmpty) {
        await tester.ensureVisible(find.byTooltip('Next code'));
        await tester.tap(find.byTooltip('Next code'));
        await tester.pump();
        if (seen.contains(showing())) break;
        seen.add(showing());
      }
      return seen;
    }

    BackupData read(List<String> frames) {
      final receiver = TransferReceiver();
      frames.forEach(receiver.add);
      expect(receiver.isComplete, isTrue);
      return decodeBackup(receiver.assemble());
    }

    /// In the camera's place: a button that "scans" each of [frames].
    void scanWith(List<String> frames) {
      ReceiveScreen.readerForTests = (onText) => Center(
        child: TextButton(
          onPressed: () => frames.forEach(onText),
          child: const Text('scan'),
        ),
      );
    }

    testWidgets('everything goes across and arrives as new groups, with Undo', (
      tester,
    ) async {
      await openSend(tester);
      await showCodes(tester);
      expect(find.text('Sending 1 counter and 3 entries.'), findsOneWidget);
      final frames = await codes(tester);
      await tester.ensureVisible(find.text('Done'));
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      scanWith(frames);
      await tapSetting(tester, 'Receive from another phone');
      await tester.pumpAndSettle();
      expect(
        find.text('Point the camera at the code on the other phone.'),
        findsOneWidget,
      );
      await tester.tap(find.text('scan'));
      await tester.pumpAndSettle();

      expect(find.text('Received 1 counter and 3 entries.'), findsOneWidget);
      expect(
        [for (final g in store.counters.groups) g.name],
        ['Fitness', 'Fitness'],
      );
      final arrived = store.counters.counters.last;
      expect(arrived.id, isNot(pullUps.id));
      expect(
        (arrived.name, arrived.daily, store.counters.valueOf(arrived)),
        ('Pull-ups', true, 3),
      );
      expect(repo.log, hasLength(6));

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(store.counters.groups, hasLength(1));
      expect(repo.log, hasLength(3));
    });

    testWidgets('just some counters: only those chosen are sent', (
      tester,
    ) async {
      final pushUps = await store.addCounter(
        groupId: pullUps.groupId,
        name: 'Push-ups',
      );
      await store.addAmount(pushUps, 7);
      await openSend(tester);
      await tester.tap(find.text('Just some counters'));
      await tester.pumpAndSettle();
      expect(find.text('Choose at least one counter to send.'), findsOne);
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, 'Show the codes'),
            )
            .onPressed,
        isNull,
      );

      await tester.tap(find.text('Push-ups'));
      await tester.pumpAndSettle();
      await showCodes(tester);
      final sent = read(await codes(tester));
      expect(sent.counters.single.name, 'Push-ups');
      expect(sent.events.single.delta, 7);
      expect(sent.groups.single.name, 'Fitness');
    });

    testWidgets('numbers only sends each counter with one entry', (
      tester,
    ) async {
      await openSend(tester);
      await tester.ensureVisible(find.text('Counters and their numbers'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Counters and their numbers'));
      await tester.pumpAndSettle();
      await showCodes(tester);
      expect(find.text('Sending 1 counter and 1 entry.'), findsOneWidget);
      final sent = read(await codes(tester));
      expect(
        (sent.events.single.delta, sent.events.single.kind),
        (3, EventKind.set),
      );
    });

    testWidgets('a long history is several codes, which change on their own', (
      tester,
    ) async {
      for (var i = 0; i < 400; i++) {
        await repo.record(
          pullUps.id,
          1,
          at: now.add(Duration(minutes: -i * 7)),
        );
      }
      await store.load();
      await openSend(tester);
      await showCodes(tester);
      expect(find.textContaining('Code 1 of '), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 1900));
      expect(find.textContaining('Code 2 of '), findsOneWidget);

      // Stepping by hand stops them, so one can be held up to a slow camera.
      await tester.ensureVisible(find.byTooltip('Next code'));
      await tester.tap(find.byTooltip('Next code'));
      await tester.pump();
      expect(find.textContaining('Code 3 of '), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 4000));
      expect(find.textContaining('Code 3 of '), findsOneWidget);

      final frames = await codes(tester);
      expect(frames.length, greaterThan(2));
      expect(read(frames).events, hasLength(403));

      // Back goes to the choices, not out of the screen.
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.text('What would you like to send?'), findsOneWidget);
    });

    testWidgets('receiving shows how far along it is and what is missing', (
      tester,
    ) async {
      for (var i = 0; i < 400; i++) {
        await repo.record(
          pullUps.id,
          1,
          at: now.add(Duration(minutes: -i * 7)),
        );
      }
      await store.load();
      await openSend(tester);
      await showCodes(tester);
      final frames = await codes(tester);
      await tester.ensureVisible(find.text('Done'));
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      scanWith([frames[1]]);
      await tapSetting(tester, 'Receive from another phone');
      await tester.pumpAndSettle();
      await tester.tap(find.text('scan'));
      await tester.pumpAndSettle();
      expect(find.text('1 of ${frames.length} codes received'), findsOneWidget);
      expect(find.textContaining('Still needed: 1, 3'), findsOneWidget);
      expect(store.counters.groups, hasLength(1), reason: 'nothing yet');
    });

    testWidgets('a code from somewhere else is said to be so', (tester) async {
      scanWith(['https://example.com', 'EBB1:ABCD:1/1:BB8']);
      await openSettings(tester);
      await tapSetting(tester, 'Receive from another phone');
      await tester.pumpAndSettle();
      await tester.tap(find.text('scan'));
      await tester.pumpAndSettle();
      expect(find.text("That code isn't from Countersink."), findsOneWidget);
      expect(store.counters.groups, hasLength(1));
    });

    testWidgets('codes that do not add up to a backup start it over', (
      tester,
    ) async {
      // A whole, intact transfer of something that isn't a backup.
      scanWith(encodeTransfer('{"not": "a backup"}'));
      await openSettings(tester);
      await tapSetting(tester, 'Receive from another phone');
      await tester.pumpAndSettle();
      await tester.tap(find.text('scan'));
      await tester.pumpAndSettle();
      expect(
        find.text("Some codes didn't read cleanly. Let's scan them again."),
        findsOneWidget,
      );
      expect(find.text('Receive from another phone'), findsOneWidget);
    });

    testWidgets('backing out of receiving changes nothing', (tester) async {
      scanWith(const []);
      await openSettings(tester);
      await tapSetting(tester, 'Receive from another phone');
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsNothing);
      expect(store.counters.groups, hasLength(1));
    });
  });

  group('messages with Undo', () {
    testWidgets('go away on their own after their time', (tester) async {
      await store.addAmount(store.counters.counters.single, 5);
      await start(tester);
      await hold(tester, 'Pull-ups');
      await tester.tap(find.text('Reset to zero'));
      await tester.pumpAndSettle();
      expect(find.text('Undo'), findsOneWidget);

      await tester.pump(const Duration(seconds: 7));
      expect(find.text('Undo'), findsOneWidget, reason: 'still time to undo');
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();
      expect(find.text('Undo'), findsNothing);
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('can be swiped away to the side', (tester) async {
      await store.addAmount(store.counters.counters.single, 5);
      await start(tester);
      await hold(tester, 'Pull-ups');
      await tester.tap(find.text('Reset to zero'));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(SnackBar), const Offset(500, 0));
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsNothing);
      expect(store.counters.valueOf(store.counters.counters.single), 0);
    });

    test('every one of them is told to time out', () {
      // Flutter keeps a message that has a button on screen until it is
      // dismissed, unless it is told otherwise. Each of ours must be.
      for (final file in Directory('lib/ui').listSync().whereType<File>()) {
        final source = file.readAsStringSync();
        expect(
          'persist: false'.allMatches(source).length,
          'SnackBarAction('.allMatches(source).length,
          reason: file.path,
        );
      }
    });
  });

  group('arranging counters', () {
    setUp(() async {
      final fitness = store.counters.groups.single;
      await store.addCounter(groupId: fitness.id, name: 'Push-ups');
      await store.addCounter(groupId: fitness.id, name: 'Squats');
      await store.addGroup('Game night');
    });

    List<String> inGroup(String name) {
      final g = store.counters.groups.firstWhere((g) => g.name == name);
      return [for (final c in store.counters.inGroup(g.id)) c.name];
    }

    testWidgets('drag a counter by its handle to reorder', (tester) async {
      await start(tester);
      await hold(tester, 'Pull-ups');
      await tester.tap(find.text('Reorder counters'));
      await tester.pumpAndSettle();

      final handles = find.byIcon(Icons.drag_handle);
      final rowHeight =
          tester.getCenter(handles.at(1)).dy -
          tester.getCenter(handles.at(0)).dy;
      final drag = await tester.startGesture(tester.getCenter(handles.first));
      await tester.pump(const Duration(milliseconds: 100));
      for (var i = 0; i < 10; i++) {
        await drag.moveBy(Offset(0, rowHeight * 2.4 / 10));
        await tester.pump(const Duration(milliseconds: 20));
      }
      await drag.up();
      await tester.pumpAndSettle();
      expect(inGroup('Fitness'), ['Push-ups', 'Squats', 'Pull-ups']);

      await tester.pageBack();
      await tester.pumpAndSettle();
      final cards = tester
          .widgetList<CounterCard>(find.byType(CounterCard))
          .map((c) => c.counter.name);
      expect(cards, ['Push-ups', 'Squats', 'Pull-ups']);
    });

    testWidgets('move a counter to another group, with its count', (
      tester,
    ) async {
      final pullUps = store.counters.counters.first;
      await store.addAmount(pullUps, 12);
      await start(tester);
      await hold(tester, 'Pull-ups');
      await tester.tap(find.text('Move to another group'));
      await tester.pumpAndSettle();
      expect(find.text('Move Pull-ups to'), findsOneWidget);
      expect(
        find.widgetWithText(ListTile, 'Fitness'),
        findsNothing,
        reason: "not the group it's already in",
      );
      await tester.tap(find.widgetWithText(ListTile, 'Game night'));
      await tester.pumpAndSettle();

      expect(find.text('Moved to Game night'), findsOneWidget);
      expect(inGroup('Fitness'), ['Push-ups', 'Squats']);
      expect(inGroup('Game night'), ['Pull-ups']);
      expect(store.counters.totals[pullUps.id], 12);
    });

    testWidgets('with one group and one counter, neither is offered', (
      tester,
    ) async {
      final only = InMemoryCounterRepository();
      store = CounterStore(repository: only, clock: () => now);
      final g = await store.addGroup('Solo');
      await store.addCounter(groupId: g.id, name: 'Laps');
      await start(tester);
      await hold(tester, 'Laps');
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Reorder counters'), findsNothing);
      expect(find.text('Move to another group'), findsNothing);
    });
  });

  group('colours and patterns', () {
    Future<void> openEditor(WidgetTester tester) async {
      await start(tester);
      await hold(tester, 'Pull-ups');
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();
    }

    Future<void> more(WidgetTester tester) async {
      await tester.tap(find.byTooltip('More colors and patterns'));
      await tester.pumpAndSettle();
    }

    testWidgets('pick a colour from the wider palette', (tester) async {
      await openEditor(tester);
      await more(tester);
      expect(find.text('Color and pattern'), findsOneWidget);
      await tester.tap(find.byTooltip('Ochre').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(
        find.byTooltip('Ochre'),
        findsOneWidget,
        reason: 'shown in the editor as the colour in use',
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      final c = store.counters.counters.single;
      expect(
        (c.color, c.color2, c.pattern),
        (0xFFC28A2C, null, CounterPattern.none),
      );
    });

    testWidgets('a second colour and a pattern', (tester) async {
      await openEditor(tester);
      await more(tester);
      // The second set of swatches is the second colour's.
      await tester.ensureVisible(find.byTooltip('Moss').last);
      await tester.tap(find.byTooltip('Moss').last);
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Stripes'));
      await tester.tap(find.text('Stripes'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      final c = store.counters.counters.single;
      expect(
        (c.color, c.color2, c.pattern),
        (counterColors.first.toARGB32(), 0xFF2F5A45, CounterPattern.stripes),
      );
      expect(
        find.text('Pull-ups'),
        findsOneWidget,
        reason: 'the card still draws',
      );
    });

    testWidgets('every pattern choice is drawn at a size you can see', (
      tester,
    ) async {
      await openEditor(tester);
      await more(tester);
      // Far enough down the list that it isn't built until scrolled to.
      await tester.scrollUntilVisible(
        find.text('Stripes'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      for (final name in ['Plain', 'Stripes', 'Dots', 'Grid']) {
        final swatch = find.descendant(
          of: find
              .ancestor(of: find.text(name), matching: find.byType(InkWell))
              .first,
          matching: find.byType(LookBox),
        );
        expect(tester.getSize(swatch).width, greaterThan(40), reason: name);
        expect(tester.getSize(swatch).height, greaterThan(40), reason: name);
      }
      // And the cards around the swatches are all one width.
      final cards = tester.widgetList<Card>(find.byType(Card)).length;
      final widths = {
        for (var i = 0; i < cards; i++)
          tester.getSize(find.byType(Card).at(i)).width,
      };
      expect(widths, hasLength(1));
    });

    testWidgets('the second colour can be taken off again', (tester) async {
      final c = store.counters.counters.single;
      await store.updateCounter(
        Counter(
          id: c.id,
          groupId: c.groupId,
          name: c.name,
          color: c.color,
          color2: 0xFF2F5A45,
          pattern: CounterPattern.grid,
          daily: c.daily,
        ),
      );
      await openEditor(tester);
      await more(tester);
      await tester.ensureVisible(find.byTooltip('None'));
      await tester.tap(find.byTooltip('None'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      final after = store.counters.counters.single;
      expect((after.color2, after.pattern), (null, CounterPattern.grid));
    });

    testWidgets('any colour at all, by its hex code', (tester) async {
      await openEditor(tester);
      await more(tester);
      await tester.tap(find.byTooltip('Custom color').first);
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextField, 'Hex code'),
        '#336699',
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Use'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(store.counters.counters.single.color, 0xFF336699);
    });

    testWidgets('backing out of the colour screen keeps what was there', (
      tester,
    ) async {
      await openEditor(tester);
      await more(tester);
      await tester.tap(find.byTooltip('Ochre').first);
      await tester.pumpAndSettle();
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(
        store.counters.counters.single.color,
        counterColors.first.toARGB32(),
      );
    });

    testWidgets('a one-tap family colour makes the card plain again', (
      tester,
    ) async {
      final c = store.counters.counters.single;
      await store.updateCounter(
        Counter(
          id: c.id,
          groupId: c.groupId,
          name: c.name,
          color: 0xFF336699,
          color2: 0xFF2F5A45,
          pattern: CounterPattern.dots,
        ),
      );
      await openEditor(tester);
      await tester.tap(find.byTooltip('Navy'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      final after = store.counters.counters.single;
      expect(
        (after.color, after.color2, after.pattern),
        (0xFF14344B, null, CounterPattern.none),
      );
    });

    test('hex codes read and write', () {
      expect(parseHex('#c4613f'), const Color(0xFFC4613F));
      expect(parseHex('C4613F'), const Color(0xFFC4613F));
      expect(parseHex('#12'), isNull);
      expect(parseHex('#GGGGGG'), isNull);
      expect(hexOf(const Color(0xFF0A0B0C)), '#0A0B0C');
    });

    test('ink on a blend is judged at its middle', () {
      CounterLook blend(int from, int to) =>
          (color: Color(from), color2: Color(to), pattern: CounterPattern.none);
      // Navy into linen: dark at one end, light at the other, light enough
      // in the middle for dark ink.
      expect(inkOnLook(blend(0xFF14344B, 0xFFE9DFCF)), const Color(0xFF14232E));
      expect(inkOnLook(blend(0xFF14344B, 0xFF26323A)), Colors.white);
      expect(inkOnLook(blend(0xFFE9DFCF, 0xFFD9B98A)), const Color(0xFF14232E));
    });
  });

  test('card text is picked for contrast with the card', () {
    expect(inkOn(const Color(0xFF14344B)), Colors.white);
    expect(inkOn(const Color(0xFFA09EB9)), const Color(0xFF14232E));
  });
}
