# Security and privacy reports

Countersink's core promise is simple: **your counts stay on your device.** It
has no account and no server, and release builds can't use the internet. If
you find something that breaks that promise, or any other security problem,
please tell us privately first.

## How to report

Use GitHub's private form: **[Report a vulnerability](https://github.com/SuperDaveOrg/Countersink/security/advisories/new)**
(Security tab → *Report a vulnerability*). Only the maintainers can see it.

Please don't open a public issue for these until there's a fix.

Helpful to include:

- the Countersink version (shown at the bottom of Settings) and your Android
  version;
- what you did, what you expected, and what happened;
- anything that shows the problem, ideally with made-up counters rather than
  your own.

You'll get a reply within a week. Fixes ship as a new release, and the report
is credited in the release notes unless you'd rather it wasn't.

## What counts

Anything that could let counts leave the device, or be read by someone or
something it shouldn't, for example:

- a release build that can reach the network, or that asks for any permission
  other than the camera;
- the camera being used for anything but reading QR codes while receiving
  from another phone;
- data ending up in Android's cloud backup or device-to-device transfer;
- another app being able to read Countersink's data, or to count through the
  home-screen widget or the quick-settings tile;
- a crafted backup file, import file or QR code that crashes Countersink,
  corrupts data, or does more than add the counters it describes;
- automatic backup writing outside the folder that was chosen, or deleting a
  file it didn't write itself;
- a published APK that isn't signed by SuperDaveLab or doesn't match its
  published SHA-256.

Not in scope: someone who already has your unlocked phone opening the app, or
reading a backup file you saved somewhere they can reach. Countersink is an
ordinary app, not a vault; see [docs/privacy.md](docs/privacy.md) for why.

## Supported versions

Only the latest release gets fixes. Download it from
[countersink.superdavelab.com](https://countersink.superdavelab.com/).
