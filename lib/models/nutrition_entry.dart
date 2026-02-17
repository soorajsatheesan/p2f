import 'package:p2f/models/nutrition_analysis.dart';

class NutritionEntry {
  const NutritionEntry({
    this.id,
    required this.imagePath,
    required this.description,
    required this.createdAt,
    required this.analysis,
  });

  final int? id;
  final String imagePath;
  final String description;
  final DateTime createdAt;
  final NutritionAnalysis analysis;

  NutritionEntry copyWith({
    int? id,
    String? imagePath,
    String? description,
    DateTime? createdAt,
    NutritionAnalysis? analysis,
  }) {
    return NutritionEntry(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      analysis: analysis ?? this.analysis,
    );
  }

  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'image_path': imagePath,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'calories': analysis.calories,
      'protein_g': analysis.proteinG,
      'carbs_g': analysis.carbsG,
      'fats_g': analysis.fatsG,
      'fiber_g': analysis.fiberG,
      'summary': analysis.summary,
    };
  }

  factory NutritionEntry.fromDbMap(Map<String, dynamic> map) {
    return NutritionEntry(
      id: map['id'] as int?,
      imagePath: map['image_path'] as String,
      description: map['description'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      analysis: NutritionAnalysis(
        calories: (map['calories'] as num).round(),
        proteinG: (map['protein_g'] as num).toDouble(),
        carbsG: (map['carbs_g'] as num).toDouble(),
        fatsG: (map['fats_g'] as num).toDouble(),
        fiberG: (map['fiber_g'] as num).toDouble(),
        summary: (map['summary'] as String?) ?? '',
      ),
    );
  }
}
