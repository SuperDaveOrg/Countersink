# Countersink — working notes for Claude

A tally counter that keeps count of anything, kept on the phone. Flutter,
Android-only, GPL-3.0-or-later. Structured like `../nexpill` and `../ebb`,
which are the reference for anything not yet built here. The landing page is `site/`, built by `tool/deploy_site.sh`
into `dist/site/`; its screenshots are the store listing's, in
`fastlane/metadata/android/en-US/images/phoneScreenshots/`.

Privacy means *we never receive the data*. It does not mean the app hides
from the people around the user: no disguised names or icons, no PIN by
default. [docs/privacy.md](docs/privacy.md) has the whole of it.

## Architecture

| Layer | Location | Notes |
|---|---|---|
| Streaks | `lib/domain/streaks.dart` | Runs of days in a row, from the day summaries. Pure. A day isn't missed until it's over. |
| Search | `lib/domain/search.dart` | Which counters a query finds. Pure. |
| Averages | `lib/domain/averages.dart` | The per-day average over a window. Pure. An empty day is a zero; the time before a counter's first use isn't counted against it. Change that definition only on purpose, with its tests. |
| Formulas | `lib/domain/formulas.dart` | What a calculated counter comes to, from the numbers on other cards. Pure. |
| Days | `lib/domain/dates.dart` | A tap is an *instant*; the day it counts toward is a *local calendar day* that starts at a configurable hour. Keep them apart. A week is seven of those days from a configurable first day (`weekOf`). Pure, no I/O. |
| Models | `lib/models/` | `CounterGroup` (a tab), `Counter`, `TapEvent`, `CountersSnapshot`. Own their SQLite row mapping. |
| Exports | `lib/export/` | The CSV of every entry. Pure, no Flutter. |
| Storage | `lib/data/` | sqflite. `CountersinkDatabase` owns schema/migrations; `CounterRepository` owns queries. `backup.dart` reads and writes the backup file, with no Flutter in it. |
| Transfer | `lib/data/qr_transfer.dart`, `lib/ui/send_screen.dart`, `lib/ui/receive_screen.dart` | Counters sent between phones as QR codes: a backup of what was chosen, gzipped, Base45, in `CSK1:` frames. Ebb's scheme under another name; keep the two in step. What arrives is added like an import (`importBackup`), never put in place of what is there. |
| Importers | `lib/data/importers.dart` | Reads BetterCounter, Counter and Simple Counter files into new groups. Pure, no Flutter. Each format was read from that app's source, linked in the file; check there before changing one. An import only ever adds, so it happens at once with Undo. |
| Services | `lib/services/` | The installed version, the Website and Send feedback links handed to the browser (`openInBrowser`), and Android's Save, Open and folder pickers (`DocumentService`), all over method channels in `MainActivity.kt`, so no plugin can merge a permission in; `AutoBackup` writes the day's backup file into the chosen folder; `Preferences` (shared_preferences) for settings: the day-start hour, keep-screen-on, the theme. Never counts: those live in the database. |
| Widget and tile | `android/…/CounterWidget.kt`, `CounterTileService.kt`, `WidgetStore.kt`, `WidgetConfigActivity.kt` | The home-screen widget and the quick-settings tile, in plain Kotlin on Android's own classes: no Glance, no library. They read and write the app's SQLite file themselves (`WidgetStore`), so they work without Flutter running. Their few words are in `res/values*/widget_strings.xml`. |
| UI | `lib/ui/` | Material 3, `StatefulWidget` + one `CounterStore` (a plain `ChangeNotifier`); every edit goes through `CounterStore.change`. |

## Invariants

- **A counter stores no number. Its value is the sum of its events.** Every
  change (a tap, a typed value, a reset) is one row in `events` with its
  time. History, daily totals, undo, charts and exports all read that log, so
  never add a "current value" column or change a count without an event.
- A calculated counter (`Counter.formula`) follows from that: it has no
  events and nothing is ever written for it. Its number is worked out on the
  spot from the cards of the counters in `sources`
  (`CountersSnapshot.valueOf`), so it cannot drift from them. With "Keep a
  running total" on (`Counter.allTime`) a per-day source counts for every
  day it has counted, not just today: the same sum of events over a wider
  window, still nothing stored. Such a total may also "start from" a
  number (`Counter.startFrom`): a constant of the formula, like the round
  size, never an event. Never "feed"
  one counter into another by writing events. Its sources are ordinary
  counters only, which is what rules out a loop; a source that has been
  deleted stays in the list, so Undo mends it, and is skipped. Anything that
  counts must refuse a calculated counter: the store does, and so does
  `WidgetStore.kt`, which leaves them out of the widget and the tile.
- A ready-made set (`lib/ui/presets.dart`) is only a pattern for ordinary
  and calculated counters, copied into a new group
  (`CounterStore.addGroupWith`, which copying a group uses too). There is no
  "template" kept anywhere and nothing a set can do that a person couldn't
  build by hand; keep it that way, so a set never needs its own storage or
  its own rules.
