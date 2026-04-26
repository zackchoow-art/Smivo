
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:smivo/data/repositories/listing_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:smivo/core/providers/supabase_provider.dart';

part 'listing_views_provider.g.dart';

/// A single view event with optional viewer profile.
class ListingView {
  const ListingView({
    required this.id,
    required this.listingId,
    this.viewerId,
    this.viewerName,
    this.viewerAvatarUrl,
    this.viewerEmail,
    required this.viewedAt,
  });

  final String id;
  final String listingId;
  final String? viewerId;
  final String? viewerName;
  final String? viewerAvatarUrl;
  final String? viewerEmail;
  final DateTime viewedAt;
}

@riverpod
class ListingViews extends _$ListingViews {
  RealtimeChannel? _channel;

  @override
  Future<List<ListingView>> build(String listingId) async {
    ref.onDispose(() {
      _channel?.unsubscribe();
      _channel = null;
    });

    _subscribe(listingId);

    final repository = ref.watch(listingRepositoryProvider);
    final data = await repository.fetchListingViews(listingId);

    return data.map((json) => ListingView(
      id: json['id'] as String,
      listingId: json['listing_id'] as String,
      viewerId: json['viewer_id'] as String?,
      viewerName: (json['viewer'] as Map<String, dynamic>?)?['display_name'] as String?,
      viewerAvatarUrl: (json['viewer'] as Map<String, dynamic>?)?['avatar_url'] as String?,
      viewerEmail: (json['viewer'] as Map<String, dynamic>?)?['email'] as String?,
      viewedAt: DateTime.parse(json['viewed_at'] as String),
    )).toList();
  }

  void _subscribe(String listingId) {
    final client = ref.read(supabaseClientProvider);
    _channel = client
        .channel('listing_views:$listingId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'listing_views',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'listing_id',
            value: listingId,
          ),
          callback: (payload) {
            ref.invalidateSelf();
          },
        )
        .subscribe();
  }
}
