import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fridgeiq/core/utils/id_generator.dart';
import 'package:fridgeiq/features/meal_suggestion/domain/entities/recipe_review.dart';
import 'package:fridgeiq/features/meal_suggestion/presentation/providers/meal_suggestion_providers.dart';

class AddReviewSheet extends ConsumerStatefulWidget {
  const AddReviewSheet({
    super.key,
    required this.recipeId,
    required this.recipeName,
    this.editReview,
  });

  final String recipeId;
  final String recipeName;
  final RecipeReview? editReview;

  @override
  ConsumerState<AddReviewSheet> createState() => _AddReviewSheetState();
}

class _AddReviewSheetState extends ConsumerState<AddReviewSheet> {
  final _commentController = TextEditingController();
  late int _rating;

  bool get _isEditing => widget.editReview != null;

  @override
  void initState() {
    super.initState();
    _rating = widget.editReview?.rating ?? 0;
    _commentController.text = widget.editReview?.comment ?? '';
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _isEditing ? 'Edit Review' : 'Write a Review',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              widget.recipeName,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              'Rating',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final starIndex = index + 1;
                return IconButton(
                  onPressed: () => setState(() => _rating = starIndex),
                  icon: Icon(
                    starIndex <= _rating ? Icons.star : Icons.star_border,
                    color: starIndex <= _rating
                        ? Colors.amber
                        : Theme.of(context).colorScheme.outline,
                    size: 36,
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _commentController,
              decoration: const InputDecoration(
                labelText: 'Comment (optional)',
                prefixIcon: Icon(Icons.comment),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _rating > 0 ? _submit : null,
              icon: Icon(_isEditing ? Icons.save : Icons.rate_review),
              label: Text(_isEditing ? 'Save Review' : 'Submit Review'),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    final review = RecipeReview(
      id: widget.editReview?.id ?? IdGenerator.generate(),
      recipeId: widget.recipeId,
      rating: _rating,
      comment: _commentController.text.trim(),
      createdAt: widget.editReview?.createdAt ?? DateTime.now(),
    );

    if (_isEditing) {
      ref.read(reviewsProvider.notifier).updateReview(review);
    } else {
      ref.read(reviewsProvider.notifier).addReview(review);
    }

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isEditing ? 'Review updated' : 'Review added'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
