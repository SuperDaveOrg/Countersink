/// A tab of counters.
class CounterGroup {
  const CounterGroup({required this.id, required this.name, this.position = 0});

  final String id;
  final String name;

  /// Order among the tabs, lowest first.
  final int position;

  Map<String, Object?> toRow() => {
    'id': id,
    'name': name,
    'position': position,
  };

  static CounterGroup fromRow(Map<String, Object?> row) => CounterGroup(
    id: row['id'] as String,
    name: row['name'] as String,
    position: row['position'] as int,
  );
}
