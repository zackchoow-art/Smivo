import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/core/router/app_routes.dart';
import 'package:smivo/core/theme/app_spacing.dart';
import 'package:smivo/core/constants/app_constants.dart';
import 'package:smivo/core/theme/app_text_styles.dart';
import 'package:smivo/data/models/pickup_location.dart';
import 'package:smivo/features/profile/providers/profile_provider.dart';
import 'package:smivo/features/listing/providers/create_listing_provider.dart';
import 'package:smivo/features/listing/widgets/custom_text_field.dart';
import 'package:smivo/features/listing/widgets/photo_picker_section.dart';
import 'package:smivo/features/shared/providers/school_provider.dart';
import 'package:smivo/shared/widgets/custom_app_bar.dart';

class CreateListingFormScreen extends ConsumerStatefulWidget {
  const CreateListingFormScreen({
    super.key,
    required this.initialMode,
  });

  final String initialMode;

  @override
  ConsumerState<CreateListingFormScreen> createState() => _CreateListingFormScreenState();
}

class _CreateListingFormScreenState extends ConsumerState<CreateListingFormScreen> {
  late ProviderListenable<String> modeProvider;
  
  PickupLocation? _selectedPickup;
  bool _allowBuyerToSuggest = false;
  bool _isPinned = false;
  double _pinnedDays = 1.0;
  bool _isSubmitting = false;

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _depositController = TextEditingController();
  final _dailyController = TextEditingController();
  final _weeklyController = TextEditingController();
  final _monthlyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize the provider with the passed mode
    modeProvider = listingFormModeProvider(initialMode: widget.initialMode);

