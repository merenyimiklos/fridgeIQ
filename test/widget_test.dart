import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fridgeiq/features/auth/domain/entities/app_user.dart';
import 'package:fridgeiq/features/auth/presentation/providers/auth_providers.dart';
import 'package:fridgeiq/features/family/presentation/providers/family_providers.dart';
import 'package:fridgeiq/app.dart';

void main() {
  testWidgets('FridgeIQ app shows login screen when not authenticated',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith(() => _MockAuthNotifier(null)),
        ],
        child: const FridgeIQApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('FridgeIQ'), findsOneWidget);
    expect(find.text('Sign in with Google'), findsOneWidget);
  });

  testWidgets(
      'FridgeIQ app shows create/join family screen when authenticated but no family',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith(() => _MockAuthNotifier(
                const AppUser(
                  id: 'test-id',
                  email: 'test@test.com',
                  displayName: 'Test User',
                  familyIds: [],
                ),
              )),
          currentFamilyIdProvider
              .overrideWith((ref) => _MockCurrentFamilyIdNotifier(null)),
        ],
        child: const FridgeIQApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Create or Join a Family'), findsOneWidget);
  });

  testWidgets(
      'FridgeIQ app shows main navigation when authenticated with family',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith(() => _MockAuthNotifier(
                const AppUser(
                  id: 'test-id',
                  email: 'test@test.com',
                  displayName: 'Test User',
                  familyIds: ['family-1'],
                ),
              )),
          currentFamilyIdProvider
              .overrideWith((ref) => _MockCurrentFamilyIdNotifier('family-1')),
        ],
        child: const FridgeIQApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Inventory'), findsOneWidget);
    expect(find.text('Meals'), findsOneWidget);
    expect(find.text('Shopping'), findsOneWidget);
  });
}

class _MockAuthNotifier extends AsyncNotifier<AppUser?>
    implements AuthNotifier {
  final AppUser? _user;
  _MockAuthNotifier(this._user);

  @override
  Future<AppUser?> build() async => _user;

  @override
  Future<AppUser?> signInWithGoogle() async => _user;

  @override
  Future<void> signOut() async {}

  @override
  Future<void> refreshUser() async {}

  @override
  Future<void> updateUser(AppUser user) async {}
}

class _MockCurrentFamilyIdNotifier extends CurrentFamilyIdNotifier {
  _MockCurrentFamilyIdNotifier(String? initialValue) : super() {
    state = initialValue;
  }

  @override
  void setFamily(String familyId) {
    state = familyId;
  }

  @override
  void clear() {
    state = null;
  }
}
