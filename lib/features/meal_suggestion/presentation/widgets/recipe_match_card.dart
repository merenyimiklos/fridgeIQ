import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fridgeiq/features/meal_suggestion/domain/entities/recipe_match.dart';
import 'package:fridgeiq/features/meal_suggestion/domain/entities/recipe_review.dart';
import 'package:fridgeiq/features/meal_suggestion/presentation/providers/meal_suggestion_providers.dart';
import 'package:fridgeiq/features/meal_suggestion/presentation/widgets/add_recipe_sheet.dart';
import 'package:fridgeiq/features/meal_suggestion/presentation/widgets/add_review_sheet.dart';
import 'package:fridgeiq/features/shopping_list/presentation/providers/shopping_list_providers.dart';
import 'package:fridgeiq/features/shopping_list/domain/entities/shopping_item.dart';
import 'package:fridgeiq/core/utils/id_generator.dart';
import 'package:intl/intl.dart';

class RecipeMatchCard extends ConsumerWidget {
  const RecipeMatchCard({super.key, required this.match});

  final RecipeMatch match;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final percentage = (match.matchPercentage * 100).round();
    final reviewsAsync = ref.watch(recipeReviewsProvider(match.recipeId));

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ExpansionTile(
        leading: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                value: match.matchPercentage,
                backgroundColor: colorScheme.surfaceContainerHighest,
                color: match.hasAllIngredients
                    ? Colors.green
                    : percentage >= 50
                        ? Colors.orange
                        : colorScheme.error,
                strokeWidth: 4,
              ),
            ),
            Text(
              '$percentage%',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                match.recipeName,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            _buildPopupMenu(context, ref),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.restaurant, size: 14, color: colorScheme.outline),
                const SizedBox(width: 4),
                Text(
                  match.mealType[0].toUpperCase() +
                      match.mealType.substring(1),
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: colorScheme.outline),
                ),
                const SizedBox(width: 12),
                Icon(Icons.timer, size: 14, color: colorScheme.outline),
                const SizedBox(width: 4),
                Text(
                  '${match.prepTimeMinutes} min',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: colorScheme.outline),
                ),
                const SizedBox(width: 12),
                Icon(Icons.people, size: 14, color: colorScheme.outline),
                const SizedBox(width: 4),
                Text(
                  '${match.servings}',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: colorScheme.outline),
                ),
              ],
            ),
            reviewsAsync.when(
              data: (reviews) {
                if (reviews.isEmpty) return const SizedBox.shrink();
                final avgRating =
                    reviews.fold<int>(0, (sum, r) => sum + r.rating) /
                        reviews.length;
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      ...List.generate(5, (index) {
                        return Icon(
                          index < avgRating.round()
                              ? Icons.star
                              : Icons.star_border,
                          size: 14,
                          color: Colors.amber,
                        );
                      }),
                      const SizedBox(width: 4),
                      Text(
                        '${avgRating.toStringAsFixed(1)} (${reviews.length})',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: colorScheme.outline),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (match.availableIngredients.isNotEmpty) ...[
                  Text(
                    'Available at home:',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.green,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: match.availableIngredients
                        .map((i) => Chip(
                              label: Text(i),
                              avatar: const Icon(Icons.check, size: 16),
                              backgroundColor:
                                  Colors.green.withOpacity(0.1),
                              visualDensity: VisualDensity.compact,
                            ))
                        .toList(),
                  ),
                ],
                if (match.missingIngredients.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Need to buy:',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: colorScheme.error,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: match.missingIngredients
                        .map((i) => Chip(
                              label: Text(i),
                              avatar:
                                  const Icon(Icons.shopping_cart, size: 16),
                              backgroundColor: colorScheme.errorContainer
                                  .withOpacity(0.3),
                              visualDensity: VisualDensity.compact,
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 12),
                  FilledButton.tonalIcon(
                    onPressed: () =>
                        _addMissingToShoppingList(context, ref),
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text('Add missing to shopping list'),
                  ),
                ],
                if (match.instructions.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'Instructions:',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    match.instructions,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                _buildReviewsSection(context, ref, reviewsAsync),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopupMenu(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        switch (value) {
          case 'edit':
            _editRecipe(context, ref);
          case 'delete':
            _confirmDelete(context, ref);
          case 'review':
            _showAddReview(context);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: ListTile(
            leading: Icon(Icons.edit),
            title: Text('Edit'),
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ),
        const PopupMenuItem(
          value: 'review',
          child: ListTile(
            leading: Icon(Icons.rate_review),
            title: Text('Write Review'),
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: ListTile(
            leading: Icon(Icons.delete, color: Colors.red),
            title: Text('Delete', style: TextStyle(color: Colors.red)),
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ),
      ],
    );
  }

  Widget _buildReviewsSection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<List<RecipeReview>> reviewsAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Reviews',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            TextButton.icon(
              onPressed: () => _showAddReview(context),
              icon: const Icon(Icons.rate_review, size: 18),
              label: const Text('Write Review'),
            ),
          ],
        ),
        reviewsAsync.when(
          data: (reviews) {
            if (reviews.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'No reviews yet. Be the first to review!',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
              );
            }
            return Column(
              children: reviews.map((review) {
                return _buildReviewTile(context, ref, review);
              }).toList(),
            );
          },
          loading: () => const Padding(
            padding: EdgeInsets.all(8),
            child: CircularProgressIndicator(),
          ),
          error: (_, __) => const Text('Failed to load reviews'),
        ),
      ],
    );
  }

  Widget _buildReviewTile(
    BuildContext context,
    WidgetRef ref,
    RecipeReview review,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ...List.generate(5, (index) {
                  return Icon(
                    index < review.rating ? Icons.star : Icons.star_border,
                    size: 16,
                    color: Colors.amber,
                  );
                }),
                const Spacer(),
                Text(
                  DateFormat('MMM dd, yyyy').format(review.createdAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.outline,
                      ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        _showEditReview(context, review);
                      case 'delete':
                        _confirmDeleteReview(context, ref, review.id);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        leading: Icon(Icons.edit, size: 20),
                        title: Text('Edit'),
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading:
                            Icon(Icons.delete, size: 20, color: Colors.red),
                        title: Text('Delete',
                            style: TextStyle(color: Colors.red)),
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (review.comment.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                review.comment,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _editRecipe(BuildContext context, WidgetRef ref) {
    final recipesAsync = ref.read(recipesProvider);
    recipesAsync.whenData((recipes) {
      final recipe = recipes.where((r) => r.id == match.recipeId).firstOrNull;
      if (recipe != null) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          builder: (context) => AddRecipeSheet(editRecipe: recipe),
        );
      }
    });
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Recipe'),
        content: Text(
            'Are you sure you want to delete "${match.recipeName}"? This will also delete all reviews.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(recipesProvider.notifier).deleteRecipe(match.recipeId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('"${match.recipeName}" deleted'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddReview(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => AddReviewSheet(
        recipeId: match.recipeId,
        recipeName: match.recipeName,
      ),
    );
  }

  void _showEditReview(BuildContext context, RecipeReview review) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => AddReviewSheet(
        recipeId: match.recipeId,
        recipeName: match.recipeName,
        editReview: review,
      ),
    );
  }

  void _confirmDeleteReview(
      BuildContext context, WidgetRef ref, String reviewId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Review'),
        content:
            const Text('Are you sure you want to delete this review?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(reviewsProvider.notifier).deleteReview(reviewId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Review deleted'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _addMissingToShoppingList(BuildContext context, WidgetRef ref) {
    final items = match.missingIngredients
        .map((ingredient) => ShoppingItem(
              id: IdGenerator.generate(),
              name: ingredient,
              isChecked: false,
              createdAt: DateTime.now(),
            ))
        .toList();
    ref.read(shoppingListProvider.notifier).addItems(items);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${match.missingIngredients.length} item(s) added to shopping list',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
