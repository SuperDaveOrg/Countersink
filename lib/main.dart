import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';

import 'package:countersink/data/counter_repository.dart';
import 'package:countersink/services/app_info.dart';
import 'package:countersink/services/preferences.dart';
import 'package:countersink/ui/app.dart';
import 'package:countersink/ui/counter_store.dart';
import 'package:countersink/ui/language.dart';
import 'package:countersink/ui/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final store = CounterStore(
    repository: CounterRepository(),
    dayStartHour: await Preferences.dayStartHour(),
    // Until one is chosen, a week begins where the phone's region says.
    weekStart:
        await Preferences.weekStart() ??
        phoneWeekStart(PlatformDispatcher.instance.locales),
  );
  await store.load();
  chosenLanguage.value = await Preferences.language();
  homeScreenTakesWidgets = await canPinWidget();
  await keepScreenOn(await Preferences.keepScreenOn());
  themeChoice.value =
      ThemeMode.values.asNameMap()[await Preferences.themeMode()] ??
      ThemeMode.system;

  // A new install opens on a counter that's ready to tap, not an empty page.
  if (store.counters.groups.isEmpty) {
    final l = stringsFor(PlatformDispatcher.instance.locales);
    final group = await store.addGroup(l.firstGroupName);
    await store.addCounter(
      groupId: group.id,
      name: l.firstCounterName,
      description: l.firstCounterDescription,
    );
  }

  runApp(CountersinkApp(store: store));
}
