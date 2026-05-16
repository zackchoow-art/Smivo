import 'package:flutter/material.dart';
import 'package:smivo/core/theme/breakpoints.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/core/router/app_routes.dart';
import 'package:smivo/features/shared/providers/school_data_provider.dart';
import 'package:smivo/features/profile/providers/profile_provider.dart';
import 'package:smivo/features/listing/providers/create_listing_provider.dart';
import 'package:smivo/features/listing/widgets/custom_text_field.dart';
import 'package:smivo/features/listing/widgets/photo_picker_section.dart';
import 'package:smivo/shared/widgets/action_success_dialog.dart';
import 'package:smivo/shared/widgets/content_width_constraint.dart';
import 'package:smivo/features/home/providers/home_provider.dart';
import 'package:smivo/features/shared/providers/school_provider.dart';
import 'package:smivo/shared/widgets/pickup_address_selector.dart';

import 'package:smivo/shared/widgets/collapsing_title_app_bar.dart';
import 'package:smivo/shared/widgets/unified_page_header.dart';

class CreateListingFormScreen extends ConsumerStatefulWidget {
  const CreateListingFormScreen({super.key, required this.initialMode});
  final String initialMode;

  @override
  ConsumerState<CreateListingFormScreen> createState() =>
      _CreateListingFormScreenState();
}

