import 'dart:convert';
import 'dart:math';

import 'package:countersink/data/backup.dart';
import 'package:countersink/data/ids.dart';
import 'package:countersink/data/importers.dart';
import 'package:countersink/data/qr_transfer.dart';
import 'package:countersink/models/counter.dart';
import 'package:countersink/models/counter_group.dart';
import 'package:countersink/models/tap_event.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr/qr.dart';

/// A fictional phone's worth: two groups, four counters (one calculated,
/// one put away) and [entries] taps on the first, a minute apart.
BackupData sample({int entries = 300}) {
  final start = DateTime.utc(2026, 10, 1, 8);
  return BackupData(
    dayStartHour: 4,
    weekStart: DateTime.sunday,
    groups: const [
      CounterGroup(id: 'fitness', name: 'Fitness', position: 0),
      CounterGroup(id: 'games', name: 'Games', position: 1),
    ],
    counters: const [
      Counter(
        id: 'pullups',
        groupId: 'fitness',
        name: 'Pull-ups',
        color: 0xFFC4613F,
        goal: 50,
        daily: true,
        position: 0,
      ),
      Counter(
        id: 'pushups',
        groupId: 'fitness',
        name: 'Push-ups',
        color: 0xFF1A8783,
        step: 5,
        position: 1,
      ),
      Counter(
        id: 'both',
        groupId: 'games',
        name: 'Both',
        color: 0xFF14344B,
        formula: Formula.sum,
        sources: ['pullups', 'pushups'],
        position: 0,
      ),
      Counter(
        id: 'old',
        groupId: 'games',
        name: 'Old score',
        color: 0xFFA09EB9,
        archived: true,
        position: 1,
      ),
    ],
    events: [
      for (var i = 0; i < entries; i++)
        TapEvent(
          id: 'e$i',
          counterId: 'pullups',
          at: start.add(Duration(minutes: i * 97)),
          delta: 1,
        ),
      TapEvent(
        id: 'p1',
        counterId: 'pushups',
        at: start,
        delta: 40,
        kind: EventKind.set,
      ),
      TapEvent(id: 'o1', counterId: 'old', at: start, delta: 7),
    ],
  );
}

String text(BackupData data) =>
    encodeBackup(data, exportedAt: DateTime.utc(2026, 11, 23));

