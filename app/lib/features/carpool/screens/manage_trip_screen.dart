import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:go_router/go_router.dart';
import 'package:smivo/core/router/app_routes.dart';
import 'package:smivo/data/models/carpool_member.dart';
import 'package:smivo/data/models/carpool_trip.dart';
import 'package:smivo/features/carpool/providers/carpool_detail_provider.dart';
import 'package:smivo/features/carpool/providers/carpool_members_provider.dart';
import 'package:smivo/data/repositories/carpool_repository.dart';
import 'package:smivo/shared/widgets/smivo_user_avatar.dart';
import 'package:smivo/core/maps/map_location_picker.dart';
import 'package:smivo/shared/widgets/collapsible_section.dart';

class ManageTripScreen extends ConsumerStatefulWidget {
  const ManageTripScreen({
    super.key,
    required this.tripId,
    required this.creatorId,
  });

  final String tripId;
  final String creatorId;

  @override
  ConsumerState<ManageTripScreen> createState() => _ManageTripScreenState();
}

class _ManageTripScreenState extends ConsumerState<ManageTripScreen> {
  bool _isInit = false;
  bool _isSaving = false;

  final _formKey = GlobalKey<FormState>();

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
  final _priceController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    _departureDescController.dispose();
    _destinationDescController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _initFields(CarpoolTrip trip) {
    if (_isInit) return;
    _departureAddress = trip.departureAddress;
    _departureLat = trip.departureLat;
    _departureLng = trip.departureLng;
    _departurePlaceId = trip.departurePlaceId;

    _destinationAddress = trip.destinationAddress;
    _destinationLat = trip.destinationLat;
    _destinationLng = trip.destinationLng;
    _destinationPlaceId = trip.destinationPlaceId;

    _departureTime = trip.departureTime;
    _closingTime = trip.closingTime;

    _totalSeats = trip.totalSeats;
    _luggageLimit = trip.luggageLimit ?? 'none';
    _autoApproval = trip.approvalMode == 'auto';
    _estimatedTotalPrice = trip.estimatedTotalPrice;

    _noteController.text = trip.note ?? '';
    _departureDescController.text = trip.departureDescription ?? '';
    _destinationDescController.text = trip.destinationDescription ?? '';
    if (trip.estimatedTotalPrice != null) {
      _priceController.text = trip.estimatedTotalPrice.toString();
    }

    _isInit = true;
  }

