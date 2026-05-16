import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:smivo/features/carpool/providers/create_carpool_provider.dart';
import 'package:smivo/core/maps/map_location_picker.dart';
import 'package:smivo/features/carpool/widgets/legal_disclaimer_dialog.dart';
import 'package:smivo/shared/widgets/action_success_dialog.dart';
import 'package:smivo/shared/widgets/action_error_dialog.dart';

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
  bool _autoApproval = true;
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
                  _departureAddress = location.address ?? location.displayName;
                  _departureLat = location.latitude;
                  _departureLng = location.longitude;
                  _departurePlaceId = location.placeId;
                } else {
                  _destinationAddress = location.address ?? location.displayName;
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
    final now = DateTime.now();
    DateTime first = now;
    DateTime last = isDeparture ? now.add(const Duration(days: 90)) : (_departureTime ?? now.add(const Duration(days: 90)));
    if (last.isBefore(first)) last = first;

    DateTime initial = isDeparture ? (_departureTime ?? now) : (_closingTime ?? now);
    if (initial.isBefore(first)) initial = first;
    if (initial.isAfter(last)) initial = last;

    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
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
        final defaultClosing = selected.subtract(const Duration(hours: 1));
        _closingTime = defaultClosing.isBefore(DateTime.now()) ? DateTime.now() : defaultClosing;
      } else {
        if (_departureTime != null && selected.isAfter(_departureTime!)) {
          _closingTime = _departureTime;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registration deadline cannot be after departure time')),
          );
        } else {
          _closingTime = selected;
        }
      }
    });
  }

  void _submit() async {
    // NOTE: Validate TextFormFields (e.g. price) before running location checks.
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_departureAddress == null || _destinationAddress == null || _departureTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete required fields (location and time)')),
      );
      return;
    }

    // Show Legal Disclaimer before posting
    final agreed = await LegalDisclaimerDialog.show(context);

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
      await showDialog(
        context: context,
        builder: (ctx) => const ActionSuccessDialog(
          title: 'Posted successfully',
          message: 'Your carpool trip has been posted.',
        ),
      );
      if (mounted) Navigator.pop(context);
    } else if (mounted) {
      showDialog(
        context: context,
        builder: (ctx) => ActionErrorDialog(
          title: 'Failed to post',
          message: error.toString(),
        ),
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
            Text('Pricing Model', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                ChoiceChip(
                  label: const Text('Fixed Price'),
                  selected: _role == 'driver',
                  onSelected: (val) {
                    if (val) setState(() => _role = 'driver');
                  },
                ),
                const SizedBox(width: 12),
                ChoiceChip(
                  label: const Text('Split Cost'),
                  selected: _role == 'organizer',
                  onSelected: (val) {
                    if (val) setState(() => _role = 'organizer');
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.lightbulb, color: Colors.amber, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _role == 'driver'
                        ? 'Fixed Price: Each passenger pays a set amount regardless of total people or final expenses. Ideal for driving yourself and covering gas/tolls.'
                        : 'Split Cost: The total expense is divided equally among everyone (including you). Ideal for rideshares like Uber/Lyft to a shared destination.',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Route', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            TextFormField(
              controller: _departureDescController,
              decoration: const InputDecoration(
                labelText: 'Departure Name (e.g. School)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _destinationDescController,
              decoration: const InputDecoration(
                labelText: 'Destination Name (e.g. Airport)',
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
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: _role == 'driver'
                    ? 'Fixed Price per person (\$)'
                    : 'Estimated Total Cost (\$)',
                hintText: _role == 'driver' ? 'e.g. 30.00' : 'e.g. 100.00',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.attach_money),
              ),
              onChanged: (val) =>
                  setState(() => _estimatedTotalPrice = double.tryParse(val)),
              // NOTE: Price is required for both modes — driver sets a fixed
              // per-person rate; organizer provides an estimate so potential
              // passengers can evaluate cost before joining.
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return _role == 'driver'
                      ? 'Fixed price is required'
                      : 'Please enter an estimated total cost';
                }
                if (double.tryParse(val.trim()) == null) {
                  return 'Enter a valid number';
                }
                return null;
              },
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
                      _role == 'driver'
                          ? 'Passengers will pay exactly this amount upon completion.'
                          : 'Actual cost per person may vary based on the final total expenses and the final headcount.',
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
              title: const Text('Auto approve requests'),
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
