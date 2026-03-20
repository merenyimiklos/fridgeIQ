import 'dart:convert';

import 'package:google_generative_ai/google_generative_ai.dart';

class ParsedRecipeData {
  final String name;
  final String mealType;
  final List<String> ingredients;
  final String instructions;
  final int servings;
  final int prepTimeMinutes;

  const ParsedRecipeData({
    required this.name,
    required this.mealType,
    required this.ingredients,
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
{"name":"Recipe Name","mealType":"lunch or dinner","ingredients":["ingredient 1","ingredient 2"],"instructions":"Step by step instructions","servings":2,"prepTimeMinutes":30}

Rules:
- "name": A clear, concise recipe name
- "mealType": Either "lunch" or "dinner" based on the dish type
- "ingredients": A list of ingredients with quantities (e.g. "2 cups flour", "1 tbsp olive oil")
- "instructions": Clear step-by-step cooking instructions
- "servings": Number of servings (integer)
- "prepTimeMinutes": Estimated total preparation and cooking time in minutes (integer)
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
    final ingredients = rawIngredients
        .map((e) => (e as String).trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final instructions =
        (json['instructions'] as String?)?.trim() ?? '';

    final servings = (json['servings'] as num?)?.toInt() ?? 2;
    final prepTimeMinutes = (json['prepTimeMinutes'] as num?)?.toInt() ?? 30;

    return ParsedRecipeData(
      name: name,
      mealType: mealType,
      ingredients: ingredients,
      instructions: instructions,
      servings: servings,
      prepTimeMinutes: prepTimeMinutes,
    );
  }
}
