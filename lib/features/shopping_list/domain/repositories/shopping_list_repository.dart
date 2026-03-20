import 'package:fridgeiq/features/shopping_list/domain/entities/shopping_item.dart';

abstract class ShoppingListRepository {
  Future<List<ShoppingItem>> getAllItems();
  Future<void> addItem(ShoppingItem item);
  Future<void> updateItem(ShoppingItem item);
  Future<void> deleteItem(String id);
  Future<void> deleteCheckedItems();
}
