import 'package:flutter/material.dart';

enum StorageLocation {
  fridge,
  pantry,
  freezer,
  unplaced;

  String get displayName {
    switch (this) {
      case StorageLocation.fridge:
        return 'Fridge';
      case StorageLocation.pantry:
        return 'Pantry';
      case StorageLocation.freezer:
        return 'Freezer';
      case StorageLocation.unplaced:
        return 'Unplaced';
    }
  }

  /// Returns the icon for this storage location.
  IconData get icon {
    switch (this) {
      case StorageLocation.fridge:
        return Icons.kitchen;
      case StorageLocation.pantry:
        return Icons.inventory_2;
      case StorageLocation.freezer:
        return Icons.ac_unit;
      case StorageLocation.unplaced:
        return Icons.inbox;
    }
  }

  /// Whether this is an assigned (placed) location.
  bool get isPlaced => this != StorageLocation.unplaced;
}
