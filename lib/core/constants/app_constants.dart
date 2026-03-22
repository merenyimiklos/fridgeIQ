class AppConstants {
  AppConstants._();

  static const String appName = 'FridgeIQ';
  static const int expirationWarningDays = 3;
  static const int defaultExpirationDays = 7;
  static const String foodBoxName = 'food_items';
  static const String recipeBoxName = 'recipes';
  static const String shoppingBoxName = 'shopping_items';
  static const String reviewBoxName = 'recipe_reviews';
  static const String settingsBoxName = 'settings';
  static const String geminiApiKeySettingKey = 'gemini_api_key';

  static const String firebaseDatabaseUrl =
      'https://firedgeiq-default-rtdb.europe-west1.firebasedatabase.app';

  static const String firebaseApiKeySettingKey = 'firebase_api_key';
}
