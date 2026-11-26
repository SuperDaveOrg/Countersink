# Countersink backup format

A Countersink backup is a UTF-8 JSON file holding everything on the phone:
the groups, their counters, and every change ever made to each count. This
document is the contract; `lib/data/backup.dart` is one implementation of it.
The format is public on purpose, so no one is locked in to Countersink.

A file is written only when the user asks, and goes wherever they choose
through Android's Save picker. Restoring **replaces** everything on the phone,
in one step: a file with a problem anywhere is refused whole.

## Versioning

`countersinkBackup` is the format version, currently **1**. Adding an optional
field doesn't change it. Changing what a field means, or adding a required
one, needs a new version, a section here, and a reader that still accepts the
old versions. Countersink refuses a file whose version it doesn't know.

An optional field that older versions of Countersink would silently drop,
where dropping it would change a count, also gets a new version, so an older
app refuses the file instead of half-restoring it.

## Example

```json
{
  "countersinkBackup": 1,
  "exportedAt": "2026-11-22T20:30:00.000Z",
  "dayStartHour": 4,
  "weekStartsOn": 1,
  "groups": [
    {
      "id": "5b0d…",
      "name": "Fitness",
      "counters": [
        {
          "id": "a41c…",
          "name": "Pull-ups",
          "description": "Strict, full hang",
          "color": "#C4613F",
          "color2": "#2F5A45",
          "pattern": "stripes",
          "step": 1,
          "goal": 300,
          "goalPeriod": "week",
          "buzzEvery": 10,
          "perDay": true,
          "events": [
            {"id": "0c7e…", "at": "2026-11-22T14:02:11.000Z", "change": 8, "kind": "tap"},
            {"id": "91fa…", "at": "2026-11-22T18:40:03.000Z", "change": 6, "kind": "tap"}
          ]
        }
      ]
    }
  ]
}
```

## Fields

### The file

| Field | | |
|---|---|---|
| `countersinkBackup` | required | The format version, a whole number. Its presence is what marks the file as a Countersink backup. |
| `exportedAt` | optional | When the file was written. Informational; ignored on restore. |
| `dayStartHour` | optional | The hour a counting day begins, 0 to 11; 0 is midnight. An event before this hour counts toward the day before. Without it, a restore leaves the phone's own setting alone. |
| `weekStartsOn` | optional | The day a week begins on, 1 for Monday through 7 for Sunday. It decides which days a goal for the week adds up. Without it, a restore leaves the phone's own setting alone. |
| `groups` | required | The groups, in tab order. May be empty. |

### A group

| Field | | |
|---|---|---|
| `id` | required | Unique in the file. |
| `name` | required | Not empty. |
| `counters` | required | The group's counters, in the order they are shown. May be empty. |

### A counter

| Field | | |
|---|---|---|
| `id` | required | Unique in the file. |
| `name` | required | Not empty. |
| `description` | optional | Free text. |
| `color` | required | The card's color, `#RRGGBB`. |
| `color2` | optional | A second color the first blends into, corner to corner, `#RRGGBB`. |
| `pattern` | optional | Drawn over the color: `none` (the default), `stripes`, `dots` or `grid`. |
| `step` | optional | How much one press of plus or minus changes the count; a whole number of 1 or more. 1 if absent. |
| `goal` | optional | A number to reach; a whole number of 1 or more. For a `perDay` counter it is each day's goal, or the week's if `goalPeriod` says so. |
| `goalPeriod` | optional | What a `perDay` counter's goal is for: `day` (the default) or `week`. It means nothing on a counter that isn't `perDay`. |
| `buzzEvery` | optional | A whole number of 1 or more: the phone gives a double buzz each time the number on the card passes a multiple of it. No buzz if absent. |
| `formula` | optional | Makes this a calculated counter, worked out from others instead of counted: `sum` (all of `of` added up), `difference` (the first of `of`, less the rest), `percent` (the first as a share of all of them together, in whole percent) or `every` (how many whole rounds of `roundSize` the first holds). Absent for an ordinary counter. |
| `of` | optional | For a calculated counter, the `id`s of the counters it is worked out from, in order. Each must be another counter in the file. |
| `roundSize` | optional | For `every`, how many make a round; a whole number of 1 or more. |
| `allTime` | optional | For a calculated counter, `true` to keep a running total: a `perDay` counter in `of` counts for all of its events, not only the current day's. `false` if absent. |
| `startFrom` | optional | For a `sum`, a number the total already stood at, added to what the counters in `of` come to; a whole number of 1 or more. Nothing if absent. |
| `perDay` | optional | `true` for a counter that shows the current day's total and starts from zero each day. `false` if absent. |
| `archived` | optional | `true` for a counter put away off its group's tab. `false` if absent. |
| `events` | optional | Every change to the count, in any order. |

A counter holds no number of its own. **Its value is the sum of its events'
`change`**; for a `perDay` counter, the sum of those that fall in the current
counting day.

A calculated counter's value comes from the values of the counters in `of`,
each as its own card shows it (so the current day's, for a `perDay` one),
unless `allTime` is `true`: then a `perDay` counter counts for the sum of
all its events, so the calculated counter carries on while that one starts
each day from zero.
Countersink ignores any events a calculated counter has, but keeps them: they
are its count from before it was made calculated, and come back if it is
made ordinary again.

### An event

| Field | | |
|---|---|---|
| `id` | required | Unique in the file. |
| `at` | required | The instant it happened, ISO 8601 **with an offset** (`Z` or `+01:00`). A bare local time is refused: it would mean different moments on different phones. |
| `change` | required | How much the count changed, a whole number; negative to take away. |
| `kind` | optional | Why: `tap` (the default; a press of plus or minus, or an amount typed in), `set` (the value was typed in directly, and `change` is the difference) or `reset` (back to zero, and `change` cancels what was there). |

Ids are unique across the whole file, whatever they belong to. Countersink
writes random UUIDs.

## What a restore refuses

- Anything that isn't JSON, or has no `countersinkBackup`.
- A version newer than the app knows.
- A required field that is missing, empty or the wrong kind of value.
- An id used twice.
- A calculated counter whose `of` names something that isn't another
  counter in the file.
- A color that isn't `#RRGGBB`, a pattern, kind, formula or goal period it
  doesn't know, a time without an offset, a step, goal, buzz or starting number below 1, a day-start
  hour outside 0 to 11, a week's first day outside 1 to 7.

Nothing on the phone changes when a file is refused.

## Sent between phones

"Send to another phone" shows a file in this same format as a series of QR
codes, holding whichever counters were chosen. The file is gzipped and cut
into frames of plain text in the QR alphanumeric set:

```
CSK1:K7Q2:3/6:<Base45 chunk>
```

`CSK1` is the frame format, `K7Q2` tells one send from another so their
frames never mix, and `3/6` is the frame's place. Frames can be read in any
order; gzip's own check catches a misread. To keep the codes few, the ids in
a file sent this way are short ones (`g0`, `c0`, and a count for each event)
made up for the occasion, and the phone's own settings are left out. The
phone receiving gives everything new ids and adds it beside what it has.
