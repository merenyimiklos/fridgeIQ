class ShoppingItem {
  final String id;
  final String name;
  final bool isChecked;
  final int quantity;
  final String? note;
  final DateTime createdAt;

  const ShoppingItem({
    required this.id,
    required this.name,
    this.isChecked = false,
    this.quantity = 1,
    this.note,
    required this.createdAt,
  });

  ShoppingItem copyWith({
    String? id,
    String? name,
    bool? isChecked,
    int? quantity,
    String? note,
    DateTime? createdAt,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      isChecked: isChecked ?? this.isChecked,
      quantity: quantity ?? this.quantity,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShoppingItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
