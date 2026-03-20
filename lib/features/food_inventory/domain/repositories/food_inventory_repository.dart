import 'package:fridgeiq/features/food_inventory/domain/entities/food_item.dart';
import 'package:fridgeiq/features/food_inventory/domain/entities/storage_location.dart';

abstract class FoodInventoryRepository {
  Future<List<FoodItem>> getAllItems();
  Future<List<FoodItem>> getItemsByLocation(StorageLocation location);
  Future<List<FoodItem>> getExpiringItems({int withinDays = 3});
  Future<FoodItem?> getItemByBarcode(String barcode);
  Future<void> addItem(FoodItem item);
  Future<void> updateItem(FoodItem item);
  Future<void> deleteItem(String id);
  Future<void> deleteAllExpired();
}
