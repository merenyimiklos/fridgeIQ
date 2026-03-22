import 'package:flutter_riverpod/flutter_riverpod.dart' hide Family;
import 'package:hive/hive.dart';
import 'package:fridgeiq/core/constants/app_constants.dart';
import 'package:fridgeiq/features/auth/presentation/providers/auth_providers.dart';
import 'package:fridgeiq/features/family/data/datasources/family_data_source.dart';
import 'package:fridgeiq/features/family/data/repositories/family_repository_impl.dart';
import 'package:fridgeiq/features/family/domain/entities/family.dart';
import 'package:fridgeiq/features/family/domain/repositories/family_repository.dart';
import 'package:fridgeiq/features/food_inventory/presentation/providers/food_inventory_providers.dart';

final familyDataSourceProvider = Provider<FamilyDataSource>((ref) {
  return FamilyDataSource(ref.watch(firebaseDatabaseServiceProvider));
});

final familyRepositoryProvider = Provider<FamilyRepository>((ref) {
  return FamilyRepositoryImpl(ref.watch(familyDataSourceProvider));
});

/// The currently active family ID, stored in Hive settings.
final currentFamilyIdProvider =
    StateNotifierProvider<CurrentFamilyIdNotifier, String?>((ref) {
  return CurrentFamilyIdNotifier();
});

class CurrentFamilyIdNotifier extends StateNotifier<String?> {
  static const _key = 'current_family_id';

  CurrentFamilyIdNotifier() : super(null) {
    try {
      final box = Hive.box<String>(AppConstants.settingsBoxName);
      state = box.get(_key);
    } catch (_) {
      // Hive not initialized (e.g., in tests)
    }
  }

  void setFamily(String familyId) {
    try {
      final box = Hive.box<String>(AppConstants.settingsBoxName);
      box.put(_key, familyId);
    } catch (_) {}
    state = familyId;
  }

  void clear() {
    try {
      final box = Hive.box<String>(AppConstants.settingsBoxName);
      box.delete(_key);
    } catch (_) {}
    state = null;
  }
}

/// Provider for all families the current user belongs to.
final userFamiliesProvider =
    AsyncNotifierProvider<UserFamiliesNotifier, List<Family>>(
        UserFamiliesNotifier.new);

class UserFamiliesNotifier extends AsyncNotifier<List<Family>> {
  @override
  Future<List<Family>> build() async {
    final user = ref.watch(authStateProvider).valueOrNull;
    if (user == null) return [];
    final repo = ref.watch(familyRepositoryProvider);
    return repo.getFamiliesForUser(user.familyIds);
  }

  Future<Family> createFamily(String name) async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) throw Exception('Not signed in');

    final repo = ref.read(familyRepositoryProvider);
    final family = await repo.createFamily(name, user.id);

    // Update user's family list
    final authNotifier = ref.read(authStateProvider.notifier);
    final updatedUser =
        user.copyWith(familyIds: [...user.familyIds, family.id]);
    await authNotifier.updateUser(updatedUser);

    // Set as current family
    ref.read(currentFamilyIdProvider.notifier).setFamily(family.id);

    ref.invalidateSelf();
    return family;
  }

  Future<Family?> joinFamily(String inviteCode) async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) throw Exception('Not signed in');

    final repo = ref.read(familyRepositoryProvider);
    final family = await repo.joinFamilyByCode(inviteCode, user.id);
    if (family == null) return null;

    // Update user's family list if not already there
    if (!user.familyIds.contains(family.id)) {
      final authNotifier = ref.read(authStateProvider.notifier);
      final updatedUser =
          user.copyWith(familyIds: [...user.familyIds, family.id]);
      await authNotifier.updateUser(updatedUser);
    }

    // Set as current family
    ref.read(currentFamilyIdProvider.notifier).setFamily(family.id);

    ref.invalidateSelf();
    return family;
  }

  Future<void> leaveFamily(String familyId) async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;

    final repo = ref.read(familyRepositoryProvider);
    await repo.leaveFamily(familyId, user.id);

    // Update user's family list
    final authNotifier = ref.read(authStateProvider.notifier);
    final updatedFamilyIds =
        user.familyIds.where((id) => id != familyId).toList();
    final updatedUser = user.copyWith(familyIds: updatedFamilyIds);
    await authNotifier.updateUser(updatedUser);

    // If we left the current family, switch to another or clear
    final currentId = ref.read(currentFamilyIdProvider);
    if (currentId == familyId) {
      if (updatedFamilyIds.isNotEmpty) {
        ref
            .read(currentFamilyIdProvider.notifier)
            .setFamily(updatedFamilyIds.first);
      } else {
        ref.read(currentFamilyIdProvider.notifier).clear();
      }
    }

    ref.invalidateSelf();
  }

  Future<void> deleteFamily(String familyId) async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;

    final repo = ref.read(familyRepositoryProvider);
    final family = await repo.getFamilyById(familyId);
    if (family == null) return;

    // Only the creator can delete
    if (family.createdBy != user.id) {
      throw Exception('Only the family creator can delete this family');
    }

    // Remove familyId from all members' user records concurrently
    final authRepo = ref.read(authRepositoryProvider);
    await Future.wait(family.memberIds.map((memberId) async {
      final member = await authRepo.getUserById(memberId);
      if (member != null) {
        final updatedMemberFamilyIds =
            member.familyIds.where((id) => id != familyId).toList();
        await authRepo.saveUser(member.copyWith(familyIds: updatedMemberFamilyIds));
      }
    }));

    // Delete the family
    await repo.deleteFamily(familyId);

    // Update current user's state
    final updatedFamilyIds =
        user.familyIds.where((id) => id != familyId).toList();
    final updatedUser = user.copyWith(familyIds: updatedFamilyIds);
    await ref.read(authStateProvider.notifier).updateUser(updatedUser);

    // If we were in the deleted family, switch to another or clear
    final currentId = ref.read(currentFamilyIdProvider);
    if (currentId == familyId) {
      if (updatedFamilyIds.isNotEmpty) {
        ref
            .read(currentFamilyIdProvider.notifier)
            .setFamily(updatedFamilyIds.first);
      } else {
        ref.read(currentFamilyIdProvider.notifier).clear();
      }
    }

    ref.invalidateSelf();
  }

  Future<void> removeMember(String familyId, String memberId) async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;

    final repo = ref.read(familyRepositoryProvider);
    final family = await repo.getFamilyById(familyId);
    if (family == null) return;

    // Only the creator can kick members
    if (family.createdBy != user.id) {
      throw Exception('Only the family creator can remove members');
    }

    // Remove the member from the family
    await repo.removeMember(familyId, memberId);

    // Update the removed member's user record
    final authRepo = ref.read(authRepositoryProvider);
    final member = await authRepo.getUserById(memberId);
    if (member != null) {
      final updatedMemberFamilyIds =
          member.familyIds.where((id) => id != familyId).toList();
      await authRepo.saveUser(member.copyWith(familyIds: updatedMemberFamilyIds));
    }

    ref.invalidateSelf();
  }
}

/// Provider for the current active family details.
final currentFamilyProvider = Provider<AsyncValue<Family?>>((ref) {
  final familyId = ref.watch(currentFamilyIdProvider);
  if (familyId == null) return const AsyncData(null);

  final families = ref.watch(userFamiliesProvider);
  return families.whenData((list) {
    try {
      return list.firstWhere((f) => f.id == familyId);
    } catch (_) {
      return null;
    }
  });
});
