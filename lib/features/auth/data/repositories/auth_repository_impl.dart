import 'package:fridgeiq/features/auth/data/datasources/auth_data_source.dart';
import 'package:fridgeiq/features/auth/data/models/app_user_model.dart';
import 'package:fridgeiq/features/auth/domain/entities/app_user.dart';
import 'package:fridgeiq/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource _dataSource;

  AuthRepositoryImpl(this._dataSource);

  @override
  Future<AppUser?> signInWithGoogle() async {
    final account = await _dataSource.signInWithGoogle();
    if (account == null) return null;

    final userId = account.id;

    // Check if user already exists in Firebase
    var existingModel = await _dataSource.getUserById(userId);

    if (existingModel != null) {
      // Update display info but keep familyIds
      final updatedModel = AppUserModel(
        id: userId,
        email: account.email,
        displayName: account.displayName ?? account.email,
        photoUrl: account.photoUrl,
        familyIds: existingModel.familyIds,
      );
      await _dataSource.saveUser(updatedModel);
      await _dataSource.saveCurrentUserId(userId);
      return updatedModel.toEntity();
    }

    // New user
    final newModel = AppUserModel(
      id: userId,
      email: account.email,
      displayName: account.displayName ?? account.email,
      photoUrl: account.photoUrl,
      familyIds: [],
    );
    await _dataSource.saveUser(newModel);
    await _dataSource.saveCurrentUserId(userId);
    return newModel.toEntity();
  }

  @override
  Future<void> signOut() async {
    await _dataSource.signOut();
  }

  @override
  Future<AppUser?> getCurrentUser() async {
    final userId = _dataSource.getCurrentUserId();
    if (userId == null) return null;
    final model = await _dataSource.getUserById(userId);
    return model?.toEntity();
  }

  @override
  Future<void> saveUser(AppUser user) async {
    await _dataSource.saveUser(AppUserModel.fromEntity(user));
  }

  @override
  Future<AppUser?> getUserById(String id) async {
    final model = await _dataSource.getUserById(id);
    return model?.toEntity();
  }
}
