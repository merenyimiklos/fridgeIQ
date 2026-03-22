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

  Future<AppUser?> signInWithEmailPassword(
      String email, String password) async {
    state = const AsyncLoading();
    try {
      final user = await ref
          .read(authRepositoryProvider)
          .signInWithEmailPassword(email, password);
      state = AsyncData(user);
      return user;
    } catch (e, s) {
      state = AsyncError(e, s);
      rethrow;
    }
  }

  Future<AppUser?> signUpWithEmailPassword(
      String email, String password, String displayName) async {
    state = const AsyncLoading();
    try {
      final user = await ref
          .read(authRepositoryProvider)
          .signUpWithEmailPassword(email, password, displayName);
      state = AsyncData(user);
      return user;
    } catch (e, s) {
      state = AsyncError(e, s);
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await ref.read(authRepositoryProvider).sendPasswordResetEmail(email);
  }

  Future<void> sendEmailVerification() async {
    await ref.read(authRepositoryProvider).sendEmailVerification();
  }

  Future<bool> checkEmailVerified() async {
    final verified =
        await ref.read(authRepositoryProvider).checkEmailVerified();
    if (verified) {
      final currentUser = state.valueOrNull;
      if (currentUser != null && !currentUser.emailVerified) {
        final updatedUser = currentUser.copyWith(emailVerified: true);
        await ref.read(authRepositoryProvider).saveUser(updatedUser);
        state = AsyncData(updatedUser);
      }
    }
    return verified;
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
