import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:smivo/core/providers/supabase_provider.dart';
import 'package:smivo/data/models/carpool_member.dart';
import 'package:smivo/features/carpool/providers/carpool_lifecycle_provider.dart';
import 'package:smivo/shared/widgets/smivo_user_avatar.dart';

/// A bottom sheet for submitting peer reviews after a carpool trip.
///
/// Displays one row per fellow member with a 5-star rating selector
/// and an optional comment field. The submit button batches all reviews
/// into a single repository call.
class ReviewBatchSheet extends ConsumerStatefulWidget {
  const ReviewBatchSheet({
    super.key,
    required this.tripId,
    required this.members,
  });

  /// The completed trip's ID (used to build the review payload).
  final String tripId;

  /// Approved members to review — must already have self filtered out.
  final List<CarpoolMember> members;

  @override
  ConsumerState<ReviewBatchSheet> createState() => _ReviewBatchSheetState();
}

class _ReviewBatchSheetState extends ConsumerState<ReviewBatchSheet> {
  // Maps member userId → selected star rating (1–5). Defaults to 5.
  late final Map<String, int> _ratings;
  // Maps member userId → optional comment text controller.
  late final Map<String, TextEditingController> _comments;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _ratings = {for (final m in widget.members) m.userId: 5};
    _comments = {
      for (final m in widget.members)
        m.userId: TextEditingController(),
    };
  }

  @override
  void dispose() {
    for (final controller in _comments.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    final currentUserId =
        ref.read(supabaseClientProvider).auth.currentUser?.id;
    if (currentUserId == null) return;

    // Build the reviews payload — skip members with no user data.
    final reviews = widget.members
        .where((m) => m.user != null)
        .map((m) => {
              'trip_id': widget.tripId,
              'reviewer_id': currentUserId,
              'reviewee_id': m.userId,
              'rating': _ratings[m.userId] ?? 5,
              'comment': _comments[m.userId]?.text.trim().isEmpty ?? true
                  ? null
                  : _comments[m.userId]!.text.trim(),
            })
        .toList();

    if (reviews.isEmpty) {
      Navigator.of(context).pop();
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await ref
          .read(tripReviewsProvider(widget.tripId).notifier)
          .submitReviews(widget.tripId, reviews);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reviews submitted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submission failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant
                      .withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Rate Fellow Riders',
                  style: theme.textTheme.titleLarge,
                ),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: ListView.separated(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: widget.members.length,
                  separatorBuilder: (_, __) => const Divider(height: 24),
                  itemBuilder: (context, index) {
                    final member = widget.members[index];
                    return _MemberReviewRow(
                      member: member,
                      rating: _ratings[member.userId] ?? 5,
                      commentController:
                          _comments[member.userId] ?? TextEditingController(),
                      onRatingChanged: (value) {
                        setState(() => _ratings[member.userId] = value);
                      },
                    );
                  },
                ),
              ),

              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Submit Reviews'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// A single member row: avatar + name, star rating row, comment field.
class _MemberReviewRow extends StatelessWidget {
  const _MemberReviewRow({
    required this.member,
    required this.rating,
    required this.commentController,
    required this.onRatingChanged,
  });

  final CarpoolMember member;
  final int rating;
  final TextEditingController commentController;
  final ValueChanged<int> onRatingChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = member.user;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Member identity row
        Row(
          children: [
            if (user != null)
              SmivoUserAvatar(user: user, radius: 20, enableTap: false),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                user?.displayName ?? 'Unknown User',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Star rating row
        Row(
          children: List.generate(5, (i) {
            final starValue = i + 1;
            return IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
              icon: Icon(
                starValue <= rating ? Icons.star : Icons.star_border,
                color: starValue <= rating
                    ? Colors.amber
                    : theme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.4),
              ),
              onPressed: () => onRatingChanged(starValue),
            );
          }),
        ),

        const SizedBox(height: 8),

        // Optional comment field
        TextField(
          controller: commentController,
          maxLines: 2,
          maxLength: 200,
          decoration: InputDecoration(
            hintText: 'Write a review (Optional)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
        ),
      ],
    );
  }
}
