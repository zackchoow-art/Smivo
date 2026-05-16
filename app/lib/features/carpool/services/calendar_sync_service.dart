import 'package:device_calendar/device_calendar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:smivo/data/models/carpool_trip.dart';

final calendarSyncServiceProvider = Provider<CalendarSyncService>((ref) {
  return CalendarSyncService();
});

class CalendarSyncService {
  final DeviceCalendarPlugin _deviceCalendarPlugin;

  CalendarSyncService() : _deviceCalendarPlugin = DeviceCalendarPlugin();

  String _getPrefKey(String tripId) => 'calendar_event_$tripId';

  Future<bool> hasSyncedTrip(String tripId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_getPrefKey(tripId));
  }

  Future<void> syncTrip(CarpoolTrip trip) async {
    // 1. Request permissions
    var permissionsGranted = await _deviceCalendarPlugin.hasPermissions();
    if (permissionsGranted.isSuccess && !(permissionsGranted.data ?? false)) {
      permissionsGranted = await _deviceCalendarPlugin.requestPermissions();
      if (!permissionsGranted.isSuccess || !(permissionsGranted.data ?? false)) {
        throw Exception('Calendar permissions not granted');
      }
    }

    // 2. Find default calendar
    final calendarsResult = await _deviceCalendarPlugin.retrieveCalendars();
    if (!calendarsResult.isSuccess || (calendarsResult.data?.isEmpty ?? true)) {
      throw Exception('No calendars available on the device');
    }
    
    final calendars = calendarsResult.data!;
    
    // First try to find the default calendar. If not found, find a writable one.
    final defaultCalendar = calendars.firstWhere(
      (c) => c.isDefault == true && c.isReadOnly == false,
      orElse: () => calendars.firstWhere(
        (c) => c.isReadOnly == false, 
        orElse: () => throw Exception('No writable calendars found on the device')
      ),
    );

    // 3. Prepare the event
    final departure = trip.departureDescription ?? trip.departureAddress;
    final destination = trip.destinationDescription ?? trip.destinationAddress;
    String? targetCalendarId = defaultCalendar.id;
    String? existingEventId;
    
    // Check local preferences to see if we already created an event for this trip
    final prefs = await SharedPreferences.getInstance();
    final prefValue = prefs.getString(_getPrefKey(trip.id));
    
    if (prefValue != null) {
      final index = prefValue.indexOf(':');
      if (index != -1) {
        final savedCalId = prefValue.substring(0, index);
        final savedEventId = prefValue.substring(index + 1);
        
        // If the calendar we originally saved to still exists, use it.
        // This prevents duplicate events if the default calendar ordering changes.
        if (calendars.any((c) => c.id == savedCalId)) {
          targetCalendarId = savedCalId;
          existingEventId = savedEventId;
        }
      }
    }

    Event createEventObj(String? eventId) {
      return Event(
        targetCalendarId,
        eventId: eventId,
        title: 'Carpool: $departure → $destination',
        description: trip.note ?? 'Smivo Carpool Trip',
        location: trip.departureAddress,
        start: tz.TZDateTime.from(trip.departureTime, tz.local),
        end: tz.TZDateTime.from(
          trip.estimatedArrivalTime ?? trip.departureTime.add(const Duration(hours: 1)),
          tz.local,
        ),
        reminders: [Reminder(minutes: 60)],
      );
    }

    // 4. Save the event
    var result = await _deviceCalendarPlugin.createOrUpdateEvent(createEventObj(existingEventId));
    
    // If it failed and we provided an existingEventId, it might have been manually deleted from the calendar.
    // Try to create a brand new event instead.
    if ((result == null || !result.isSuccess || result.data == null) && existingEventId != null) {
      result = await _deviceCalendarPlugin.createOrUpdateEvent(createEventObj(null));
    }

    if (result == null || !result.isSuccess || result.data == null) {
      throw Exception('Failed to save event: ${result?.errors.map((e) => e.errorMessage).join(", ")}');
    }

    // 5. Store the mapping locally
    await prefs.setString(_getPrefKey(trip.id), '$targetCalendarId:${result.data}');
  }
}
