import 'dart:math';

import 'package:fridgeiq/core/services/firebase_database_service.dart';
import 'package:fridgeiq/features/family/data/models/family_model.dart';

class FamilyDataSource {
  final FirebaseDatabaseService _firebaseService;

  FamilyDataSource(this._firebaseService);

  static const _familiesCollection = 'families';
  static const _inviteCodesCollection = 'invite_codes';

  Future<void> saveFamily(FamilyModel model) async {
    await _firebaseService.put(_familiesCollection, model.id, model.toMap());
  }

  Future<FamilyModel?> getFamilyById(String id) async {
    final map = await _firebaseService.getById(_familiesCollection, id);
    if (map == null) return null;
    return FamilyModel.fromMap(map);
  }

  Future<void> saveInviteCode(String code, String familyId) async {
    await _firebaseService.put(
      _inviteCodesCollection,
      code,
      {'familyId': familyId},
    );
  }

  Future<String?> getFamilyIdByInviteCode(String code) async {
    final map = await _firebaseService.getById(_inviteCodesCollection, code);
    if (map == null) return null;
    return map['familyId'] as String?;
  }

  String generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    return List.generate(6, (_) => chars[random.nextInt(chars.length)]).join();
  }
}
