class Recipe {
  final String id;
  final String name;
  final String mealType;
  final List<String> ingredients;
  final String instructions;
  final int servings;
  final int prepTimeMinutes;

  const Recipe({
    required this.id,
    required this.name,
    required this.mealType,
    required this.ingredients,
    required this.instructions,
    this.servings = 2,
    this.prepTimeMinutes = 30,
  });

  Recipe copyWith({
    String? id,
    String? name,
    String? mealType,
    List<String>? ingredients,
    String? instructions,
    int? servings,
    int? prepTimeMinutes,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      mealType: mealType ?? this.mealType,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      servings: servings ?? this.servings,
      prepTimeMinutes: prepTimeMinutes ?? this.prepTimeMinutes,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Recipe && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
