import 'package:smivo/data/models/order.dart';

/// Formats the display price for an order.
///
/// NOTE: Rental orders have totalPrice = 0 before the seller accepts,
/// because the final price is calculated at acceptance time. To avoid
/// showing "$0" to users, we fall back to the listing's rental rates.
String formatOrderPrice(Order order) {
  if (order.totalPrice > 0) {
    return '\$${order.totalPrice.toStringAsFixed(0)}';
  }

  // Fallback for rental orders with zero total (pre-acceptance)
  if (order.orderType == 'rental' && order.listing != null) {
    final listing = order.listing!;
    final parts = <String>[];
    if (listing.rentalDailyPrice != null && listing.rentalDailyPrice! > 0) {
      parts.add('\$${listing.rentalDailyPrice!.toStringAsFixed(0)}/day');
    }
    if (listing.rentalWeeklyPrice != null && listing.rentalWeeklyPrice! > 0) {
      parts.add('\$${listing.rentalWeeklyPrice!.toStringAsFixed(0)}/wk');
    }
    if (listing.rentalMonthlyPrice != null && listing.rentalMonthlyPrice! > 0) {
      parts.add('\$${listing.rentalMonthlyPrice!.toStringAsFixed(0)}/mo');
    }
    if (parts.isNotEmpty) return parts.join(' · ');
  }

  return '\$${order.totalPrice.toStringAsFixed(0)}';
}

/// Returns a suitable price label for chat popup display.
///
/// For rental orders with $0 total, returns the rate string.
/// For sale orders, returns null (uses default listingPrice display).
String? formatOrderPriceLabel(Order order) {
  if (order.totalPrice > 0) return null;
  if (order.orderType != 'rental') return null;

  final listing = order.listing;
  if (listing == null) return null;

  final parts = <String>[];
  if (listing.rentalDailyPrice != null && listing.rentalDailyPrice! > 0) {
    parts.add('\$${listing.rentalDailyPrice!.toStringAsFixed(0)}/day');
  }
  if (listing.rentalWeeklyPrice != null && listing.rentalWeeklyPrice! > 0) {
    parts.add('\$${listing.rentalWeeklyPrice!.toStringAsFixed(0)}/wk');
  }
  if (listing.rentalMonthlyPrice != null && listing.rentalMonthlyPrice! > 0) {
    parts.add('\$${listing.rentalMonthlyPrice!.toStringAsFixed(0)}/mo');
  }
  return parts.isNotEmpty ? parts.join(' · ') : null;
}
