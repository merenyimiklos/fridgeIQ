import 'package:fridgeiq/features/auth/domain/entities/app_user.dart';

class AppUserModel {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final List<String> familyIds;

  const AppUserModel({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.familyIds = const [],
  });

  factory AppUserModel.fromEntity(AppUser entity) {
    return AppUserModel(
      id: entity.id,
      email: entity.email,
      displayName: entity.displayName,
      photoUrl: entity.photoUrl,
      familyIds: entity.familyIds,
    );
  }

  AppUser toEntity() {
    return AppUser(
      id: id,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      familyIds: familyIds,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'familyIds': familyIds,
    };
  }

  factory AppUserModel.fromMap(Map<dynamic, dynamic> map) {
    return AppUserModel(
      id: map['id'] as String,
      email: map['email'] as String,
      displayName: map['displayName'] as String,
      photoUrl: map['photoUrl'] as String?,
      familyIds: (map['familyIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}