  Future<void> _pickLocation(bool isDeparture) async {
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
    DateTime last = isDeparture
        ? now.add(const Duration(days: 90))
        : (_departureTime ?? now.add(const Duration(days: 90)));
    if (last.isBefore(first)) last = first;

    DateTime initial =
        isDeparture ? (_departureTime ?? now) : (_closingTime ?? now);
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
        _closingTime = defaultClosing.isBefore(DateTime.now())
            ? DateTime.now()
            : defaultClosing;
      } else {
        if (_departureTime != null && selected.isAfter(_departureTime!)) {
          _closingTime = _departureTime;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content:
                    Text('Registration deadline cannot be after departure time')),
          );
        } else {
          _closingTime = selected;
        }
      }
    });
  }

  Future<void> _saveChanges(CarpoolTrip originalTrip) async {
    if (_departureAddress == null ||
        _destinationAddress == null ||
        _departureTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete required fields')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final updates = <String, dynamic>{
        if (_departureAddress != originalTrip.departureAddress)
          'departure_address': _departureAddress,
        if (_departureLat != originalTrip.departureLat)
          'departure_lat': _departureLat,
        if (_departureLng != originalTrip.departureLng)
          'departure_lng': _departureLng,
        if (_departurePlaceId != originalTrip.departurePlaceId)
          'departure_place_id': _departurePlaceId,
        if (_destinationAddress != originalTrip.destinationAddress)
          'destination_address': _destinationAddress,
        if (_destinationLat != originalTrip.destinationLat)
          'destination_lat': _destinationLat,
        if (_destinationLng != originalTrip.destinationLng)
          'destination_lng': _destinationLng,
        if (_destinationPlaceId != originalTrip.destinationPlaceId)
          'destination_place_id': _destinationPlaceId,
        if (_departureTime != originalTrip.departureTime)
          'departure_time': _departureTime!.toUtc().toIso8601String(),
        if (_closingTime != originalTrip.closingTime)
          'closing_time': _closingTime?.toUtc().toIso8601String(),
        if (_totalSeats != originalTrip.totalSeats) 'total_seats': _totalSeats,
        if (_luggageLimit != originalTrip.luggageLimit)
          'luggage_limit': _luggageLimit,
        if ((_autoApproval ? 'auto' : 'manual') != originalTrip.approvalMode)
          'approval_mode': _autoApproval ? 'auto' : 'manual',
        if (_estimatedTotalPrice != originalTrip.estimatedTotalPrice)
          'estimated_total_price': _estimatedTotalPrice,
        if (_noteController.text.trim() != originalTrip.note)
          'note': _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
        if (_departureDescController.text.trim() != originalTrip.departureDescription)
          'departure_description': _departureDescController.text.trim().isEmpty ? null : _departureDescController.text.trim(),
        if (_destinationDescController.text.trim() != originalTrip.destinationDescription)
          'destination_description': _destinationDescController.text.trim().isEmpty ? null : _destinationDescController.text.trim(),
      };

      if (updates.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No changes to save.')),
        );
        setState(() => _isSaving = false);
        return;
      }

      await ref
          .read(carpoolRepositoryProvider)
          .updateTrip(widget.tripId, updates);

      ref.invalidate(carpoolDetailProvider(widget.tripId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Trip updated successfully.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildEditTripForm(ThemeData theme, CarpoolTrip trip) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  const Text('Total Seats'),
                  Text(
                    'Including empty seats you offer',
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
                  DropdownMenuItem(
                      value: 'small', child: Text('Small Bags Only')),
                  DropdownMenuItem(
                      value: 'medium', child: Text('Medium Luggage')),
                  DropdownMenuItem(
                      value: 'large', child: Text('Large Luggage OK')),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _luggageLimit = val);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _priceController,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Estimated Total Price (\$)',
              hintText: 'e.g. 120.00',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.attach_money),
            ),
            onChanged: (val) =>
                setState(() => _estimatedTotalPrice = double.tryParse(val)),
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
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isSaving ? null : () => _saveChanges(trip),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Save Changes'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersSection(ThemeData theme, CarpoolTrip trip) {
    final membersAsync = ref.watch(carpoolTripMembersProvider(widget.tripId));

    return membersAsync.when(
      data: (members) {
        // Exclude the creator from the management list
        final manageable = members
            .where((m) => m.userId != widget.creatorId)
            .toList();

        if (manageable.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.group_off, size: 64, color: theme.dividerColor),
                  const SizedBox(height: 16),
                  Text(
                    'No members yet',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final pending =
            manageable.where((m) => m.status == 'pending').toList();
        final approved =
            manageable.where((m) => m.status == 'approved').toList();
        final others = manageable
            .where((m) => m.status != 'pending' && m.status != 'approved')
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (pending.isNotEmpty) ...[
              _SectionHeader(
                  title: 'Pending Requests',
                  count: pending.length,
                  color: Colors.orange),
              ...pending.map((m) => _MemberTile(
                  member: m, trip: trip, status: 'pending')),
            ],
            if (approved.isNotEmpty) ...[
              _SectionHeader(
                  title: 'Approved',
                  count: approved.length,
                  color: Colors.green),
              ...approved.map((m) => _MemberTile(
                  member: m, trip: trip, status: 'approved')),
            ],
            if (others.isNotEmpty) ...[
              _SectionHeader(
                  title: 'Rejected / Left',
                  count: others.length,
                  color: Colors.grey),
              ...others.map((m) => _MemberTile(
                  member: m, trip: trip, status: m.status)),
            ],
          ],
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Padding(
        padding: const EdgeInsets.all(32),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(error.toString(), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    ref.invalidate(carpoolTripMembersProvider(widget.tripId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tripAsync = ref.watch(carpoolDetailProvider(widget.tripId));

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Trip')),
      body: tripAsync.when(
        data: (trip) {
          if (trip == null) {
            return const Center(child: Text('Trip not found.'));
          }

          WidgetsBinding.instance.addPostFrameCallback((_) {
            _initFields(trip);
          });

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(carpoolDetailProvider(widget.tripId));
              ref.invalidate(carpoolTripMembersProvider(widget.tripId));
            },
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              children: [
                CollapsibleSection(
                  title: 'Edit Trip Details',
                  initiallyExpanded: false,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: _buildEditTripForm(theme, trip),
                  ),
                ),
                const SizedBox(height: 24),
                CollapsibleSection(
                  title: 'Members',
                  initiallyExpanded: true,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: _buildMembersSection(theme, trip),
                  ),
                ),
                const SizedBox(height: 32),
                if (trip.status == 'active' || trip.status == 'inactive')
                  _buildConfirmTripButton(context, theme, trip),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text(error.toString())),
      ),
    );
  }

  Widget _buildConfirmTripButton(BuildContext context, ThemeData theme, CarpoolTrip trip) {
    return ElevatedButton.icon(
      onPressed: () => _handleConfirmTrip(context, trip),
      icon: const Icon(Icons.check_circle, size: 24),
      label: const Text('Confirm Trip'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        textStyle: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> _handleConfirmTrip(BuildContext context, CarpoolTrip trip) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Trip?'),
        content: const Text(
          'Confirming this trip will lock all details and send a notification to all members. '
          'Once confirmed, the trip can no longer be cancelled. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Wait'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.primary,
            ),
            child: const Text('Yes, Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref.read(carpoolRepositoryProvider).confirmTrip(trip.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Trip confirmed successfully!')),
      );
      ref.invalidate(carpoolDetailProvider(trip.id));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to confirm trip: $e')),
      );
    }
  }
}

