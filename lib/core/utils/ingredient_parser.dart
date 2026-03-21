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

    // Pattern: optional quantity (number), optional unit, then the name
    // Examples: "2 kg chicken", "3 eggs", "1.5 l milk", "salt"
    final regex = RegExp(
      r'^(\d+(?:[.,]\d+)?)\s*'  // quantity (e.g., "2", "1.5", "0,5")
      r'([a-záéíóöőúüűA-ZÁÉÍÓÖŐÚÜŰ]+)?\s*'  // optional unit
      r'(.+)?$',  // remaining name
    );

    final match = regex.firstMatch(trimmed);

    if (match == null) {
      // No number found, entire string is the name
      return ParsedIngredient(name: trimmed);
    }

    final quantityStr = match.group(1)!.replaceAll(',', '.');
    final quantity = double.tryParse(quantityStr) ?? 1;
    final possibleUnit = match.group(2)?.toLowerCase();
    final remainingName = match.group(3)?.trim();

    if (possibleUnit != null && _knownUnits.contains(possibleUnit)) {
      // We have a valid unit
      return ParsedIngredient(
        name: remainingName?.isNotEmpty == true ? remainingName! : possibleUnit,
        quantity: quantity,
        unit: possibleUnit,
      );
    } else if (possibleUnit != null) {
      // The "unit" is actually part of the name (e.g., "3 eggs" → possibleUnit="eggs")
      final fullName = remainingName?.isNotEmpty == true
          ? '$possibleUnit $remainingName'
          : possibleUnit;
      return ParsedIngredient(
        name: fullName,
        quantity: quantity,
      );
    } else {
      // Only a number and a name
      return ParsedIngredient(
        name: remainingName ?? trimmed,
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
