import 'package:hive/hive.dart';
import 'package:fridgeiq/core/constants/app_constants.dart';
import 'package:fridgeiq/features/meal_suggestion/data/models/recipe_review_model.dart';

class ReviewLocalDataSource {
  Box<Map>? _box;

  Future<Box<Map>> get box async {
    _box ??= await Hive.openBox<Map>(AppConstants.reviewBoxName);
    return _box!;
  }

  Future<List<RecipeReviewModel>> getAllReviews() async {
    final b = await box;
    return b.values.map((map) => RecipeReviewModel.fromMap(map)).toList();
  }

  Future<List<RecipeReviewModel>> getReviewsForRecipe(String recipeId) async {
    final all = await getAllReviews();
    return all.where((r) => r.recipeId == recipeId).toList();
  }

  Future<void> saveReview(RecipeReviewModel model) async {
    final b = await box;
    await b.put(model.id, model.toMap());
  }

  Future<void> deleteReview(String id) async {
    final b = await box;
    await b.delete(id);
  }
}
