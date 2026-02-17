class NutritionAnalysis {
  const NutritionAnalysis({
    required this.mealName,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatsG,
    required this.fiberG,
    required this.summary,
  });

  final String mealName;
  final int calories;
  final double proteinG;
  final double carbsG;
  final double fatsG;
  final double fiberG;
  final String summary;

  factory NutritionAnalysis.fromJson(Map<String, dynamic> json) {
    return NutritionAnalysis(
      mealName: (json['meal_name'] as String?)?.trim().isNotEmpty == true
          ? (json['meal_name'] as String).trim()
          : 'Meal',
      calories: (json['calories'] as num).round(),
      proteinG: (json['protein_g'] as num).toDouble(),
      carbsG: (json['carbs_g'] as num).toDouble(),
      fatsG: (json['fats_g'] as num).toDouble(),
      fiberG: (json['fiber_g'] as num).toDouble(),
      summary: (json['summary'] as String?)?.trim() ?? 'No summary provided.',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'meal_name': mealName,
      'calories': calories,
      'protein_g': proteinG,
      'carbs_g': carbsG,
      'fats_g': fatsG,
      'fiber_g': fiberG,
      'summary': summary,
    };
  }
}
