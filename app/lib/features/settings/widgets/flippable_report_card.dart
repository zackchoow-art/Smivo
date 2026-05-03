import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/data/models/content_report.dart';

// ─────────────────────────────────────────────────────────────────────────────
// FlippableReportCard — used by the *reporter* to see their submitted reports.
// Front: report target + status.
// Back: platform response (dismiss note OR exact penalty given to reported user
//       + contribution points awarded to the reporter).
// ─────────────────────────────────────────────────────────────────────────────

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
            child: isFrontFacing
                ? _buildFrontSide(context)
                : _buildBackSide(context),
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

    final (statusColor, statusBgColor, statusText) = _statusMeta(
      f.status,
      f.actionTaken,
      colors,
      isReporter: true,
    );

    final String reportType =
        isListingReport ? 'REPORTED LISTING' : 'REPORTED USER';

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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        reportType,
                        style: typo.labelSmall
                            .copyWith(color: colors.onSurfaceVariant),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      statusText,
                      style: typo.labelSmall.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateStr,
                    style: typo.labelSmall
                        .copyWith(color: colors.onSurfaceVariant),
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
                        style: typo.bodyMedium
                            .copyWith(color: colors.onSurface),
                        maxLines: _isExpanded ? null : 1,
                        overflow:
                            _isExpanded ? null : TextOverflow.ellipsis,
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
                    Text(
                      _isExpanded ? 'Show less' : 'Details',
                      style: typo.labelSmall
                          .copyWith(color: colors.primary),
                    ),
                    Icon(
                      _isExpanded
                          ? Icons.expand_less
                          : Icons.expand_more,
                      color: colors.primary,
                      size: 20,
                    ),
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

    final responseDate =
        DateFormat('MMM d, yyyy HH:mm').format(f.updatedAt.toLocal());
    final note = f.resolutionNote;
    final isPending = f.status == 'pending';
    final isDismissed = f.status == 'dismissed';
    final isActioned = f.status == 'resolved' &&
        (f.actionTaken == 'warn' || f.actionTaken == 'restrict');

    final (statusColor, statusBgColor, statusText) = _statusMeta(
      f.status,
      f.actionTaken,
      colors,
      isReporter: true,
    );

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
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: colors.primary,
                      child: const Icon(
                        Icons.shield,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Trust & Safety Team',
                      style: typo.labelLarge.copyWith(
                        color: colors.onSurface,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        statusText,
                        style: typo.labelSmall.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      responseDate,
                      style: typo.labelSmall.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── Body: outcome-specific content ──────────────────────
            if (isPending) ...[
              Text(
                'Your report is currently being reviewed by our moderation '
                'team. You will be notified once a decision is made.',
                style: typo.bodyMedium.copyWith(
                  color: colors.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ] else if (isDismissed) ...[
              // NOTE: Dismissed means no violation was found.
              // Be neutral and informative — not accusatory toward reporter.
              Text(
                'After reviewing your report, our team determined that the '
                'reported content does not violate our community guidelines. '
                'No action was taken against the reported party.',
                style: typo.bodyMedium.copyWith(color: colors.onSurface),
              ),
              if (note != null && note.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    note,
                    style: typo.bodySmall.copyWith(
                      color: colors.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ] else if (isActioned) ...[
              // Reporter view: penalty applied + reward points
              _ReporterOutcomeContent(report: f),
            ] else ...[
              // Fallback: resolved but no specific action recorded
              if (note != null && note.isNotEmpty)
                Text(
                  note,
                  style: typo.bodyMedium.copyWith(color: colors.onSurface),
                )
              else
                Text(
                  'This report has been closed.',
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

// ─────────────────────────────────────────────────────────────────────────────
// _ReporterOutcomeContent — shown on the back of the reporter's card when
// their report was actioned (warn or restrict).
// ─────────────────────────────────────────────────────────────────────────────
class _ReporterOutcomeContent extends StatelessWidget {
  final ContentReport report;
  const _ReporterOutcomeContent({required this.report});

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    final penaltyLabel = report.actionTaken == 'warn'
        ? 'Formal Warning'
        : 'Account Restriction';
    final penaltyIcon = report.actionTaken == 'warn'
        ? Icons.warning_amber_rounded
        : Icons.block_rounded;
    final penaltyColor =
        report.actionTaken == 'warn' ? colors.warning : colors.error;

    final hasPoints = report.reporterRewardPoints > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thank you for keeping Smivo safe! We\'ve reviewed your report and '
          'taken the following action:',
          style: typo.bodyMedium.copyWith(color: colors.onSurface),
        ),
        const SizedBox(height: 10),
        // Penalty chip
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: penaltyColor.withAlpha(20),
            borderRadius: BorderRadius.circular(radius.md),
            border: Border.all(color: penaltyColor.withAlpha(60)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(penaltyIcon, size: 16, color: penaltyColor),
              const SizedBox(width: 6),
              Text(
                penaltyLabel,
                style: typo.labelSmall.copyWith(
                  color: penaltyColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        if (report.resolutionNote != null &&
            report.resolutionNote!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            report.resolutionNote!,
            style: typo.bodySmall.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
        // Contribution points row
        if (hasPoints) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colors.success.withAlpha(20),
              borderRadius: BorderRadius.circular(radius.md),
              border: Border.all(color: colors.success.withAlpha(60)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star_rounded, size: 16, color: colors.success),
                const SizedBox(width: 6),
                Text(
                  '+${report.reporterRewardPoints} contribution points awarded',
                  style: typo.labelSmall.copyWith(
                    color: colors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PenaltyCard — shown in the *reported user's* Trust & Safety section when
// they have received a platform penalty (warn or restrict).
// Only visible when action_taken IN ('warn', 'restrict') per RLS.
// ─────────────────────────────────────────────────────────────────────────────

class PenaltyCard extends StatefulWidget {
  final ContentReport report;
  const PenaltyCard({super.key, required this.report});

  @override
  State<PenaltyCard> createState() => _PenaltyCardState();
}

class _PenaltyCardState extends State<PenaltyCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
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

  void _flip() {
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
      onTap: _flip,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (_, __) {
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(_animation.value * pi);
          final isFrontFacing = _animation.value < 0.5;
          return Transform(
            transform: transform,
            alignment: Alignment.center,
            child: isFrontFacing
                ? _buildFront(context)
                : _buildBack(context),
          );
        },
      ),
    );
  }

  Widget _buildFront(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;
    final f = widget.report;

    final isWarn = f.actionTaken == 'warn';
    final penaltyColor = isWarn ? colors.warning : colors.error;
    final penaltyLabel = isWarn ? 'Warning Received' : 'Account Restricted';
    final penaltyIcon =
        isWarn ? Icons.warning_amber_rounded : Icons.block_rounded;

    final isListingReport = f.listingId != null;
    final contentLabel = isListingReport
        ? 'Related to listing: ${f.listing?.title ?? 'Unknown'}'
        : 'Related to a chat message';

    final dateStr =
        DateFormat('MMM d, yyyy').format(f.createdAt.toLocal());

    return Container(
      constraints: const BoxConstraints(minHeight: 120),
      decoration: BoxDecoration(
        color: penaltyColor.withAlpha(10),
        borderRadius: BorderRadius.circular(radius.lg),
        border: Border.all(color: penaltyColor.withAlpha(60)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: penaltyColor.withAlpha(25),
              borderRadius: BorderRadius.circular(radius.md),
            ),
            child: Icon(penaltyIcon, color: penaltyColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  penaltyLabel,
                  style: typo.titleMedium.copyWith(
                    color: penaltyColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  contentLabel,
                  style: typo.bodySmall.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  dateStr,
                  style: typo.labelSmall.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.flip_rounded,
            size: 16,
            color: colors.onSurfaceVariant.withAlpha(120),
          ),
        ],
      ),
    );
  }

  Widget _buildBack(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;
    final f = widget.report;

    final isWarn = f.actionTaken == 'warn';
    final penaltyColor = isWarn ? colors.warning : colors.error;
    final penaltyLabel = isWarn ? 'Formal Warning' : 'Account Restriction';

    final note = f.resolutionNote;

    return Transform(
      transform: Matrix4.rotationY(pi),
      alignment: Alignment.center,
      child: Container(
        constraints: const BoxConstraints(minHeight: 120),
        width: double.infinity,
        decoration: BoxDecoration(
          color: colors.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(radius.lg),
          border: Border.all(color: colors.outlineVariant.withAlpha(60)),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: colors.primary,
                  child: const Icon(
                    Icons.shield,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Trust & Safety Team',
                  style: typo.labelLarge.copyWith(color: colors.onSurface),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Penalty type chip
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: penaltyColor.withAlpha(20),
                borderRadius: BorderRadius.circular(radius.sm),
                border: Border.all(color: penaltyColor.withAlpha(60)),
              ),
              child: Text(
                penaltyLabel,
                style: typo.labelSmall.copyWith(
                  color: penaltyColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Explanation
            Text(
              isWarn
                  ? 'Your content was found to violate our community guidelines. '
                      'This is a formal warning. Further violations may result in '
                      'account restrictions.'
                  : 'Due to violations of our community guidelines, restrictions '
                      'have been applied to your account. Please review our '
                      'guidelines to avoid further action.',
              style: typo.bodySmall.copyWith(color: colors.onSurface),
            ),
            if (note != null && note.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  note,
                  style: typo.bodySmall.copyWith(
                    color: colors.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
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

// ─────────────────────────────────────────────────────────────────────────────
// Shared helper: maps (status, actionTaken) → (color, bgColor, label)
// isReporter=true → reporter-facing labels
// isReporter=false → reported-user-facing labels (only warn/restrict)
// ─────────────────────────────────────────────────────────────────────────────
(Color, Color, String) _statusMeta(
  String status,
  String? actionTaken,
  SmivoColors colors, {
  required bool isReporter,
}) {
  switch (status) {
    case 'pending':
      return (colors.error, colors.error.withAlpha(20), 'Pending Review');
    case 'reviewed':
      return (colors.primary, colors.primary.withAlpha(20), 'Under Review');
    case 'dismissed':
      return (
        colors.onSurfaceVariant,
        colors.surfaceContainerHighest,
        'Dismissed',
      );
    case 'resolved':
      // NOTE: If action_taken is available, show the specific penalty label.
      // This replaces the generic "Action Taken" badge that confused reporters.
      if (actionTaken == 'warn') {
        return (colors.warning, colors.warning.withAlpha(20), 'Warned');
      } else if (actionTaken == 'restrict') {
        return (colors.error, colors.error.withAlpha(20), 'Restricted');
      }
      return (colors.success, colors.success.withAlpha(20), 'Resolved');
    default:
      return (
        colors.onSurfaceVariant,
        colors.surfaceContainerHighest,
        status.toUpperCase(),
      );
  }
}
