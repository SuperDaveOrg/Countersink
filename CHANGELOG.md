# Changelog

What changed in each release of Countersink, newest first. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

New entries go under **Unreleased** as work lands.

## [Unreleased]

### Added
- Website and Send feedback in Settings. Each hands the address to the
  phone's browser when tapped; Countersink still has no internet permission.

## [0.2.1] - 2026-11-24

### Fixed
- Switching a counter to "Count per day" could show a number below zero,
  when a day in its history took away more than it counted. The editor now
  keeps the switch off and says why; correcting that day in History lets it
  be switched.

## [0.2.0] - 2026-11-24

### Added
- "Keep a running total" on a calculated counter, offered when one of its
  counters counts per day: that counter then counts for everything it has
  ever counted, not just today, so the calculated one carries on while it
  starts each day from zero. Off, it follows the numbers on the cards, as
  before.
- "Start from" on a running total: a number it already stood at before it
  was counted here, which everything counted is added to.

## [0.1.0] - 2026-11-23

### Added
- Counters in groups, each group a tab. A counter is a coloured card with
  minus on the left, plus on the right, and its name, number and description
  between them.
- Every tap is saved with its time; a counter's value is the sum of its taps.
- Counters that count per day: they show today's total and start from zero
  each day, with past days kept.
- Add a counter with a name, an optional description, a colour and the
  per-day switch.
- Press and hold a counter to edit or delete it. Editing keeps its history.
  Deleting offers Undo, which brings the counter back with every tap it had.
- A step for each counter, so one press can count by 5 or by 10. Minus never
  takes a count below zero.
- Press and hold plus to type in an amount, a whole set at once; press and
  hold minus to take an amount away. Also in the counter's menu as "Add an
  amount".
- "Set value" and "Reset to zero" in the counter's menu. Both are saved as
  events, so the history keeps what was there, and a reset offers Undo.
- History for each counter, from its menu: every day that has a count, newest
  first, with the day's total and how many entries made it up.
- "Day starts at" in Settings, from midnight to 11 in the morning. Anything
  counted before that hour belongs to the day before, so a late set still
  counts toward the evening it was done.
- Back up to a file and restore from one, in Settings, through Android's own
  Save and Open pickers. The file is plain JSON in a documented format and
  holds everything, the day-start hour included. A restore checks the whole
  file first and says what it holds before replacing anything.
- Twenty named colours for counters, any other colour mixed by hand (hue,
  saturation, brightness or a hex code), a second colour to blend into, and
  three patterns: stripes, dots and a grid.
- "Reorder counters" in a counter's menu opens the group's counters as a
  list to drag into order. "Move to another group" takes a counter, with its
  history, to the end of another tab.
- "Export as a spreadsheet" in Settings: a CSV with one row per entry, with
  its group, counter, local time, counting day, change and kind.
- "Keep the screen on" in Settings, for counting without the phone dimming
  or locking. It applies only while Countersink is open.
- A theme choice in Settings: same as the phone, light or dark. The dark
  theme sits on true black.
- A logo and launcher icon: five tally marks, four upright and a clay
  stroke across them.
- A goal for a counter: a number to reach, each day for a per-day counter.
  The card shows how far along it is and marks the goal when reached, with
  a longer buzz on the tap that gets there. History marks the days that met
  it.
- Streaks in a counter's History: the run of days still going and the
  longest ever. A day counts when its goal was met, or, with no goal, when
  anything was counted. Today not being done yet doesn't break a streak.
- A month calendar in History, each day showing its total, tinted when
  something was counted and filled when the goal was met. The arrows step
  back through earlier months.
- A chart in History for the last 7, 30 or 90 days: a bar a day, the total
  and the average per day, with the goal drawn across as a line. The average
  counts a day with nothing as zero, but doesn't count the time before the
  counter was first used.
- Tap a day in History, in the list or on the calendar, to see its entries
  with their times. Tap an entry to correct its amount or time, or to delete
  it (with Undo). "Add entry" puts in a count that was missed, on that day.
  A change that would take a count below zero is refused.
- "Full screen" in a counter's menu: the counter fills the screen, a tap
  anywhere counts, and a press and hold anywhere asks for an amount. Minus
  and Close are small and in the corners. The screen stays on while it is
  open.
