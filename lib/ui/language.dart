import 'package:flutter/widgets.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/date_symbols.dart';

import 'package:countersink/l10n/app_localizations.dart';

/// The language picked in Settings, as a language code; null follows the
/// phone. Loaded from Preferences at start.
final chosenLanguage = ValueNotifier<String?>(null);

/// Each language Countersink speaks, by its own name, as Settings lists it.
/// Never translated: someone looking for their language reads it in theirs.
const languageNames = {
  'de': 'Deutsch',
  'en': 'English',
  'es': 'Español',
  'fr': 'Français',
  'it': 'Italiano',
  // European Portuguese; a Brazilian phone gets it too, rather than English.
  'pt': 'Português (Portugal)',
  'ru': 'Русский',
};

/// The language Countersink will use: [chosen], or the first of the phone's
/// [preferred] languages that it speaks, or English.
Locale resolveLanguage(String? chosen, List<Locale> preferred) {
  if (chosen != null) return Locale(chosen);
  final spoken = {
    for (final l in AppLocalizations.supportedLocales) l.languageCode,
  };
  for (final l in preferred) {
    if (spoken.contains(l.languageCode)) return Locale(l.languageCode);
  }
  return const Locale('en');
}

/// The day a week begins on where the phone is set up for, as
/// [DateTime.weekday] numbers them: 1 for Monday through 7 for Sunday. It
/// goes by the first of the phone's languages and its region, so English in
/// Britain gets Monday and English in the United States gets Sunday,
/// whichever language Countersink itself is showing. Monday if the phone's
/// language isn't one that is known.
int phoneWeekStart(List<Locale> preferred) {
  final symbols = dateTimeSymbolMap();
  for (final l in preferred) {
    final region = l.countryCode;
    final found =
        (region == null ? null : symbols['${l.languageCode}_$region']) ??
        symbols[l.languageCode];
    // The table counts from Monday as 0.
    if (found is DateSymbols) return found.FIRSTDAYOFWEEK + 1;
  }
  return DateTime.monday;
}

/// The app's words in the language [resolveLanguage] gives. For the few
/// places with no widget to ask, such as naming the first counter on a new
/// install.
AppLocalizations stringsFor(List<Locale> preferred) =>
    lookupAppLocalizations(resolveLanguage(chosenLanguage.value, preferred));

extension Strings on BuildContext {
  /// The app's words, in the language on screen.
  AppLocalizations get l => AppLocalizations.of(this);
}
