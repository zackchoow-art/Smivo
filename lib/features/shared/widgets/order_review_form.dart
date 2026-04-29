import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/data/models/order.dart';
import 'package:smivo/features/shared/providers/order_review_provider.dart';

class OrderReviewSection extends ConsumerStatefulWidget {
  const OrderReviewSection({
    super.key,
    required this.order,
    required this.currentUserId,
    required this.targetUserId,
    required this.role, // 'buyer' or 'seller'
  });

  final Order order;
  final String currentUserId;
  final String targetUserId;
  final String role;

  @override
  ConsumerState<OrderReviewSection> createState() => _OrderReviewSectionState();
}

class _OrderReviewSectionState extends ConsumerState<OrderReviewSection> {
  int _rating = 0;
  final Set<String> _selectedTagIds = {};
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    final tagsAsync = ref.watch(reviewTagsProvider(role: widget.role));
    final actionsState = ref.watch(orderReviewActionsProvider);
    final isSubmitting = actionsState.isLoading;

    ref.listen(orderReviewActionsProvider, (prev, next) {
      if (next.hasError && !next.isLoading) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit review: ${next.error}')),
        );
      } else if (!next.hasError && !next.isLoading && next.hasValue) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review submitted successfully!')),
        );
        // Clear form after successful submit (since it's inline now)
        setState(() {
          _rating = 0;
          _selectedTagIds.clear();
          _commentController.clear();
        });
      }
    });

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(radius.md),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Rate the ${widget.role}',
            style: typo.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                icon: Icon(
                  index < _rating
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  color: Colors.amber,
                  size: 40,
                ),
                onPressed: () => setState(() => _rating = index + 1),
              );
            }),
          ),
          const SizedBox(height: 16),
          tagsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error:
                (err, _) => Text(
                  'Failed to load tags',
                  style: typo.bodySmall.copyWith(color: colors.error),
                ),
            data: (tags) {
              if (tags.isEmpty) return const SizedBox.shrink();
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    tags.map((tag) {
                      final isSelected = _selectedTagIds.contains(tag.id);
                      return FilterChip(
                        label: Text(tag.name),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedTagIds.add(tag.id);
                            } else {
                              _selectedTagIds.remove(tag.id);
                            }
                          });
                        },
                        selectedColor: colors.primary.withValues(alpha: 0.2),
                        checkmarkColor: colors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(radius.sm),
                        ),
                        side: BorderSide(
                          color:
                              isSelected
                                  ? colors.primary
                                  : colors.outlineVariant,
                        ),
                      );
                    }).toList(),
              );
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _commentController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Add an optional comment...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(radius.input),
              ),
              filled: true,
              fillColor: colors.surfaceContainerLowest,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed:
                (_rating == 0 || isSubmitting)
                    ? null
                    : () {
                      ref
                          .read(orderReviewActionsProvider.notifier)
                          .submitReview(
                            orderId: widget.order.id,
                            reviewerId: widget.currentUserId,
                            targetUserId: widget.targetUserId,
                            role: widget.role,
                            rating: _rating,
                            comment: _commentController.text,
                            tagIds: _selectedTagIds.toList(),
                          );
                    },
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: colors.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(radius.button),
              ),
            ),
            child:
                isSubmitting
                    ? const SizedBox(
                      height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)
                    )
                    : const Text('Submit Review'),
          ),
        ],
      ),
    );
  }
}
