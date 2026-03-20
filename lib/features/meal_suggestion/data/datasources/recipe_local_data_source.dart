import 'package:fridgeiq/core/constants/app_constants.dart';
import 'package:fridgeiq/core/services/firebase_database_service.dart';
import 'package:fridgeiq/features/meal_suggestion/data/models/recipe_model.dart';

class RecipeLocalDataSource {
  final FirebaseDatabaseService _firebaseService;

  RecipeLocalDataSource(this._firebaseService);

  static const _collection = AppConstants.recipeBoxName;

  Future<List<RecipeModel>> getAllRecipes() async {
    final data = await _firebaseService.getAll(_collection);
    return data.values.map((map) => RecipeModel.fromMap(map)).toList();
  }

  Future<void> saveRecipe(RecipeModel model) async {
    await _firebaseService.put(_collection, model.id, model.toMap());
  }

  Future<void> deleteRecipe(String id) async {
    await _firebaseService.delete(_collection, id);
  }
}