- The camera is the only permission Countersink asks for, and only for
  receiving from another phone by QR code; Android asks when that screen is
  first opened. Don't add another, and don't use the camera for anything
  else. The plugins that bring it (`flutter_zxing`, and through it `camera`
  and `image_picker`) declare audio and storage too, which the manifest
  strips. Wording everywhere says "no internet permission", never "no
  permissions".
- **Never add `INTERNET` to `android/app/src/main/AndroidManifest.xml`.**
  Flutter puts it in the debug/profile manifests only, so release builds
  cannot use the network. When adding a dependency, check it doesn't merge
  the permission back in: `flutter build apk --release && aapt dump
  permissions <apk>`.
- Free and open source, permanently: no ads, paid tier, premium features or
  donation nags. Nothing that is free is ever gated later. The app is offered
  for its own sake, as a high-quality free alternative among the counters
  that exist. It is not out to replace any of them, so never word it that
  way in copy, docs or store listings.
- No analytics, crash reporting, ad SDKs, or remote fonts. Ever.
- Keep `allowBackup="false"` and the data extraction rules.
- F-Droid compliant: every dependency, including transitive Android ones,
  must be open source — no Play services, Firebase or ML Kit. Strip unused
  plugin permissions with `tools:node="remove"` in the main manifest.
- Once a version ships, a new migration never edits a shipped one.
- The plus and minus buttons never move between versions; people count
  without looking. A left-handed flip is a setting, not a redesign.
- A plain tap on a card only ever counts. Everything else about a counter
  opens from press and hold, so a stray touch mid-count can't open a dialog:
  on plus or minus it asks for an amount, anywhere else it opens the menu.
- Full screen (`lib/ui/focus_screen.dart`) does not hide the system bars:
  doing so makes Android show its own "Viewing full screen" panel over the
  count. Anything on that screen that is switched off must still swallow its
  tap, or the tap falls through and counts.
- The volume buttons count only in full screen, where there is one counter
  they can mean, and only when the setting is on. `MainActivity` swallows
  them there (`dispatchKeyEvent`) and hands each first press to Dart; the
  mode must go back to 0 when full screen closes, or the volume stops
  working for the rest of the app.
- The widget's and the tile's few words are the exception to the next rule: they are in
  `res/values*/widget_strings.xml`, in the same seven languages.
- Every word on screen comes from `lib/l10n/app_en.arb` and is translated in
  the six other `.arb` files in the same change: German, Spanish, French,
  Italian, Portuguese (Portugal), Russian, as in Ebb and Nexpill. Read
  [docs/translating.md](docs/translating.md) first; the plural rules there
  are easy to get wrong. A screen test that finds a button by its words
  breaks in another language, so find by icon where the language varies.
- A counter's menu and everything it does live in
  `lib/ui/counter_actions.dart`; a card that counts is a `LiveCounterCard`.
  Use those wherever a counter is shown, so it behaves the same everywhere.
- An archived counter stays in `CountersSnapshot.counters`. `inGroup` is
  what a tab shows (not archived); `allInGroup` is everything the group
  owns, and is what deleting a group and placing a new counter must use.
- A count never goes below zero; taking away stops there. Correcting,
  deleting or adding a past entry is refused if it would leave a count below
  zero: the whole total for an ordinary counter, any one day's for a per-day
  counter (`CounterStore._belowZero`). Switching a counter to per day is
  refused the same way (`CounterStore.canCountPerDay`), in the editor,
  which says why.
- An entry can be corrected in place: its amount and time may change, its
  kind and counter may not. Moving it to another day is done by deleting it
  and adding one there.
- A message with an Undo button must say `persist: false`. Flutter now keeps
  any snack bar that has an action on screen until it is dismissed; without
  that line the Undo bar never leaves. A test counts them.
- Destructive actions happen at once and offer Undo; they don't ask first.
  The one exception is restoring a backup, which first says what the file
  holds.
- Backup files are a public format ([docs/backup-format.md](docs/backup-format.md)).
  Changing a field's meaning needs a new `countersinkBackup` version and an
  update to that doc. A restore checks the whole file before touching
  anything.
- A goal is for each day, for the week (`GoalPeriod`, per-day counters
  only) or, on any other counter, a total. Ask the counter which
  (`dailyGoal`, `weeklyGoal`) and the snapshot how far along it is
  (`progressOf`); the number on the card is always `valueOf`. The week's
  first day is `CounterStore.weekStart`, which the calendar uses too: never
  the app language's convention, which would move weeks when the language
  changes.
- What a count feels like is decided in one place: `CounterStore.markOf`
  says whether it reaches a goal or passes a multiple, and `markCount`
  (`lib/ui/feel.dart`) turns that into touch feedback and, for a goal, a
  message. `CounterStore.reachedBy` works out every goal a count reaches
  *before* the count is made, the tapped counter's and those of calculated
  counters built on it, by asking the snapshot what the cards would show
  (`withAdded`). Anything that counts from a screen goes through
  `markCount` first; the widget and the tile have no screen to say it on. It goes through
  Flutter's `HapticFeedback`, which needs no permission; never add
  `VIBRATE`.
