import 'package:fridgeiq/core/services/firebase_database_service.dart';
import 'package:fridgeiq/features/meal_suggestion/data/models/recipe_review_model.dart';

class ReviewLocalDataSource {
  final FirebaseDatabaseService _firebaseService;
  final String _collection;

  ReviewLocalDataSource(this._firebaseService, this._collection);

  Future<List<RecipeReviewModel>> getAllReviews() async {
    final data = await _firebaseService.getAll(_collection);
    return data.values.map((map) => RecipeReviewModel.fromMap(map)).toList();
  }

  Future<List<RecipeReviewModel>> getReviewsForRecipe(String recipeId) async {
    final all = await getAllReviews();
    return all.where((r) => r.recipeId == recipeId).toList();
  }

  Future<void> saveReview(RecipeReviewModel model) async {
    await _firebaseService.put(_collection, model.id, model.toMap());
  }

  Future<void> deleteReview(String id) async {
    await _firebaseService.delete(_collection, id);
  }
}
