import 'package:add_2_calendar/add_2_calendar.dart';
import 'package:flutter/material.dart';

import 'package:smivo/data/models/carpool_trip.dart';

/// A button that adds the carpool trip to the user's system calendar.
///
/// Uses the `add_2_calendar` package which handles iOS/Android calendar
/// intents natively. No permissions are required on modern OS versions
/// since the package uses the native calendar UI flow.
class CalendarSyncButton extends StatelessWidget {
  const CalendarSyncButton({super.key, required this.trip});

  final CarpoolTrip trip;

  void _syncToCalendar() {
    final event = Event(
      title: '拼车: ${trip.departureAddress} → ${trip.destinationAddress}',
      description: trip.note ?? '校园拼车行程',
      location: trip.departureAddress,
      startDate: trip.departureTime,
      // NOTE: Fall back to +1 hour if estimated arrival is unknown,
      // so the calendar event has a valid non-zero duration.
      endDate: trip.estimatedArrivalTime ??
          trip.departureTime.add(const Duration(hours: 1)),
    );
    Add2Calendar.addEvent2Cal(event);
  }

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      icon: const Icon(Icons.calendar_month),
      label: const Text('添加到日历'),
      onPressed: _syncToCalendar,
    );
  }
}
