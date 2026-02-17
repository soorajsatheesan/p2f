class UserProfile {
  const UserProfile({
    required this.name,
    required this.dateOfBirth,
    required this.weightKg,
    required this.heightCm,
    required this.healthGoal,
  });

  final String name;
  final DateTime dateOfBirth;
  final double weightKg;
  final double heightCm;
  final String healthGoal;

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
    String? healthGoal,
  }) {
    return UserProfile(
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      healthGoal: healthGoal ?? this.healthGoal,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'weightKg': weightKg,
      'heightCm': heightCm,
      'healthGoal': healthGoal,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] as String,
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      weightKg: (json['weightKg'] as num).toDouble(),
      heightCm: (json['heightCm'] as num).toDouble(),
      healthGoal: json['healthGoal'] as String,
    );
  }
}
