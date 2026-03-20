import 'package:hive/hive.dart';
import 'package:fridgeiq/core/constants/app_constants.dart';
import 'package:fridgeiq/features/shopping_list/data/models/shopping_item_model.dart';

class ShoppingLocalDataSource {
  Box<Map>? _box;

  Future<Box<Map>> get box async {
    _box ??= await Hive.openBox<Map>(AppConstants.shoppingBoxName);
    return _box!;
  }

  Future<List<ShoppingItemModel>> getAllItems() async {
    final b = await box;
    return b.values.map((map) => ShoppingItemModel.fromMap(map)).toList();
  }

  Future<void> saveItem(ShoppingItemModel model) async {
    final b = await box;
    await b.put(model.id, model.toMap());
  }

  Future<void> deleteItem(String id) async {
    final b = await box;
    await b.delete(id);
  }

  Future<void> deleteAll(List<String> ids) async {
    final b = await box;
    await b.deleteAll(ids);
  }
}
