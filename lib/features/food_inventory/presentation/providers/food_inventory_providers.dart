import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fridgeiq/core/constants/app_constants.dart';
import 'package:fridgeiq/core/services/firebase_database_service.dart';
import 'package:fridgeiq/core/utils/date_utils.dart';
import 'package:fridgeiq/features/food_inventory/data/datasources/food_local_data_source.dart';
import 'package:fridgeiq/features/food_inventory/data/repositories/food_inventory_repository_impl.dart';
import 'package:fridgeiq/features/food_inventory/domain/entities/food_item.dart';
import 'package:fridgeiq/features/food_inventory/domain/entities/storage_location.dart';
import 'package:fridgeiq/features/food_inventory/domain/repositories/food_inventory_repository.dart';

final firebaseDatabaseServiceProvider = Provider<FirebaseDatabaseService>((ref) {
  return FirebaseDatabaseService();
});

final foodLocalDataSourceProvider = Provider<FoodLocalDataSource>((ref) {
  return FoodLocalDataSource(ref.watch(firebaseDatabaseServiceProvider));
});

final foodInventoryRepositoryProvider =
    Provider<FoodInventoryRepository>((ref) {
  return FoodInventoryRepositoryImpl(ref.watch(foodLocalDataSourceProvider));
});

final foodInventoryProvider =
    AsyncNotifierProvider<FoodInventoryNotifier, List<FoodItem>>(
  FoodInventoryNotifier.new,
);

class FoodInventoryNotifier extends AsyncNotifier<List<FoodItem>> {
  @override
  Future<List<FoodItem>> build() async {
    return ref.watch(foodInventoryRepositoryProvider).getAllItems();
  }

  Future<void> addItem(FoodItem item) async {
    final repo = ref.read(foodInventoryRepositoryProvider);
    await repo.addItem(item);
    ref.invalidateSelf();
  }

  Future<void> updateItem(FoodItem item) async {
    final repo = ref.read(foodInventoryRepositoryProvider);
    await repo.updateItem(item);
    ref.invalidateSelf();
  }

  Future<void> deleteItem(String id) async {
    final repo = ref.read(foodInventoryRepositoryProvider);
    await repo.deleteItem(id);
    ref.invalidateSelf();
  }

  Future<void> deleteAllExpired() async {
    final repo = ref.read(foodInventoryRepositoryProvider);
    await repo.deleteAllExpired();
    ref.invalidateSelf();
  }
}

final selectedLocationFilterProvider =
    StateProvider<StorageLocation?>((ref) => null);

final filteredFoodItemsProvider = Provider<AsyncValue<List<FoodItem>>>((ref) {
  final allItems = ref.watch(foodInventoryProvider);
  final filter = ref.watch(selectedLocationFilterProvider);

  return allItems.whenData((items) {
    if (filter == null) return items;
    return items.where((item) => item.location == filter).toList();
  });
});

final expiringItemsProvider = Provider<AsyncValue<List<FoodItem>>>((ref) {
  final allItems = ref.watch(foodInventoryProvider);
  return allItems.whenData((items) {
    return items.where((item) {
      return AppDateUtils.isExpired(item.expirationDate) ||
          AppDateUtils.isExpiringSoon(
            item.expirationDate,
            warningDays: AppConstants.expirationWarningDays,
          );
    }).toList();
  });
});