void main() {
  group('Base45 (RFC 9285 test vectors)', () {
    const vectors = {
      'AB': 'BB8',
      'Hello!!': '%69 VD92EX0',
      'base-45': 'UJCLQE7W581',
      'ietf!': 'QED8WEX0',
    };
    vectors.forEach((plain, encoded) {
      test(plain, () {
        expect(base45Encode(utf8.encode(plain)), encoded);
        expect(utf8.decode(base45Decode(encoded)!), plain);
      });
    });

    test('rejects invalid input', () {
      expect(base45Decode('GGW'), isNull); // 65535 < value: out of range
      expect(base45Decode('a'), isNull);
      expect(base45Decode('ab!'), isNull);
    });

    test('round-trips every byte value', () {
      final all = List.generate(256, (i) => i);
      expect(base45Decode(base45Encode(all)), all);
      expect(base45Decode(base45Encode(all.sublist(1))), all.sublist(1));
    });
  });

  final json = text(sample());

  group('frames', () {
    final frames = encodeTransfer(json, random: Random(1));

    test('stay in the QR alphanumeric set', () {
      final alnum = RegExp(r'^[0-9A-Z $%*+\-./:]+$');
      expect(frames.every(alnum.hasMatch), isTrue);
    });

    test('stay small enough for a phone camera to read off a screen', () {
      for (final f in frames) {
        final code = QrCode(
          payload: QrPayload.fromString(f),
          errorCorrectLevel: QrErrorCorrectLevel.medium,
        );
        expect(code.typeNumber, lessThanOrEqualTo(22));
      }
    });

    test('how many codes a history takes', () {
      int codes(BackupData data) => encodeTransfer(text(data)).length;
      // ignore: avoid_print
      print(
        'codes: 300 entries ${codes(sample())}, '
        '1000 entries ${codes(sample(entries: 1000))}, '
        '5000 entries ${codes(sample(entries: 5000))}',
      );
    });
  });

  group('receiving', () {
    test('reassembles in any order, ignoring repeats', () {
      final frames = encodeTransfer(json);
      final r = TransferReceiver();
      final order = [...frames, ...frames]..shuffle(Random(7));
      for (final f in order) {
        r.add(f);
      }
      expect(r.isComplete, isTrue);
      expect(r.assemble(), json);
    });

    test('reports progress and what is missing', () {
      final frames = encodeTransfer(json);
      final r = TransferReceiver();
      expect(r.add(frames.last), FrameResult.added);
      expect(r.add(frames.last), FrameResult.duplicate);
      expect(r.received, 1);
      expect(r.total, frames.length);
      expect(r.missing, [for (var i = 1; i < frames.length; i++) i]);
    });

    test('a new send replaces a half-finished one', () {
      final first = encodeTransfer(json, random: Random(1));
      final second = encodeTransfer(json, random: Random(2));
      final r = TransferReceiver()..add(first[0]);
      expect(r.add(second[1]), FrameResult.restarted);
      expect(r.received, 1);
    });

    test('a frame that disagrees on the length never completes a send', () {
      final frames = encodeTransfer(json, random: Random(1));
      final r = TransferReceiver();
      frames.take(frames.length - 1).forEach(r.add);
      // Same send ID, but numbered past the end: only a misread does that.
      final id = frames.first.split(':')[1];
      final n = frames.length + 1;
      expect(r.add('CSK1:$id:$n/$n:BB8'), FrameResult.restarted);
      expect(r.isComplete, isFalse);
      expect(r.received, 1);
    });

    test('other QR codes are ignored, Ebb\'s included', () {
      final r = TransferReceiver();
      expect(r.add('https://example.com'), FrameResult.notCountersink);
      expect(r.add('WIFI:S:home;T:WPA;P:secret;;'), FrameResult.notCountersink);
      expect(r.add('EBB1:ABCD:1/1:BB8'), FrameResult.notCountersink);
      expect(r.add('CSK9:ABCD:1/1:BB8'), FrameResult.newerVersion);
      expect(r.add('CSK1:ABCD:2/1:BB8'), FrameResult.notCountersink);
      expect(r.received, 0);
    });

    test('a corrupted frame is caught on assembly', () {
      final frames = encodeTransfer(json);
      final r = TransferReceiver();
      for (final f in frames) {
        // Flip one data character in the middle of the first frame.
        final i = f.length ~/ 2;
        final bad = f == frames.first
            ? f.replaceRange(i, i + 1, f[i] == '0' ? '1' : '0')
            : f;
        r.add(bad);
      }
      expect(r.assemble, throwsFormatException);
    });

    test('the result is the original backup', () {
      final frames = encodeTransfer(json);
      final r = TransferReceiver();
      frames.forEach(r.add);
      final back = decodeBackup(r.assemble());
      expect(
        [for (final c in back.counters) c.name],
        ['Pull-ups', 'Push-ups', 'Both', 'Old score'],
      );
      expect(back.events, hasLength(302));
    });
  });

  group('choosing what to send', () {
    final all = sample(entries: 10);
    int shown(Counter c) => switch (c.id) {
      'pullups' => 4,
      'pushups' => 40,
      _ => 0,
    };
    final now = DateTime.utc(2026, 11, 23, 12);

    BackupData pick(Set<String> chosen, {bool withHistory = true}) =>
        selectForTransfer(
          all,
          chosen,
          withHistory: withHistory,
          valueOf: shown,
          now: now,
        );

    test('one counter goes with its group and its own entries only', () {
      final sent = pick({'pushups'});
      expect(sent.groups.single.name, 'Fitness');
      expect(sent.counters.single.name, 'Push-ups');
      expect(
        (sent.events.single.delta, sent.events.single.kind),
        (40, EventKind.set),
      );
    });

    test('a calculated counter brings what it is worked out from', () {
      final sent = pick({'both'});
      expect(
        [for (final c in sent.counters) c.name],
        ['Pull-ups', 'Push-ups', 'Both'],
      );
      expect([for (final g in sent.groups) g.name], ['Fitness', 'Games']);
      expect(sent.events, hasLength(11));
    });

    test('the phone\'s own settings stay behind', () {
      final sent = pick({'pullups'});
      expect((sent.dayStartHour, sent.weekStart), (null, null));
    });

    test('a counter put away is sent as put away', () {
      expect(pick({'old'}).counters.single.archived, isTrue);
    });

    test('without history, each counter goes with the number on its card', () {
      final sent = pick({
        'pullups',
        'pushups',
        'both',
        'old',
      }, withHistory: false);
      expect(sent.counters, hasLength(4));
      final names = {for (final c in sent.counters) c.id: c.name};
      expect(
        {
          for (final e in sent.events)
            names[e.counterId]: (e.delta, e.kind, e.at),
        },
        {
          'Pull-ups': (4, EventKind.set, now),
          'Push-ups': (40, EventKind.set, now),
        },
        reason: 'nothing for a count of nothing, or for a calculated counter',
      );
    });

    test('what is chosen survives the codes and comes out a valid backup', () {
      final frames = encodeTransfer(text(pick({'both'})));
      final r = TransferReceiver();
      frames.forEach(r.add);
      final back = decodeBackup(r.assemble());
      expect(back.counters.last.sources, [
        back.counters[0].id,
        back.counters[1].id,
      ]);
    });

    test('long random ids are swapped for short ones, to save codes', () {
      // As a real phone has it: every id a random UUID.
      final real = BackupData(
        groups: all.groups,
        counters: all.counters,
        events: [
          for (var i = 0; i < 1000; i++)
            TapEvent(
              id: newId(),
              counterId: 'pullups',
              at: DateTime.utc(2026, 10, 1, 8).add(Duration(minutes: i * 97)),
              delta: 1,
            ),
        ],
      );
      final asKept = encodeTransfer(text(real)).length;
      final asSent = encodeTransfer(
        text(
          selectForTransfer(
            real,
            {'pullups'},
            withHistory: true,
            valueOf: shown,
            now: now,
          ),
        ),
      ).length;
      // ignore: avoid_print
      print('1000 real entries: $asKept codes as kept, $asSent as sent');
      expect(asSent, lessThan(asKept * 0.6));
      expect(asSent, lessThanOrEqualTo(20));
    });
  });

  group('what arrives', () {
    test('comes in under new ids, with everything still joined up', () {
      final got = importBackup(sample(entries: 10));
      final original = sample(entries: 10);
      expect(
        {for (final g in got.groups) g.id}
            .intersection({for (final g in original.groups) g.id}),
        isEmpty,
      );
      expect(
        {for (final c in got.counters) c.id}
            .intersection({for (final c in original.counters) c.id}),
        isEmpty,
      );
      final byName = {for (final c in got.counters) c.name: c};
      expect(byName['Both']!.sources, [
        byName['Pull-ups']!.id,
        byName['Push-ups']!.id,
      ]);
      expect(
        got.events.where((e) => e.counterId == byName['Pull-ups']!.id),
        hasLength(10),
      );
      expect(
        got.counters.every((c) => got.groups.any((g) => g.id == c.groupId)),
        isTrue,
      );
    });

    test('keeps looks, settings and order, and unarchives', () {
      final got = importBackup(sample(entries: 1));
      final pullUps = got.counters.first;
      expect(
        (pullUps.goal, pullUps.daily, pullUps.color),
        (50, true, 0xFFC4613F),
      );
      expect(got.counters[1].step, 5);
      expect([for (final c in got.counters) c.position], [0, 1, 0, 1]);
      expect(got.counters.any((c) => c.archived), isFalse);
      expect([for (final g in got.groups) g.name], ['Fitness', 'Games']);
    });

    test('twice over gives two separate sets', () {
      final a = importBackup(sample(entries: 1));
      final b = importBackup(sample(entries: 1));
      expect(a.counters.first.id, isNot(b.counters.first.id));
      expect(a.events.first.id, isNot(b.events.first.id));
    });
  });
}
