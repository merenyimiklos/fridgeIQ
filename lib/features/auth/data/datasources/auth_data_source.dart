import 'package:fridgeiq/core/services/firebase_database_service.dart';
import 'package:fridgeiq/features/auth/data/models/app_user_model.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:fridgeiq/core/constants/app_constants.dart';

class AuthDataSource {
  final FirebaseDatabaseService _firebaseService;
  final GoogleSignIn _googleSignIn;

  AuthDataSource(this._firebaseService, {GoogleSignIn? googleSignIn})
      : _googleSignIn = googleSignIn ?? GoogleSignIn(scopes: ['email']);

  static const _collection = 'users';
  static const _currentUserKey = 'current_user_id';

  Future<GoogleSignInAccount?> signInWithGoogle() async {
    return _googleSignIn.signIn();
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    final box = Hive.box<String>(AppConstants.settingsBoxName);
    await box.delete(_currentUserKey);
  }

  String? getCurrentUserId() {
    final box = Hive.box<String>(AppConstants.settingsBoxName);
    return box.get(_currentUserKey);
  }

  Future<void> saveCurrentUserId(String userId) async {
    final box = Hive.box<String>(AppConstants.settingsBoxName);
    await box.put(_currentUserKey, userId);
  }

  Future<void> saveUser(AppUserModel model) async {
    await _firebaseService.put(_collection, model.id, model.toMap());
  }

  Future<AppUserModel?> getUserById(String id) async {
    final map = await _firebaseService.getById(_collection, id);
    if (map == null) return null;
    return AppUserModel.fromMap(map);
  }
}
