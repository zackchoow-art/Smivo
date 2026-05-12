import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:smivo/features/carpool/providers/create_carpool_provider.dart';
import 'package:smivo/core/maps/map_location_picker.dart';

class CreateCarpoolScreen extends ConsumerStatefulWidget {
  const CreateCarpoolScreen({super.key});

  @override
  ConsumerState<CreateCarpoolScreen> createState() => _CreateCarpoolScreenState();
}

class _CreateCarpoolScreenState extends ConsumerState<CreateCarpoolScreen> {
  final _formKey = GlobalKey<FormState>();

  String _role = 'driver'; // 'driver' or 'organizer'
  String? _departureAddress;
  double? _departureLat;
  double? _departureLng;
  String? _departurePlaceId;

  String? _destinationAddress;
  double? _destinationLat;
  double? _destinationLng;
  String? _destinationPlaceId;

  DateTime? _departureTime;
  DateTime? _closingTime;

  int _totalSeats = 3;
  String _luggageLimit = 'none';
  bool _autoApproval = false;
  double? _estimatedTotalPrice;

  final _noteController = TextEditingController();
  final _departureDescController = TextEditingController();
  final _destinationDescController = TextEditingController();

  Future<void> _pickLocation(bool isDeparture) async {
    // NOTE: MapLocationPicker is an inline widget with onLocationSelected
    // callback. We show it in a bottom sheet for a full-screen feel.
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, _) => Padding(
          padding: const EdgeInsets.all(16),
          child: MapLocationPicker(
            label: isDeparture ? 'Departure Location' : 'Destination',
            onLocationSelected: (location) {
              setState(() {
                if (isDeparture) {
                  _departureAddress = location.displayName;
                  _departureLat = location.latitude;
                  _departureLng = location.longitude;
                  _departurePlaceId = location.placeId;
                } else {
                  _destinationAddress = location.displayName;
                  _destinationLat = location.latitude;
                  _destinationLng = location.longitude;
                  _destinationPlaceId = location.placeId;
                }
              });
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  Future<void> _pickDateTime(bool isDeparture) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (date == null) return;

    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time == null) return;

    final selected = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      if (isDeparture) {
        _departureTime = selected;
      } else {
        _closingTime = selected;
      }
    });
  }

  void _submit() async {
    if (_departureAddress == null || _destinationAddress == null || _departureTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete required fields (location and time)')),
      );
      return;
    }

    // Show Disclaimer Dialog (Phase 8 placeholder)
    final agreed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Carpool Disclaimer'),
        content: const Text('I confirm that the information posted is true and valid, and agree to the relevant carpool rules and disclaimers.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Agree & Post'),
          ),
        ],
      ),
    );

    if (agreed != true) return;

    await ref.read(createCarpoolProvider.notifier).createTrip(
          role: _role,
          departureAddress: _departureAddress!,
          destinationAddress: _destinationAddress!,
          departureTime: _departureTime!,
          totalSeats: _totalSeats,
          luggageLimit: _luggageLimit,
          approvalMode: _autoApproval ? 'auto' : 'manual',
          closingTime: _closingTime,
          note: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
          departureLat: _departureLat,
          departureLng: _departureLng,
          departurePlaceId: _departurePlaceId,
          destinationLat: _destinationLat,
          destinationLng: _destinationLng,
          destinationPlaceId: _destinationPlaceId,
          estimatedTotalPrice: _estimatedTotalPrice,
          departureDescription: _departureDescController.text.trim().isEmpty ? null : _departureDescController.text.trim(),
          destinationDescription: _destinationDescController.text.trim().isEmpty ? null : _destinationDescController.text.trim(),
        );

    final error = ref.read(createCarpoolProvider).error;
    if (error == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Posted successfully')),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    _departureDescController.dispose();
    _destinationDescController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = ref.watch(createCarpoolProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Post a Ride')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Your Role', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                ChoiceChip(
                  label: const Text('I\'m the Driver'),
                  selected: _role == 'driver',
                  onSelected: (val) {
                    if (val) setState(() => _role = 'driver');
                  },
                ),
                const SizedBox(width: 12),
                ChoiceChip(
                  label: const Text('I\'m Organizing (splitting cost)'),
                  selected: _role == 'organizer',
                  onSelected: (val) {
                    if (val) setState(() => _role = 'organizer');
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Route', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            TextFormField(
              controller: _departureDescController,
              decoration: const InputDecoration(
                labelText: 'Departure Name (e.g. Smith College)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _destinationDescController,
              decoration: const InputDecoration(
                labelText: 'Destination Name (e.g. Bradley Airport)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.trip_origin, color: theme.colorScheme.primary),
              title: Text(_departureAddress ?? 'Select Departure Location'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _pickLocation(true),
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.location_on, color: theme.colorScheme.error),
              title: Text(_destinationAddress ?? 'Select Destination'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _pickLocation(false),
            ),
            const SizedBox(height: 24),
            Text('Trip Details', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.access_time),
              title: Text(_departureTime != null
                  ? DateFormat('yyyy-MM-dd HH:mm').format(_departureTime!)
                  : 'Departure Time (Required)'),
              trailing: const Icon(Icons.calendar_today, size: 20),
              onTap: () => _pickDateTime(true),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Available Seats'),
                    Text(
                      'Number of empty seats you can offer',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline),
                      onPressed: _totalSeats > 1
                          ? () => setState(() => _totalSeats--)
                          : null,
                    ),
                    SizedBox(
                      width: 32,
                      child: Text(
                        '$_totalSeats',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      onPressed: _totalSeats < 9
                          ? () => setState(() => _totalSeats++)
                          : null,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Luggage Limit'),
                DropdownButton<String>(
                  value: _luggageLimit,
                  items: const [
                    DropdownMenuItem(value: 'none', child: Text('No Limit')),
                    DropdownMenuItem(value: 'small', child: Text('Small Bags Only')),
                    DropdownMenuItem(value: 'medium', child: Text('Medium Luggage')),
                    DropdownMenuItem(value: 'large', child: Text('Large Luggage OK')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _luggageLimit = val);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Estimated Total Price (\$)',
                hintText: 'e.g. 120.00',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              onChanged: (val) => setState(() => _estimatedTotalPrice = double.tryParse(val)),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16,
                    color: theme.colorScheme.onSecondaryContainer),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Actual cost may vary based on final headcount and total expenses.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Approval Mode'),
              subtitle: Text(_autoApproval ? 'Auto-approve requests' : 'Manual approval'),
              value: _autoApproval,
              onChanged: (val) => setState(() => _autoApproval = val),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.timer_off),
              title: Text(_closingTime != null
                  ? DateFormat('yyyy-MM-dd HH:mm').format(_closingTime!)
                  : 'Registration Deadline (Optional)'),
              trailing: IconButton(
                icon: const Icon(Icons.clear, size: 20),
                onPressed: () => setState(() => _closingTime = null),
              ),
              onTap: () => _pickDateTime(false),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              height: 48,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _submit,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Post a Ride'),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
