import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/data/models/content_report.dart';

class FlippableReportCard extends StatefulWidget {
  final ContentReport report;

  const FlippableReportCard({super.key, required this.report});

  @override
  State<FlippableReportCard> createState() => _FlippableReportCardState();
}

class _FlippableReportCardState extends State<FlippableReportCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
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
            child: isFrontFacing ? _buildFrontSide(context) : _buildBackSide(context),
          );
        },
      ),
    );
  }

  Widget _buildFrontSide(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;
    final f = widget.report;

    final isListingReport = f.listingId != null;
    final targetName = isListingReport
        ? (f.listing?.title ?? 'Unknown Listing')
        : (f.reportedUser?.displayName ?? 'Unknown User');

    final dateStr = DateFormat('MMM d, yyyy HH:mm').format(f.createdAt.toLocal());

    Color statusColor;
    Color statusBgColor;
    String statusText;

    switch (f.status) {
      case 'pending':
        statusColor = colors.error;
        statusBgColor = colors.error.withAlpha(20);
        statusText = 'Pending';
        break;
      case 'reviewed':
        statusColor = colors.primary;
        statusBgColor = colors.primary.withAlpha(20);
        statusText = 'Under Review';
        break;
      case 'resolved':
        statusColor = colors.success;
        statusBgColor = colors.success.withAlpha(20);
        statusText = 'Action Taken';
        break;
      case 'dismissed':
        statusColor = colors.onSurfaceVariant;
        statusBgColor = colors.surfaceContainerHighest;
        statusText = 'Dismissed';
        break;
      default:
        statusColor = colors.onSurfaceVariant;
        statusBgColor = colors.surfaceContainerHighest;
        statusText = f.status.toUpperCase();
    }

    final String reportType = isListingReport ? 'REPORTED LISTING' : 'REPORTED USER';

    return Container(
      constraints: const BoxConstraints(minHeight: 140),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(radius.lg),
        border: Border.all(color: colors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        reportType,
                        style: typo.labelSmall.copyWith(color: colors.onSurfaceVariant),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      targetName,
                      style: typo.titleMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      statusText,
                      style: typo.labelSmall.copyWith(color: statusColor, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateStr,
                    style: typo.labelSmall.copyWith(color: colors.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        'Reason: ${f.reason}',
                        style: typo.bodyMedium.copyWith(color: colors.onSurface),
                        maxLines: _isExpanded ? null : 1,
                        overflow: _isExpanded ? null : TextOverflow.ellipsis,
                      ),
                    ),
                    if (!_isExpanded && _hasImageOrAvatar()) ...[
                      const SizedBox(width: 12),
                      _buildImageOrAvatar(),
                    ],
                  ],
                ),
                if (_isExpanded && _hasImageOrAvatar()) ...[
                  const SizedBox(height: 12),
                  _buildImageOrAvatar(expanded: true),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.bottomRight,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_isExpanded ? 'Show less' : 'Details', style: typo.labelSmall.copyWith(color: colors.primary)),
                    Icon(_isExpanded ? Icons.expand_less : Icons.expand_more, color: colors.primary, size: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _hasImageOrAvatar() {
    if (widget.report.listingId != null) {
      return widget.report.listing?.images.isNotEmpty == true;
    }
    return widget.report.reportedUser?.avatarUrl != null;
  }

  Widget _buildImageOrAvatar({bool expanded = false}) {
    final colors = context.smivoColors;
    final isListingReport = widget.report.listingId != null;

    if (isListingReport) {
      final imageUrl = widget.report.listing?.images.isNotEmpty == true
          ? widget.report.listing!.images.first.imageUrl
          : null;
      if (imageUrl == null) return const SizedBox.shrink();

      return ClipRRect(
        borderRadius: BorderRadius.circular(context.smivoRadius.sm),
        child: Image.network(
          imageUrl,
          width: expanded ? double.infinity : 40,
          height: expanded ? 160 : 40,
          fit: BoxFit.cover,
        ),
      );
    } else {
      final avatarUrl = widget.report.reportedUser?.avatarUrl;
      if (avatarUrl == null) return const SizedBox.shrink();

      if (expanded) {
        return Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: colors.surfaceContainer,
              backgroundImage: NetworkImage(avatarUrl),
            ),
            const SizedBox(width: 8),
            Text(
              widget.report.reportedUser?.displayName ?? 'Unknown',
              style: context.smivoTypo.bodyMedium,
            ),
          ],
        );
      } else {
        return CircleAvatar(
          radius: 20,
          backgroundColor: colors.surfaceContainer,
          backgroundImage: NetworkImage(avatarUrl),
        );
      }
    }
  }

  Widget _buildBackSide(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;
    final f = widget.report;

    final responseDate = DateFormat('MMM d, yyyy HH:mm').format(f.updatedAt.toLocal());
    final note = f.resolutionNote;
    final isPending = f.status == 'pending';

    String statusText;
    Color statusColor;
    if (isPending) {
      statusText = 'Pending';
      statusColor = colors.error;
    } else {
      statusText = 'Reviewed';
      statusColor = colors.success;
    }

    return Transform(
      transform: Matrix4.rotationY(pi),
      alignment: Alignment.center,
      child: Container(
        constraints: const BoxConstraints(minHeight: 140),
        width: double.infinity,
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(radius.lg),
          border: Border.all(
            color: colors.outlineVariant.withAlpha(50),
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: colors.error,
                      child: const Icon(Icons.shield, size: 14, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Text('Trust & Safety Team', style: typo.labelLarge.copyWith(color: colors.onSurface)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(statusText, style: typo.labelSmall.copyWith(color: statusColor, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(responseDate, style: typo.labelSmall.copyWith(color: colors.onSurfaceVariant)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
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
            // Since this is a report and not feedback, there are no contribution points shown by default.
            // But we add the layout structure just in case.
            if (!isPending) ...[
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.bottomRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: f.status == 'dismissed' ? colors.surfaceContainerHighest : colors.error,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        f.status == 'dismissed' ? Icons.info_outline : Icons.gavel, 
                        color: f.status == 'dismissed' ? colors.onSurfaceVariant : Colors.white, 
                        size: 16
                      ),
                      const SizedBox(width: 4),
                      Text(
                        f.status == 'dismissed' ? 'No violation found' : 'Action Taken',
                        style: typo.labelSmall.copyWith(
                          color: f.status == 'dismissed' ? colors.onSurfaceVariant : Colors.white, 
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
