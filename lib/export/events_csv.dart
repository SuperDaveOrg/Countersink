import 'package:countersink/data/backup.dart';
import 'package:countersink/domain/dates.dart';

/// The suggested file name for a CSV taken on [day].
String csvFileName(DateTime day) {
  String two(int n) => n.toString().padLeft(2, '0');
  return 'countersink-entries-${day.year}-${two(day.month)}-${two(day.day)}.csv';
}

/// Every change to every count as a spreadsheet: one row per entry, oldest
/// first, under a header row.
///
/// `time` is the local time with its offset; `day` is the counting day the
/// entry belongs to under [dayStartHour], so a pivot by `day` gives the same
/// daily totals the app shows. For reading in a spreadsheet, not for
/// restoring: that is what a backup is for.
String eventsCsv(BackupData data, {required int dayStartHour}) {
  final groupNames = {for (final g in data.groups) g.id: g.name};
  final counters = {for (final c in data.counters) c.id: c};
  final events = [...data.events]..sort((a, b) => a.at.compareTo(b.at));

  final out = StringBuffer('group,counter,time,day,change,kind\r\n');
  for (final e in events) {
    final counter = counters[e.counterId];
    if (counter == null) continue;
    final local = e.at.toLocal();
    out
      ..write(_text(groupNames[counter.groupId] ?? ''))
      ..write(',')
      ..write(_text(counter.name))
      ..write(',')
      ..write(isoWithOffset(local))
      ..write(',')
      ..write(isoDay(countingDay(local, dayStartHour: dayStartHour)))
      ..write(',')
      ..write(e.delta)
      ..write(',')
      ..write(e.kind.name)
      ..write('\r\n');
  }
  return out.toString();
}

/// "2026-11-22".
String isoDay(DateTime day) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${day.year.toString().padLeft(4, '0')}-${two(day.month)}-${two(day.day)}';
}

/// "2026-11-22T14:02:11-05:00": [local] as the clock on the wall read, with
/// how far that was from UTC.
String isoWithOffset(DateTime local) {
  String two(int n) => n.toString().padLeft(2, '0');
  final offset = local.timeZoneOffset;
  final sign = offset.isNegative ? '-' : '+';
  final minutes = offset.inMinutes.abs();
  return '${isoDay(local)}T${two(local.hour)}:${two(local.minute)}:'
      '${two(local.second)}$sign${two(minutes ~/ 60)}:${two(minutes % 60)}';
}

/// A name as a CSV field: quoted when it holds a comma, a quote or a line
/// break, with quotes doubled. One that a spreadsheet would run as a formula
/// gets an apostrophe in front, which spreadsheets read as "this is text".
String _text(String value) {
  var v = value;
  if (v.startsWith(RegExp(r'[=+\-@\t\r]'))) v = "'$v";
  if (v.contains(RegExp('[",\r\n]'))) v = '"${v.replaceAll('"', '""')}"';
  return v;
}
