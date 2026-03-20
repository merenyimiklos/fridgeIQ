import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fridgeiq/features/meal_suggestion/domain/entities/recipe_match.dart';
import 'package:fridgeiq/features/shopping_list/presentation/providers/shopping_list_providers.dart';
import 'package:fridgeiq/features/shopping_list/domain/entities/shopping_item.dart';
import 'package:fridgeiq/core/utils/id_generator.dart';

class RecipeMatchCard extends ConsumerWidget {
  const RecipeMatchCard({super.key, required this.match});

  final RecipeMatch match;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final percentage = (match.matchPercentage * 100).round();

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
        title: Text(
          match.recipeName,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Row(
          children: [
            Icon(Icons.restaurant, size: 14, color: colorScheme.outline),
            const SizedBox(width: 4),
            Text(
              match.mealType[0].toUpperCase() + match.mealType.substring(1),
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
                              avatar: const Icon(Icons.shopping_cart, size: 16),
                              backgroundColor:
                                  colorScheme.errorContainer.withOpacity(0.3),
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
              ],
            ),
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
