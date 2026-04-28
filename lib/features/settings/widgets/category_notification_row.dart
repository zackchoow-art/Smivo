import 'package:flutter/material.dart';
import 'package:smivo/core/theme/theme_extensions.dart';

class CategoryNotificationRow extends StatelessWidget {
  const CategoryNotificationRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.pushValue,
    required this.emailValue,
    required this.onPushChanged,
    required this.onEmailChanged,
    required this.pushEnabled,
    required this.emailEnabled,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool pushValue;
  final bool emailValue;
  final ValueChanged<bool> onPushChanged;
  final ValueChanged<bool> onEmailChanged;
  final bool pushEnabled;
  final bool emailEnabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(radius.xl),
        boxShadow: [
          BoxShadow(
            color: colors.shadow,
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: colors.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: typo.headlineSmall.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            style: typo.bodyMedium.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Divider(color: colors.dividerColor),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Push Notification',
                style: typo.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: pushEnabled ? colors.onSurface : colors.onSurfaceVariant,
                ),
              ),
              Switch.adaptive(
                value: pushEnabled ? pushValue : false,
                onChanged: pushEnabled ? onPushChanged : null,
                activeTrackColor: colors.primary,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Email',
                style: typo.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: emailEnabled ? colors.onSurface : colors.onSurfaceVariant,
                ),
              ),
              Switch.adaptive(
                value: emailEnabled ? emailValue : false,
                onChanged: emailEnabled ? onEmailChanged : null,
                activeTrackColor: colors.primary,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
