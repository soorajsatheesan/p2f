class WeightEntry {
  const WeightEntry({
    this.id,
    required this.weightKg,
    required this.loggedAt,
  });

  final int? id;
  final double weightKg;
  final DateTime loggedAt;

  WeightEntry copyWith({int? id, double? weightKg, DateTime? loggedAt}) {
    return WeightEntry(
      id: id ?? this.id,
      weightKg: weightKg ?? this.weightKg,
      loggedAt: loggedAt ?? this.loggedAt,
    );
  }

  Map<String, dynamic> toDbMap() => {
    if (id != null) 'id': id,
    'weight_kg': weightKg,
    'logged_at': loggedAt.toIso8601String(),
  };

  factory WeightEntry.fromDbMap(Map<String, dynamic> map) => WeightEntry(
    id: map['id'] as int,
    weightKg: (map['weight_kg'] as num).toDouble(),
    loggedAt: DateTime.parse(map['logged_at'] as String),
  );
}
