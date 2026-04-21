/// Item categories available for listings.
///
/// Matches the CHECK constraint on the `listings.category` column.
/// Using an enum prevents invalid category strings at compile time.
enum ItemCategory {
  furniture,
  electronics,
  instruments,
  books,
  clothing,
  sports,
  other;

  /// Display label for UI rendering.
  String get label {
    switch (this) {
      case ItemCategory.furniture:
        return 'Furniture';
      case ItemCategory.electronics:
        return 'Electronics';
      case ItemCategory.instruments:
        return 'Instruments';
      case ItemCategory.books:
        return 'Books';
      case ItemCategory.clothing:
        return 'Clothing';
      case ItemCategory.sports:
        return 'Sports';
      case ItemCategory.other:
        return 'Other';
    }
  }
}
