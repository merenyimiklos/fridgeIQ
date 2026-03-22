import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fridgeiq/features/auth/data/datasources/auth_data_source.dart';
import 'package:fridgeiq/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:fridgeiq/features/auth/domain/entities/app_user.dart';
import 'package:fridgeiq/features/auth/domain/repositories/auth_repository.dart';
import 'package:fridgeiq/features/food_inventory/presentation/providers/food_inventory_providers.dart';

final authDataSourceProvider = Provider<AuthDataSource>((ref) {
  return AuthDataSource(ref.watch(firebaseDatabaseServiceProvider));
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(authDataSourceProvider));
});

final authStateProvider =
    AsyncNotifierProvider<AuthNotifier, AppUser?>(AuthNotifier.new);

class AuthNotifier extends AsyncNotifier<AppUser?> {
  @override
  Future<AppUser?> build() async {
    return ref.watch(authRepositoryProvider).getCurrentUser();
  }

  Future<AppUser?> signInWithGoogle() async {
    state = const AsyncLoading();
    try {
      final user =
          await ref.read(authRepositoryProvider).signInWithGoogle();
      state = AsyncData(user);
      return user;
    } catch (e, s) {
      state = AsyncError(e, s);
      return null;
    }
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    state = const AsyncData(null);
  }

  Future<void> refreshUser() async {
    final user = await ref.read(authRepositoryProvider).getCurrentUser();
    state = AsyncData(user);
  }

  Future<void> updateUser(AppUser user) async {
    await ref.read(authRepositoryProvider).saveUser(user);
    state = AsyncData(user);
  }
}
