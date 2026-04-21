import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smivo/core/theme/app_spacing.dart';
import 'package:smivo/core/constants/app_constants.dart';
import 'package:smivo/core/theme/app_text_styles.dart';
import 'package:smivo/features/listing/providers/create_listing_provider.dart';
import 'package:smivo/features/listing/widgets/custom_text_field.dart';
import 'package:smivo/features/listing/widgets/photo_picker_section.dart';
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
  
  String _selectedLocation = 'Student Union, North Entrance';
  bool _allowBuyerToSuggest = false;
  bool _isPinned = false;
  double _pinnedDays = 1.0;

  final _dailyController = TextEditingController();
  final _weeklyController = TextEditingController();
  final _monthlyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize the provider with the passed mode
    modeProvider = listingFormModeProvider(initialMode: widget.initialMode);
  }

  @override
  void dispose() {
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
                  ButtonSegment(value: 'rent', label: Text('Rent')),
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
            const CustomTextField(
              label: 'Item Title',
              hintText: "Name of the item you're selling",
            ),
            const SizedBox(height: AppSpacing.xl),

            // Description
            const CustomTextField(
              label: 'Item Description',
              hintText: "Describe its condition, features, and why someone should buy it...",
              maxLines: 4,
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
              const CustomTextField(
                label: 'Price',
                hintText: '0.00',
                prefixText: '\$',
                keyboardType: TextInputType.numberWithOptions(decimal: true),
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
              const CustomTextField(
                label: 'Security Deposit',
                hintText: '0.00',
                prefixText: '\$',
                keyboardType: TextInputType.numberWithOptions(decimal: true),
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
              decoration: BoxDecoration(
                color: const Color(0xFFF2EFFF),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedLocation,
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF585781)),
                  style: AppTextStyles.titleMedium.copyWith(color: const Color(0xFF2B2A51)),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedLocation = newValue;
                      });
                    }
                  },
                  items: <String>[
                    'Student Union, North Entrance',
                    'Library, 1st Floor',
                    'Dorm A Lobby',
                    'Cafeteria'
                  ].map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
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
                onPressed: () {
                  // Show Success Dialog
                  showDialog(
                    context: context,
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
                                Navigator.pop(context); // Go back to previous screen
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
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5271FF), // Blue button
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  elevation: 0,
                ),
                child: Text(
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
