import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fridgeiq/core/widgets/empty_state_widget.dart';
import 'package:fridgeiq/features/barcode_scanner/presentation/screens/barcode_scanner_screen.dart';
import 'package:fridgeiq/features/food_inventory/domain/entities/storage_location.dart';
import 'package:fridgeiq/features/food_inventory/presentation/providers/food_inventory_providers.dart';
import 'package:fridgeiq/features/food_inventory/presentation/widgets/add_food_item_sheet.dart';
import 'package:fridgeiq/features/food_inventory/presentation/widgets/food_item_tile.dart';

class FoodInventoryScreen extends ConsumerWidget {
  const FoodInventoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredItems = ref.watch(filteredFoodItemsProvider);
    final selectedFilter = ref.watch(selectedLocationFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Inventory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Scan Barcode',
            onPressed: () => _scanBarcode(context),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'delete_expired') {
                _confirmDeleteExpired(context, ref);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'delete_expired',
                child: Text('Remove expired items'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _FilterChip(
                    label: 'All',
                    selected: selectedFilter == null,
                    onSelected: (_) => ref
                        .read(selectedLocationFilterProvider.notifier)
                        .state = null,
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Unplaced',
                    selected: selectedFilter == StorageLocation.unplaced,
                    onSelected: (_) => ref
                        .read(selectedLocationFilterProvider.notifier)
                        .state = StorageLocation.unplaced,
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Fridge',
                    selected: selectedFilter == StorageLocation.fridge,
                    onSelected: (_) => ref
                        .read(selectedLocationFilterProvider.notifier)
                        .state = StorageLocation.fridge,
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Pantry',
                    selected: selectedFilter == StorageLocation.pantry,
                    onSelected: (_) => ref
                        .read(selectedLocationFilterProvider.notifier)
                        .state = StorageLocation.pantry,
                  ),
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: 'Freezer',
                    selected: selectedFilter == StorageLocation.freezer,
                    onSelected: (_) => ref
                        .read(selectedLocationFilterProvider.notifier)
                        .state = StorageLocation.freezer,
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: filteredItems.when(
              data: (items) {
                if (items.isEmpty) {
                  return const EmptyStateWidget(
                    icon: Icons.kitchen,
                    title: 'No items yet',
                    subtitle: 'Add food items to track their expiration dates',
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    return FoodItemTile(
                      item: items[index],
                      onDelete: () => ref
                          .read(foodInventoryProvider.notifier)
                          .deleteItem(items[index].id),
                      onEdit: () => _showEditSheet(context, ref, items[index]),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
      ),
    );
  }

  void _showAddSheet(BuildContext context, {String? barcode}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => AddFoodItemSheet(initialBarcode: barcode),
    );
  }

  void _showEditSheet(BuildContext context, WidgetRef ref, dynamic item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => AddFoodItemSheet(editItem: item),
    );
  }

  Future<void> _scanBarcode(BuildContext context) async {
    final barcode = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const BarcodeScannerScreen()),
    );
    if (barcode != null && context.mounted) {
      _showAddSheet(context, barcode: barcode);
    }
  }

  void _confirmDeleteExpired(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Expired Items'),
        content: const Text(
          'Are you sure you want to remove all expired items?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(foodInventoryProvider.notifier).deleteAllExpired();
              Navigator.pop(context);
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
    );
  }
}
