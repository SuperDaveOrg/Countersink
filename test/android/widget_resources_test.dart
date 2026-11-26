import 'dart:io';

import 'package:countersink/ui/language.dart';
import 'package:flutter_test/flutter_test.dart';

/// The home-screen widget is drawn by Android, without Flutter, so its few
/// words and its fonts live in Android's own resources. These keep them in
/// step with the app's.
void main() {
  const res = 'android/app/src/main/res';

  /// The strings in one widget_strings.xml, by name.
  Map<String, String> strings(String folder) {
    final text = File('$res/$folder/widget_strings.xml').readAsStringSync();
    return {
      for (final m in RegExp(
        r'<string name="(\w+)">(.*?)</string>',
        dotAll: true,
      ).allMatches(text))
        m.group(1)!: m.group(2)!,
    };
  }

  /// The places a string takes a value, such as %1$d, in order.
  List<String> slots(String text) =>
      [for (final m in RegExp(r'%\d\$[ds]').allMatches(text)) m.group(0)!]
        ..sort();

  final english = strings('values');

  test('the widget has its words in English', () {
    expect(english.keys, containsAll(['widget_choose', 'widget_add']));
    expect(english.values, everyElement(isNotEmpty));
  });

  for (final code in languageNames.keys.where((c) => c != 'en')) {
    test('the widget speaks $code, with every word and every value', () {
      final translated = strings('values-$code');
      expect(translated.keys.toSet(), english.keys.toSet());
      for (final name in english.keys) {
        expect(translated[name], isNotEmpty, reason: name);
        expect(slots(translated[name]!), slots(english[name]!), reason: name);
      }
    });
  }

  test('the widget has no language the app does not', () {
    final folders = Directory(res)
        .listSync()
        .whereType<Directory>()
        .where((d) => File('${d.path}/widget_strings.xml').existsSync())
        .map((d) => d.uri.pathSegments.lastWhere((s) => s.isNotEmpty))
        .toSet();
    expect(folders, {
      'values',
      for (final code in languageNames.keys)
        if (code != 'en') 'values-$code',
    });
  });

  test('an apostrophe is escaped, as Android needs', () {
    for (final code in languageNames.keys.where((c) => c != 'en')) {
      for (final text in strings('values-$code').values) {
        expect(
          RegExp(r"(?<!\\)'").hasMatch(text),
          isFalse,
          reason: '$code: $text',
        );
      }
    }
  });

  test('the widget uses the very same fonts as the app', () {
    for (final (asset, resource) in [
      ('assets/fonts/Fraunces.ttf', '$res/font/fraunces.ttf'),
      ('assets/fonts/Figtree.ttf', '$res/font/figtree.ttf'),
    ]) {
      expect(
        File(resource).readAsBytesSync(),
        File(asset).readAsBytesSync(),
        reason: '$resource is a copy of $asset and must stay one',
      );
    }
  });

  test('the widget is never redrawn on a timer', () {
    final info = File('$res/xml/counter_widget_info.xml').readAsStringSync();
    expect(info, contains('android:updatePeriodMillis="0"'));
  });

  test('the camera is the only permission asked for', () {
    final manifest = File('android/app/src/main/AndroidManifest.xml')
        .readAsStringSync();
    final asked = [
      for (final m in RegExp(r'<uses-permission[^>]*>').allMatches(manifest))
        if (!m.group(0)!.contains('tools:node="remove"')) m.group(0)!,
    ];
    expect(asked, hasLength(1));
    expect(asked.single, contains('android.permission.CAMERA'));
    expect(manifest, isNot(contains('INTERNET"/>')));
  });
}
