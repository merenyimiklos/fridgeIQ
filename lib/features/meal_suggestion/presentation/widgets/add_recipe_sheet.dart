import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fridgeiq/core/utils/id_generator.dart';
import 'package:fridgeiq/features/meal_suggestion/domain/entities/recipe.dart';
import 'package:fridgeiq/features/meal_suggestion/presentation/providers/meal_suggestion_providers.dart';

class AddRecipeSheet extends ConsumerStatefulWidget {
  const AddRecipeSheet({super.key, this.editRecipe, this.isNewFromImport = false});

  final Recipe? editRecipe;
  final bool isNewFromImport;

  @override
  ConsumerState<AddRecipeSheet> createState() => _AddRecipeSheetState();
}

class _AddRecipeSheetState extends ConsumerState<AddRecipeSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _instructionsController;
  late final TextEditingController _servingsController;
  late final TextEditingController _prepTimeController;
  late String _selectedMealType;
  final List<String> _ingredients = [];
  final TextEditingController _ingredientController = TextEditingController();

  bool get _isEditing => widget.editRecipe != null && !widget.isNewFromImport;

  @override
  void initState() {
    super.initState();
    final recipe = widget.editRecipe;
    _nameController = TextEditingController(text: recipe?.name ?? '');
    _instructionsController =
        TextEditingController(text: recipe?.instructions ?? '');
    _servingsController =
        TextEditingController(text: (recipe?.servings ?? 2).toString());
    _prepTimeController =
        TextEditingController(text: (recipe?.prepTimeMinutes ?? 30).toString());
    _selectedMealType = recipe?.mealType ?? 'lunch';
    if (recipe != null) {
      _ingredients.addAll(recipe.ingredients);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _instructionsController.dispose();
    _servingsController.dispose();
    _prepTimeController.dispose();
    _ingredientController.dispose();
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
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _isEditing ? 'Edit Recipe' : 'Add Recipe',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Recipe Name',
                  prefixIcon: Icon(Icons.restaurant_menu),
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a recipe name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'lunch',
                    label: Text('Lunch'),
                    icon: Icon(Icons.lunch_dining),
                  ),
                  ButtonSegment(
                    value: 'dinner',
                    label: Text('Dinner'),
                    icon: Icon(Icons.dinner_dining),
                  ),
                ],
                selected: {_selectedMealType},
                onSelectionChanged: (selection) {
                  setState(() => _selectedMealType = selection.first);
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _servingsController,
                      decoration: const InputDecoration(
                        labelText: 'Servings',
                        prefixIcon: Icon(Icons.people),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _prepTimeController,
                      decoration: const InputDecoration(
                        labelText: 'Prep time (min)',
                        prefixIcon: Icon(Icons.timer),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Ingredients',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ingredientController,
                      decoration: const InputDecoration(
                        labelText: 'Add ingredient',
                        prefixIcon: Icon(Icons.add_circle_outline),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                      onFieldSubmitted: (_) => _addIngredient(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _addIngredient,
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (_ingredients.isNotEmpty)
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: _ingredients.asMap().entries.map((entry) {
                    return Chip(
                      label: Text(entry.value),
                      onDeleted: () {
                        setState(() => _ingredients.removeAt(entry.key));
                      },
                    );
                  }).toList(),
                ),
              if (_ingredients.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'No ingredients added yet',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _instructionsController,
                decoration: const InputDecoration(
                  labelText: 'Instructions',
                  prefixIcon: Icon(Icons.notes),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _submit,
                icon: Icon(_isEditing ? Icons.save : Icons.add),
                label: Text(_isEditing ? 'Save Changes' : 'Add Recipe'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addIngredient() {
    final text = _ingredientController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _ingredients.add(text);
      _ingredientController.clear();
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_ingredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one ingredient'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final recipe = Recipe(
      id: widget.editRecipe?.id ?? IdGenerator.generate(),
      name: _nameController.text.trim(),
      mealType: _selectedMealType,
      ingredients: List.from(_ingredients),
      instructions: _instructionsController.text.trim(),
      servings: int.tryParse(_servingsController.text) ?? 2,
      prepTimeMinutes: int.tryParse(_prepTimeController.text) ?? 30,
    );

    if (_isEditing) {
      ref.read(recipesProvider.notifier).updateRecipe(recipe);
    } else {
      ref.read(recipesProvider.notifier).addRecipe(recipe);
    }

    Navigator.pop(context);
  }
}