    // Make the form reactive to all input changes
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(modeProvider);
    final isSale = mode == 'sale';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'List Item', showBackButton: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Description
            Text(
              isSale ? 'List an Item' : 'List a Rental',
              style: AppTextStyles.displayLarge.copyWith(
                fontSize: 36,
                letterSpacing: -1,
                color: const Color(0xFF2B2A51),
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              isSale
                  ? 'Turn your unused gear into cash on campus.'
                  : 'Make money by renting out your stuff.',
              style: AppTextStyles.bodyLarge.copyWith(color: const Color(0xFF585781)),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Mode Toggle (Optional enhancement to switch without going back)
            Center(
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'sale', label: Text('Sell')),
                  ButtonSegment(value: 'rental', label: Text('Rent')),
                ],
                selected: {mode},
                onSelectionChanged: (Set<String> newSelection) {
                  ref.read(listingFormModeProvider(initialMode: widget.initialMode).notifier).setMode(newSelection.first);
                },
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Photos Section
            const PhotoPickerSection(),
            const SizedBox(height: AppSpacing.xl),

            // Title
            CustomTextField(
              label: 'Item Title',
              hintText: "Name of the item you're selling",
              controller: _titleController,
            ),
            const SizedBox(height: AppSpacing.xl),

            // Description
            CustomTextField(
              label: 'Item Description',
              hintText: "Describe its condition, features, and why someone should buy it...",
              maxLines: 4,
              controller: _descriptionController,
            ),
            const SizedBox(height: AppSpacing.xl),

            // Category Chips
            Text(
              'Category',
              style: AppTextStyles.labelLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2B2A51),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _CategoryPicker(),
            const SizedBox(height: AppSpacing.xl),

            // Pricing
            if (isSale)
              CustomTextField(
                label: 'Price',
                hintText: '0.00',
                prefixText: '\$',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                controller: _priceController,
              )
            else ...[
              Text(
                'Rental Pricing',
                style: AppTextStyles.labelLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2B2A51),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              CustomTextField(
                label: 'Daily Rate',
                hintText: '0.00',
                prefixText: '\$',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                controller: _dailyController,
              ),
              const SizedBox(height: AppSpacing.md),
              CustomTextField(
                label: 'Weekly Rate',
                hintText: '0.00',
                prefixText: '\$',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                controller: _weeklyController,
              ),
              const SizedBox(height: AppSpacing.md),
              CustomTextField(
                label: 'Monthly Rate',
                hintText: '0.00',
                prefixText: '\$',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                controller: _monthlyController,
              ),
              const SizedBox(height: AppSpacing.xl),
              CustomTextField(
                label: 'Security Deposit',
                hintText: '0.00',
                prefixText: '\$',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                controller: _depositController,
              ),
            ],
            const SizedBox(height: AppSpacing.xl),

            // Pickup Location
            Text(
              'Pickup Location',
              style: AppTextStyles.labelLarge.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2B2A51),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Consumer(
              builder: (context, ref, _) {
                final pickupsAsync = ref.watch(myPickupLocationsProvider);
                return pickupsAsync.when(
                  loading: () => const SizedBox(
                    height: 56,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (err, _) => Text('Failed to load locations: $err'),
                  data: (locations) {
                    if (locations.isEmpty) {
                      return const Text('No pickup locations available');
                    }
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2EFFF),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<PickupLocation>(
                          value: _selectedPickup,
                          hint: const Text('Select pickup location'),
                          isExpanded: true,
                          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF585781)),
                          style: AppTextStyles.titleMedium.copyWith(color: const Color(0xFF2B2A51)),
                          onChanged: (PickupLocation? newValue) {
                            setState(() => _selectedPickup = newValue);
                          },
                          items: locations.map((loc) {
                            return DropdownMenuItem<PickupLocation>(
                              value: loc,
                              child: Text(loc.name),
                            );
                          }).toList(),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            CheckboxListTile(
              title: const Text('Allow buyer to suggest alternative location'),
              value: _allowBuyerToSuggest,
              onChanged: (bool? value) {
                setState(() {
                  _allowBuyerToSuggest = value ?? false;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: AppSpacing.xl),

            // Pinning Section
            CheckboxListTile(
              title: const Text('Pin this listing to top of feed'),
              subtitle: const Text('Increase visibility for your item'),
              value: _isPinned,
              onChanged: (bool? value) {
                setState(() {
                  _isPinned = value ?? false;
                });
              },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            if (_isPinned) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Pin for ${_pinnedDays.toInt()} days (\$${(_pinnedDays * 1.5).toStringAsFixed(2)})',
                style: AppTextStyles.bodyMedium,
              ),
              Slider(
                value: _pinnedDays,
                min: 1,
                max: 14,
                divisions: 13,
                label: _pinnedDays.round().toString(),
                onChanged: (double value) {
                  setState(() {
                    _pinnedDays = value;
                  });
                },
              ),
            ],
            const SizedBox(height: AppSpacing.xxxl),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_isFormValid && !_isSubmitting)
                    ? () => _handleSubmit(context)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5271FF), // Blue button
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        isSale ? 'List Item for Sale' : 'Post Rental',
                        style: AppTextStyles.titleMedium.copyWith(color: Colors.white),
                      ),
              ),
            ),
            const SizedBox(height: 80), // Reserve for bottom navigation or general safe area
          ],
        ),
      ),
    );
  }

  bool get _isFormValid {
    final mode = ref.read(modeProvider);
    final category = ref.watch(selectedListingCategoryProvider);
    // final photos = ref.watch(listingPhotosProvider);

    if (_titleController.text.trim().isEmpty) return false;
    if (_descriptionController.text.trim().isEmpty) return false;
    if (category == null || category.isEmpty) return false;
    // TODO(images): Re-enable photo requirement once upload works.
    // if (photos.isEmpty) return false;

    if (mode == 'sale') {
      final price = double.tryParse(_priceController.text.trim());
      if (price == null || price <= 0) return false;
    } else {
      final daily = double.tryParse(_dailyController.text.trim()) ?? 0;
      final weekly = double.tryParse(_weeklyController.text.trim()) ?? 0;
      final monthly = double.tryParse(_monthlyController.text.trim()) ?? 0;
      if (daily <= 0 && weekly <= 0 && monthly <= 0) return false;
    }

    return true;
  }

  Future<void> _handleSubmit(BuildContext context) async {
    setState(() => _isSubmitting = true);
    try {
      final profile = ref.read(profileProvider).valueOrNull;
      if (profile == null) {
        throw StateError('Not logged in');
      }

      final mode = ref.read(modeProvider);
      final category = ref.read(selectedListingCategoryProvider)!;
      final isSale = mode == 'sale';

      double? price;
      double? dailyRate;
      double? weeklyRate;
      double? monthlyRate;

      if (isSale) {
        price = double.parse(_priceController.text.trim());
      } else {
        dailyRate = double.tryParse(_dailyController.text.trim());
        weeklyRate = double.tryParse(_weeklyController.text.trim());
        monthlyRate = double.tryParse(_monthlyController.text.trim());
      }

      final deposit = double.tryParse(_depositController.text.trim());

      await ref.read(createListingActionProvider.notifier).submit(
            title: _titleController.text,
            description: _descriptionController.text,
            category: category,
            transactionType: mode,
            schoolId: profile.schoolId,
            price: price,
            dailyRate: dailyRate,
            weeklyRate: weeklyRate,
            monthlyRate: monthlyRate,
            depositAmount: deposit,
            pickupLocationId: _selectedPickup?.id,
            allowPickupChange: _allowBuyerToSuggest,
            isPinned: _isPinned,
            pinnedDays: _isPinned ? _pinnedDays.toInt() : null,
          );

      if (!context.mounted) return;

      await _showSuccessDialog(context, isSale);

      if (!context.mounted) return;

      context.goNamed(AppRoutes.home);
    } catch (e, stackTrace) {
      // Log full error to terminal for debugging
      debugPrint('=== LISTING SUBMIT ERROR ===');
      debugPrint('Error: $e');
      debugPrint('Stack trace:');
      debugPrint(stackTrace.toString());
      debugPrint('=== END ERROR ===');

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to post: ${e.toString()}'),
          backgroundColor: Colors.red,
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
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF1E8E64), size: 80),
            const SizedBox(height: 24),
            Text(
              'Success!',
              style: AppTextStyles.headlineSmall.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              isSale ? 'Your item has been listed for sale.' : 'Your rental listing has been posted.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5271FF),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Back to Home', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryPicker extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectedListingCategoryProvider);

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: AppConstants.categories.map((category) {
        final isSelected = selectedCategory == category;
        return GestureDetector(
          onTap: () => ref.read(selectedListingCategoryProvider.notifier).setCategory(category),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF0546ED) : const Color(0xFFE2DFFF),
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            ),
            child: Text(
              category,
              style: AppTextStyles.labelLarge.copyWith(
                color: isSelected ? Colors.white : const Color(0xFF585781),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
