import 'package:fridgeiq/features/family/domain/entities/family.dart';

class FamilyModel {
  final String id;
  final String name;
  final String createdBy;
  final String inviteCode;
  final List<String> memberIds;

  const FamilyModel({
    required this.id,
    required this.name,
    required this.createdBy,
    required this.inviteCode,
    this.memberIds = const [],
  });

  factory FamilyModel.fromEntity(Family entity) {
    return FamilyModel(
      id: entity.id,
      name: entity.name,
      createdBy: entity.createdBy,
      inviteCode: entity.inviteCode,
      memberIds: entity.memberIds,
    );
  }

  Family toEntity() {
    return Family(
      id: id,
      name: name,
      createdBy: createdBy,
      inviteCode: inviteCode,
      memberIds: memberIds,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'createdBy': createdBy,
      'inviteCode': inviteCode,
      'memberIds': memberIds,
    };
  }

  factory FamilyModel.fromMap(Map<dynamic, dynamic> map) {
    return FamilyModel(
      id: map['id'] as String,
      name: map['name'] as String,
      createdBy: map['createdBy'] as String,
      inviteCode: map['inviteCode'] as String,
      memberIds: (map['memberIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}
