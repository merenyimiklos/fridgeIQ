import 'package:fridgeiq/features/food_inventory/domain/entities/storage_location.dart';

class FoodItem {
  final String id;
  final String name;
  final String? barcode;
  final StorageLocation location;
  final DateTime expirationDate;
  final int quantity;
  final String? category;
  final DateTime createdAt;

  const FoodItem({
    required this.id,
    required this.name,
    this.barcode,
    required this.location,
    required this.expirationDate,
    this.quantity = 1,
    this.category,
    required this.createdAt,
  });

  FoodItem copyWith({
    String? id,
    String? name,
    String? barcode,
    StorageLocation? location,
    DateTime? expirationDate,
    int? quantity,
    String? category,
    DateTime? createdAt,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      barcode: barcode ?? this.barcode,
      location: location ?? this.location,
      expirationDate: expirationDate ?? this.expirationDate,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
