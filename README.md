# FridgeIQ

Smart food inventory management app with expiration tracking, barcode scanning, meal suggestions, and shopping lists.

## Features

- **Food Inventory** — Store food items in your fridge or pantry with expiration dates, quantities, and categories
- **Barcode Scanner** — Scan barcodes to quickly add items to your inventory
- **Expiration Tracking** — Get visual alerts when items are expiring soon or already expired
- **Meal Suggestions** — Add recipes and see which ingredients you already have at home vs. what you need to buy
- **Shopping List** — Manually add items or auto-populate from missing recipe ingredients

## Architecture

Built with **Clean Architecture** and a feature-based folder structure:

```
lib/
├── core/                          # Shared utilities, theme, widgets, constants
├── features/
│   ├── barcode_scanner/           # Barcode scanning feature
│   ├── food_inventory/            # Food item CRUD with fridge/pantry locations
│   │   ├── data/                  # Models, data sources, repository implementations
│   │   ├── domain/                # Entities, repository interfaces
│   │   └── presentation/          # Providers, screens, widgets
│   ├── home/                      # Dashboard with expiring items overview
│   ├── meal_suggestion/           # Recipe management and ingredient matching
│   └── shopping_list/             # Shopping list with check-off functionality
├── app.dart                       # App shell with bottom navigation
└── main.dart                      # Entry point with Hive & Riverpod setup
```

## Tech Stack

- **Flutter** with Material 3 design
- **Riverpod** for state management
- **Hive** for local storage
- **mobile_scanner** for barcode scanning
- **intl** for date formatting

## Getting Started

```bash
flutter pub get
flutter run
```
