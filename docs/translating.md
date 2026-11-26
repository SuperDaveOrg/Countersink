# Translating Countersink

Countersink speaks English, German, Spanish, French, Italian, Portuguese
(Portugal) and Russian: the same languages as Ebb and Nexpill. This is how
the words are kept, how to add a language, and what a translation has to get
right.

Every language but English is a first draft that no native speaker has
checked yet.

## Where the words are

Every word the app shows is in `lib/l10n/app_<language>.arb`: plain JSON,
one message per key. `app_en.arb` is the template; each other file
translates every one of its keys. Flutter's `gen-l10n` (set up in
`l10n.yaml`, run by any `flutter` build or `flutter gen-l10n`) turns them
into `AppLocalizations` in `lib/l10n/`.

Screens use `context.l` (from `lib/ui/language.dart`), so they rebuild when
the language changes. The one place with no screen to ask, naming the first
counter on a new install, uses `stringsFor`.

The one exception is the home-screen widget and the quick-settings tile,
which Android draws without Flutter. Their few strings are Android
resources:
`android/app/src/main/res/values/widget_strings.xml` in English and
`values-<code>/widget_strings.xml` for each other language. A test
(`test/android/widget_resources_test.dart`) checks that every language has
all of them, with the same `%1$d` and `%2$s` places, and that apostrophes
are written `\'`, as Android needs.

The language follows the phone unless one is picked in Settings → Language.
A phone set to a language Countersink doesn't speak gets English. On Android
13 and later the language can also be set per app in the phone's settings,
from `android/app/src/main/res/xml/locales_config.xml`.

Not translated, on purpose: the brand name, the backup file's field names
and the spreadsheet's column names (they're public formats), file names, the
technical detail shown when a backup is damaged, and anything the user typed.

## What a translation has to get right

`flutter test test/l10n test/ui/languages_fit_test.dart` checks all of this.

- **Every key, and no extra ones.** `gen-l10n` quietly fills a gap with
  English, which is exactly what the test is there to refuse.
- **The same blanks.** A message with `{name}` or `{count}` in English has
  them in every language.
- **Plurals that show the right number.** Each language's plural rule
  decides which form a count gets, and they differ: French puts 0 with 1,
  Russian puts 21 with 1. So a form written for one must still show its
  number (`one{{count} compteur}`, not `=1{1 compteur}`), unless the message
  has a form for exactly that count (`=0{Aucun compteur}`). Russian needs
  `one`, `few`, `many` and `other`.
- **Words that fit.** The walk-through test opens every main screen in each
  language on a small phone and fails if anything runs off its edge.
- **Wording that doesn't depend on a name's gender.** A counter or group can
  be called anything, so "Deleted {name}" is written to work for any name
  ("Supprimé : {name}").
- **The register the family uses:** informal in German, Spanish and Italian;
  formal in French, Portuguese and Russian.

## Adding a language

1. Add `lib/l10n/app_<code>.arb` with every key translated.
2. Add its own name to `languageNames` in `lib/ui/language.dart`.
3. Add it to `android/app/src/main/res/xml/locales_config.xml`.
4. Add `android/app/src/main/res/values-<code>/widget_strings.xml`, for the
   home-screen widget and the quick-settings tile.
5. Run the tests above.
