import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smivo/data/models/listing.dart';
import 'package:smivo/data/repositories/listing_repository.dart';

part 'listing_detail_provider.g.dart';

/// State for the selected rental rate (DAY, WEEK, MONTH).
/// 
/// Defaults to 'MONTH' as per the primary design.
@riverpod
class SelectedRentalRate extends _$SelectedRentalRate {
  @override
  String build() => 'MONTH';

  void setRate(String rate) {
    state = rate;
  }
}

/// State for the rental duration stepper (e.g., number of months).
@riverpod
class RentalDuration extends _$RentalDuration {
  @override
  int build() => 1;

  void increment() {
    state++;
  }

  void decrement() {
    if (state > 1) state--;
  }
}

/// State for the selected rental start date.
@riverpod
class RentalStartDate extends _$RentalStartDate {
  @override
  DateTime build() => DateTime.now();

  void setDate(DateTime date) {
    state = date;
  }
}

/// State for the selected rental end date.
@riverpod
class RentalEndDate extends _$RentalEndDate {
  @override
  DateTime build() => DateTime.now().add(const Duration(days: 1));

  void setDate(DateTime date) {
    state = date;
  }
}

/// Fetches a single listing with all joined details (images, seller) from Supabase.
/// 
/// Takes a listing [id] as a parameter.
@riverpod
Future<Listing> listingDetail(Ref ref, String id) async {
  final repository = ref.watch(listingRepositoryProvider);
  return repository.fetchListing(id);
}