/// Section header with colored dot indicator and member count.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.count,
    required this.color,
  });

  final String title;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 16, 0, 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: theme.textTheme.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual member tile with avatar, name, status chip, and action buttons.
class _MemberTile extends ConsumerWidget {
  const _MemberTile({
    required this.member,
    required this.trip,
    required this.status,
  });

  final CarpoolMember member;
  final CarpoolTrip trip;
  final String status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = member.user;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: _buildAvatar(theme),
      title: Text(
        user?.displayName ?? 'Unknown User',
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        user?.email ?? '',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.outline,
        ),
      ),
      trailing: _buildTrailing(context, ref, theme),
    );
  }

  Widget _buildAvatar(ThemeData theme) {
    final user = member.user;
    if (user != null) {
      return SmivoUserAvatar(
        user: user,
        radius: 20,
        enableTap: true,
      );
    }
    return CircleAvatar(
      radius: 20,
      backgroundColor: theme.colorScheme.surfaceContainerHighest,
      child: const Icon(Icons.person, size: 20),
    );
  }

  Widget? _buildTrailing(
      BuildContext context, WidgetRef ref, ThemeData theme) {
    if (status == 'pending') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.close, color: theme.colorScheme.error),
            tooltip: 'Reject',
            onPressed: () => _handleReject(context, ref),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: Icon(Icons.check, color: Colors.green.shade600),
            tooltip: 'Approve',
            style: IconButton.styleFrom(
              backgroundColor: Colors.green.shade50,
            ),
            onPressed: () => _handleApprove(context, ref),
          ),
        ],
      );
    }

    bool isPendingChanges = false;
    // Basic heuristic: if lastAcknowledgedSnapshot exists but is older than trip update?
    // Or just check if snapshot doesn't match current trip fields
    if (status == 'approved' && member.lastAcknowledgedSnapshot != null) {
       final snap = member.lastAcknowledgedSnapshot!;
       if (snap['estimated_total_price'] != trip.estimatedTotalPrice || 
           snap['departure_time'] != trip.departureTime.toIso8601String() ||
           snap['departure_address'] != trip.departureAddress) {
           isPendingChanges = true;
       }
    }

    final (label, chipColor) = switch (status) {
      'approved' => isPendingChanges 
          ? ('Pending Changes', Colors.orange) 
          : ('Accepted', Colors.green),
      'rejected' => ('Rejected', Colors.red),
      'left' => ('Left', Colors.grey),
      _ => (status, Colors.grey),
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (status == 'approved') ...[
          IconButton(
            icon: const Icon(Icons.forum, size: 20),
            tooltip: 'Group Chat',
            color: theme.colorScheme.primary,
            onPressed: () => context.pushNamed(
              AppRoutes.groupChatRoom,
              pathParameters: {'id': trip.id},
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, size: 20),
            tooltip: 'Private Chat',
            color: theme.colorScheme.secondary,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Private chat coming soon')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person_remove, size: 20),
            tooltip: 'Kick Out',
            color: theme.colorScheme.error,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Kick voting coming soon')),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: chipColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: chipColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleApprove(BuildContext context, WidgetRef ref) async {
    try {
      await ref
          .read(carpoolMemberActionsProvider.notifier)
          .approveMember(member.id, trip.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${member.user?.displayName ?? "Member"} approved'),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to approve: $e')),
      );
    }
  }

  Future<void> _handleReject(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Request'),
        content: Text(
          'Are you sure you want to reject '
          '${member.user?.displayName ?? "this member"}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref
          .read(carpoolMemberActionsProvider.notifier)
          .rejectMember(member.id, trip.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${member.user?.displayName ?? "Member"} rejected'),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to reject: $e')),
      );
    }
  }
}
