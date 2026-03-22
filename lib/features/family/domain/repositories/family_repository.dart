import 'package:fridgeiq/features/family/domain/entities/family.dart';

abstract class FamilyRepository {
  Future<Family> createFamily(String name, String createdByUserId);
  Future<Family?> joinFamilyByCode(String inviteCode, String userId);
  Future<Family?> getFamilyById(String id);
  Future<List<Family>> getFamiliesForUser(List<String> familyIds);
  Future<void> updateFamily(Family family);
  Future<void> leaveFamily(String familyId, String userId);
}
