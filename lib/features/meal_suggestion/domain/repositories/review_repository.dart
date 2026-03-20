import 'package:fridgeiq/features/meal_suggestion/domain/entities/recipe_review.dart';

abstract class ReviewRepository {
  Future<List<RecipeReview>> getReviewsForRecipe(String recipeId);
  Future<List<RecipeReview>> getAllReviews();
  Future<void> addReview(RecipeReview review);
  Future<void> updateReview(RecipeReview review);
  Future<void> deleteReview(String id);
}
