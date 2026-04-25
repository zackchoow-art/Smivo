import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:smivo/core/constants/app_constants.dart';
import 'package:smivo/core/exceptions/app_exception.dart';
import 'package:smivo/core/providers/supabase_provider.dart';

part 'listing_views_provider.g.dart';

/// A single view event with optional viewer profile.
class ListingView {
  const ListingView({
    required this.id,
    required this.listingId,
    this.viewerName,
    this.viewerAvatarUrl,
    this.viewerEmail,
    required this.viewedAt,
  });

  final String id;
  final String listingId;
  final String? viewerName;
  final String? viewerAvatarUrl;
  final String? viewerEmail;
  final DateTime viewedAt;
}

@riverpod
Future<List<ListingView>> listingViews(Ref ref, String listingId) async {
  final client = ref.watch(supabaseClientProvider);
  try {
    final data = await client
        .from(AppConstants.tableListingViews)
        .select('*, viewer:user_profiles!viewer_id(display_name, avatar_url, email)')
        .eq('listing_id', listingId)
        .order('viewed_at', ascending: false)
        .limit(100);

    return (data as List).map((json) => ListingView(
      id: json['id'] as String,
      listingId: json['listing_id'] as String,
      viewerName: (json['viewer'] as Map<String, dynamic>?)?['display_name'] as String?,
      viewerAvatarUrl: (json['viewer'] as Map<String, dynamic>?)?['avatar_url'] as String?,
      viewerEmail: (json['viewer'] as Map<String, dynamic>?)?['email'] as String?,
      viewedAt: DateTime.parse(json['viewed_at'] as String),
    )).toList();
  } on PostgrestException catch (e) {
    throw DatabaseException(e.message, e);
  }
}
