class RecipeReview {
  final String id;
  final String recipeId;
  final int rating;
  final String comment;
  final DateTime createdAt;

  const RecipeReview({
    required this.id,
    required this.recipeId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  RecipeReview copyWith({
    String? id,
    String? recipeId,
    int? rating,
    String? comment,
    DateTime? createdAt,
  }) {
    return RecipeReview(
      id: id ?? this.id,
      recipeId: recipeId ?? this.recipeId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecipeReview &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
