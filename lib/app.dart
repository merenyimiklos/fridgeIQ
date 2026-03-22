import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fridgeiq/core/theme/app_theme.dart';
import 'package:fridgeiq/features/auth/presentation/providers/auth_providers.dart';
import 'package:fridgeiq/features/auth/presentation/screens/login_screen.dart';
import 'package:fridgeiq/features/family/presentation/providers/family_providers.dart';
import 'package:fridgeiq/features/family/presentation/screens/create_join_family_screen.dart';
import 'package:fridgeiq/features/family/presentation/widgets/family_drawer.dart';
import 'package:fridgeiq/features/home/presentation/screens/home_screen.dart';
import 'package:fridgeiq/features/food_inventory/presentation/screens/food_inventory_screen.dart';
import 'package:fridgeiq/features/meal_suggestion/presentation/screens/meal_suggestion_screen.dart';
import 'package:fridgeiq/features/shopping_list/presentation/screens/shopping_list_screen.dart';

class FridgeIQApp extends StatelessWidget {
  const FridgeIQApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FridgeIQ',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const AuthGate(),
    );
  }
}

/// Decides which screen to show based on auth and family state.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          return const LoginScreen();
        }

        final currentFamilyId = ref.watch(currentFamilyIdProvider);
        if (currentFamilyId == null || user.familyIds.isEmpty) {
          return const CreateJoinFamilyScreen();
        }

        return const AppShell();
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (_, __) => const LoginScreen(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  static const _screens = [
    HomeScreen(),
    FoodInventoryScreen(),
    MealSuggestionScreen(),
    ShoppingListScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const FamilyDrawer(),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.kitchen_outlined),
            selectedIcon: Icon(Icons.kitchen),
            label: 'Inventory',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu),
            label: 'Meals',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            selectedIcon: Icon(Icons.shopping_cart),
            label: 'Shopping',
          ),
        ],
      ),
    );
  }
}
