import 'package:fridgeiq/core/utils/id_generator.dart';
import 'package:fridgeiq/features/family/data/datasources/family_data_source.dart';
import 'package:fridgeiq/features/family/data/models/family_model.dart';
import 'package:fridgeiq/features/family/domain/entities/family.dart';
import 'package:fridgeiq/features/family/domain/repositories/family_repository.dart';

class FamilyRepositoryImpl implements FamilyRepository {
  final FamilyDataSource _dataSource;

  FamilyRepositoryImpl(this._dataSource);

  @override
  Future<Family> createFamily(String name, String createdByUserId) async {
    final id = IdGenerator.generate();
    final inviteCode = _dataSource.generateInviteCode();

    final model = FamilyModel(
      id: id,
      name: name,
      createdBy: createdByUserId,
      inviteCode: inviteCode,
      memberIds: [createdByUserId],
    );

    await _dataSource.saveFamily(model);
    await _dataSource.saveInviteCode(inviteCode, id);
    return model.toEntity();
  }

  @override
  Future<Family?> joinFamilyByCode(String inviteCode, String userId) async {
    final familyId =
        await _dataSource.getFamilyIdByInviteCode(inviteCode.toUpperCase());
    if (familyId == null) return null;

    final familyModel = await _dataSource.getFamilyById(familyId);
    if (familyModel == null) return null;

    // Check if user is already a member
    if (familyModel.memberIds.contains(userId)) {
      return familyModel.toEntity();
    }

    final updatedModel = FamilyModel(
      id: familyModel.id,
      name: familyModel.name,
      createdBy: familyModel.createdBy,
      inviteCode: familyModel.inviteCode,
      memberIds: [...familyModel.memberIds, userId],
    );

    await _dataSource.saveFamily(updatedModel);
    return updatedModel.toEntity();
  }

  @override
  Future<Family?> getFamilyById(String id) async {
    final model = await _dataSource.getFamilyById(id);
    return model?.toEntity();
  }

  @override
  Future<List<Family>> getFamiliesForUser(List<String> familyIds) async {
    final families = <Family>[];
    for (final id in familyIds) {
      final model = await _dataSource.getFamilyById(id);
      if (model != null) {
        families.add(model.toEntity());
      }
    }
    return families;
  }

  @override
  Future<void> updateFamily(Family family) async {
    await _dataSource.saveFamily(FamilyModel.fromEntity(family));
  }

  @override
  Future<void> leaveFamily(String familyId, String userId) async {
    final model = await _dataSource.getFamilyById(familyId);
    if (model == null) return;

    final updatedMemberIds =
        model.memberIds.where((id) => id != userId).toList();
    final updatedModel = FamilyModel(
      id: model.id,
      name: model.name,
      createdBy: model.createdBy,
      inviteCode: model.inviteCode,
      memberIds: updatedMemberIds,
    );
    await _dataSource.saveFamily(updatedModel);
  }
}
