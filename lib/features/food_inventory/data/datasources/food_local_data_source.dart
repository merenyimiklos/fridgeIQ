import 'package:hive/hive.dart';
import 'package:fridgeiq/core/constants/app_constants.dart';
import 'package:fridgeiq/features/food_inventory/data/models/food_item_model.dart';

class FoodLocalDataSource {
  Box<Map>? _box;

  Future<Box<Map>> get box async {
    _box ??= await Hive.openBox<Map>(AppConstants.foodBoxName);
    return _box!;
  }

  Future<List<FoodItemModel>> getAllItems() async {
    final b = await box;
    return b.values
        .map((map) => FoodItemModel.fromMap(map))
        .toList();
  }

  Future<FoodItemModel?> getItemById(String id) async {
    final b = await box;
    final map = b.get(id);
    if (map == null) return null;
    return FoodItemModel.fromMap(map);
  }

  Future<void> saveItem(FoodItemModel model) async {
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
