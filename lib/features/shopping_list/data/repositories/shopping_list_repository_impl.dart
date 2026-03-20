import 'package:fridgeiq/features/shopping_list/data/datasources/shopping_local_data_source.dart';
import 'package:fridgeiq/features/shopping_list/data/models/shopping_item_model.dart';
import 'package:fridgeiq/features/shopping_list/domain/entities/shopping_item.dart';
import 'package:fridgeiq/features/shopping_list/domain/repositories/shopping_list_repository.dart';

class ShoppingListRepositoryImpl implements ShoppingListRepository {
  final ShoppingLocalDataSource _dataSource;

  ShoppingListRepositoryImpl(this._dataSource);

  @override
  Future<List<ShoppingItem>> getAllItems() async {
    final models = await _dataSource.getAllItems();
    final items = models.map((m) => m.toEntity()).toList();
    items.sort((a, b) {
      if (a.isChecked != b.isChecked) return a.isChecked ? 1 : -1;
      return b.createdAt.compareTo(a.createdAt);
    });
    return items;
  }

  @override
  Future<void> addItem(ShoppingItem item) async {
    await _dataSource.saveItem(ShoppingItemModel.fromEntity(item));
  }

  @override
  Future<void> updateItem(ShoppingItem item) async {
    await _dataSource.saveItem(ShoppingItemModel.fromEntity(item));
  }

  @override
  Future<void> deleteItem(String id) async {
    await _dataSource.deleteItem(id);
  }

  @override
  Future<void> deleteCheckedItems() async {
    final all = await getAllItems();
    final checkedIds =
        all.where((item) => item.isChecked).map((item) => item.id).toList();
    await _dataSource.deleteAll(checkedIds);
  }
}