- Count with the phone's volume buttons in full screen: volume up adds, and
  optionally volume down takes away. Chosen in Settings and off by default.
  While it is on the buttons don't change the volume, a button held down
  counts once, and a lock in the corner turns touch off so that only the
  buttons count. Press and hold the lock to turn touch back on.
- German, Spanish, French, Italian, Portuguese (Portugal) and Russian, the
  same languages as Ebb and Nexpill, with a language choice in Settings.
  All are first drafts that no native speaker has checked yet.
- Archive a counter from its menu: it leaves its tab but keeps its history,
  with Undo. Archived counters are listed from the Groups screen, where each
  can be looked back over, moved back to its group, or deleted.
- Search, from the home screen: finds counters in any group by name,
  description or group, and shows them as their own cards, ready to count.
- "Automatic backup" in Settings: choose a folder, and Countersink saves a
  backup there each time you leave the app, if anything has changed. One
  file a day, the last seven days kept; other files in the folder are left
  alone. Settings says so if a backup couldn't be saved. Off by default, and
  it needs no permission beyond the folder you pick.
- A goal for the week: a counter that counts per day can aim for each day
  or for the week as a whole. The card still shows today's number, with the
  week so far against the goal beneath it, and the longer buzz comes on the
  count that brings the week there. History counts weeks in a row and fills
  in the days of the weeks that made it.
- "Week starts on" in Settings: Saturday, Sunday or Monday, for weekly goals
  and the calendar. Until one is chosen it follows the phone's region.
- "Buzz every" for a counter: a double buzz each time the count passes a
  multiple of a number you choose, such as every 10, so sets can be counted
  without looking. It uses the phone's touch feedback and needs no
  permission.
- A home-screen widget for any counter, in the counter's own colours, with
  minus and plus that count without opening the app. "Add to home screen" in
  a counter's menu puts one there; it can also be added from the phone's
  widget list, which asks which counter. It resizes from one cell up, a
  per-day counter starts from zero when the day turns over, and a touch on
  the name or number opens the app. It needs no permission.
- A tile for the phone's quick settings that adds to one counter, chosen in
  Settings under "Quick settings tile". It shows the counter's name and
  number, and a press adds the counter's step without opening the app. On
  Android 13 and later the app offers to add the tile; on earlier versions
  it says how to add it by hand. It needs no permission.
- Calculated counters: a counter can show a number worked out from other
  counters instead of being counted on. A total of several, a difference
  (in, less out), a share in percent, or the completed rounds of another
  counter (every 108 beads, every 8 rows) with how far along the next one
  is. Set up from "Calculated from other counters" in the editor. Its card
  has no plus or minus and keeps up as the counters it is made of change;
  deleting one of those offers Undo as ever, which mends it.
- Ready-made sets: "Add group" now offers an empty group or a set that
  brings its counters with it. Rows and repeats, beads in rounds of 108, in
  and out, a scoreboard, and made and missed. Each is made of ordinary and
  calculated counters, so every part can be renamed or changed afterwards.
- Copy a group, from the Groups screen: the same counters with their looks
  and settings and none of their counts, for the next game or the next
  piece of work.
- "Import from another app" in Settings: counters from BetterCounter,
  Counter or Simple Counter files, added as new groups beside what is
  there, with Undo. BetterCounter's file brings the time of every count;
  the other two keep only each counter's number, which comes in as one
  entry. Simple Counter's labels become groups. A count below zero comes in
  as zero.
- A calculated counter can have a goal, with its bar and its mark on the
  card like any other: a total to get to, or how many may be inside.
- A message when a goal is reached, with the longer buzz: "Pull-ups has
  reached 50". It names every counter the count brings to its goal, so a
  calculated counter on another tab that reaches its goal is noticed too.
- Send to another phone, and receive from one, by QR codes: one phone
  shows a series of codes and the other scans them, in any order. Send
  everything or just the counters you choose, with their history or with
  only their numbers, which takes far fewer codes. What arrives is added as
  new groups, with Undo. Nothing goes over a network. Receiving uses the
  camera, the one permission Countersink asks for, and asks only then; a
  saved screenshot of a code can be read instead.
- A Groups screen, from the folder button on the home screen: add a group,
  tap one to rename it, drag it by its handle to reorder the tabs, or delete
  it. Deleting a group offers Undo, which brings back its counters and their
  history. The last group can't be deleted.
- Light and dark looks in the SuperDaveLab family style, following the phone.
- Settings and About screens.
