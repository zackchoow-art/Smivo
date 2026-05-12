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

  int _totalSeats = 4;
  String _luggageLimit = 'none';
  bool _autoApproval = false;

  final _noteController = TextEditingController();

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
            label: isDeparture ? '选择出发地点' : '选择目的地点',
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
        const SnackBar(content: Text('请完善必填信息（地点和时间）')),
      );
      return;
    }

    // Show Disclaimer Dialog (Phase 8 placeholder)
    final agreed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('拼车免责声明'),
        content: const Text('我确认发布的信息真实有效，并同意相关拼车规则及免责条款。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('同意并发布'),
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
        );

    final error = ref.read(createCarpoolProvider).error;
    if (error == null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('发布成功！')),
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLoading = ref.watch(createCarpoolProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('发布拼车')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('角色身份', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                ChoiceChip(
                  label: const Text('我是司机'),
                  selected: _role == 'driver',
                  onSelected: (val) {
                    if (val) setState(() => _role = 'driver');
                  },
                ),
                const SizedBox(width: 12),
                ChoiceChip(
                  label: const Text('我是发起人（找人分摊）'),
                  selected: _role == 'organizer',
                  onSelected: (val) {
                    if (val) setState(() => _role = 'organizer');
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('路线信息', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.trip_origin, color: theme.colorScheme.primary),
              title: Text(_departureAddress ?? '选择出发地点'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _pickLocation(true),
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.location_on, color: theme.colorScheme.error),
              title: Text(_destinationAddress ?? '选择目的地点'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _pickLocation(false),
            ),
            const SizedBox(height: 24),
            Text('行程细节', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.access_time),
              title: Text(_departureTime != null
                  ? DateFormat('yyyy-MM-dd HH:mm').format(_departureTime!)
                  : '出发时间（必填）'),
              trailing: const Icon(Icons.calendar_today, size: 20),
              onTap: () => _pickDateTime(true),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('座位数 (1-4)'),
                DropdownButton<int>(
                  value: _totalSeats,
                  items: [1, 2, 3, 4]
                      .map((e) => DropdownMenuItem(value: e, child: Text('$e 座')))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _totalSeats = val);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('行李限额'),
                DropdownButton<String>(
                  value: _luggageLimit,
                  items: const [
                    DropdownMenuItem(value: 'none', child: Text('不限')),
                    DropdownMenuItem(value: 'small', child: Text('仅小包')),
                    DropdownMenuItem(value: 'medium', child: Text('中等行李')),
                    DropdownMenuItem(value: 'large', child: Text('大件行李')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _luggageLimit = val);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('审核模式'),
              subtitle: Text(_autoApproval ? '自动接受申请' : '手动审核申请'),
              value: _autoApproval,
              onChanged: (val) => setState(() => _autoApproval = val),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.timer_off),
              title: Text(_closingTime != null
                  ? DateFormat('yyyy-MM-dd HH:mm').format(_closingTime!)
                  : '截止报名时间（选填）'),
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
                labelText: '备注（选填）',
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
                    : const Text('发布拼车'),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
