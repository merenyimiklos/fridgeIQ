import 'package:hive/hive.dart';
import 'package:fridgeiq/features/meal_suggestion/domain/entities/recipe.dart';

class RecipeModel {
  final String id;
  final String name;
  final String mealType;
  final List<String> ingredients;
  final String instructions;
  final int servings;
  final int prepTimeMinutes;

  const RecipeModel({
    required this.id,
    required this.name,
    required this.mealType,
    required this.ingredients,
    required this.instructions,
    this.servings = 2,
    this.prepTimeMinutes = 30,
  });

  factory RecipeModel.fromEntity(Recipe entity) {
    return RecipeModel(
      id: entity.id,
      name: entity.name,
      mealType: entity.mealType,
      ingredients: entity.ingredients,
      instructions: entity.instructions,
      servings: entity.servings,
      prepTimeMinutes: entity.prepTimeMinutes,
    );
  }

  Recipe toEntity() {
    return Recipe(
      id: id,
      name: name,
      mealType: mealType,
      ingredients: ingredients,
      instructions: instructions,
      servings: servings,
      prepTimeMinutes: prepTimeMinutes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'mealType': mealType,
      'ingredients': ingredients,
      'instructions': instructions,
      'servings': servings,
      'prepTimeMinutes': prepTimeMinutes,
    };
  }

  factory RecipeModel.fromMap(Map<dynamic, dynamic> map) {
    return RecipeModel(
      id: map['id'] as String,
      name: map['name'] as String,
      mealType: map['mealType'] as String,
      ingredients: (map['ingredients'] as List).cast<String>(),
      instructions: map['instructions'] as String,
      servings: map['servings'] as int? ?? 2,
      prepTimeMinutes: map['prepTimeMinutes'] as int? ?? 30,
    );
  }
}
