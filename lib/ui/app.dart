import 'package:flutter/material.dart';

import 'package:countersink/l10n/app_localizations.dart';
import 'package:countersink/services/app_info.dart';
import 'package:countersink/services/auto_backup.dart';
import 'package:countersink/ui/counter_store.dart';
import 'package:countersink/ui/counters_screen.dart';
import 'package:countersink/ui/language.dart';
import 'package:countersink/ui/theme.dart';

/// The app: the family look, light or dark as chosen in Settings, and the
/// counters kept fresh.
class CountersinkApp extends StatefulWidget {
  const CountersinkApp({super.key, required this.store});

  final CounterStore store;

  @override
  State<CountersinkApp> createState() => _CountersinkAppState();
}

class _CountersinkAppState extends State<CountersinkApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Coming back, a new day may have begun while the app was away, and a
  /// home-screen widget may have counted. Going away is when an automatic
  /// backup is written, if one is set up and anything has changed, and when
  /// the widgets are redrawn to match what was done here.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      widget.store.load();
      takeWidgetCounts().then((counted) {
        if (counted) widget.store.markChanged();
      });
    }
    if (state == AppLifecycleState.paused) {
      AutoBackup().run(widget.store);
      refreshWidgets();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([themeChoice, chosenLanguage]),
      builder: (context, _) {
        final choice = themeChoice.value;
        final chosen = chosenLanguage.value;
        return MaterialApp(
          title: 'Countersink',
          debugShowCheckedModeBanner: false,
          theme: CountersinkTheme.light(),
          darkTheme: CountersinkTheme.dark(),
          // System follows the phone's own light or dark setting.
          themeMode: choice,
          // Null follows the phone, among the languages Countersink speaks;
          // a phone set to none of them gets English, not whichever language
          // happens to be listed first.
          locale: chosen == null ? null : Locale(chosen),
          // Works out the phone's language only, never the chosen one:
          // Flutter keeps this answer for as long as the phone's languages
          // don't change, so a chosen language mixed in here would outlive
          // the choice.
          localeListResolutionCallback: (preferred, _) =>
              resolveLanguage(null, preferred ?? const []),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: CountersScreen(store: widget.store),
        );
      },
    );
  }
}
