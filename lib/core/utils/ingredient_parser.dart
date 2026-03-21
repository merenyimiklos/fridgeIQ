/// Parsed ingredient with separated name, quantity, and unit.
class ParsedIngredient {
  final String name;
  final double quantity;
  final String? unit;

  const ParsedIngredient({
    required this.name,
    this.quantity = 1,
    this.unit,
  });
}

/// Utility class to parse ingredient strings into structured data.
///
/// Handles formats like:
/// - "2 kg chicken breast" → (name: "chicken breast", quantity: 2, unit: "kg")
/// - "3 eggs" → (name: "eggs", quantity: 3, unit: null)
/// - "1.5 l milk" → (name: "milk", quantity: 1.5, unit: "l")
/// - "salt" → (name: "salt", quantity: 1, unit: null)
/// - "2 cups flour" → (name: "flour", quantity: 2, unit: "cups")
class IngredientParser {
  IngredientParser._();

  static const _knownUnits = {
    'kg', 'g', 'dkg', 'mg',
    'l', 'dl', 'cl', 'ml',
    'db', 'pcs', 'piece', 'pieces',
    'cup', 'cups',
    'tbsp', 'tsp',
    'oz', 'lb',
    'csomag', 'szelet', 'gerezd', 'csésze',
    'kanál', 'evőkanál', 'teáskanál', 'kávéskanál',
  };

  /// Parses an ingredient string into a [ParsedIngredient].
  static ParsedIngredient parse(String ingredient) {
    final trimmed = ingredient.trim();
    if (trimmed.isEmpty) {
      return const ParsedIngredient(name: '');
    }

    // Try to extract a leading number (e.g., "2", "1.5", "0,5")
    final numberRegex = RegExp(r'^(\d+(?:[.,]\d+)?)\s*(.*)$');
    final numberMatch = numberRegex.firstMatch(trimmed);

    if (numberMatch == null) {
      // No number found, entire string is the name
      return ParsedIngredient(name: trimmed);
    }

    final quantityStr = numberMatch.group(1)!.replaceAll(',', '.');
    final quantity = double.tryParse(quantityStr) ?? 1;
    final remainder = numberMatch.group(2)?.trim() ?? '';

    if (remainder.isEmpty) {
      return ParsedIngredient(name: trimmed, quantity: quantity);
    }

    // Check if the first word of the remainder is a known unit
    final words = remainder.split(RegExp(r'\s+'));
    final firstWord = words.first.toLowerCase();

    if (_knownUnits.contains(firstWord)) {
      // The first word is a unit, the rest is the ingredient name
      final name = words.length > 1 ? words.sublist(1).join(' ') : firstWord;
      return ParsedIngredient(
        name: name,
        quantity: quantity,
        unit: firstWord,
      );
    } else {
      // No known unit, the entire remainder is the ingredient name
      return ParsedIngredient(
        name: remainder,
        quantity: quantity,
      );
    }
  }

  /// Formats a quantity and unit for display.
  static String formatQuantity(double quantity, String? unit) {
    final qtyStr = quantity == quantity.roundToDouble()
        ? quantity.toInt().toString()
        : quantity.toStringAsFixed(1);

    if (unit != null && unit.isNotEmpty) {
      return '$qtyStr $unit';
    }
    return '×$qtyStr';
  }
}
