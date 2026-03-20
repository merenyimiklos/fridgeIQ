import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fridgeiq/core/constants/app_constants.dart';
import 'package:fridgeiq/core/utils/date_utils.dart';
import 'package:fridgeiq/core/utils/id_generator.dart';
import 'package:fridgeiq/features/food_inventory/domain/entities/food_item.dart';
import 'package:fridgeiq/features/food_inventory/domain/entities/storage_location.dart';
import 'package:fridgeiq/features/food_inventory/presentation/providers/food_inventory_providers.dart';

class AddFoodItemSheet extends ConsumerStatefulWidget {
  const AddFoodItemSheet({super.key, this.editItem, this.initialBarcode});

  final FoodItem? editItem;
  final String? initialBarcode;

  @override
  ConsumerState<AddFoodItemSheet> createState() => _AddFoodItemSheetState();
}

class _AddFoodItemSheetState extends ConsumerState<AddFoodItemSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _barcodeController;
  late final TextEditingController _quantityController;
  late final TextEditingController _categoryController;
  late StorageLocation _selectedLocation;
  late DateTime _selectedDate;

  bool get _isEditing => widget.editItem != null;

  @override
  void initState() {
    super.initState();
    final item = widget.editItem;
    _nameController = TextEditingController(text: item?.name ?? '');
    _barcodeController = TextEditingController(
      text: item?.barcode ?? widget.initialBarcode ?? '',
    );
    _quantityController = TextEditingController(
      text: (item?.quantity ?? 1).toString(),
    );
    _categoryController = TextEditingController(text: item?.category ?? '');
    _selectedLocation = item?.location ?? StorageLocation.fridge;
    _selectedDate = item?.expirationDate ??
        DateTime.now().add(const Duration(days: AppConstants.defaultExpirationDays));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _barcodeController.dispose();
    _quantityController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _isEditing ? 'Edit Food Item' : 'Add Food Item',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  prefixIcon: Icon(Icons.fastfood),
                ),
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _barcodeController,
                decoration: const InputDecoration(
                  labelText: 'Barcode (optional)',
                  prefixIcon: Icon(Icons.qr_code),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      decoration: const InputDecoration(
                        labelText: 'Quantity',
                        prefixIcon: Icon(Icons.numbers),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) return null;
                        final parsed = int.tryParse(value);
                        if (parsed == null || parsed < 1) {
                          return 'Enter a valid quantity';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _categoryController,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        prefixIcon: Icon(Icons.label_outline),
                      ),
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SegmentedButton<StorageLocation>(
                segments: const [
                  ButtonSegment(
                    value: StorageLocation.fridge,
                    label: Text('Fridge'),
                    icon: Icon(Icons.kitchen),
                  ),
                  ButtonSegment(
                    value: StorageLocation.pantry,
                    label: Text('Pantry'),
                    icon: Icon(Icons.inventory_2),
                  ),
                ],
                selected: {_selectedLocation},
                onSelectionChanged: (selection) {
                  setState(() => _selectedLocation = selection.first);
                },
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('Expiration Date'),
                subtitle: Text(AppDateUtils.formatForDisplay(_selectedDate)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                onTap: _pickDate,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _submit,
                icon: Icon(_isEditing ? Icons.save : Icons.add),
                label: Text(_isEditing ? 'Save Changes' : 'Add Item'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final item = FoodItem(
      id: widget.editItem?.id ?? IdGenerator.generate(),
      name: _nameController.text.trim(),
      barcode: _barcodeController.text.trim().isEmpty
          ? null
          : _barcodeController.text.trim(),
      location: _selectedLocation,
      expirationDate: _selectedDate,
      quantity: int.tryParse(_quantityController.text) ?? 1,
      category: _categoryController.text.trim().isEmpty
          ? null
          : _categoryController.text.trim(),
      createdAt: widget.editItem?.createdAt ?? DateTime.now(),
    );

    if (_isEditing) {
      ref.read(foodInventoryProvider.notifier).updateItem(item);
    } else {
      ref.read(foodInventoryProvider.notifier).addItem(item);
    }

    Navigator.pop(context);
  }
}
