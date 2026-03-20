import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fridgeiq/features/shopping_list/data/datasources/shopping_local_data_source.dart';
import 'package:fridgeiq/features/shopping_list/data/repositories/shopping_list_repository_impl.dart';
import 'package:fridgeiq/features/shopping_list/domain/entities/shopping_item.dart';
import 'package:fridgeiq/features/shopping_list/domain/repositories/shopping_list_repository.dart';

final shoppingLocalDataSourceProvider =
    Provider<ShoppingLocalDataSource>((ref) {
  return ShoppingLocalDataSource();
});

final shoppingListRepositoryProvider =
    Provider<ShoppingListRepository>((ref) {
  return ShoppingListRepositoryImpl(
    ref.watch(shoppingLocalDataSourceProvider),
  );
});

final shoppingListProvider =
    AsyncNotifierProvider<ShoppingListNotifier, List<ShoppingItem>>(
  ShoppingListNotifier.new,
);

class ShoppingListNotifier extends AsyncNotifier<List<ShoppingItem>> {
  @override
  Future<List<ShoppingItem>> build() async {
    return ref.watch(shoppingListRepositoryProvider).getAllItems();
  }

  Future<void> addItem(ShoppingItem item) async {
    final repo = ref.read(shoppingListRepositoryProvider);
    await repo.addItem(item);
    ref.invalidateSelf();
  }

  Future<void> addItems(List<ShoppingItem> items) async {
    final repo = ref.read(shoppingListRepositoryProvider);
    for (final item in items) {
      await repo.addItem(item);
    }
    ref.invalidateSelf();
  }

  Future<void> toggleItem(ShoppingItem item) async {
    final repo = ref.read(shoppingListRepositoryProvider);
    await repo.updateItem(item.copyWith(isChecked: !item.isChecked));
    ref.invalidateSelf();
  }

  Future<void> updateItem(ShoppingItem item) async {
    final repo = ref.read(shoppingListRepositoryProvider);
    await repo.updateItem(item);
    ref.invalidateSelf();
  }

  Future<void> deleteItem(String id) async {
    final repo = ref.read(shoppingListRepositoryProvider);
    await repo.deleteItem(id);
    ref.invalidateSelf();
  }

  Future<void> deleteCheckedItems() async {
    final repo = ref.read(shoppingListRepositoryProvider);
    await repo.deleteCheckedItems();
    ref.invalidateSelf();
  }
}
