import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fridgeiq/core/constants/app_constants.dart';
import 'package:fridgeiq/core/utils/id_generator.dart';
import 'package:fridgeiq/core/widgets/empty_state_widget.dart';
import 'package:fridgeiq/features/food_inventory/domain/entities/food_item.dart';
import 'package:fridgeiq/features/food_inventory/domain/entities/storage_location.dart';
import 'package:fridgeiq/features/food_inventory/presentation/providers/food_inventory_providers.dart';
import 'package:fridgeiq/features/shopping_list/domain/entities/shopping_item.dart';
import 'package:fridgeiq/features/shopping_list/presentation/providers/shopping_list_providers.dart';

class ShoppingListScreen extends ConsumerWidget {
  const ShoppingListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shoppingItems = ref.watch(shoppingListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping List'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'clear_checked') {
                _confirmClearChecked(context, ref);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'clear_checked',
                child: Text('Remove checked items'),
              ),
            ],
          ),
        ],
      ),
      body: shoppingItems.when(
        data: (items) {
          if (items.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.shopping_cart,
              title: 'Shopping list is empty',
              subtitle: 'Add items to your shopping list or get suggestions from recipes',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return _ShoppingItemTile(item: item);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddItemDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
      ),
    );
  }

  void _showAddItemDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Shopping Item'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Item name',
            hintText: 'e.g., Milk, Bread, Eggs...',
          ),
          textCapitalization: TextCapitalization.sentences,
          onSubmitted: (_) {
            _addItem(context, ref, controller.text);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => _addItem(context, ref, controller.text),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _addItem(BuildContext context, WidgetRef ref, String name) {
    if (name.trim().isEmpty) return;
    final item = ShoppingItem(
      id: IdGenerator.generate(),
      name: name.trim(),
      isChecked: false,
      createdAt: DateTime.now(),
    );
    ref.read(shoppingListProvider.notifier).addItem(item);
    Navigator.pop(context);
  }

  void _confirmClearChecked(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Checked Items'),
        content:
            const Text('Remove all checked items from the shopping list?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(shoppingListProvider.notifier).deleteCheckedItems();
              Navigator.pop(context);
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}

class _ShoppingItemTile extends ConsumerWidget {
  const _ShoppingItemTile({required this.item});

  final ShoppingItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) {
        ref.read(shoppingListProvider.notifier).deleteItem(item.id);
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: colorScheme.error,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.delete, color: colorScheme.onError),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: ListTile(
          leading: Checkbox(
            value: item.isChecked,
            onChanged: (_) {
              final willBeChecked = !item.isChecked;
              ref.read(shoppingListProvider.notifier).toggleItem(item);
              if (willBeChecked) {
                final foodItem = FoodItem(
                  id: IdGenerator.generate(),
                  name: item.name,
                  location: StorageLocation.unplaced,
                  expirationDate: DateTime.now().add(
                    const Duration(days: AppConstants.defaultExpirationDays),
                  ),
                  quantity: item.quantity,
                  createdAt: DateTime.now(),
                );
                ref.read(foodInventoryProvider.notifier).addItem(foodItem);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${item.name} added to inventory'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              }
            },
          ),
          title: Text(
            item.name,
            style: TextStyle(
              decoration: item.isChecked ? TextDecoration.lineThrough : null,
              color: item.isChecked ? colorScheme.outline : null,
            ),
          ),
          subtitle: item.note != null ? Text(item.note!) : null,
          trailing: item.quantity > 1
              ? Chip(label: Text('×${item.quantity}'))
              : null,
        ),
      ),
    );
  }
}
