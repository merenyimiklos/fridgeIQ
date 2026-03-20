import 'package:fridgeiq/features/meal_suggestion/data/datasources/recipe_local_data_source.dart';
import 'package:fridgeiq/features/meal_suggestion/data/models/recipe_model.dart';
import 'package:fridgeiq/features/meal_suggestion/domain/entities/recipe.dart';
import 'package:fridgeiq/features/meal_suggestion/domain/repositories/recipe_repository.dart';

class RecipeRepositoryImpl implements RecipeRepository {
  final RecipeLocalDataSource _dataSource;

  RecipeRepositoryImpl(this._dataSource);

  @override
  Future<List<Recipe>> getAllRecipes() async {
    final models = await _dataSource.getAllRecipes();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> addRecipe(Recipe recipe) async {
    await _dataSource.saveRecipe(RecipeModel.fromEntity(recipe));
  }

  @override
  Future<void> updateRecipe(Recipe recipe) async {
    await _dataSource.saveRecipe(RecipeModel.fromEntity(recipe));
  }

  @override
  Future<void> deleteRecipe(String id) async {
    await _dataSource.deleteRecipe(id);
  }
}