class _CreateListingFormScreenState
    extends ConsumerState<CreateListingFormScreen> {
  late dynamic modeProvider;
  // NOTE: Resolved by PickupAddressSelector via callbacks.
  String? _selectedPickupId; // null = custom address / 'Specify Address'
  String _customLocationNote = ''; // Effective address text
  bool _allowBuyerToSuggest = true; // Default true per UX guidelines
  final GlobalKey<PickupAddressSelectorState> _addressSelectorKey =
      GlobalKey<PickupAddressSelectorState>();
  bool _isSubmitting = false;
  String _selectedCondition = 'good';
  // C2: Available date — null means "available now" or not specified.
  DateTime? _availableDate;

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _depositController = TextEditingController();
  final _dailyController = TextEditingController();
  final _weeklyController = TextEditingController();
  final _monthlyController = TextEditingController();
  final _customLocationController = TextEditingController();

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
    for (final c in [
      _titleController,
      _descriptionController,
      _priceController,
      _depositController,
      _dailyController,
      _weeklyController,
      _monthlyController,
    ]) {
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
    _customLocationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(modeProvider);
    final isSale = mode == 'sale';
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = Breakpoints.isDesktop(screenWidth);

    final banAsync = ref.watch(userListingBanProvider);

    return banAsync.when(
      loading:
          () => Scaffold(
            backgroundColor: colors.surfaceContainerLowest,
            body: const Center(child: CircularProgressIndicator()),
          ),
      error:
          (_, __) => Scaffold(
            backgroundColor: colors.surfaceContainerLowest,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Failed to check account status'),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            ),
          ),
      data: (banExpiration) {
        if (banExpiration != null) {
          final isPermanent = banExpiration.year == 2099;
          final dateStr =
              isPermanent
                  ? 'Permanently'
                  : '${banExpiration.year}-${banExpiration.month.toString().padLeft(2, '0')}-${banExpiration.day.toString().padLeft(2, '0')}';

          return Scaffold(
            backgroundColor: colors.surfaceContainerLowest,
            body: GestureDetector(
              onTap: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.goNamed(AppRoutes.home);
                }
              },
              behavior: HitTestBehavior.opaque,
              child: SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.block, size: 64, color: colors.error),
                        const SizedBox(height: 24),
                        Text(
                          'Listing Privileges Suspended',
                          style: typo.headlineSmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.onSurface,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          isPermanent
                              ? 'Your account has been permanently restricted from creating listings due to violations of our community guidelines.'
                              : 'Your ability to create listings has been temporarily suspended.\n\nRestriction lifts on: $dateStr',
                          style: typo.bodyLarge.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 48),
                        Text(
                          'Tap anywhere to go back',
                          style: typo.bodyMedium.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: colors.surfaceContainerLowest,
          body: SafeArea(
            top: false,
            bottom: false,
            child: CustomScrollView(
              slivers: [
                if (Breakpoints.isMobile(MediaQuery.of(context).size.width))
                  CollapsingTitleAppBar(
                    title: isSale ? 'List an Item' : 'List a Rental',
                    subtitle:
                        isSale
                            ? 'Turn your unused gear into cash on campus.'
                            : 'Make money by renting out your stuff.',
                  ),
                if (!Breakpoints.isMobile(MediaQuery.of(context).size.width))
                  SliverToBoxAdapter(
                    child: UnifiedPageHeader(
                      title: isSale ? 'List an Item' : 'List a Rental',
                    ),
                  ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverToBoxAdapter(
                    // NOTE: ContentWidthConstraint centers the form on desktop.
                    // maxWidth 640 keeps the form readable without stretching.
                    child: ContentWidthConstraint(
                      maxWidth: 640,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          DefaultTabController(
                            length: 2,
                            initialIndex: mode == 'sale' ? 0 : 1,
                            child: TabBar(
                              onTap:
                                  (index) => ref
                                      .read(
                                        listingFormModeProvider(
                                          initialMode: widget.initialMode,
                                        ).notifier,
                                      )
                                      .setMode(index == 0 ? 'sale' : 'rental'),
                              labelColor: colors.primary,
                              unselectedLabelColor: colors.onSurfaceVariant,
                              indicatorColor: colors.primary,
                              indicatorSize: TabBarIndicatorSize.tab,
                              dividerColor: Colors.transparent,
                              tabs: const [
                                Tab(text: 'Sell'),
                                Tab(text: 'Rent'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          // NOTE: ConstrainedBox limits photo area height on desktop
                          // to avoid the picker dominating the wide-screen layout.
                          if (isDesktop)
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxHeight: 300),
                              child: const PhotoPickerSection(),
                            )
                          else
                            const PhotoPickerSection(),
                          const SizedBox(height: 24),
                          CustomTextField(
                            label: 'Item Title',
                            icon: Icons.label_outlined,
                            hintText: "Name of the item",
                            controller: _titleController,
                          ),
                          const SizedBox(height: 24),
                          CustomTextField(
                            label: 'Item Description',
                            icon: Icons.description_outlined,
                            hintText:
                                "Describe its condition, features, and why someone should buy it...",
                            maxLines: 4,
                            controller: _descriptionController,
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Icon(
                                Icons.category_outlined,
                                size: 18,
                                color: colors.onSurface,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Category',
                                style: typo.labelLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colors.onSurface,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _CategoryTabBar(),
                          const SizedBox(height: 32),
                          Row(
                            children: [
                              Icon(
                                Icons.verified_outlined,
                                size: 18,
                                color: colors.onSurface,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Condition',
                                style: typo.labelLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colors.onSurface,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _ConditionTabBar(
                            selectedCondition: _selectedCondition,
                            onChanged:
                                (v) => setState(() => _selectedCondition = v),
                          ),
                          const SizedBox(height: 32),
                          if (isSale)
                            CustomTextField(
                              label: 'Price',
                              icon: Icons.sell_outlined,
                              hintText: '0.00',
                              prefixText: '\$',
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              controller: _priceController,
                            )
                          else ...[
                            Row(
                              children: [
                                Icon(
                                  Icons.request_quote_outlined,
                                  size: 18,
                                  color: colors.onSurface,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Rental Pricing',
                                  style: typo.labelLarge.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colors.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildRentalRateRow(
                              context,
                              label: 'Daily Rate',
                              controller: _dailyController,
                              enabled: _dailyEnabled,
                              hasError: _dailyHasError,
                              onChanged:
                                  (v) => setState(() {
                                    _dailyEnabled = v ?? false;
                                    if (!_dailyEnabled) {
                                      _dailyController.clear();
                                      _dailyHasError = false;
                                    }
                                  }),
                            ),
                            const SizedBox(height: 12),
                            _buildRentalRateRow(
                              context,
                              label: 'Weekly Rate',
                              controller: _weeklyController,
                              enabled: _weeklyEnabled,
                              hasError: _weeklyHasError,
                              onChanged:
                                  (v) => setState(() {
                                    _weeklyEnabled = v ?? false;
                                    if (!_weeklyEnabled) {
                                      _weeklyController.clear();
                                      _weeklyHasError = false;
                                    }
                                  }),
                            ),
                            const SizedBox(height: 12),
                            _buildRentalRateRow(
                              context,
                              label: 'Monthly Rate',
                              controller: _monthlyController,
                              enabled: _monthlyEnabled,
                              hasError: _monthlyHasError,
                              onChanged:
                                  (v) => setState(() {
                                    _monthlyEnabled = v ?? false;
                                    if (!_monthlyEnabled) {
                                      _monthlyController.clear();
                                      _monthlyHasError = false;
                                    }
                                  }),
                            ),
                            if (_rentalRateErrorText != null)
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 4,
                                  left: 140,
                                ),
                                child: Text(
                                  _rentalRateErrorText!,
                                  style: TextStyle(
                                    color: colors.error,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Icon(
                                  Icons.shield_outlined,
                                  size: 18,
                                  color: colors.onSurface,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Security Deposit',
                                  style: typo.labelLarge.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colors.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _depositController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              style: typo.bodyLarge.copyWith(
                                color: colors.onSurface,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Required for rentals',
                                prefixText: '\$ ',
                                prefixStyle: typo.bodyLarge.copyWith(
                                  color: colors.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                                filled: true,
                                fillColor: colors.surfaceContainerLow,
                                contentPadding: const EdgeInsets.all(12),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    radius.input,
                                  ),
                                  borderSide:
                                      _depositHasError
                                          ? BorderSide(
                                            color: colors.error,
                                            width: 2,
                                          )
                                          : BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    radius.input,
                                  ),
                                  borderSide:
                                      _depositHasError
                                          ? BorderSide(
                                            color: colors.error,
                                            width: 2,
                                          )
                                          : BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    radius.input,
                                  ),
                                  borderSide: BorderSide(
                                    color:
                                        _depositHasError
                                            ? colors.error
                                            : colors.primary,
                                    width: 2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 18,
                                color: colors.onSurface,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Pickup Location',
                                style: typo.labelLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colors.onSurface,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // NOTE: PickupAddressSelector handles:
                          //  1. School preset locations
                          //  2. User custom history
                          //  3. 'Specify Address' free-text entry + auto-save
                          PickupAddressSelector(
                            key: _addressSelectorKey,
                            initialPickupId: _selectedPickupId,
                            initialAddress:
                                _customLocationNote.isNotEmpty
                                    ? _customLocationNote
                                    : null,
                            onPickupIdChanged:
                                (id) => setState(() => _selectedPickupId = id),
                            onAddressChanged:
                                (addr) =>
                                    setState(() => _customLocationNote = addr),
                          ),
                          // Display current user's school — always visible below
                          // the address selector, separate from the address text.
                          // This is intentionally read-only context for the seller.
                          Consumer(
                            builder: (context, ref, _) {
                              final schoolAsync = ref.watch(mySchoolProvider);
                              return schoolAsync.when(
                                loading: () => const SizedBox.shrink(),
                                error: (_, __) => const SizedBox.shrink(),
                                data: (school) {
                                  if (school == null) {
                                    return const SizedBox.shrink();
                                  }
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                      top: 8,
                                      bottom: 4,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.school_outlined,
                                          size: 18,
                                          color: colors.onSurface,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Campus: ${school.name}',
                                          style: typo.labelLarge.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: colors.onSurface,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                          CheckboxListTile(
                            title: Text(
                              'Allow buyer to change pickup address',
                              style: typo.bodySmall,
                            ),
                            value: _allowBuyerToSuggest,
                            onChanged:
                                (v) => setState(
                                  () => _allowBuyerToSuggest = v ?? false,
                                ),
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                          ),
                          const SizedBox(height: 24),
                          // C2: Available date picker
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 18,
                                color: colors.onSurface,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Available Date',
                                style: typo.labelLarge.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: colors.onSurface,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Earliest date you can hand off this item (optional)',
                            style: typo.bodySmall.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _availableDate ?? DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 365),
                                ),
                              );
                              if (picked != null) {
                                setState(() => _availableDate = picked);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: colors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(
                                  radius.input,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today_outlined,
                                    size: 18,
                                    color: colors.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _availableDate == null
                                          ? 'Available now (tap to set a date)'
                                          : '${_availableDate!.year}-'
                                              '${_availableDate!.month.toString().padLeft(2, '0')}-'
                                              '${_availableDate!.day.toString().padLeft(2, '0')}',
                                      style: typo.bodyMedium.copyWith(
                                        color:
                                            _availableDate == null
                                                ? colors.onSurfaceVariant
                                                : colors.onSurface,
                                      ),
                                    ),
                                  ),
                                  if (_availableDate != null)
                                    GestureDetector(
                                      onTap:
                                          () => setState(
                                            () => _availableDate = null,
                                          ),
                                      child: Icon(
                                        Icons.close,
                                        size: 16,
                                        color: colors.onSurfaceVariant,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 48),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                                  _isSubmitting
                                      ? null
                                      : () => _handleSubmit(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colors.primary,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    radius.button,
                                  ),
                                ),
                                elevation: 0,
                              ),
                              child:
                                  _isSubmitting
                                      ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                      : Text(
                                        isSale
                                            ? 'List Item for Sale'
                                            : 'Post Rental',
                                        style: typo.titleMedium.copyWith(
                                          color: colors.onPrimary,
                                        ),
                                      ),
                            ),
                          ),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRentalRateRow(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    required bool enabled,
    required bool hasError,
    required Function(bool?) onChanged,
  }) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;
    return Row(
      children: [
        SizedBox(
          width: 150,
          child: CheckboxListTile(
            value: enabled,
            onChanged: onChanged,
            title: Text(
              label,
              style: typo.bodyMedium.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            dense: true,
            visualDensity: VisualDensity.compact,
          ),
        ),
        Expanded(
          child: TextField(
            controller: controller,
            enabled: enabled,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: typo.bodyLarge.copyWith(color: colors.onSurface),
            decoration: InputDecoration(
              prefixText: '\$ ',
              hintText: enabled ? '' : '—',
              prefixStyle: typo.bodyLarge.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.bold,
              ),
              filled: true,
              fillColor:
                  enabled ? colors.surfaceContainerLow : colors.surfaceContainerHighest,
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(radius.input),
                borderSide:
                    hasError
                        ? BorderSide(color: colors.error, width: 2)
                        : BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(radius.input),
                borderSide:
                    hasError
                        ? BorderSide(color: colors.error, width: 2)
                        : BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(radius.input),
                borderSide: BorderSide(
                  color: hasError ? colors.error : colors.primary,
                  width: 2,
                ),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(radius.input),
                borderSide: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.5)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleSubmit(BuildContext context) async {
    final colors = context.smivoColors;
    setState(() {
      _dailyHasError = false;
      _weeklyHasError = false;
      _monthlyHasError = false;
      _depositHasError = false;
      _rentalRateErrorText = null;
    });
    final formMode = ref.read(modeProvider);
    final category = ref.read(selectedListingCategoryProvider);
    final isSale = formMode == 'sale';
    final errors = <String>[];
    if (_titleController.text.trim().isEmpty) errors.add('Title is required');
    if (category == null || category.isEmpty) {
      errors.add('Please select a category');
    }
    final photoFiles = ref.read(listingPhotosProvider);
    if (photoFiles.isEmpty) {
      errors.add('At least one photo is required');
    }
    if (isSale) {
      final price = double.tryParse(_priceController.text.trim());
      if (price == null || price <= 0) errors.add('Valid sale price required');
    }
    if (!isSale) {
      final daily =
          _dailyEnabled ? double.tryParse(_dailyController.text.trim()) : null;
      final weekly =
          _weeklyEnabled
              ? double.tryParse(_weeklyController.text.trim())
              : null;
      final monthly =
          _monthlyEnabled
              ? double.tryParse(_monthlyController.text.trim())
              : null;
      if (_dailyEnabled && (daily == null || daily <= 0)) {
        setState(() => _dailyHasError = true);
        errors.add('Daily rate must be greater than 0');
      }
      if (_weeklyEnabled && (weekly == null || weekly <= 0)) {
        setState(() => _weeklyHasError = true);
        errors.add('Weekly rate must be greater than 0');
      }
      if (_monthlyEnabled && (monthly == null || monthly <= 0)) {
        setState(() => _monthlyHasError = true);
        errors.add('Monthly rate must be greater than 0');
      }
      if (!_dailyEnabled && !_weeklyEnabled && !_monthlyEnabled) {
        setState(
          () => _rentalRateErrorText = 'Select at least one rental mode',
        );
        errors.add('Select at least one rental mode');
      }
      final depositText = _depositController.text.trim();
      final deposit = double.tryParse(depositText);
      if (deposit == null || deposit < 0) {
        setState(() => _depositHasError = true);
        errors.add('Deposit must be a valid number (0 or greater)');
      }
    }
    if (errors.isNotEmpty) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errors.first), backgroundColor: colors.error),
      );
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      final profile = ref.read(profileProvider).value;
      if (profile == null) throw StateError('Not logged in');
      final selectedCategory = ref.read(selectedListingCategoryProvider)!;
      double? price, dailyRate, weeklyRate, monthlyRate;
      if (isSale) {
        price = double.tryParse(_priceController.text.trim()) ?? 0.0;
      } else {
        dailyRate =
            _dailyEnabled
                ? double.tryParse(_dailyController.text.trim())
                : null;
        weeklyRate =
            _weeklyEnabled
                ? double.tryParse(_weeklyController.text.trim())
                : null;
        monthlyRate =
            _monthlyEnabled
                ? double.tryParse(_monthlyController.text.trim())
                : null;
      }
      final deposit = double.tryParse(_depositController.text.trim()) ?? 0.0;
      final result = await ref
          .read(createListingActionProvider.notifier)
          .submit(
            title: _titleController.text,
            description: _descriptionController.text,
            category: selectedCategory,
            transactionType: isSale ? 'sale' : 'rental',
            condition: _selectedCondition,
            schoolId: profile.schoolId,
            price: price,
            dailyRate: dailyRate,
            weeklyRate: weeklyRate,
            monthlyRate: monthlyRate,
            depositAmount: deposit,
            pickupLocationId: _selectedPickupId,
            customPickupNote: () {
              // _customLocationNote is always the resolved address text:
              // it may come from a preset name callback or typed free text.
              final note = _customLocationNote.trim();
              return note.isEmpty ? null : note;
            }(),
            allowPickupChange: _allowBuyerToSuggest,
            isPinned: false,
            pinnedDays: null,
            availableDate: _availableDate,
          );

      // Post-creation cleanup — done here (screen level) rather than inside
      // the provider to avoid using ref after the provider's async gap, which
      // can cause a "provider disposed" exception even though the listing was
      // successfully created.
      if (!mounted) return;
      // Force save the selector's current 'Specify Address' value before
      // clearing state, in case the user typed but did not dismiss the keyboard.
      _addressSelectorKey.currentState?.saveIfSpecifying();
      // NOTE: The selector also auto-saves on focus-loss;
      // this is a redundant safety net for the form-submit path.
      ref.invalidate(homeListingsProvider);
      ref.read(listingPhotosProvider.notifier).clear();
      ref.read(selectedListingCategoryProvider.notifier).clear();

      if (!context.mounted) return;

      // If content filter generated a warning (mask or warn_only), show it.
      if (result.warningMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.warningMessage!),
            backgroundColor: Colors.amber.shade800,
            duration: const Duration(seconds: 4),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      await _showSuccessDialog(context, isSale);
      if (!context.mounted) return;
      context.goNamed(AppRoutes.home);
    } catch (e, stackTrace) {
      debugPrint('=== LISTING SUBMIT ERROR ===');
      debugPrint('Error: $e');
      debugPrint(stackTrace.toString());
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to post: ${e.toString()}'),
          backgroundColor: colors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _showSuccessDialog(BuildContext context, bool isSale) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => ActionSuccessDialog(
            title: 'Success!',
            message: 'Submitted successfully. Under platform review.',
            buttonText: 'Back to Home',
            onPressed: () => Navigator.pop(context),
          ),
    );
  }
}

class _CategoryTabBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedListingCategoryProvider);
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;
    final categoriesAsync = ref.watch(mySchoolCategoriesProvider);

    return categoriesAsync.when(
      loading:
          () => const SizedBox(
            height: 48,
            child: Center(child: CircularProgressIndicator()),
          ),
      error:
          (_, __) => const SizedBox(
            height: 48,
            child: Center(child: Text('Failed to load categories')),
          ),
      data: (cats) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children:
                cats.map((c) {
                  final isSelected = selectedCategory == c.slug;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(c.name),
                      selected: isSelected,
                      selectedColor: colors.primary,
                      backgroundColor: colors.surfaceContainerLow,
                      labelStyle: typo.bodyMedium.copyWith(
                        color: isSelected ? colors.onPrimary : colors.onSurface,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      showCheckmark: false,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(radius.input),
                        side: BorderSide.none,
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          ref
                              .read(selectedListingCategoryProvider.notifier)
                              .setCategory(c.slug);
                        }
                      },
                    ),
                  );
                }).toList(),
          ),
        );
      },
    );
  }
}

class _ConditionTabBar extends ConsumerWidget {
  final String selectedCondition;
  final ValueChanged<String> onChanged;

  const _ConditionTabBar({
    required this.selectedCondition,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.smivoColors;
    final conditionsAsync = ref.watch(mySchoolConditionsProvider);

    return conditionsAsync.when(
      loading:
          () => const SizedBox(
            height: 48,
            child: Center(child: CircularProgressIndicator()),
          ),
      error:
          (_, __) => const SizedBox(
            height: 48,
            child: Center(child: Text('Failed to load conditions')),
          ),
      data: (conditions) {
        final initialIndex = conditions.indexWhere(
          (c) => c.slug == selectedCondition,
        );

        return DefaultTabController(
          length: conditions.length,
          initialIndex:
              initialIndex != -1 ? initialIndex : 2, // Default to 'Good'
          child: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            onTap: (index) => onChanged(conditions[index].slug),
            labelColor: colors.primary,
            unselectedLabelColor: colors.onSurfaceVariant,
            indicatorColor: colors.primary,
            dividerColor: Colors.transparent,
            tabs: conditions.map((c) => Tab(text: c.name)).toList(),
          ),
        );
      },
    );
  }
}
