enum StorageLocation {
  fridge,
  pantry;

  String get displayName {
    switch (this) {
      case StorageLocation.fridge:
        return 'Fridge';
      case StorageLocation.pantry:
        return 'Pantry';
    }
  }
}
