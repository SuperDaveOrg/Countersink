import 'package:countersink/models/counter.dart';
import 'package:countersink/services/app_info.dart';
import 'package:countersink/ui/app.dart';
import 'package:countersink/ui/counter_store.dart';
import 'package:countersink/ui/language.dart';
import 'package:countersink/ui/receive_screen.dart';
import 'package:countersink/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/fakes.dart';

/// Walks the main screens in every language on a small phone. Words that
/// don't fit their place make Flutter raise an overflow error, which fails
/// the test: German and Russian run long.
void main() {
  // A tap that lands on something else means a screen went unchecked.
  WidgetController.hitTestWarningShouldBeFatal = true;

  for (final code in languageNames.keys) {
    testWidgets('every screen fits in $code', (tester) async {
      // Automatic backup switched on, so its longer line and its sheet show.
      SharedPreferences.setMockInitialValues({
        'auto_backup_folder': 'content://folders/backups',
        'auto_backup_folder_name': 'Backups',
      });
      themeChoice.value = ThemeMode.system;
      chosenLanguage.value = code;
      // So the counter's menu is at its longest.
      homeScreenTakesWidgets = true;
      addTearDown(() => homeScreenTakesWidgets = false);
      addTearDown(() => chosenLanguage.value = null);
      // A small phone: 360 by 640.
      tester.view.physicalSize = const Size(720, 1280);
      tester.view.devicePixelRatio = 2;
      addTearDown(tester.view.reset);

      final repo = InMemoryCounterRepository();
      final store = CounterStore(
        repository: repo,
        clock: () => DateTime(2026, 11, 22, 12),
      );
      final group = await store.addGroup('Fitness');
      await store.addGroup('Games');
      final counter = await store.addCounter(
        groupId: group.id,
        name: 'Pull-ups',
        description: 'Strict, full hang',
        // A goal for the week and a buzz: the longest line under the
        // number, and every field the editor has.
        goal: 300,
        goalPeriod: GoalPeriod.week,
        buzzEvery: 10,
        daily: true,
        color2: const Color(0xFF14344B),
        pattern: CounterPattern.stripes,
      );
      // A calculated counter, of the kind with the most to say on its card.
      await store.addCounter(
        groupId: group.id,
        name: 'Rounds',
        formula: Formula.every,
        sources: [counter.id],
        roundSize: 8,
      );
      await store.addCounter(groupId: group.id, name: 'Push-ups');
      for (var day = 15; day <= 22; day++) {
        await repo.record(counter.id, 52, at: DateTime(2026, 11, day, 9));
      }
      await store.load();

      // The quick-settings tile switched on, so its longer line shows.
      const app = MethodChannel('countersink/app');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            app,
            (call) async => call.method == 'tileCounter' ? counter.id : null,
          );
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(app, null),
      );

      await tester.pumpWidget(CountersinkApp(store: store));
      await tester.pumpAndSettle();
      final l = stringsFor(const []);

      Future<void> back() async {
        await tester.tap(find.byType(BackButton).last);
        await tester.pumpAndSettle();
      }

      Future<void> menu() async {
        await tester.longPress(find.text('Pull-ups'));
        await tester.pumpAndSettle();
      }

      Future<void> pick(String item) async {
        await tester.ensureVisible(find.text(item).last);
        await tester.pumpAndSettle();
        await tester.tap(find.text(item).last);
        await tester.pumpAndSettle();
      }

      // The counter's menu, then the editor and the color screen.
      await menu();
      await pick(l.edit);
      // On a small phone the editor scrolls; bring the button into view.
      await tester.ensureVisible(find.byTooltip(l.moreColors));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip(l.moreColors));
      await tester.pumpAndSettle();
      // Down to the swatch for mixing any color, then on to the patterns.
      await tester.ensureVisible(find.byTooltip(l.customColor).first);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip(l.customColor).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text(l.cancel).last);
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text(l.patternStripes),
        200,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.pumpAndSettle();
      await back();
      await tester.tap(find.text(l.cancel).last);
      await tester.pumpAndSettle();

      // A calculated counter: its editor, and each kind on the screen where
      // it is set up.
      await tester.longPress(find.text('Rounds'));
      await tester.pumpAndSettle();
      await pick(l.edit);
      await tester.ensureVisible(find.text(l.calculated));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l.calculated));
      await tester.pumpAndSettle();
      for (final kind in [
        l.formulaSum,
        l.formulaDifference,
        l.formulaPercent,
        l.formulaEvery,
      ]) {
        await tester.ensureVisible(find.text(kind));
        await tester.pumpAndSettle();
        await tester.tap(find.text(kind));
        await tester.pumpAndSettle();
        await tester.drag(find.byType(ListView).last, const Offset(0, -900));
        await tester.pumpAndSettle();
        await tester.drag(find.byType(ListView).last, const Offset(0, 900));
        await tester.pumpAndSettle();
      }
      await back();
      await tester.tap(find.text(l.cancel).last);
      await tester.pumpAndSettle();

      // History: figures, chart, calendar, a day and its entry dialog.
      await menu();
      await pick(l.history);
      await tester.scrollUntilVisible(
        find.text(l.dayYesterday),
        300,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.ensureVisible(find.text(l.dayYesterday));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l.dayYesterday));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l.addEntry));
      await tester.pumpAndSettle();
      await tester.tap(find.text(l.cancel).last);
      await tester.pumpAndSettle();
      await back();
      await back();

      // Full screen, the amount dialog, reorder and move.
      await menu();
      await pick(l.fullScreen);
      await tester.tap(find.byTooltip(l.closeFullScreen));
      await tester.pumpAndSettle();
      await menu();
      await pick(l.addAmount);
      await tester.tap(find.text(l.cancel).last);
      await tester.pumpAndSettle();
      await menu();
      await pick(l.reorderCounters);
      await back();
      await menu();
      await pick(l.moveToGroup);
      await tester.tap(find.text('Games').last);
      await tester.pumpAndSettle();

      // Groups, then Settings from top to bottom, and About.
      await tester.tap(find.byIcon(Icons.folder_outlined));
      await tester.pumpAndSettle();
      // What a new group can be, and a ready-made set added.
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await pick(l.presetMade);
      await tester.tap(find.byIcon(Icons.delete_outline).first);
      await tester.pumpAndSettle();
      // The archive, with something in it and its menu open.
      await store.archiveCounter(store.counters.counters.last);
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.archive_outlined));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(ListTile).first);
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(4, 4));
      await tester.pumpAndSettle();
      await back();
      await back();
      // Search: the prompt, then results, then nothing found.
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'pull');
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'zzz');
      await tester.pumpAndSettle();
      await back();
      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();
      // An Undo bar from earlier is still up and would lie over the buttons
      // at the bottom of the screens that follow.
      ScaffoldMessenger.of(tester.element(find.byType(ListView).last))
          .clearSnackBars();
      await tester.pumpAndSettle();
      for (final title in [
        l.dayStartsAt,
        l.weekStartsOn,
        l.quickTile,
        l.volumeKeys,
        l.theme,
        l.language,
        l.autoBackup,
        l.importFromApp,
      ]) {
        await pick(title);
        await tester.tapAt(const Offset(4, 4));
        await tester.pumpAndSettle();
      }
      // Sending: the choices with some counters picked, then the codes.
      await pick(l.sendToPhone);
      await pick(l.sendSomeCounters);
      await tester.drag(find.byType(ListView).last, const Offset(0, -900));
      await tester.pumpAndSettle();
      await tester.drag(find.byType(ListView).last, const Offset(0, 900));
      await tester.pumpAndSettle();
      await pick(l.sendEverything);
      await pick(l.shareShowCodes);
      await tester.drag(find.byType(ListView).last, const Offset(0, -900));
      await tester.pumpAndSettle();
      await pick(l.done);
      // Receiving, with a stand-in for the camera, part way through.
      ReceiveScreen.readerForTests = (onText) => Center(
        child: TextButton(
          onPressed: () => onText('CSK1:ABCD:2/9:BB8'),
          child: const Text('scan'),
        ),
      );
      addTearDown(() => ReceiveScreen.readerForTests = null);
      await pick(l.receiveFromPhone);
      await tester.tap(find.text('scan'));
      await tester.pumpAndSettle();
      await back();
      await tester.drag(find.byType(ListView).last, const Offset(0, -1200));
      await tester.pumpAndSettle();
      // An Undo bar from earlier is still up and can lie over the last rows.
      ScaffoldMessenger.of(tester.element(find.text(l.aboutCountersink)))
          .clearSnackBars();
      await tester.pumpAndSettle();
      await pick(l.aboutCountersink);
      await tester.drag(find.byType(ListView).last, const Offset(0, -800));
      await tester.pumpAndSettle();
    });
  }
}
