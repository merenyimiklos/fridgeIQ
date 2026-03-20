import 'package:hive/hive.dart';
import 'package:fridgeiq/core/constants/app_constants.dart';
import 'package:fridgeiq/features/meal_suggestion/data/models/recipe_model.dart';

class RecipeLocalDataSource {
  Box<Map>? _box;

  Future<Box<Map>> get box async {
    _box ??= await Hive.openBox<Map>(AppConstants.recipeBoxName);
    return _box!;
  }

  Future<List<RecipeModel>> getAllRecipes() async {
    final b = await box;
    return b.values.map((map) => RecipeModel.fromMap(map)).toList();
  }

  Future<void> saveRecipe(RecipeModel model) async {
    final b = await box;
    await b.put(model.id, model.toMap());
  }

  Future<void> deleteRecipe(String id) async {
    final b = await box;
    await b.delete(id);
  }
}
