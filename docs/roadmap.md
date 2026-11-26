# Countersink — roadmap

What Countersink does, what it should do next, and what it deliberately
won't. The reasoning and evidence are in
`../reports/Tally counter app market research.md`.

## Done so far

| Feature | State |
|---|---|
| Event log: every change stored with its time | Done, tested |
| Counting days with a configurable start hour | Done, set in Settings |
| History per counter: each day's total, newest first | Done |
| Groups as tabs, counter cards with minus, number, plus | Done |
| Per-day counters showing today's total | Done |
| Add a counter (name, description, color, per-day) | Done |
| Edit a counter, keeping its history | Done, from press and hold |
| Delete a counter, with Undo instead of a confirmation | Done |
| Custom step per counter | Done |
| Type in an amount (press and hold plus or minus) | Done |
| Set the value directly; reset to zero with Undo | Done |
| Add, rename, reorder and delete groups, with Undo on delete | Done |
| Reorder counters by dragging; move a counter to another group | Done |
| Export a CSV with one row per entry | Done |
| Keep the screen on while the app is open | Done |
| Choose light or dark; the dark theme sits on true black | Done |
| Logo and launcher icon (adaptive, with a themed monochrome layer) | Done |
| A goal per counter, daily for per-day counters, marked on the card and in History | Done |
| Streaks (current and best) and a month calendar in History | Done |
| A bar chart for 7, 30 or 90 days, with a defined, tested average per day | Done |
| A day's entries: view, correct, delete with Undo, and add one that was missed | Done |
| Full-screen counting: tap anywhere, screen kept on | Done |
| Volume buttons count in full screen, with a touch lock; a held button counts once | Done |
| Seven languages, with a language choice in Settings ([translating.md](translating.md)) | Done, as first drafts |
| Archive a counter, with a list of archived ones; search across groups | Done |
| Backup to a file and restore from one ([backup-format.md](backup-format.md)) | Done |
| Automatic backup to a folder the user chooses: one file a day, seven kept | Done |
| A goal for the week, with week streaks and a choice of the week's first day | Done |
| A double buzz on every Nth count, chosen per counter | Done |
| Home-screen widget for any counter, from one cell, with plus and minus | Done |
| A quick-settings tile that adds to a chosen counter | Done |
| Calculated counters: a total, a difference, a share in percent, completed rounds | Done |
| Ready-made sets of counters, and copying a group without its counts | Done |
| A goal on a calculated counter, and a message when any goal is reached | Done |
| Release tooling as in Nexpill and Ebb: verified builds with a permission allow-list, an APK per processor type, CI, store text and an F-Droid recipe draft ([RELEASING.md](RELEASING.md)) | Done; three betas built with the release key. Building from a tag and CI are untried until the repository is on GitHub |
| Website and Send feedback in Settings, handed to the phone's browser | Done |
| What "private" means here ([privacy.md](privacy.md)) and how to report a problem (`SECURITY.md`) | Done |
| Send to and receive from another phone by QR codes, all counters or chosen ones | Done; scanning with a real camera between two phones not yet tried |
| Import from BetterCounter, Counter and Simple Counter files | Done, against files shaped by each app's code; not yet tried with one made on a phone |
| Any color for a counter, a second color to blend into, patterns | Done |
| Light and dark looks, following the phone | Done |
| Settings and About | Done |

## 1. Out of beta: on GitHub, then F-Droid

Three betas (0.1.0 to 0.2.1) were built from the working tree, before there
was a repository, and are on the website. What is left needs something only
the maintainer has.

- The repository on GitHub, with the "Protect main" ruleset and private
  vulnerability reporting switched on (the link in `SECURITY.md` needs it).
- The first release built from a tag, by [RELEASING.md](RELEASING.md), and
  published as a GitHub release. The betas have no commit to point at, so
  this is a new version.
- F-Droid: the recipe draft (`docs/fdroid/`) needs that release's version,
  codes and commit, then a run of `tool/fdroid_build_test.sh` before it is
  submitted. Its category, Habit Tracker, was checked against fdroiddata's
  list on 2026-11-26.
- Hosted Weblate, as Nexpill and Ebb have, once the repository is public;
  then the README gets its link and badge.
- Native speakers to check the six translations, which are first drafts.
- Screenshots of the widget, the quick-settings tile, sending by QR code and
  a calculated counter, for the store listing and the README.
- Still untried on real phones: scanning between two of them, and importing
  a file made by BetterCounter, Counter or Simple Counter on a phone.

## 2. Daily depth and counting without looking

Everything planned for this phase is built; see the table above.

## 3. Counting without opening the app

- A notification with +1. Undecided: from Android 13 it needs the
  notification permission, in an app that asks for none.
- On the widget, later: the card's pattern, and the goal's progress. Both
  are left to the app for now.

## 4. Linked counters and templates

- For calculated counters, later: a history of their own and a place on
  the widget. For now they show the present number only.
- Alerts, later, if wanted: a sound, or a counter that stops at its goal.
  Reaching a goal is felt and said in the app; it makes no sound and a
  count can carry on past it.

## 5. Desktop

- Linux and Windows from the same code, with keys the user assigns.

## Not planned

- Ads, accounts, cloud sync, analytics, rating prompts, or a gate on anything
  that is free.
- Counting with the screen off: Android intercepts the volume keys then.
- Material You colors. The family's clay is part of what Countersink is,
  and a counter already takes any color; the phone's wallpaper colors
  would replace the first and add nothing to the second.
