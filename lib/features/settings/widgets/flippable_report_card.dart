import 'dart:math';
import 'package:flutter/material.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/data/models/content_report.dart';

class FlippableReportCard extends StatefulWidget {
  final ContentReport report;

  const FlippableReportCard({
    super.key,
    required this.report,
  });

  @override
  State<FlippableReportCard> createState() => _FlippableReportCardState();
}

class _FlippableReportCardState extends State<FlippableReportCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    _isFront = !_isFront;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flipCard,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(_animation.value * pi);

          final isFrontFacing = _animation.value < 0.5;

          return Transform(
            transform: transform,
            alignment: Alignment.center,
            child: isFrontFacing ? _buildFrontSide() : _buildBackSide(),
          );
        },
      ),
    );
  }

  Widget _buildFrontSide() {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    final isListingReport = widget.report.listingId != null;
    final targetName = isListingReport
        ? (widget.report.listing?.title ?? 'Unknown Listing')
        : (widget.report.reportedUser?.displayName ?? 'Unknown User');

    final displayStatus = widget.report.status.substring(0, 1).toUpperCase() +
        widget.report.status.substring(1);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(radius.lg),
        border: Border.all(color: colors.outlineVariant),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              _buildImageOrAvatar(),
              const SizedBox(height: 8),
              Text(
                widget.report.createdAt.toLocal().toString().split(' ')[0],
                style: typo.labelSmall.copyWith(color: colors.outline),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        targetName,
                        style: typo.titleMedium.copyWith(color: colors.onSurface),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: widget.report.status == 'pending'
                            ? colors.errorContainer
                            : colors.secondaryContainer,
                        borderRadius: BorderRadius.circular(radius.sm),
                      ),
                      child: Text(
                        displayStatus,
                        style: typo.labelSmall.copyWith(
                          color: widget.report.status == 'pending'
                              ? colors.error
                              : colors.onSecondaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Reason: ${widget.report.reason}',
                  style: typo.bodyMedium.copyWith(color: colors.onSurfaceVariant),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.report.status != 'pending') ...[
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Tap to view resolution',
                          style: typo.bodySmall.copyWith(color: colors.primary),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.flip, size: 14, color: colors.primary),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageOrAvatar() {
    final colors = context.smivoColors;
    final isListingReport = widget.report.listingId != null;

    if (isListingReport) {
      final imageUrl = widget.report.listing?.images.isNotEmpty == true
          ? widget.report.listing!.images.first.imageUrl
          : null;
      return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: colors.surfaceContainer,
          borderRadius: BorderRadius.circular(context.smivoRadius.sm),
        ),
        clipBehavior: Clip.antiAlias,
        child: imageUrl != null
            ? Image.network(imageUrl, fit: BoxFit.cover)
            : Icon(Icons.storefront, color: colors.onSurfaceVariant),
      );
    } else {
      final avatarUrl = widget.report.reportedUser?.avatarUrl;
      return CircleAvatar(
        radius: 25,
        backgroundColor: colors.surfaceContainer,
        backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
        child: avatarUrl == null
            ? Icon(Icons.person, color: colors.onSurfaceVariant)
            : null,
      );
    }
  }

  Widget _buildBackSide() {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    final note = widget.report.resolutionNote;
    final isPending = widget.report.status == 'pending';

    // Wrapping in Transform to correct mirroring caused by rotateY(pi)
    return Transform(
      transform: Matrix4.rotationY(pi),
      alignment: Alignment.center,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: colors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(radius.lg),
          border: Border.all(color: colors.primary.withValues(alpha: 0.5), width: 1.5),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.gavel, size: 20, color: colors.primary),
                const SizedBox(width: 8),
                Text(
                  'Platform Resolution',
                  style: typo.titleMedium.copyWith(color: colors.primary),
                ),
              ],
            ),
            Divider(height: 24, color: colors.outlineVariant),
            if (note != null && note.isNotEmpty) ...[
              Text(
                note,
                style: typo.bodyMedium.copyWith(color: colors.onSurface),
              ),
            ] else ...[
              Text(
                isPending
                    ? 'Your report is currently being reviewed by our moderation team. You will be notified once a decision is made.'
                    : 'This report has been closed without an additional note.',
                style: typo.bodyMedium.copyWith(
                  color: colors.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
