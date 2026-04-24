import 'package:flutter/material.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/core/router/app_routes.dart';
import 'package:smivo/core/constants/app_constants.dart';
import 'package:smivo/data/models/pickup_location.dart';
import 'package:smivo/features/profile/providers/profile_provider.dart';
import 'package:smivo/features/listing/providers/create_listing_provider.dart';
import 'package:smivo/features/listing/widgets/custom_text_field.dart';
import 'package:smivo/features/listing/widgets/photo_picker_section.dart';
import 'package:smivo/features/shared/providers/school_provider.dart';


class CreateListingFormScreen extends ConsumerStatefulWidget {
  const CreateListingFormScreen({super.key, required this.initialMode});
  final String initialMode;

  @override
  ConsumerState<CreateListingFormScreen> createState() => _CreateListingFormScreenState();
}

class _CreateListingFormScreenState extends ConsumerState<CreateListingFormScreen> {
  late ProviderListenable<String> modeProvider;
  PickupLocation? _selectedPickup;
  bool _allowBuyerToSuggest = false;
  bool _isSubmitting = false;
  String _selectedCondition = 'good';

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _depositController = TextEditingController();
  final _dailyController = TextEditingController();
  final _weeklyController = TextEditingController();
  final _monthlyController = TextEditingController();

  bool _dailyEnabled = true;
  bool _weeklyEnabled = false;
  bool _monthlyEnabled = false;
  bool _dailyHasError = false;
  bool _weeklyHasError = false;
  bool _monthlyHasError = false;
  bool _depositHasError = false;
  String? _rentalRateErrorText;

