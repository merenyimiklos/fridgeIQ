import 'package:fridgeiq/core/utils/date_utils.dart';
import 'package:fridgeiq/features/food_inventory/data/datasources/food_local_data_source.dart';
import 'package:fridgeiq/features/food_inventory/data/models/food_item_model.dart';
import 'package:fridgeiq/features/food_inventory/domain/entities/food_item.dart';
import 'package:fridgeiq/features/food_inventory/domain/entities/storage_location.dart';
import 'package:fridgeiq/features/food_inventory/domain/repositories/food_inventory_repository.dart';

class FoodInventoryRepositoryImpl implements FoodInventoryRepository {
  final FoodLocalDataSource _dataSource;

  FoodInventoryRepositoryImpl(this._dataSource);

  @override
  Future<List<FoodItem>> getAllItems() async {
    final models = await _dataSource.getAllItems();
    return models.map((m) => m.toEntity()).toList()
      ..sort((a, b) => a.expirationDate.compareTo(b.expirationDate));
  }

  @override
  Future<List<FoodItem>> getItemsByLocation(StorageLocation location) async {
    final all = await getAllItems();
    return all.where((item) => item.location == location).toList();
  }

  @override
  Future<List<FoodItem>> getExpiringItems({int withinDays = 3}) async {
    final all = await getAllItems();
    return all.where((item) {
      final days = AppDateUtils.daysUntilExpiration(item.expirationDate);
      return days >= 0 && days <= withinDays;
    }).toList();
  }

  @override
  Future<FoodItem?> getItemByBarcode(String barcode) async {
    final all = await getAllItems();
    try {
      return all.firstWhere((item) => item.barcode == barcode);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> addItem(FoodItem item) async {
    await _dataSource.saveItem(FoodItemModel.fromEntity(item));
  }

  @override
  Future<void> updateItem(FoodItem item) async {
    await _dataSource.saveItem(FoodItemModel.fromEntity(item));
  }

  @override
  Future<void> deleteItem(String id) async {
    await _dataSource.deleteItem(id);
  }

  @override
  Future<void> deleteAllExpired() async {
    final all = await getAllItems();
    final expiredIds = all
        .where((item) => AppDateUtils.isExpired(item.expirationDate))
        .map((item) => item.id)
        .toList();
    await _dataSource.deleteAll(expiredIds);
  }
}
