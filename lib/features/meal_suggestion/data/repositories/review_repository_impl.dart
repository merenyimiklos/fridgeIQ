import 'package:fridgeiq/features/meal_suggestion/data/datasources/review_local_data_source.dart';
import 'package:fridgeiq/features/meal_suggestion/data/models/recipe_review_model.dart';
import 'package:fridgeiq/features/meal_suggestion/domain/entities/recipe_review.dart';
import 'package:fridgeiq/features/meal_suggestion/domain/repositories/review_repository.dart';

class ReviewRepositoryImpl implements ReviewRepository {
  final ReviewLocalDataSource _dataSource;

  ReviewRepositoryImpl(this._dataSource);

  @override
  Future<List<RecipeReview>> getAllReviews() async {
    final models = await _dataSource.getAllReviews();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<RecipeReview>> getReviewsForRecipe(String recipeId) async {
    final models = await _dataSource.getReviewsForRecipe(recipeId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> addReview(RecipeReview review) async {
    await _dataSource.saveReview(RecipeReviewModel.fromEntity(review));
  }

  @override
  Future<void> updateReview(RecipeReview review) async {
    await _dataSource.saveReview(RecipeReviewModel.fromEntity(review));
  }

  @override
  Future<void> deleteReview(String id) async {
    await _dataSource.deleteReview(id);
  }
}
