/// Why a count changed.
enum EventKind {
  /// A press of plus or minus.
  tap,

  /// The value typed in directly; [TapEvent.delta] is the difference.
  set,

  /// Back to zero; [TapEvent.delta] cancels what was there.
  reset,
}

/// One change to a counter, at one moment.
class TapEvent {
  const TapEvent({
    required this.id,
    required this.counterId,
    required this.at,
    required this.delta,
    this.kind = EventKind.tap,
  });

  final String id;
  final String counterId;

  /// The instant it happened.
  final DateTime at;

  /// How much the count changed; negative for a minus.
  final int delta;
  final EventKind kind;

  Map<String, Object?> toRow() => {
    'id': id,
    'counter_id': counterId,
    'at': at.toUtc().millisecondsSinceEpoch,
    'delta': delta,
    'kind': kind.name,
  };

  static TapEvent fromRow(Map<String, Object?> row) => TapEvent(
    id: row['id'] as String,
    counterId: row['counter_id'] as String,
    at: DateTime.fromMillisecondsSinceEpoch(row['at'] as int, isUtc: true),
    delta: row['delta'] as int,
    kind: EventKind.values.byName(row['kind'] as String),
  );
}
