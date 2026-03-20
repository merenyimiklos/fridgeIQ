import 'package:fridgeiq/features/shopping_list/domain/entities/shopping_item.dart';

class ShoppingItemModel {
  final String id;
  final String name;
  final bool isChecked;
  final int quantity;
  final String? note;
  final DateTime createdAt;

  const ShoppingItemModel({
    required this.id,
    required this.name,
    this.isChecked = false,
    this.quantity = 1,
    this.note,
    required this.createdAt,
  });

  factory ShoppingItemModel.fromEntity(ShoppingItem entity) {
    return ShoppingItemModel(
      id: entity.id,
      name: entity.name,
      isChecked: entity.isChecked,
      quantity: entity.quantity,
      note: entity.note,
      createdAt: entity.createdAt,
    );
  }

  ShoppingItem toEntity() {
    return ShoppingItem(
      id: id,
      name: name,
      isChecked: isChecked,
      quantity: quantity,
      note: note,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'isChecked': isChecked,
      'quantity': quantity,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ShoppingItemModel.fromMap(Map<dynamic, dynamic> map) {
    return ShoppingItemModel(
      id: map['id'] as String,
      name: map['name'] as String,
      isChecked: map['isChecked'] as bool? ?? false,
      quantity: map['quantity'] as int? ?? 1,
      note: map['note'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
}