  @override
  void initState() {
    super.initState();
    modeProvider = listingFormModeProvider(initialMode: widget.initialMode);
    _dailyController.text = '';
    _weeklyController.text = '';
    _monthlyController.text = '';
    _depositController.text = '';
    for (final c in [_titleController, _descriptionController, _priceController, _depositController, _dailyController, _weeklyController, _monthlyController]) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _depositController.dispose();
    _dailyController.dispose();
    _weeklyController.dispose();
    _monthlyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(modeProvider);
    final isSale = mode == 'sale';
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: Colors.transparent, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () { if (Navigator.of(context).canPop()) Navigator.of(context).pop(); }),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(isSale ? 'List an Item' : 'List a Rental',
            style: typo.displayLarge.copyWith(fontSize: 36, letterSpacing: -1, color: colors.onSurface)),
          const SizedBox(height: 4),
          Text(isSale ? 'Turn your unused gear into cash on campus.' : 'Make money by renting out your stuff.',
            style: typo.bodyLarge.copyWith(color: colors.onSurfaceVariant)),
          const SizedBox(height: 24),
          Center(child: SegmentedButton<String>(
            segments: const [ButtonSegment(value: 'sale', label: Text('Sell')), ButtonSegment(value: 'rental', label: Text('Rent'))],
            selected: {mode},
            onSelectionChanged: (s) => ref.read(listingFormModeProvider(initialMode: widget.initialMode).notifier).setMode(s.first),
          )),
          const SizedBox(height: 24),
          const PhotoPickerSection(),
          const SizedBox(height: 24),
          CustomTextField(label: 'Item Title', hintText: "Name of the item you're selling", controller: _titleController),
          const SizedBox(height: 24),
          CustomTextField(label: 'Item Description', hintText: "Describe its condition, features, and why someone should buy it...", maxLines: 4, controller: _descriptionController),
          const SizedBox(height: 24),
          Text('Category', style: typo.labelLarge.copyWith(fontWeight: FontWeight.bold, color: colors.onSurface)),
          const SizedBox(height: 8),
          _CategoryPicker(),
          const SizedBox(height: 24),
          Text('Condition', style: typo.labelLarge.copyWith(fontWeight: FontWeight.bold, color: colors.onSurface)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            _ConditionChip(label: 'New', value: 'new', isSelected: _selectedCondition == 'new', onTap: () => setState(() => _selectedCondition = 'new')),
            _ConditionChip(label: 'Like New', value: 'like_new', isSelected: _selectedCondition == 'like_new', onTap: () => setState(() => _selectedCondition = 'like_new')),
            _ConditionChip(label: 'Good', value: 'good', isSelected: _selectedCondition == 'good', onTap: () => setState(() => _selectedCondition = 'good')),
            _ConditionChip(label: 'Fair', value: 'fair', isSelected: _selectedCondition == 'fair', onTap: () => setState(() => _selectedCondition = 'fair')),
            _ConditionChip(label: 'Poor', value: 'poor', isSelected: _selectedCondition == 'poor', onTap: () => setState(() => _selectedCondition = 'poor')),
          ]),
          const SizedBox(height: 24),
          if (isSale)
            CustomTextField(label: 'Price', hintText: '0.00', prefixText: '\$',
              keyboardType: const TextInputType.numberWithOptions(decimal: true), controller: _priceController)
          else ...[
            Text('Rental Pricing', style: typo.labelLarge.copyWith(fontWeight: FontWeight.bold, color: colors.onSurface)),
            const SizedBox(height: 12),
            _buildRentalRateRow(context, label: 'Daily Rate', controller: _dailyController, enabled: _dailyEnabled, hasError: _dailyHasError,
              onChanged: (v) => setState(() { _dailyEnabled = v ?? false; if (!_dailyEnabled) { _dailyController.clear(); _dailyHasError = false; } })),
            const SizedBox(height: 12),
            _buildRentalRateRow(context, label: 'Weekly Rate', controller: _weeklyController, enabled: _weeklyEnabled, hasError: _weeklyHasError,
              onChanged: (v) => setState(() { _weeklyEnabled = v ?? false; if (!_weeklyEnabled) { _weeklyController.clear(); _weeklyHasError = false; } })),
            const SizedBox(height: 12),
            _buildRentalRateRow(context, label: 'Monthly Rate', controller: _monthlyController, enabled: _monthlyEnabled, hasError: _monthlyHasError,
              onChanged: (v) => setState(() { _monthlyEnabled = v ?? false; if (!_monthlyEnabled) { _monthlyController.clear(); _monthlyHasError = false; } })),
            if (_rentalRateErrorText != null) Padding(
              padding: const EdgeInsets.only(top: 4, left: 140),
              child: Text(_rentalRateErrorText!, style: TextStyle(color: colors.error, fontSize: 12))),
            const SizedBox(height: 24),
            Text('Security Deposit', style: typo.labelLarge.copyWith(fontWeight: FontWeight.bold, color: colors.onSurface)),
            const SizedBox(height: 8),
            TextField(
              controller: _depositController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: typo.bodyLarge.copyWith(color: colors.onSurface),
              decoration: InputDecoration(
                hintText: 'Required for rentals', prefixText: '\$ ',
                prefixStyle: typo.bodyLarge.copyWith(color: colors.onSurface, fontWeight: FontWeight.bold),
                filled: true, fillColor: colors.surfaceContainerLow, contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(radius.input),
                  borderSide: _depositHasError ? BorderSide(color: colors.error, width: 2) : BorderSide.none),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(radius.input),
                  borderSide: _depositHasError ? BorderSide(color: colors.error, width: 2) : BorderSide.none),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(radius.input),
                  borderSide: BorderSide(color: _depositHasError ? colors.error : colors.primary, width: 2)),
              ),
            ),
          ],
          const SizedBox(height: 24),
          Text('Pickup Location', style: typo.labelLarge.copyWith(fontWeight: FontWeight.bold, color: colors.onSurface)),
          const SizedBox(height: 8),
          Consumer(builder: (context, ref, _) {
            final pickupsAsync = ref.watch(myPickupLocationsProvider);
            return pickupsAsync.when(
              loading: () => const SizedBox(height: 56, child: Center(child: CircularProgressIndicator())),
              error: (err, _) => Text('Failed to load locations: $err'),
              data: (locations) {
                if (locations.isEmpty) return const Text('No pickup locations available');
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(color: colors.surfaceContainerLow, borderRadius: BorderRadius.circular(radius.input)),
                  child: DropdownButtonHideUnderline(child: DropdownButton<PickupLocation>(
                    value: _selectedPickup, hint: const Text('Select pickup location'), isExpanded: true,
                    icon: Icon(Icons.arrow_drop_down, color: colors.onSurfaceVariant),
                    style: typo.titleMedium.copyWith(color: colors.onSurface),
                    onChanged: (v) => setState(() => _selectedPickup = v),
                    items: locations.map((loc) => DropdownMenuItem<PickupLocation>(value: loc, child: Text(loc.name))).toList(),
                  )),
                );
              },
            );
          }),
          CheckboxListTile(
            title: const Text('Allow buyer to suggest alternative location'),
            value: _allowBuyerToSuggest,
            onChanged: (v) => setState(() => _allowBuyerToSuggest = v ?? false),
            controlAffinity: ListTileControlAffinity.leading, contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 24),
          const SizedBox(height: 48),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: _isSubmitting ? null : () => _handleSubmit(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary, padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius.button)), elevation: 0),
            child: _isSubmitting
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text(isSale ? 'List Item for Sale' : 'Post Rental', style: typo.titleMedium.copyWith(color: colors.onPrimary)),
          )),
          const SizedBox(height: 80),
        ]),
      ),
    );
  }

  Widget _buildRentalRateRow(BuildContext context, {required String label, required TextEditingController controller,
    required bool enabled, required bool hasError, required Function(bool?) onChanged}) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;
    return Row(children: [
      SizedBox(width: 150, child: CheckboxListTile(
        value: enabled, onChanged: onChanged,
        title: Text(label, style: typo.bodyMedium.copyWith(color: colors.onSurface, fontWeight: FontWeight.w500)),
        controlAffinity: ListTileControlAffinity.leading, contentPadding: EdgeInsets.zero, dense: true, visualDensity: VisualDensity.compact,
      )),
      Expanded(child: TextField(
        controller: controller, enabled: enabled,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        style: typo.bodyLarge.copyWith(color: colors.onSurface),
        decoration: InputDecoration(
          prefixText: '\$ ', hintText: enabled ? '' : '—',
          prefixStyle: typo.bodyLarge.copyWith(color: colors.onSurface, fontWeight: FontWeight.bold),
          filled: true, fillColor: enabled ? colors.surfaceContainerLow : Colors.grey.shade100, contentPadding: const EdgeInsets.all(12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(radius.input),
            borderSide: hasError ? BorderSide(color: colors.error, width: 2) : BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(radius.input),
            borderSide: hasError ? BorderSide(color: colors.error, width: 2) : BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(radius.input),
            borderSide: BorderSide(color: hasError ? colors.error : colors.primary, width: 2)),
          disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(radius.input), borderSide: BorderSide(color: Colors.grey.shade200)),
        ),
      )),
    ]);
  }

  Future<void> _handleSubmit(BuildContext context) async {
    setState(() { _dailyHasError = false; _weeklyHasError = false; _monthlyHasError = false; _depositHasError = false; _rentalRateErrorText = null; });
    final formMode = ref.read(modeProvider);
    final category = ref.read(selectedListingCategoryProvider);
    final isSale = formMode == 'sale';
    final errors = <String>[];
    if (_titleController.text.trim().isEmpty) errors.add('Title is required');
    if (_descriptionController.text.trim().isEmpty) errors.add('Description is required');
    if (category == null || category.isEmpty) errors.add('Please select a category');
    if (isSale) {
      final price = double.tryParse(_priceController.text.trim());
      if (price == null || price <= 0) errors.add('Valid sale price required');
    }
    if (!isSale) {
      final daily = _dailyEnabled ? double.tryParse(_dailyController.text.trim()) : null;
      final weekly = _weeklyEnabled ? double.tryParse(_weeklyController.text.trim()) : null;
      final monthly = _monthlyEnabled ? double.tryParse(_monthlyController.text.trim()) : null;
      if (_dailyEnabled && (daily == null || daily <= 0)) { setState(() => _dailyHasError = true); errors.add('Daily rate must be greater than 0'); }
      if (_weeklyEnabled && (weekly == null || weekly <= 0)) { setState(() => _weeklyHasError = true); errors.add('Weekly rate must be greater than 0'); }
      if (_monthlyEnabled && (monthly == null || monthly <= 0)) { setState(() => _monthlyHasError = true); errors.add('Monthly rate must be greater than 0'); }
      if (!_dailyEnabled && !_weeklyEnabled && !_monthlyEnabled) { setState(() => _rentalRateErrorText = 'Select at least one rental mode'); errors.add('Select at least one rental mode'); }
      final depositText = _depositController.text.trim();
      final deposit = double.tryParse(depositText);
      if (deposit == null || deposit < 0) { setState(() => _depositHasError = true); errors.add('Deposit must be a valid number (0 or greater)'); }
    }
    if (errors.isNotEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errors.first), backgroundColor: Colors.red)); return;
    }
    setState(() => _isSubmitting = true);
    try {
      final profile = ref.read(profileProvider).valueOrNull;
      if (profile == null) throw StateError('Not logged in');
      final selectedCategory = ref.read(selectedListingCategoryProvider)!;
      double? price, dailyRate, weeklyRate, monthlyRate;
      if (isSale) { price = double.tryParse(_priceController.text.trim()) ?? 0.0; } else {
        dailyRate = _dailyEnabled ? double.tryParse(_dailyController.text.trim()) : null;
        weeklyRate = _weeklyEnabled ? double.tryParse(_weeklyController.text.trim()) : null;
        monthlyRate = _monthlyEnabled ? double.tryParse(_monthlyController.text.trim()) : null;
      }
      final deposit = double.tryParse(_depositController.text.trim()) ?? 0.0;
      await ref.read(createListingActionProvider.notifier).submit(
        title: _titleController.text, description: _descriptionController.text, category: selectedCategory,
        transactionType: isSale ? 'sale' : 'rental', condition: _selectedCondition, schoolId: profile.schoolId,
        price: price, dailyRate: dailyRate, weeklyRate: weeklyRate, monthlyRate: monthlyRate,
        depositAmount: deposit, pickupLocationId: _selectedPickup?.id, allowPickupChange: _allowBuyerToSuggest,
        isPinned: false, pinnedDays: null);
      if (!context.mounted) return;
      await _showSuccessDialog(context, isSale);
      if (!context.mounted) return;
      context.goNamed(AppRoutes.home);
    } catch (e, stackTrace) {
      debugPrint('=== LISTING SUBMIT ERROR ==='); debugPrint('Error: $e'); debugPrint(stackTrace.toString());
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to post: ${e.toString()}'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _showSuccessDialog(BuildContext context, bool isSale) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;
    return showDialog(
      context: context, barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius.dialog)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.check_circle, color: colors.success, size: 80),
          const SizedBox(height: 24),
          Text('Success!', style: typo.headlineSmall.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(isSale ? 'Your item has been listed for sale.' : 'Your rental listing has been posted.',
            textAlign: TextAlign.center, style: typo.bodyMedium),
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: colors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius.md))),
            child: Text('Back to Home', style: TextStyle(color: colors.onPrimary)),
          )),
        ]),
      ),
    );
  }
}

class _CategoryPicker extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedListingCategoryProvider);
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;
    return Wrap(spacing: 8, runSpacing: 8,
      children: AppConstants.categories.map((category) {
        final isSelected = selectedCategory == category;
        return GestureDetector(
          onTap: () => ref.read(selectedListingCategoryProvider.notifier).setCategory(category),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: isSelected ? colors.primary : colors.secondaryContainer, borderRadius: BorderRadius.circular(radius.full)),
            child: Text(category, style: typo.labelLarge.copyWith(
              color: isSelected ? colors.onPrimary : colors.onSurfaceVariant, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
          ),
        );
      }).toList(),
    );
  }
}

class _ConditionChip extends StatelessWidget {
  const _ConditionChip({required this.label, required this.value, required this.isSelected, required this.onTap});
  final String label;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: isSelected ? colors.primary : colors.secondaryContainer, borderRadius: BorderRadius.circular(radius.full)),
        child: Text(label, style: typo.labelLarge.copyWith(
          color: isSelected ? colors.onPrimary : colors.onSurfaceVariant, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
      ),
    );
  }
}
