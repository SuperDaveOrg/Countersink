# What "private" means in Countersink

Read this before writing code, copy or UI for this project.

## What we mean

**The data belongs to the user. We never receive it, so we cannot sell it,
share it, hand it over, lose it in a breach, or look at it ourselves.**

That is the whole claim. It is a statement about *our* obligations and *our*
architecture.

Concretely:

- Everything counted (groups, counters, every tap with its time) is written
  to a SQLite database on the device and nowhere else.
- There is no account, no login, no server, no sync and no telemetry.
- The release build ships without the `INTERNET` permission, so Android itself
  prevents the app from sending anything anywhere. The promise is enforced by
  the operating system, not by our good intentions.
- The app is open source under the GNU GPL, so anyone can check the claim.

A count looks harmless, and often is. But people count cigarettes, drinks,
symptoms, prayers and money, and a log of every tap with its time says when
someone was awake and what they were doing. Countersink doesn't know which
kind of counter it holds, so it treats them all the same way: it never
receives any of them.

## What we do NOT mean

**Countersink is not secret software.** It is not a vault, a decoy, or
something to hide from the people around the user. Counting things is
ordinary, and an app that disguises itself or locks itself by default gets in
the way of the one thing it is for: a tap, without looking, mid-count.

So Countersink does not:

- disguise its name or icon;
- default to requiring a PIN or biometric unlock;
- hide what a widget or the quick-settings tile is counting;
- frame the user as being watched or in danger.

If a design decision only makes sense under the assumption that the user is
hiding from someone, it is the wrong decision for Countersink.

## Where the line falls

| Choice | Why it's in scope |
|---|---|
| No `INTERNET` permission | The data genuinely cannot leave. The wording is always "no internet permission", never "no permissions": the camera is one. |
| `allowBackup="false"` and data extraction rules | Otherwise Android silently copies the database to the user's cloud backup, and "it stays on this phone" would be false. |
| No analytics, crash reporting, ad SDKs or remote fonts | Those are the channels that carry data to third parties. |
| Explicit, user-initiated backup and export | The user can move their own data; we never do it for them. Files go through Android's own Save picker, so they choose where. |
| Automatic backup into a folder the user picked | Still the user's choice: off until they pick a folder through Android's folder picker, and it only ever writes there. If that folder is one a cloud app syncs, that is their decision, made outside Countersink. It needs no storage permission and no background worker. |
| QR phone-to-phone transfer | Moves counters without a network: one screen, one camera. Costs `CAMERA`, the only permission Countersink asks for, requested when Receive is first opened; frames are read and discarded. |
| Importing another counter app's file | Read on the device, through Android's Open picker. Nothing is fetched. |
| Home-screen widget and quick-settings tile | They read and write the same database on the device, in the app's own process. They ask for no permission, and nothing else can count through them. |
| Links to the website | Settings → Website and Send feedback hand the address to the phone's browser, only when tapped. Countersink itself still can't use the network, and nothing from the app goes with the link. The feedback form is part of the website: only what the user types there is sent. |
| Unused plugin permissions stripped | The camera plugins merge in audio, storage and network permissions Countersink never uses. They're removed in the manifest so the permission list reads as exactly what the app does. |
| Touch feedback through Flutter's `HapticFeedback` | Needs no permission, so `VIBRATE` stays off the list. |

Out of scope unless real users ask:

| Choice | Why it's out |
|---|---|
| App lock / PIN by default | Offer it as an option if asked; never a default. A lock between a person and a tally is a worse tally. |
| Generic app name or icon | The app says what it is. |
| A widget that hides its counter's name or number | A widget is there to be read at a glance. |
| Encrypted-at-rest database by default | Adds a passphrase prompt for little gain on a locked phone, and the widget and tile would have to hold the key anyway. |
| A notification with +1 | Undecided, for a different reason: it would need the notification permission (see the [roadmap](roadmap.md)). |

## Tone for user-facing copy

- Plain and short. People read these words mid-count, if at all.
- The privacy message is a reassurance, not a warning. "Your counts stay on
  your phone," not "protect your data".
- Say "no internet permission" and say how to check it. A claim the reader
  can verify in the app's permission list is worth more than an adjective.
- Never guess why someone is counting, and never comment on the number.
- Countersink is offered for its own sake, as a free alternative among the
  counters that exist. It is not out to replace any of them; don't word it
  that way.

## The honest trade-off

**If the phone is lost, so are the counts**, unless a backup was saved. There
is no cloud copy, because a cloud copy is what we promised not to keep. The
mitigation is a backup the user starts: a file saved where they like,
automatic backup into a folder they chose, or a transfer to another phone.
The app says so plainly, in About.

The same choice means two phones don't sync. Counters can be sent from one to
the other, and what arrives is added, never merged into a shared count.
