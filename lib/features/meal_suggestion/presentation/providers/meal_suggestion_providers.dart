import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fridgeiq/features/food_inventory/presentation/providers/food_inventory_providers.dart';
import 'package:fridgeiq/features/meal_suggestion/data/datasources/recipe_local_data_source.dart';
import 'package:fridgeiq/features/meal_suggestion/data/repositories/recipe_repository_impl.dart';
import 'package:fridgeiq/features/meal_suggestion/domain/entities/recipe.dart';
import 'package:fridgeiq/features/meal_suggestion/domain/entities/recipe_match.dart';
import 'package:fridgeiq/features/meal_suggestion/domain/repositories/recipe_repository.dart';

final recipeLocalDataSourceProvider = Provider<RecipeLocalDataSource>((ref) {
  return RecipeLocalDataSource();
});

final recipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  return RecipeRepositoryImpl(ref.watch(recipeLocalDataSourceProvider));
});

final recipesProvider =
    AsyncNotifierProvider<RecipesNotifier, List<Recipe>>(RecipesNotifier.new);

class RecipesNotifier extends AsyncNotifier<List<Recipe>> {
  @override
  Future<List<Recipe>> build() async {
    return ref.watch(recipeRepositoryProvider).getAllRecipes();
  }

  Future<void> addRecipe(Recipe recipe) async {
    final repo = ref.read(recipeRepositoryProvider);
    await repo.addRecipe(recipe);
    ref.invalidateSelf();
  }

  Future<void> updateRecipe(Recipe recipe) async {
    final repo = ref.read(recipeRepositoryProvider);
    await repo.updateRecipe(recipe);
    ref.invalidateSelf();
  }

  Future<void> deleteRecipe(String id) async {
    final repo = ref.read(recipeRepositoryProvider);
    await repo.deleteRecipe(id);
    ref.invalidateSelf();
  }
}

final mealTypeFilterProvider = StateProvider<String?>((ref) => null);

final recipeMatchesProvider = Provider<AsyncValue<List<RecipeMatch>>>((ref) {
  final recipesAsync = ref.watch(recipesProvider);
  final inventoryAsync = ref.watch(foodInventoryProvider);
  final mealFilter = ref.watch(mealTypeFilterProvider);

  return recipesAsync.when(
    data: (recipes) => inventoryAsync.whenData((inventory) {
      final availableNames = inventory
          .map((item) => item.name.toLowerCase().trim())
          .toSet();

      var matches = recipes.map((recipe) {
        final available = <String>[];
        final missing = <String>[];

        for (final ingredient in recipe.ingredients) {
          final normalizedIngredient = ingredient.toLowerCase().trim();
          final isAvailable = availableNames.any((name) =>
              name == normalizedIngredient ||
              name.split(' ').contains(normalizedIngredient) ||
              normalizedIngredient.split(' ').any((word) => word.length > 2 && name.contains(word)));
          if (isAvailable) {
            available.add(ingredient);
          } else {
            missing.add(ingredient);
          }
        }

        return RecipeMatch(
          recipeId: recipe.id,
          recipeName: recipe.name,
          mealType: recipe.mealType,
          allIngredients: recipe.ingredients,
          availableIngredients: available,
          missingIngredients: missing,
          instructions: recipe.instructions,
          servings: recipe.servings,
          prepTimeMinutes: recipe.prepTimeMinutes,
        );
      }).toList();

      if (mealFilter != null) {
        matches =
            matches.where((m) => m.mealType == mealFilter).toList();
      }

      matches.sort((a, b) => b.matchPercentage.compareTo(a.matchPercentage));
      return matches;
    }),
    loading: () => const AsyncLoading(),
    error: (e, s) => AsyncError(e, s),
  );
});
