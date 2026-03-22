import 'package:fridgeiq/features/auth/domain/entities/app_user.dart';

abstract class AuthRepository {
  Future<AppUser?> signInWithGoogle();
  Future<AppUser?> signInWithEmailPassword(String email, String password);
  Future<AppUser?> signUpWithEmailPassword(
      String email, String password, String displayName);
  Future<void> sendPasswordResetEmail(String email);
  Future<void> sendEmailVerification();
  Future<bool> checkEmailVerified();
  Future<void> signOut();
  Future<AppUser?> getCurrentUser();
  Future<void> saveUser(AppUser user);
  Future<AppUser?> getUserById(String id);
}
