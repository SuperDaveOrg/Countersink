import 'package:flutter/services.dart';

/// The installed version as "0.1.0 (100)", read from Android via
/// MainActivity. Null where there's no Android side (tests, desktop).
Future<String?> installedVersion() async {
  try {
    final info = await const MethodChannel('countersink/app')
        .invokeMapMethod<String, Object?>('version');
    if (info == null) return null;
    return '${info['name']} (${info['code']})';
  } on MissingPluginException {
    return null;
  } on PlatformException {
    return null;
  }
}

/// Countersink's website and its feedback form.
///
/// Countersink has no internet permission, so it never loads these itself:
/// it hands the address to the phone's browser, and only when someone taps
/// the row in Settings.
const String websiteUrl = 'https://countersink.superdavelab.com/';
const String feedbackUrl = 'https://countersink.superdavelab.com/#feedback';
const String websiteLabel = 'countersink.superdavelab.com';

/// Opens [url] in the phone's browser. False if nothing could open it, or
/// where there's no Android side.
Future<bool> openInBrowser(String url) async {
  try {
    return await const MethodChannel('countersink/app')
            .invokeMethod<bool>('openLink', url) ??
        false;
  } on MissingPluginException {
    return false;
  } on PlatformException {
    return false;
  }
}

/// Keeps the screen from dimming and locking while Countersink is in front,
/// or lets it again. Does nothing where there's no Android side.
Future<void> keepScreenOn(bool on) async {
  try {
    await const MethodChannel('countersink/app')
        .invokeMethod<void>('keepScreenOn', on);
  } on MissingPluginException {
    // Tests and desktop: no screen to keep on.
  } on PlatformException {
    // Not worth stopping the app over.
  }
}

/// Redraws the home-screen widgets, after counts made in the app. Does
/// nothing where there's no Android side.
Future<void> refreshWidgets() async {
  try {
    await const MethodChannel('countersink/app')
        .invokeMethod<void>('refreshWidgets');
  } on MissingPluginException {
    // Tests and desktop: no home screen.
  } on PlatformException {
    // A widget left out of date is not worth stopping the app over.
  }
}

/// Whether a home-screen widget has counted since this was last asked.
/// Asking clears it.
Future<bool> takeWidgetCounts() async {
  try {
    return await const MethodChannel('countersink/app')
            .invokeMethod<bool>('takeWidgetCounts') ??
        false;
  } on MissingPluginException {
    return false;
  } on PlatformException {
    return false;
  }
}

/// Whether the phone's home screen can be asked to add a widget, as found
/// out when the app started. A counter's menu offers it only then, and
/// reads this rather than asking, so the menu opens without a wait.
bool homeScreenTakesWidgets = false;

/// Asks Android whether the home screen can be asked to add a widget.
Future<bool> canPinWidget() async {
  try {
    return await const MethodChannel('countersink/app')
            .invokeMethod<bool>('canPinWidget') ??
        false;
  } on MissingPluginException {
    return false;
  } on PlatformException {
    return false;
  }
}

/// Asks the home screen to add a widget for the counter with [counterId].
/// The home screen shows its own confirmation; false if it couldn't be
/// asked.
Future<bool> pinWidget(String counterId) async {
  try {
    return await const MethodChannel('countersink/app')
            .invokeMethod<bool>('pinWidget', counterId) ??
        false;
  } on MissingPluginException {
    return false;
  } on PlatformException {
    return false;
  }
}

/// The id of the counter the quick-settings tile adds to, or null if none
/// is chosen or there's no Android side.
Future<String?> tileCounter() async {
  try {
    return await const MethodChannel('countersink/app')
        .invokeMethod<String>('tileCounter');
  } on MissingPluginException {
    return null;
  } on PlatformException {
    return null;
  }
}

/// Chooses the counter the quick-settings tile adds to; null turns the tile
/// off, which leaves it asking for a counter.
Future<void> setTileCounter(String? counterId) async {
  try {
    await const MethodChannel('countersink/app')
        .invokeMethod<void>('setTileCounter', counterId);
  } on MissingPluginException {
    // Tests and desktop: no quick settings.
  } on PlatformException {
    // The choice wasn't kept; the row in Settings will show as much.
  }
}

/// Asks Android to offer the tile for the phone's quick settings. True if
/// the tile is there afterwards. False if it was turned down, or on an
/// Android too old to be asked (before 13), where it is added by hand.
Future<bool> addTile() async {
  try {
    return await const MethodChannel('countersink/app')
            .invokeMethod<bool>('addTile') ??
        false;
  } on MissingPluginException {
    return false;
  } on PlatformException {
    return false;
  }
}

/// Which of the phone's volume buttons count instead of changing the volume.
enum VolumeKeys {
  /// Neither: they change the volume as usual.
  off,

  /// Volume up adds; volume down still changes the volume.
  up,

  /// Volume up adds and volume down takes away.
  both,
}

/// Asks Android to hand over the volume buttons as counts for as long as a
/// counter is in full screen, calling [onKey] with 1 for up and -1 for down.
/// A button held down counts once.
Future<void> listenForVolumeKeys(
  VolumeKeys keys,
  void Function(int direction) onKey,
) async {
  const channel = MethodChannel('countersink/app');
  channel.setMethodCallHandler((call) async {
    if (call.method == 'volumeKey') onKey(call.arguments as int);
  });
  await _setVolumeMode(keys.index);
}

/// Gives the volume buttons back to the volume.
Future<void> stopListeningForVolumeKeys() async {
  const MethodChannel('countersink/app').setMethodCallHandler(null);
  await _setVolumeMode(0);
}

Future<void> _setVolumeMode(int mode) async {
  try {
    await const MethodChannel('countersink/app')
        .invokeMethod<void>('volumeKeys', mode);
  } on MissingPluginException {
    // Tests and desktop: no volume buttons.
  } on PlatformException {
    // Not worth stopping the app over.
  }
}
