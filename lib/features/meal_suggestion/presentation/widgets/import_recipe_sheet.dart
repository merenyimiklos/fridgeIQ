import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:fridgeiq/core/utils/id_generator.dart';
import 'package:fridgeiq/features/meal_suggestion/domain/entities/recipe.dart';
import 'package:fridgeiq/features/meal_suggestion/presentation/providers/meal_suggestion_providers.dart';
import 'package:fridgeiq/features/meal_suggestion/presentation/widgets/add_recipe_sheet.dart';

class ImportRecipeSheet extends ConsumerStatefulWidget {
  const ImportRecipeSheet({super.key});

  @override
  ConsumerState<ImportRecipeSheet> createState() => _ImportRecipeSheetState();
}

class _ImportRecipeSheetState extends ConsumerState<ImportRecipeSheet> {
  final _urlController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _urlController.dispose();
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
              'Import from TikTok',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Paste a TikTok video link and we\'ll try to extract the recipe from the description.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'TikTok URL',
                prefixIcon: Icon(Icons.link),
                hintText: 'https://www.tiktok.com/@user/video/...',
              ),
              keyboardType: TextInputType.url,
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
              ),
            ],
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _isLoading ? null : _importFromUrl,
              icon: _isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.download),
              label: Text(_isLoading ? 'Importing...' : 'Import Recipe'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _importFromUrl() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      setState(() => _error = 'Please enter a URL');
      return;
    }

    if (!url.contains('tiktok.com')) {
      setState(() => _error = 'Please enter a valid TikTok URL');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final oEmbedUrl = Uri.parse(
          'https://www.tiktok.com/oembed?url=${Uri.encodeComponent(url)}');
      final response = await http.get(oEmbedUrl);

      if (response.statusCode != 200) {
        setState(() {
          _isLoading = false;
          _error =
              'Could not fetch video info. Please check the URL and try again.';
        });
        return;
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final title = data['title'] as String? ?? '';

      if (title.isEmpty) {
        setState(() {
          _isLoading = false;
          _error = 'No description found in this video.';
        });
        return;
      }

      final parsed = _parseRecipeFromText(title);

      if (!mounted) return;
      Navigator.pop(context);

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (context) => AddRecipeSheet(
          editRecipe: Recipe(
            id: IdGenerator.generate(),
            name: parsed.name,
            mealType: parsed.mealType,
            ingredients: parsed.ingredients,
            instructions: parsed.instructions,
            servings: parsed.servings,
            prepTimeMinutes: parsed.prepTimeMinutes,
          ),
          isNewFromImport: true,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = 'Failed to import. Please check your connection and try again.';
      });
    }
  }

  _ParsedRecipe _parseRecipeFromText(String text) {
    String name = '';
    String mealType = 'dinner';
    final ingredients = <String>[];
    String instructions = '';

    final lines = text.split(RegExp(r'[\n\r]+'));

    // Try to extract recipe name from first line or hashtags
    final hashtagRegex = RegExp(r'#(\w+)');
    final hashtags = hashtagRegex
        .allMatches(text)
        .map((m) => m.group(1)!.toLowerCase())
        .toList();

    // Determine meal type from hashtags or text
    if (hashtags.any((h) =>
        h.contains('lunch') || h.contains('ebéd') || h.contains('ebed'))) {
      mealType = 'lunch';
    }

    // Clean text of hashtags for processing
    final cleanText = text.replaceAll(hashtagRegex, '').trim();
    final cleanLines =
        cleanText.split(RegExp(r'[\n\r]+')).where((l) => l.trim().isNotEmpty).toList();

    if (cleanLines.isNotEmpty) {
      name = cleanLines.first.trim();
      if (name.length > 60) {
        name = name.substring(0, 60);
      }
    }

    if (name.isEmpty) {
      name = 'Imported Recipe';
    }

    // Try to find ingredient-like lines (lines starting with - or • or numbers)
    final ingredientPattern = RegExp(r'^[\s]*[-•*]\s*(.+)$');
    final numberedPattern = RegExp(r'^[\s]*\d+[.)]\s*(.+)$');
    bool foundIngredients = false;

    for (final line in lines) {
      final trimmed = line.trim();
      final ingredientMatch = ingredientPattern.firstMatch(trimmed);
      final numberedMatch = numberedPattern.firstMatch(trimmed);

      if (ingredientMatch != null) {
        final ingredient =
            ingredientMatch.group(1)!.replaceAll(hashtagRegex, '').trim();
        if (ingredient.isNotEmpty) {
          ingredients.add(ingredient);
          foundIngredients = true;
        }
      } else if (numberedMatch != null && !foundIngredients) {
        final ingredient =
            numberedMatch.group(1)!.replaceAll(hashtagRegex, '').trim();
        if (ingredient.isNotEmpty) {
          ingredients.add(ingredient);
        }
      }
    }

    // If no structured ingredients found, use the full text as instructions
    if (ingredients.isEmpty) {
      instructions = cleanText;
    } else {
      // Remaining text as instructions
      final ingredientSet = ingredients.map((i) => i.toLowerCase()).toSet();
      final instructionLines = cleanLines.where((line) {
        final trimmed = line.trim();
        final cleaned = trimmed
            .replaceAll(RegExp(r'^[-•*\d.)]+\s*'), '')
            .replaceAll(hashtagRegex, '')
            .trim();
        return !ingredientSet.contains(cleaned.toLowerCase()) &&
            trimmed != name;
      }).toList();
      if (instructionLines.isNotEmpty) {
        instructions = instructionLines.join('\n');
      }
    }

    return _ParsedRecipe(
      name: name,
      mealType: mealType,
      ingredients: ingredients,
      instructions: instructions,
    );
  }
}

class _ParsedRecipe {
  static const int defaultServings = 2;
  static const int defaultPrepTimeMinutes = 30;

  final String name;
  final String mealType;
  final List<String> ingredients;
  final String instructions;
  final int servings;
  final int prepTimeMinutes;

  const _ParsedRecipe({
    required this.name,
    required this.mealType,
    required this.ingredients,
    required this.instructions,
    this.servings = defaultServings,
    this.prepTimeMinutes = defaultPrepTimeMinutes,
  });
}
