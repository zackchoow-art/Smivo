import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/data/models/order.dart';
import 'package:smivo/features/orders/providers/orders_provider.dart';

class RentalReminderSettings extends ConsumerStatefulWidget {
  const RentalReminderSettings({
    super.key,
    required this.order,
    required this.isBuyer,
  });

  final Order order;
  final bool isBuyer;

  @override
  ConsumerState<RentalReminderSettings> createState() => _RentalReminderSettingsState();
}

class _RentalReminderSettingsState extends ConsumerState<RentalReminderSettings> {
  late int _selectedDays;
  late bool _sendEmail;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedDays = widget.order.reminderDaysBefore;
    _sendEmail = widget.order.reminderEmail;
  }

  @override
  void didUpdateWidget(RentalReminderSettings oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.order.reminderDaysBefore != widget.order.reminderDaysBefore ||
        oldWidget.order.reminderEmail != widget.order.reminderEmail) {
      setState(() {
        _selectedDays = widget.order.reminderDaysBefore;
        _sendEmail = widget.order.reminderEmail;
      });
    }
  }

  bool get _hasChanged =>
      _selectedDays != widget.order.reminderDaysBefore ||
      _sendEmail != widget.order.reminderEmail;

  Future<void> _savePreferences() async {
    setState(() => _isSaving = true);
    try {
      await ref.read(orderActionsProvider.notifier).updateReminderPreferences(
            orderId: widget.order.id,
            daysBefore: _selectedDays,
            sendEmail: _sendEmail,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reminder preferences saved')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isBuyer ||
        widget.order.orderType != 'rental' ||
        widget.order.rentalStatus != 'active' ||
        widget.order.rentalEndDate == null) {
      return const SizedBox.shrink();
    }

    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    final endDateStr = DateFormat.yMMMd().format(widget.order.rentalEndDate!);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(radius.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.notifications_active_outlined, size: 20, color: colors.primary),
              const SizedBox(width: 8),
              Text(
                'RENTAL REMINDER',
                style: typo.labelSmall.copyWith(
                  color: colors.onSurface.withValues(alpha: 0.5),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Return Reminder Timing',
            style: typo.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'A reminder is always sent before the rental expires. Adjust how early you want to be notified.',
            style: typo.bodySmall.copyWith(color: colors.outlineVariant),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text('Days before:', style: typo.bodyMedium),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<int>(
                  initialValue: _selectedDays,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(radius.md),
                      borderSide: BorderSide(color: colors.outlineVariant),
                    ),
                  ),
                  items: [1, 2, 3, 5, 7].map((days) {
                    return DropdownMenuItem(
                      value: days,
                      child: Text('$days ${days == 1 ? 'day' : 'days'}'),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedDays = val);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Checkbox(
                value: _sendEmail,
                onChanged: (val) {
                  if (val != null) setState(() => _sendEmail = val);
                },
                activeColor: colors.primary,
              ),
              Text('Also send email notification', style: typo.bodyMedium),
            ],
          ),
          const SizedBox(height: 16),
          if (widget.order.reminderSent)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(radius.md),
                border: Border.all(color: colors.success.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline, size: 18, color: colors.success),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Reminder already sent',
                      style: typo.bodySmall.copyWith(color: colors.success, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            )
          else ...[
            Text(
              'Reminder will be sent $_selectedDays day${_selectedDays == 1 ? '' : 's'} before $endDateStr',
              style: typo.bodySmall.copyWith(color: colors.outlineVariant),
            ),
            if (_hasChanged) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _savePreferences,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: _isSaving
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Save Preferences'),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
