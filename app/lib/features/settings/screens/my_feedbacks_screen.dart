import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smivo/core/router/app_routes.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/data/models/user_feedback.dart';
import 'package:smivo/features/settings/providers/feedback_provider.dart';

class MyFeedbacksScreen extends ConsumerWidget {
  const MyFeedbacksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final feedbacksAsync = ref.watch(myFeedbacksProvider);
    final feedbackBanAsync = ref.watch(userFeedbackBanProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text('My Feedbacks', style: typo.titleMedium),
        backgroundColor: colors.surface,
        elevation: 0,
      ),
      body: SelectionArea(
        child: feedbacksAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (feedbacks) {
            if (feedbacks.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.feedback_outlined, size: 64, color: colors.onSurfaceVariant.withAlpha(100)),
                    const SizedBox(height: 16),
                    Text(
                      'No feedbacks submitted yet.\nHelp us improve the app!',
                      textAlign: TextAlign.center,
                      style: typo.bodyMedium.copyWith(color: colors.onSurfaceVariant),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: feedbacks.length,
              itemBuilder: (context, index) {
                final feedback = feedbacks[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: FlipFeedbackCard(feedback: feedback),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final banDate = feedbackBanAsync.value;
          if (banDate != null) {
            final isPermanent = banDate.year > 2090;
            final dateStr = DateFormat('yyyy-MM-dd').format(banDate.toLocal());
            final msg = isPermanent
                ? 'Feedback privileges permanently suspended.'
                : 'Feedback privileges suspended until $dateStr.';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(msg),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
              ),
            );
          } else {
            context.pushNamed(AppRoutes.submitFeedback);
          }
        },
        backgroundColor: colors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Feedback', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}

class FlipFeedbackCard extends StatefulWidget {
  final UserFeedback feedback;

  const FlipFeedbackCard({super.key, required this.feedback});

  @override
  State<FlipFeedbackCard> createState() => _FlipFeedbackCardState();
}

class _FlipFeedbackCardState extends State<FlipFeedbackCard> with SingleTickerProviderStateMixin {
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
          final angle = _animation.value * pi;
          final isFrontVisible = angle <= pi / 2;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // Perspective
              ..rotateY(angle),
            child: isFrontVisible
                ? _buildFront(context)
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(pi),
                    child: _buildBack(context),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildFront(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final f = widget.feedback;
    final dateStr = DateFormat('MMM d, yyyy HH:mm').format(f.createdAt ?? DateTime.now());

    Color statusColor;
    Color statusBgColor;
    String statusText;
    switch (f.status) {
      case 'submitted':
        statusColor = colors.primary;
        statusBgColor = colors.primary.withAlpha(20);
        statusText = 'Submitted';
        break;
      case 'read':
        statusColor = Colors.blue;
        statusBgColor = Colors.blue.withAlpha(20);
        statusText = 'Read';
        break;
      case 'accepted':
        statusColor = colors.success;
        statusBgColor = colors.success.withAlpha(20);
        statusText = 'Accepted';
        break;
      case 'high_contribution':
        statusColor = Colors.amber.shade700;
        statusBgColor = Colors.amber.withAlpha(30);
        statusText = 'High Contribution';
        break;
      default:
        statusColor = colors.onSurfaceVariant;
        statusBgColor = colors.surfaceContainerHighest;
        statusText = f.status.toUpperCase();
    }

    return Container(
      constraints: const BoxConstraints(minHeight: 140),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
                        f.type.replaceAll('_', ' ').toUpperCase(),
                        style: typo.labelSmall.copyWith(color: colors.onSurfaceVariant),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(f.title, style: typo.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
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
                Text(
                  f.description,
                  style: typo.bodyMedium.copyWith(color: colors.onSurface),
                  maxLines: _isExpanded ? null : 1,
                  overflow: _isExpanded ? null : TextOverflow.ellipsis,
                ),
                if (f.screenshotUrl != null && _isExpanded)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        f.screenshotUrl!,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
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

  Widget _buildBack(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final f = widget.feedback;
    final responseDate = f.updatedAt != null ? DateFormat('MMM d, yyyy HH:mm').format(f.updatedAt!) : '';

    String statusText;
    Color statusColor;
    Color statusBgColor;
    switch (f.status) {
      case 'submitted':
        statusText = 'Unread';
        statusColor = colors.onSurfaceVariant;
        statusBgColor = colors.surfaceContainerHighest;
        break;
      case 'read':
        statusText = 'Read';
        statusColor = Colors.blue;
        statusBgColor = Colors.blue.withAlpha(20);
        break;
      case 'accepted':
        statusText = 'Accepted';
        statusColor = colors.success;
        statusBgColor = colors.success.withAlpha(20);
        break;
      case 'high_contribution':
        statusText = 'High Contribution';
        statusColor = Colors.amber.shade700;
        statusBgColor = Colors.amber.withAlpha(30);
        break;
      default:
        statusText = f.status.toUpperCase();
        statusColor = colors.onSurfaceVariant;
        statusBgColor = colors.surfaceContainerHighest;
    }

    return Container(
      constraints: const BoxConstraints(minHeight: 140),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant.withAlpha(50)),
      ),
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
                    backgroundColor: colors.primary,
                    child: const Icon(Icons.support_agent, size: 14, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  Text('Smivo Support', style: typo.labelLarge.copyWith(color: colors.onSurface)),
                ],
              ),
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
                  Text(responseDate, style: typo.labelSmall.copyWith(color: colors.onSurfaceVariant)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            f.adminResponse?.isNotEmpty == true
                ? f.adminResponse!
                : (f.status == 'submitted'
                    ? 'We have received your feedback and are reviewing it.'
                    : 'Thank you for your feedback.'),
            style: typo.bodyMedium.copyWith(color: colors.onSurface),
          ),
          if (f.pointsAwarded > 0) ...[
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.local_fire_department, color: Colors.white, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '+${f.pointsAwarded} Contribution Points',
                      style: typo.labelSmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
