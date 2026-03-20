import 'package:fridgeiq/core/constants/app_constants.dart';
import 'package:fridgeiq/core/services/firebase_database_service.dart';
import 'package:fridgeiq/features/food_inventory/data/models/food_item_model.dart';

class FoodLocalDataSource {
  final FirebaseDatabaseService _firebaseService;

  FoodLocalDataSource(this._firebaseService);

  static const _collection = AppConstants.foodBoxName;

  Future<List<FoodItemModel>> getAllItems() async {
    final data = await _firebaseService.getAll(_collection);
    return data.values.map((map) => FoodItemModel.fromMap(map)).toList();
  }

  Future<FoodItemModel?> getItemById(String id) async {
    final map = await _firebaseService.getById(_collection, id);
    if (map == null) return null;
    return FoodItemModel.fromMap(map);
  }

  Future<void> saveItem(FoodItemModel model) async {
    await _firebaseService.put(_collection, model.id, model.toMap());
  }

  Future<void> deleteItem(String id) async {
    await _firebaseService.delete(_collection, id);
  }

  Future<void> deleteAll(List<String> ids) async {
    await _firebaseService.deleteAll(_collection, ids);
  }
}
