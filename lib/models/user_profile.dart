class UserProfile {
  const UserProfile({
    required this.name,
    required this.dateOfBirth,
    required this.weightKg,
    required this.heightCm,
    required this.healthGoals,
  });

  final String name;
  final DateTime dateOfBirth;
  final double weightKg;
  final double heightCm;
  final List<String> healthGoals;

  String get healthGoal => healthGoals.join(', ');

  int get age {
    final now = DateTime.now();
    var years = now.year - dateOfBirth.year;
    final hadBirthday =
        now.month > dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day >= dateOfBirth.day);
    if (!hadBirthday) {
      years -= 1;
    }
    return years;
  }

  UserProfile copyWith({
    String? name,
    DateTime? dateOfBirth,
    double? weightKg,
    double? heightCm,
    List<String>? healthGoals,
  }) {
    return UserProfile(
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      healthGoals: healthGoals ?? this.healthGoals,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'weightKg': weightKg,
      'heightCm': heightCm,
      'healthGoals': healthGoals,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final rawGoals = json['healthGoals'] ?? json['healthGoal'];
    final healthGoals = switch (rawGoals) {
      List<dynamic> values => values.map((value) => value.toString()).toList(),
      String value => value
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList(),
      _ => const <String>[],
    };

    return UserProfile(
      name: json['name'] as String,
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      weightKg: (json['weightKg'] as num).toDouble(),
      heightCm: (json['heightCm'] as num).toDouble(),
      healthGoals: healthGoals,
    );
  }
}
