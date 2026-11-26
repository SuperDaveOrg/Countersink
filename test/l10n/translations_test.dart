import 'dart:convert';
import 'dart:io';
import 'dart:ui' show Locale;

import 'package:countersink/l10n/app_localizations.dart';
import 'package:countersink/ui/language.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

/// Every language says everything English does, with the same blanks to
/// fill, and is offered everywhere Countersink lists its languages.
void main() {
  Map<String, dynamic> arb(String code) =>
      jsonDecode(File('lib/l10n/app_$code.arb').readAsStringSync())
          as Map<String, dynamic>;
  final english = arb('en');
  final keys = {
    for (final k in english.keys)
      if (!k.startsWith('@')) k,
  };
  final codes = [
    for (final l in AppLocalizations.supportedLocales) l.languageCode,
  ];

  /// The names filled in: "{count}", "{count, plural, ...}" and so on.
  Set<String> blanks(String message) => {
    for (final m in RegExp(r'\{(\w+)[,}]').allMatches(message)) m[1]!,
  };

  test('the languages are the ones Ebb and Nexpill speak', () {
    expect(codes.toSet(), {'de', 'en', 'es', 'fr', 'it', 'pt', 'ru'});
  });

  for (final code in codes.where((c) => c != 'en')) {
    group(code, () {
      final translated = arb(code);

      test('has every message, and nothing English lacks', () {
        final theirs = {
          for (final k in translated.keys)
            if (!k.startsWith('@')) k,
        };
        expect(keys.difference(theirs), isEmpty, reason: 'untranslated');
        expect(theirs.difference(keys), isEmpty, reason: 'not in English');
      });

      test('fills in the same blanks', () {
        for (final k in keys) {
          expect(
            blanks(translated[k] as String),
            blanks(english[k] as String),
            reason: k,
          );
        }
      });

      test('no message is left empty', () {
        for (final k in keys) {
          expect((translated[k] as String).trim(), isNotEmpty, reason: k);
        }
      });
    });
  }

  // Each language's plural rule decides which form a count gets, and they
  // differ: French puts 0 with 1, Russian puts 21 with 1. A form written
  // for exactly one ("1 counter", "and its counter") would then say the
  // wrong number, so any count but 1 must show its own number, unless the
  // message has a form for exactly that count.
  test('every plural shows the right number, in every language', () {
    const counts = [0, 1, 2, 3, 5, 11, 21, 22, 25, 101];
    final wrong = <String>[];
    for (final code in codes) {
      final messages = arb(code);
      for (final k in keys) {
        final plural = _plural(messages[k] as String);
        if (plural == null) continue;
        final (name, forms) = plural;
        for (final n in counts.where((n) => n != 1)) {
          // A form for exactly this count says what it likes.
          if (forms.containsKey('=$n')) continue;
          // As the generated code picks: "=1" and "one" are the same slot,
          // the later one written winning.
          final form = Intl.pluralLogic(
            n,
            zero: forms['=0'] ?? forms['zero'],
            one: forms['one'] ?? forms['=1'],
            two: forms['=2'] ?? forms['two'],
            few: forms['few'],
            many: forms['many'],
            other: forms['other']!,
            locale: code,
          );
          if (!form.contains('{$name}')) wrong.add('$code $k($n): $form');
        }
      }
    }
    expect(wrong, isEmpty);
  });

  test('each language is named in Settings and offered to Android', () {
    expect(languageNames.keys.toSet(), codes.toSet());
    final config = File('android/app/src/main/res/xml/locales_config.xml')
        .readAsStringSync();
    // By language: Android lists Portuguese as pt-PT, which is what it is.
    final offered = {
      for (final m in RegExp(r'android:name="([\w-]+)"').allMatches(config))
        m[1]!.split('-').first,
    };
    expect(offered, codes.toSet());
    expect(
      File('android/app/src/main/AndroidManifest.xml').readAsStringSync(),
      contains('android:localeConfig="@xml/locales_config"'),
    );
  });

  test("the phone's language if Countersink speaks it, else English", () {
    expect(
      resolveLanguage(null, const [Locale('es', 'MX')]),
      const Locale('es'),
    );
    expect(
      resolveLanguage(null, const [Locale('ja'), Locale('ru')]),
      const Locale('ru'),
    );
    expect(resolveLanguage(null, const [Locale('ja')]), const Locale('en'));
    expect(
      resolveLanguage(null, const [Locale('pt', 'BR')]),
      const Locale('pt'),
    );
    expect(resolveLanguage('es', const [Locale('en')]), const Locale('es'));
    expect(resolveLanguage(null, const []), const Locale('en'));
  });

  group('plurals, as the app says them', () {
    AppLocalizations l(String code) => lookupAppLocalizations(Locale(code));

    test('Spanish', () {
      expect(l('es').countersCount(0), 'Sin contadores');
      expect(l('es').countersCount(1), '1 contador');
      expect(l('es').countersCount(3), '3 contadores');
      expect(l('es').entriesCount(1), '1 entrada');
    });

    test('French puts nothing with one', () {
      expect(l('fr').entriesCount(0), '0 entrée');
      expect(l('fr').entriesCount(1), '1 entrée');
      expect(l('fr').entriesCount(2), '2 entrées');
      expect(l('fr').countersCount(0), 'Aucun compteur');
    });

    test('Russian has a form for one, a few and many', () {
      expect(l('ru').countersCount(1), '1 счётчик');
      expect(l('ru').countersCount(3), '3 счётчика');
      expect(l('ru').countersCount(5), '5 счётчиков');
      expect(l('ru').countersCount(21), '21 счётчик');
      expect(
        l('ru').groupDeleted('Спорт', 2),
        'Удалено: Спорт и 2 счётчика в ней',
      );
    });

    test('German', () {
      expect(l('de').groupDeleted('Sport', 0), 'Sport gelöscht');
      expect(
        l('de').groupDeleted('Sport', 1),
        'Sport mit einem Zähler gelöscht',
      );
      expect(l('de').groupDeleted('Sport', 4), 'Sport mit 4 Zählern gelöscht');
    });
  });
}

/// A message that is one plural, "{count, plural, =1{…} other{…}}", as its
/// count's name and each form by selector. Null for anything else.
(String, Map<String, String>)? _plural(String message) {
  final head = RegExp(r'^\{(\w+), plural,').firstMatch(message);
  if (head == null || !message.endsWith('}')) return null;
  final forms = <String, String>{};
  final body = message.substring(head.end, message.length - 1);
  var i = 0;
  while (i < body.length) {
    final selector = RegExp(r'\s*(=\d+|\w+)\{').matchAsPrefix(body, i);
    if (selector == null) break;
    var depth = 1, j = selector.end;
    for (; depth > 0; j++) {
      if (body[j] == '{') depth++;
      if (body[j] == '}') depth--;
    }
    forms[selector[1]!] = body.substring(selector.end, j - 1);
    i = j;
  }
  return (head[1]!, forms);
}
