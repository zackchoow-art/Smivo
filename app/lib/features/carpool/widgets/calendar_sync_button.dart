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
    // NOTE: Use short descriptions for event title when available,
    // fall back to full addresses for backward compatibility.
    final departure = trip.departureDescription ?? trip.departureAddress;
    final destination = trip.destinationDescription ?? trip.destinationAddress;

    final event = Event(
      title: 'Carpool: $departure → $destination',
      description: trip.note ?? 'Campus carpool trip',
      location: trip.departureAddress,
      startDate: trip.departureTime,
      // NOTE: Fall back to +1 hour if estimated arrival is unknown,
      // so the calendar event has a valid non-zero duration.
      endDate: trip.estimatedArrivalTime ??
          trip.departureTime.add(const Duration(hours: 1)),
      // Remind user 1 hour before departure
      iosParams: const IOSParams(reminder: Duration(hours: 1)),
      androidParams: const AndroidParams(emailInvites: []),
    );
    Add2Calendar.addEvent2Cal(event);
  }

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      icon: const Icon(Icons.calendar_month),
      label: const Text('Add to Calendar'),
      onPressed: _syncToCalendar,
    );
  }
}
