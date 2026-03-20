import 'package:fridgeiq/features/meal_suggestion/domain/entities/recipe_review.dart';

class RecipeReviewModel {
  final String id;
  final String recipeId;
  final int rating;
  final String comment;
  final DateTime createdAt;

  const RecipeReviewModel({
    required this.id,
    required this.recipeId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory RecipeReviewModel.fromEntity(RecipeReview entity) {
    return RecipeReviewModel(
      id: entity.id,
      recipeId: entity.recipeId,
      rating: entity.rating,
      comment: entity.comment,
      createdAt: entity.createdAt,
    );
  }

  RecipeReview toEntity() {
    return RecipeReview(
      id: id,
      recipeId: recipeId,
      rating: rating,
      comment: comment,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'recipeId': recipeId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory RecipeReviewModel.fromMap(Map<dynamic, dynamic> map) {
    return RecipeReviewModel(
      id: map['id'] as String,
      recipeId: map['recipeId'] as String,
      rating: map['rating'] as int,
      comment: map['comment'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
