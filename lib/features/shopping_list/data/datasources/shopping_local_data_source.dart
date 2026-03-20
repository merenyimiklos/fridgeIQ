import 'package:fridgeiq/core/constants/app_constants.dart';
import 'package:fridgeiq/core/services/firebase_database_service.dart';
import 'package:fridgeiq/features/shopping_list/data/models/shopping_item_model.dart';

class ShoppingLocalDataSource {
  final FirebaseDatabaseService _firebaseService;

  ShoppingLocalDataSource(this._firebaseService);

  static const _collection = AppConstants.shoppingBoxName;

  Future<List<ShoppingItemModel>> getAllItems() async {
    final data = await _firebaseService.getAll(_collection);
    return data.values.map((map) => ShoppingItemModel.fromMap(map)).toList();
  }

  Future<void> saveItem(ShoppingItemModel model) async {
    await _firebaseService.put(_collection, model.id, model.toMap());
  }

  Future<void> deleteItem(String id) async {
    await _firebaseService.delete(_collection, id);
  }

  Future<void> deleteAll(List<String> ids) async {
    await _firebaseService.deleteAll(_collection, ids);
  }
}
