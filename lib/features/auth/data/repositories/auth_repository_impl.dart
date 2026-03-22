import 'package:fridgeiq/core/services/firebase_auth_service.dart';
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

    // Try to sign in via Firebase Auth if API key is configured
    bool emailVerified = false;
    final authService = _dataSource.createAuthService();
    if (authService != null) {
      try {
        final googleAuth = await account.authentication;
        if (googleAuth.idToken != null) {
          final result = await authService.signInWithGoogle(
            idToken: googleAuth.idToken!,
          );
          final idToken = result['idToken'] as String?;
          if (idToken != null) {
            await _dataSource.saveFirebaseIdToken(idToken);
            // Check email verified status
            try {
              final userData = await authService.getUserData(idToken);
              emailVerified = userData['emailVerified'] as bool? ?? false;
            } catch (_) {
              // If lookup fails, treat as unverified
            }
          }
        }
      } catch (_) {
        // Firebase Auth sign-in failed, continue with Google-only flow
      }
    }

    // Check if user already exists in Firebase RTDB
    var existingModel = await _dataSource.getUserById(userId);

    if (existingModel != null) {
      // Update display info but keep familyIds
      final updatedModel = AppUserModel(
        id: userId,
        email: account.email,
        displayName: account.displayName ?? account.email,
        photoUrl: account.photoUrl,
        familyIds: existingModel.familyIds,
        emailVerified: emailVerified,
      );
      await _dataSource.saveUser(updatedModel);
      await _dataSource.saveCurrentUserId(userId);
      return updatedModel.toEntity();
    }

    // New user - needs verification
    final newModel = AppUserModel(
      id: userId,
      email: account.email,
      displayName: account.displayName ?? account.email,
      photoUrl: account.photoUrl,
      familyIds: [],
      emailVerified: emailVerified,
    );
    await _dataSource.saveUser(newModel);
    await _dataSource.saveCurrentUserId(userId);

    // Send email verification for new Google users
    if (!emailVerified && authService != null) {
      try {
        final idToken = _dataSource.getFirebaseIdToken();
        if (idToken != null) {
          await authService.sendEmailVerification(idToken);
        }
      } catch (_) {
        // Verification email sending failed, user can retry later
      }
    }

    return newModel.toEntity();
  }

  @override
  Future<AppUser?> signInWithEmailPassword(
      String email, String password) async {
    final authService = _dataSource.createAuthService();
    if (authService == null) {
      throw Exception(
          'Firebase API key not configured. Please set it in Settings.');
    }

    final result = await authService.signInWithEmailPassword(
      email: email,
      password: password,
    );

    final firebaseUid = result['localId'] as String;
    final idToken = result['idToken'] as String?;

    if (idToken != null) {
      await _dataSource.saveFirebaseIdToken(idToken);
    }

    // Check email verification
    bool emailVerified = false;
    if (idToken != null) {
      try {
        final userData = await authService.getUserData(idToken);
        emailVerified = userData['emailVerified'] as bool? ?? false;
      } catch (_) {
        // Verification check failed; treat as unverified
      }
    }

    // Look up or create user in RTDB
    var existingModel = await _dataSource.getUserById(firebaseUid);
    if (existingModel != null) {
      final updatedModel = AppUserModel(
        id: firebaseUid,
        email: email,
        displayName: existingModel.displayName,
        photoUrl: existingModel.photoUrl,
        familyIds: existingModel.familyIds,
        emailVerified: emailVerified,
      );
      await _dataSource.saveUser(updatedModel);
      await _dataSource.saveCurrentUserId(firebaseUid);
      return updatedModel.toEntity();
    }

    // User exists in Auth but not in RTDB (shouldn't normally happen)
    final newModel = AppUserModel(
      id: firebaseUid,
      email: email,
      displayName: email.split('@').first,
      familyIds: [],
      emailVerified: emailVerified,
    );
    await _dataSource.saveUser(newModel);
    await _dataSource.saveCurrentUserId(firebaseUid);
    return newModel.toEntity();
  }

  @override
  Future<AppUser?> signUpWithEmailPassword(
      String email, String password, String displayName) async {
    final authService = _dataSource.createAuthService();
    if (authService == null) {
      throw Exception(
          'Firebase API key not configured. Please set it in Settings.');
    }

    final result = await authService.signUpWithEmailPassword(
      email: email,
      password: password,
    );

    final firebaseUid = result['localId'] as String;
    final idToken = result['idToken'] as String?;

    if (idToken != null) {
      await _dataSource.saveFirebaseIdToken(idToken);
      // Send verification email
      try {
        await authService.sendEmailVerification(idToken);
      } catch (_) {
        // Verification email failed to send; user can resend from verification screen
      }
    }

    final newModel = AppUserModel(
      id: firebaseUid,
      email: email,
      displayName: displayName,
      familyIds: [],
      emailVerified: false,
    );
    await _dataSource.saveUser(newModel);
    await _dataSource.saveCurrentUserId(firebaseUid);
    return newModel.toEntity();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    final authService = _dataSource.createAuthService();
    if (authService == null) {
      throw Exception(
          'Firebase API key not configured. Please set it in Settings.');
    }
    await authService.sendPasswordResetEmail(email);
  }

  @override
  Future<void> sendEmailVerification() async {
    final authService = _dataSource.createAuthService();
    if (authService == null) {
      throw Exception(
          'Firebase API key not configured. Please set it in Settings.');
    }
    final idToken = _dataSource.getFirebaseIdToken();
    if (idToken == null) {
      throw Exception('No active session. Please sign in again.');
    }
    await authService.sendEmailVerification(idToken);
  }

  @override
  Future<bool> checkEmailVerified() async {
    final authService = _dataSource.createAuthService();
    if (authService == null) return true; // No Firebase Auth → skip check

    final idToken = _dataSource.getFirebaseIdToken();
    if (idToken == null) return false;

    try {
      final userData = await authService.getUserData(idToken);
      final verified = userData['emailVerified'] as bool? ?? false;

      // Update user in RTDB if verified
      if (verified) {
        final userId = _dataSource.getCurrentUserId();
        if (userId != null) {
          final existingModel = await _dataSource.getUserById(userId);
          if (existingModel != null && !existingModel.emailVerified) {
            final updatedModel = AppUserModel(
              id: existingModel.id,
              email: existingModel.email,
              displayName: existingModel.displayName,
              photoUrl: existingModel.photoUrl,
              familyIds: existingModel.familyIds,
              emailVerified: true,
            );
            await _dataSource.saveUser(updatedModel);
          }
        }
      }

      return verified;
    } catch (_) {
      return false;
    }
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
