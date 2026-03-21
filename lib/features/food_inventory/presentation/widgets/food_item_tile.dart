import 'package:flutter/material.dart';
import 'package:fridgeiq/core/utils/date_utils.dart';
import 'package:fridgeiq/core/utils/ingredient_parser.dart';
import 'package:fridgeiq/core/widgets/expiration_badge.dart';
import 'package:fridgeiq/features/food_inventory/domain/entities/food_item.dart';
import 'package:fridgeiq/features/food_inventory/domain/entities/storage_location.dart';

class FoodItemTile extends StatelessWidget {
  const FoodItemTile({
    super.key,
    required this.item,
    required this.onDelete,
    required this.onEdit,
  });

  final FoodItem item;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isExpired = AppDateUtils.isExpired(item.expirationDate);
    final isUnplaced = !item.location.isPlaced;

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
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
        color: isUnplaced
            ? colorScheme.tertiaryContainer.withOpacity(0.3)
            : null,
        child: InkWell(
          onTap: onEdit,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isExpired
                        ? colorScheme.errorContainer
                        : isUnplaced
                            ? colorScheme.tertiaryContainer
                            : colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    item.location.icon,
                    color: isExpired
                        ? colorScheme.onErrorContainer
                        : isUnplaced
                            ? colorScheme.onTertiaryContainer
                            : colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  decoration: isExpired
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.place,
                            size: 14,
                            color: isUnplaced
                                ? colorScheme.tertiary
                                : colorScheme.outline,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            isUnplaced
                                ? 'Tap to assign location'
                                : item.location.displayName,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: isUnplaced
                                      ? colorScheme.tertiary
                                      : colorScheme.outline,
                                  fontStyle: isUnplaced
                                      ? FontStyle.italic
                                      : null,
                                ),
                          ),
                          if (item.category != null) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.label_outline,
                              size: 14,
                              color: colorScheme.outline,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              item.category!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: colorScheme.outline),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ExpirationBadge(expirationDate: item.expirationDate),
                    const SizedBox(height: 4),
                    Text(
                      IngredientParser.formatQuantity(item.quantity, item.unit),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
