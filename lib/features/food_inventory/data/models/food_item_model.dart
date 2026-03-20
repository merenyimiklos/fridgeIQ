import 'package:fridgeiq/features/food_inventory/domain/entities/food_item.dart';
import 'package:fridgeiq/features/food_inventory/domain/entities/storage_location.dart';

class FoodItemModel {
  final String id;
  final String name;
  final String? barcode;
  final int locationIndex;
  final DateTime expirationDate;
  final int quantity;
  final String? category;
  final DateTime createdAt;

  const FoodItemModel({
    required this.id,
    required this.name,
    this.barcode,
    required this.locationIndex,
    required this.expirationDate,
    this.quantity = 1,
    this.category,
    required this.createdAt,
  });

  factory FoodItemModel.fromEntity(FoodItem entity) {
    return FoodItemModel(
      id: entity.id,
      name: entity.name,
      barcode: entity.barcode,
      locationIndex: entity.location.index,
      expirationDate: entity.expirationDate,
      quantity: entity.quantity,
      category: entity.category,
      createdAt: entity.createdAt,
    );
  }

  FoodItem toEntity() {
    return FoodItem(
      id: id,
      name: name,
      barcode: barcode,
      location: StorageLocation.values[locationIndex],
      expirationDate: expirationDate,
      quantity: quantity,
      category: category,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'barcode': barcode,
      'locationIndex': locationIndex,
      'expirationDate': expirationDate.toIso8601String(),
      'quantity': quantity,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FoodItemModel.fromMap(Map<dynamic, dynamic> map) {
    return FoodItemModel(
      id: map['id'] as String,
      name: map['name'] as String,
      barcode: map['barcode'] as String?,
      locationIndex: map['locationIndex'] as int,
      expirationDate: DateTime.parse(map['expirationDate'] as String),
      quantity: map['quantity'] as int? ?? 1,
      category: map['category'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
