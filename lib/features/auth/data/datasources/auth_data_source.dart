import 'package:flutter/services.dart';
import 'package:fridgeiq/core/services/firebase_auth_service.dart';
import 'package:fridgeiq/core/services/firebase_database_service.dart';
import 'package:fridgeiq/features/auth/data/models/app_user_model.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:fridgeiq/core/constants/app_constants.dart';

class AuthDataSource {
  final FirebaseDatabaseService _firebaseService;
  final GoogleSignIn _googleSignIn;

  AuthDataSource(this._firebaseService, {GoogleSignIn? googleSignIn})
      : _googleSignIn = googleSignIn ?? GoogleSignIn(scopes: ['email', 'profile']);

  static const _collection = 'users';
  static const _currentUserKey = 'current_user_id';
  static const _firebaseIdTokenKey = 'firebase_id_token';

  Future<GoogleSignInAccount?> signInWithGoogle() async {
    try {
      return await _googleSignIn.signIn();
    } on PlatformException catch (e) {
      if (e.code == 'sign_in_canceled') {
        return null;
      }
      throw PlatformException(
        code: e.code,
        message: 'Google Sign-In failed. Please ensure Google Play Services '
            'is up to date and try again.',
        details: e.details,
      );
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    final box = Hive.box<String>(AppConstants.settingsBoxName);
    await box.delete(_currentUserKey);
    await box.delete(_firebaseIdTokenKey);
  }

  String? getCurrentUserId() {
    final box = Hive.box<String>(AppConstants.settingsBoxName);
    return box.get(_currentUserKey);
  }

  Future<void> saveCurrentUserId(String userId) async {
    final box = Hive.box<String>(AppConstants.settingsBoxName);
    await box.put(_currentUserKey, userId);
  }

  String? getFirebaseIdToken() {
    final box = Hive.box<String>(AppConstants.settingsBoxName);
    return box.get(_firebaseIdTokenKey);
  }

  Future<void> saveFirebaseIdToken(String token) async {
    final box = Hive.box<String>(AppConstants.settingsBoxName);
    await box.put(_firebaseIdTokenKey, token);
  }

  Future<void> saveUser(AppUserModel model) async {
    await _firebaseService.put(_collection, model.id, model.toMap());
  }

  Future<AppUserModel?> getUserById(String id) async {
    final map = await _firebaseService.getById(_collection, id);
    if (map == null) return null;
    return AppUserModel.fromMap(map);
  }

  /// Gets the Firebase Auth API key from Hive settings.
  String? getFirebaseApiKey() {
    try {
      final box = Hive.box<String>(AppConstants.settingsBoxName);
      return box.get(AppConstants.firebaseApiKeySettingKey);
    } catch (_) {
      return null;
    }
  }

  /// Saves the Firebase Auth API key to Hive settings.
  Future<void> saveFirebaseApiKey(String apiKey) async {
    final box = Hive.box<String>(AppConstants.settingsBoxName);
    await box.put(AppConstants.firebaseApiKeySettingKey, apiKey);
  }

  /// Creates a [FirebaseAuthService] using the stored API key.
  FirebaseAuthService? createAuthService() {
    final apiKey = getFirebaseApiKey();
    if (apiKey == null || apiKey.isEmpty) return null;
    return FirebaseAuthService(apiKey: apiKey);
  }
}
