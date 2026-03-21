import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';

class ParsedRecipeIngredient {
  final String name;
  final double quantity;
  final String? unit;

  const ParsedRecipeIngredient({
    required this.name,
    this.quantity = 1,
    this.unit,
  });

  /// Formats the ingredient for display (e.g., "2 kg chicken breast").
  String get displayString {
    final qtyStr = quantity == quantity.roundToDouble()
        ? quantity.toInt().toString()
        : quantity.toStringAsFixed(1);
    if (unit != null && unit!.isNotEmpty) {
      return '$qtyStr $unit $name';
    }
    if (quantity != 1) {
      return '$qtyStr $name';
    }
    return name;
  }
}

class ParsedRecipeData {
  final String name;
  final String mealType;
  final List<String> ingredients;
  final List<ParsedRecipeIngredient> parsedIngredients;
  final String instructions;
  final int servings;
  final int prepTimeMinutes;

  const ParsedRecipeData({
    required this.name,
    required this.mealType,
    required this.ingredients,
    this.parsedIngredients = const [],
    required this.instructions,
    this.servings = 2,
    this.prepTimeMinutes = 30,
  });
}

class GeminiRecipeService {
  GeminiRecipeService(this._apiKey);

  final String _apiKey;

  Future<ParsedRecipeData> extractRecipe(String videoDescription) async {
    final model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: _apiKey,
    );

    final prompt = '''
You are a recipe extraction assistant. Based on the following TikTok video description, identify the recipe and provide a complete recipe with ingredients and instructions.

If the description only contains a recipe name or hashtags, use your knowledge to provide the full recipe.

TikTok video description:
"""
$videoDescription
"""

Respond ONLY with a valid JSON object in this exact format (no markdown, no code blocks, no extra text):
{"name":"Recipe Name","mealType":"lunch or dinner","ingredients":[{"name":"ingredient name","quantity":2,"unit":"kg"},{"name":"egg","quantity":3,"unit":null}],"instructions":"Step by step instructions","servings":2,"prepTimeMinutes":30}

Rules:
- "name": A clear, concise recipe name
- "mealType": Either "lunch" or "dinner" based on the dish type
- "ingredients": A list of ingredient objects, each with:
  - "name": The ingredient name only (e.g. "chicken breast", "flour", "egg")
  - "quantity": A number for the amount (e.g. 2, 0.5, 1)
  - "unit": The unit of measurement (e.g. "kg", "g", "l", "dl", "db", "cups", "tbsp", "tsp") or null if it's just a count
- "instructions": Clear step-by-step cooking instructions
- "servings": Number of servings (integer)
- "prepTimeMinutes": Estimated total preparation and cooking time in minutes (integer)

Important: Each ingredient MUST be a separate object. Do NOT put quantities or units in the ingredient name. Extract them into separate fields.
''';

    final response = await model.generateContent([Content.text(prompt)]);
    final text = response.text;

    if (text == null || text.isEmpty) {
      throw Exception('Empty response from AI');
    }

    return _parseJsonResponse(text);
  }

  ParsedRecipeData _parseJsonResponse(String text) {
    // Clean up the response - remove markdown code blocks if present
    var cleaned = text.trim();
    if (cleaned.startsWith('```')) {
      cleaned = cleaned.replaceFirst(RegExp(r'^```json?\s*'), '');
      cleaned = cleaned.replaceFirst(RegExp(r'\s*```$'), '');
    }
    cleaned = cleaned.trim();

    final Map<String, dynamic> json;
    try {
      json = jsonDecode(cleaned) as Map<String, dynamic>;
    } catch (e) {
      throw FormatException('Failed to parse AI response as JSON: $cleaned');
    }

    final name = (json['name'] as String?)?.trim() ?? 'Imported Recipe';

    var mealType = (json['mealType'] as String?)?.toLowerCase().trim() ?? 'dinner';
    if (mealType != 'lunch' && mealType != 'dinner') {
      mealType = 'dinner';
    }

    final rawIngredients = json['ingredients'] as List<dynamic>? ?? [];
    final parsedIngredients = <ParsedRecipeIngredient>[];
    final ingredientStrings = <String>[];

    for (final item in rawIngredients) {
      if (item is Map<String, dynamic>) {
        // Structured ingredient object
        final ingredientName = (item['name'] as String?)?.trim() ?? '';
        if (ingredientName.isEmpty) continue;
        final qty = (item['quantity'] as num?)?.toDouble() ?? 1;
        final unit = item['unit'] as String?;

        final parsed = ParsedRecipeIngredient(
          name: ingredientName,
          quantity: qty,
          unit: unit,
        );
        parsedIngredients.add(parsed);
        ingredientStrings.add(parsed.displayString);
      } else if (item is String) {
        // Fallback: plain string ingredient
        final trimmed = item.trim();
        if (trimmed.isNotEmpty) {
          ingredientStrings.add(trimmed);
          parsedIngredients.add(ParsedRecipeIngredient(name: trimmed));
        }
      }
    }

    final instructions =
        (json['instructions'] as String?)?.trim() ?? '';

    final servings = (json['servings'] as num?)?.toInt() ?? 2;
    final prepTimeMinutes = (json['prepTimeMinutes'] as num?)?.toInt() ?? 30;

    return ParsedRecipeData(
      name: name,
      mealType: mealType,
      ingredients: ingredientStrings,
      parsedIngredients: parsedIngredients,
      instructions: instructions,
      servings: servings,
      prepTimeMinutes: prepTimeMinutes,
    );
  }
}