- The home-screen widget and the quick-settings tile are a second reader
  and writer of the database, outside Dart. `WidgetStore.kt` must keep to the same rules as the app: a
  count is one row in `events`, never below zero, a per-day counter shows
  the counting day that starts at the day-start hour. A migration that
  changes `events`, or a column of `counters` the widget reads (`name`,
  `color`, `color2`, `step`, `daily`, `archived`, `formula`), must change
  `WidgetStore.kt` in the same commit. The widget never creates or alters
  the database, and reads columns by name so it survives running against
  one the app hasn't upgraded yet.
- The quick-settings tile adds to the one counter chosen in Settings, kept
  natively beside the widgets' choices (`WidgetStore.tileCounter`), not in
  `Preferences`. Android asks it what to show each time the panel opens, so
  it holds no state and runs nothing in between. `BIND_QUICK_SETTINGS_TILE`
  on its service is a permission callers must hold, not one the app asks
  for. Try it with `adb shell cmd statusbar add-tile` and `click-tile
  com.superdavelab.countersink/.CounterTileService`.
- The widget asks for no permission and is never redrawn on a timer
  (`updatePeriodMillis="0"`): the app redraws it when it is left, a press
  redraws it, and an inexact, non-waking alarm redraws it when the day
  turns over. Nothing on it can use the app's own fonts as text, because
  the home screen draws it; the number is drawn in Fraunces as an image
  (`drawNumber`), and the copies of the fonts in `res/font` must stay
  byte-for-byte the ones in `assets/fonts` (a test checks). Widget tests
  are on a phone or emulator only: add it, count, resize to one cell,
  delete its counter.
- Automatic backup (`lib/services/auto_backup.dart`) writes when the app is
  left (`AppLifecycleState.paused` in `lib/ui/app.dart`), only if something
  changed, into a folder the user picked through Android's folder picker. It
  must stay permission-free (no storage permission, no background worker),
  must only ever delete files it named itself (`countersink-auto-…`), and a
  failure is shown in Settings, never as an interruption while counting.
- The look is the SuperDaveLab family's: Fraunces and Figtree, warm paper,
  hairline cards, settings as titled sections, an About screen of plain
  statements. Countersink leads with the family's clay; other palettes are
  added as light/dark pairs in `CountersinkTheme.looks`. Its dark theme sits
  on true black, unlike Nexpill's and Ebb's slate, and there is no setting
  for that: asked for on 2026-11-23, with the switch it replaced taken out. Card text colour
  comes from the counter's own colour (`inkOn`), not from light or dark mode.
- The clay family is the app's own look and the palette offered first. A
  counter's card may be any colour, blend into a second, and carry a pattern
  (`lib/ui/counter_look.dart`); patterns stay faint so the number is what
  reads.

## Commands

```bash
flutter test            # dates, storage and screen tests
flutter analyze         # must be clean
flutter gen-l10n        # after editing lib/l10n/*.arb
flutter test test/l10n test/ui/languages_fit_test.dart   # translations
flutter run             # debug on a connected device or emulator
tool/run_emulator.sh    # start the emulator if needed, then flutter run
                        #   (--fresh --dark --light --avd; see --help)
flutter build apk --release
dart run tool/sample_counts.dart out.json   # fictional counts, as a backup to restore
tool/deploy_site.sh --build-only            # the landing page, previewed in dist/site/
tool/bump_version.sh minor                  # set the version; see docs/RELEASING.md
tool/build_release.sh --ref vX.Y.Z          # verified, signed release APKs
tool/github_release.sh --dry-run X.Y.Z      # the same APKs as a GitHub release
tool/fdroid_build_test.sh --ref <commit>    # F-Droid's own build, locally (Docker)
```

The version lives only in `pubspec.yaml` (`NAME+CODE`, code derived from the
name: major*10000 + minor*100 + patch); change it with
`tool/bump_version.sh`, never by hand. Each APK's own version code is ten
times that plus a digit for its processor type (`android/app/build.gradle.kts`).
Record changes under "Unreleased" in `CHANGELOG.md` as they land.

The release scripts are Nexpill's and Ebb's, renamed; keep the three in
step. The permission allow-list at the top of `tool/build_release.sh` is the
enforced form of the no-`INTERNET` invariant and holds only the camera:
never widen it to make a build pass. CI
(`.github/workflows/ci.yml`) runs analyze, the tests and that check on every
push, with Flutter pinned to the version in the workflow; bump it there and
locally together. The signing key is never in the repository
([docs/RELEASING.md](docs/RELEASING.md)).

Test data is fictional only.

## Roadmap

[docs/roadmap.md](docs/roadmap.md). The market research behind it is in
`../reports/Tally counter app market research.md`.
