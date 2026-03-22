import 'package:fridgeiq/features/auth/domain/entities/app_user.dart';

abstract class AuthRepository {
  Future<AppUser?> signInWithGoogle();
  Future<void> signOut();
  Future<AppUser?> getCurrentUser();
  Future<void> saveUser(AppUser user);
  Future<AppUser?> getUserById(String id);
}
