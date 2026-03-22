class AppUser {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final List<String> familyIds;

  const AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.familyIds = const [],
  });

  AppUser copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    List<String>? familyIds,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      familyIds: familyIds ?? this.familyIds,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppUser && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
