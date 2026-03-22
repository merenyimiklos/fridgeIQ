class Family {
  final String id;
  final String name;
  final String createdBy;
  final String inviteCode;
  final List<String> memberIds;

  const Family({
    required this.id,
    required this.name,
    required this.createdBy,
    required this.inviteCode,
    this.memberIds = const [],
  });

  Family copyWith({
    String? id,
    String? name,
    String? createdBy,
    String? inviteCode,
    List<String>? memberIds,
  }) {
    return Family(
      id: id ?? this.id,
      name: name ?? this.name,
      createdBy: createdBy ?? this.createdBy,
      inviteCode: inviteCode ?? this.inviteCode,
      memberIds: memberIds ?? this.memberIds,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Family && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
