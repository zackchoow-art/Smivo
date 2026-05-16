import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:smivo/data/models/carpool_trip.dart';
import 'package:smivo/features/carpool/services/calendar_sync_service.dart';
import 'package:smivo/shared/widgets/action_error_dialog.dart';
import 'package:smivo/shared/widgets/action_success_dialog.dart';

/// A button that adds the carpool trip to the user's system calendar.
///
/// Uses the `device_calendar` package which handles iOS/Android calendar
/// natively. Requires permissions, requested at runtime.
class CalendarSyncButton extends ConsumerStatefulWidget {
  const CalendarSyncButton({super.key, required this.trip});

  final CarpoolTrip trip;

  @override
  ConsumerState<CalendarSyncButton> createState() => _CalendarSyncButtonState();
}

class _CalendarSyncButtonState extends ConsumerState<CalendarSyncButton> {
  bool _isLoading = false;
  bool _hasSynced = false;

  @override
  void initState() {
    super.initState();
    _checkSyncStatus();
  }

  Future<void> _checkSyncStatus() async {
    final hasSynced = await ref.read(calendarSyncServiceProvider).hasSyncedTrip(widget.trip.id);
    if (mounted) {
      setState(() => _hasSynced = hasSynced);
    }
  }

  Future<void> _syncToCalendar() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    try {
      await ref.read(calendarSyncServiceProvider).syncTrip(widget.trip);
      if (!mounted) return;
      
      setState(() => _hasSynced = true);
      
      showDialog(
        context: context,
        builder: (ctx) => const ActionSuccessDialog(
          title: 'Success',
          message: 'Added to your system calendar.',
        ),
      );
    } catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => ActionErrorDialog(
          title: 'Calendar Sync Failed',
          message: e.toString().replaceFirst('Exception: ', ''),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const TextButton(
        onPressed: null,
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return TextButton.icon(
      icon: Icon(_hasSynced ? Icons.edit_calendar : Icons.calendar_month),
      label: Text(_hasSynced ? 'Update Calendar' : 'Add to Calendar'),
      onPressed: _syncToCalendar,
    );
  }
}
