import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fridgeiq/core/widgets/empty_state_widget.dart';
import 'package:fridgeiq/features/meal_suggestion/presentation/providers/meal_suggestion_providers.dart';
import 'package:fridgeiq/features/meal_suggestion/presentation/widgets/add_recipe_sheet.dart';
import 'package:fridgeiq/features/meal_suggestion/presentation/widgets/import_recipe_sheet.dart';
import 'package:fridgeiq/features/meal_suggestion/presentation/widgets/recipe_match_card.dart';

class MealSuggestionScreen extends ConsumerWidget {
  const MealSuggestionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matches = ref.watch(recipeMatchesProvider);
    final selectedFilter = ref.watch(mealTypeFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Suggestions'),
        actions: [
          IconButton(
            onPressed: () => _showImportSheet(context),
            icon: const Icon(Icons.link),
            tooltip: 'Import from TikTok',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _MealFilterChip(
                  label: 'All',
                  selected: selectedFilter == null,
                  onSelected: (_) =>
                      ref.read(mealTypeFilterProvider.notifier).state = null,
                ),
                const SizedBox(width: 8),
                _MealFilterChip(
                  label: 'Lunch',
                  selected: selectedFilter == 'lunch',
                  onSelected: (_) => ref
                      .read(mealTypeFilterProvider.notifier)
                      .state = 'lunch',
                ),
                const SizedBox(width: 8),
                _MealFilterChip(
                  label: 'Dinner',
                  selected: selectedFilter == 'dinner',
                  onSelected: (_) => ref
                      .read(mealTypeFilterProvider.notifier)
                      .state = 'dinner',
                ),
              ],
            ),
          ),
          Expanded(
            child: matches.when(
              data: (matchList) {
                if (matchList.isEmpty) {
                  return EmptyStateWidget(
                    icon: Icons.restaurant_menu,
                    title: 'No recipes yet',
                    subtitle:
                        'Add recipes to get meal suggestions based on your inventory',
                    action: FilledButton.icon(
                      onPressed: () => _showAddRecipeSheet(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Recipe'),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: matchList.length,
                  itemBuilder: (context, index) {
                    return RecipeMatchCard(match: matchList[index]);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddRecipeSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Recipe'),
      ),
    );
  }

  void _showAddRecipeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => const AddRecipeSheet(),
    );
  }

  void _showImportSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => const ImportRecipeSheet(),
    );
  }
}

class _MealFilterChip extends StatelessWidget {
  const _MealFilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
    );
  }
}
