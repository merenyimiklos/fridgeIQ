class RecipeMatch {
  final String recipeId;
  final String recipeName;
  final String mealType;
  final List<String> allIngredients;
  final List<String> availableIngredients;
  final List<String> missingIngredients;
  final String instructions;
  final int servings;
  final int prepTimeMinutes;

  const RecipeMatch({
    required this.recipeId,
    required this.recipeName,
    required this.mealType,
    required this.allIngredients,
    required this.availableIngredients,
    required this.missingIngredients,
    required this.instructions,
    required this.servings,
    required this.prepTimeMinutes,
  });

  double get matchPercentage {
    if (allIngredients.isEmpty) return 0;
    return availableIngredients.length / allIngredients.length;
  }

  bool get hasAllIngredients => missingIngredients.isEmpty;
}
