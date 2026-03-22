import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fridgeiq/core/utils/date_utils.dart';
import 'package:fridgeiq/core/widgets/expiration_badge.dart';
import 'package:fridgeiq/features/family/presentation/providers/family_providers.dart';
import 'package:fridgeiq/features/food_inventory/domain/entities/food_item.dart';
import 'package:fridgeiq/features/food_inventory/domain/entities/storage_location.dart';
import 'package:fridgeiq/features/food_inventory/presentation/providers/food_inventory_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expiringItems = ref.watch(expiringItemsProvider);
    final allItems = ref.watch(foodInventoryProvider);
    final currentFamily = ref.watch(currentFamilyProvider);
    final familyName = currentFamily.whenData((f) => f?.name ?? 'FridgeIQ');

    return Scaffold(
      appBar: AppBar(
        title: Text(familyName.valueOrNull ?? 'FridgeIQ'),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InventorySummaryCard(allItems: allItems),
            const SizedBox(height: 16),
            Text(
              'Expiring Soon',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            expiringItems.when(
              data: (items) {
                if (items.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green, size: 32),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'No items expiring soon. You\'re all set!',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return Column(
                  children: items.map((item) {
                    final colorScheme = Theme.of(context).colorScheme;
                    final isExpired =
                        AppDateUtils.isExpired(item.expirationDate);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      color: isExpired
                          ? colorScheme.errorContainer.withOpacity(0.3)
                          : null,
                      child: ListTile(
                        leading: Icon(
                          item.location.icon,
                          color: isExpired
                              ? colorScheme.error
                              : colorScheme.primary,
                        ),
                        title: Text(item.name),
                        subtitle: Text(item.location.displayName),
                        trailing: ExpirationBadge(
                          expirationDate: item.expirationDate,
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Text('Error: $error'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InventorySummaryCard extends StatelessWidget {
  const _InventorySummaryCard({required this.allItems});

  final AsyncValue<List<FoodItem>> allItems;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return allItems.when(
      data: (items) {
        final fridgeCount = items
            .where((i) => i.location == StorageLocation.fridge)
            .length;
        final pantryCount = items
            .where((i) => i.location == StorageLocation.pantry)
            .length;
        final freezerCount = items
            .where((i) => i.location == StorageLocation.freezer)
            .length;
        final unplacedCount = items
            .where((i) => i.location == StorageLocation.unplaced)
            .length;

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Card(
                    color: colorScheme.primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(
                            Icons.kitchen,
                            size: 32,
                            color: colorScheme.onPrimaryContainer,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$fridgeCount',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  color: colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            'In Fridge',
                            style: TextStyle(
                              color: colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Card(
                    color: colorScheme.secondaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(
                            Icons.inventory_2,
                            size: 32,
                            color: colorScheme.onSecondaryContainer,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$pantryCount',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  color: colorScheme.onSecondaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            'In Pantry',
                            style: TextStyle(
                              color: colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Card(
                    color: colorScheme.tertiaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(
                            Icons.ac_unit,
                            size: 32,
                            color: colorScheme.onTertiaryContainer,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$freezerCount',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  color: colorScheme.onTertiaryContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            'In Freezer',
                            style: TextStyle(
                              color: colorScheme.onTertiaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (unplacedCount > 0) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: Card(
                      color: colorScheme.surfaceContainerHighest,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            Icon(
                              Icons.inbox,
                              size: 32,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '$unplacedCount',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              'Unplaced',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}
