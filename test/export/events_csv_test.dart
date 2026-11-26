import 'package:countersink/data/backup.dart';
import 'package:countersink/export/events_csv.dart';
import 'package:countersink/models/counter.dart';
import 'package:countersink/models/counter_group.dart';
import 'package:countersink/models/tap_event.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  BackupData data({
    String group = 'Fitness',
    String counter = 'Pull-ups',
    List<TapEvent>? events,
  }) => BackupData(
    groups: [CounterGroup(id: 'g', name: group)],
    counters: [
      Counter(id: 'c', groupId: 'g', name: counter, color: 0xFFC4613F),
    ],
    events:
        events ??
        [
          TapEvent(
            id: 'e',
            counterId: 'c',
            at: DateTime(2026, 11, 22, 14, 2, 11),
            delta: 8,
          ),
        ],
  );

  List<String> rows(String csv) =>
      csv.split('\r\n').where((r) => r.isNotEmpty).toList();

  test('a header, then one row per entry, oldest first', () {
    final at = DateTime(2026, 11, 22, 14, 2, 11);
    final csv = eventsCsv(
      data(
        events: [
          TapEvent(
            id: 'b',
            counterId: 'c',
            at: DateTime(2026, 11, 22, 18),
            delta: -8,
            kind: EventKind.reset,
          ),
          TapEvent(id: 'a', counterId: 'c', at: at, delta: 8),
        ],
      ),
      dayStartHour: 0,
    );
    final r = rows(csv);
    expect(r, hasLength(3));
    expect(r[0], 'group,counter,time,day,change,kind');
    expect(r[1], 'Fitness,Pull-ups,${isoWithOffset(at)},2026-11-22,8,tap');
    expect(r[2], endsWith(',2026-11-22,-8,reset'));
    expect(csv, endsWith('\r\n'));
  });

  test('the day column follows the day-start hour', () {
    final late = data(
      events: [
        TapEvent(
          id: 'e',
          counterId: 'c',
          at: DateTime(2026, 11, 23, 0, 30),
          delta: 5,
        ),
      ],
    );
    expect(
      rows(eventsCsv(late, dayStartHour: 0))[1],
      contains(',2026-11-23,5,'),
    );
    expect(
      rows(eventsCsv(late, dayStartHour: 4))[1],
      contains(',2026-11-22,5,'),
    );
  });

  test('names with commas, quotes and line breaks are quoted', () {
    final csv = eventsCsv(
      data(group: 'Home, garden', counter: 'Say "when"\nplease'),
      dayStartHour: 0,
    );
    expect(csv, contains('"Home, garden","Say ""when""\nplease",'));
  });

  test('a name a spreadsheet would run as a formula is marked as text', () {
    final csv = eventsCsv(
      data(counter: '=SUM(A1:A9)', group: '+1s'),
      dayStartHour: 0,
    );
    expect(rows(csv)[1], startsWith("'+1s,'=SUM(A1:A9),"));
  });

  test('time is written as the local clock read, with its offset', () {
    final local = DateTime(2026, 3, 7, 9, 5, 3);
    final text = isoWithOffset(local);
    expect(text, startsWith('2026-03-07T09:05:03'));
    expect(text, matches(RegExp(r'[+-]\d\d:\d\d$')));
    expect(DateTime.parse(text).toUtc(), local.toUtc());
  });

  test('nothing counted is just the header', () {
    expect(rows(eventsCsv(data(events: []), dayStartHour: 0)), hasLength(1));
  });

  test('the file name carries the day', () {
    expect(
      csvFileName(DateTime(2026, 3, 7)),
      'countersink-entries-2026-03-07.csv',
    );
  });
}
