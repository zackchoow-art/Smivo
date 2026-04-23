import 'package:flutter/material.dart';
import 'package:smivo/core/theme/app_spacing.dart';
import 'package:smivo/core/theme/app_text_styles.dart';
import 'package:smivo/core/theme/app_colors.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:smivo/data/models/listing.dart';
import 'package:smivo/features/listing/providers/listing_detail_provider.dart';

class RentalOptionsSection extends ConsumerWidget {
  const RentalOptionsSection({
    super.key,
    required this.listing,
  });

  final Listing listing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRate = ref.watch(selectedRentalRateProvider);

    // Collect only enabled pricing modes
    final List<Widget> pricingCards = [];
    
    if ((listing.rentalDailyPrice ?? 0) > 0) {
      pricingCards.add(_PricingCard(
        label: 'DAY',
        price: listing.rentalDailyPrice!,
        isSelected: selectedRate == 'DAY',
        onTap: () => ref.read(selectedRentalRateProvider.notifier).setRate('DAY'),
      ));
    }
    if ((listing.rentalWeeklyPrice ?? 0) > 0) {
      pricingCards.add(_PricingCard(
        label: 'WEEK',
        price: listing.rentalWeeklyPrice!,
        isSelected: selectedRate == 'WEEK',
        onTap: () => ref.read(selectedRentalRateProvider.notifier).setRate('WEEK'),
      ));
    }
    if ((listing.rentalMonthlyPrice ?? 0) > 0) {
      pricingCards.add(_PricingCard(
        label: 'MONTH',
        price: listing.rentalMonthlyPrice!,
        isSelected: selectedRate == 'MONTH',
        onTap: () => ref.read(selectedRentalRateProvider.notifier).setRate('MONTH'),
      ));
    }

    // Deposit text
    final depositText = listing.depositAmount > 0
        ? '\$${listing.depositAmount.toStringAsFixed(0)} Deposit'
        : 'No deposit required';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pricing Cards Row
        Row(
          children: [
            for (int i = 0; i < pricingCards.length; i++) ...[
              if (i > 0) const SizedBox(width: AppSpacing.md),
              pricingCards[i],
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        
        Text('Rental Period', style: AppTextStyles.headlineSmall),
        const SizedBox(height: AppSpacing.lg),
        
        // Rental Period Configurator
        if (selectedRate == 'DAY')
          _DateRangePicker(listing: listing)
        else
          _StepperConfigurator(
            label: selectedRate == 'WEEK' ? 'NUMBER OF WEEKS' : 'NUMBER OF MONTHS',
            unit: selectedRate,
            listing: listing,
          ),
          
        const SizedBox(height: AppSpacing.lg),
        
        // Security Deposit
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Row(
            children: [
              const Icon(Icons.shield_outlined, color: AppColors.primary),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SECURITY DEPOSIT',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.onSurface.withValues(alpha: 0.5),
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      depositText,
                      style: AppTextStyles.titleMedium,
                    ),
                  ],
                ),
              ),
              Icon(Icons.info_outline, color: AppColors.onSurface.withValues(alpha: 0.5), size: 20),
            ],
          ),
        ),
      ],
    );
  }
}

class _PricingCard extends StatelessWidget {
  const _PricingCard({
    required this.label,
    required this.price,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final double price;
  final bool isSelected;
  final VoidCallback onTap;

  String _formatPrice(double p) {
    if (p == p.toInt()) {
      return p.toStringAsFixed(0);
    }
    return p.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.priceTagPrimary : AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: isSelected ? AppColors.priceTagPrimary : AppColors.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: isSelected ? Colors.white70 : AppColors.onSurface.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '\$${_formatPrice(price)}',
                style: AppTextStyles.titleMedium.copyWith(
                  color: isSelected ? Colors.white : AppColors.priceTagPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateRangePicker extends ConsumerWidget {
  const _DateRangePicker({required this.listing});
  final Listing listing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rawStartDate = ref.watch(rentalStartDateProvider);
    final rawEndDate = ref.watch(rentalEndDateProvider);
    
    final startDate = DateTime(rawStartDate.year, rawStartDate.month, rawStartDate.day);
    final endDate = DateTime(rawEndDate.year, rawEndDate.month, rawEndDate.day);
    
    final formatter = DateFormat('MM/dd/yyyy');
    final durationDays = endDate.difference(startDate).inDays;
    
    // Total calculation using Daily Price
    final dailyPrice = listing.rentalDailyPrice ?? 0.0;
    final totalRent = dailyPrice * (durationDays > 0 ? durationDays : 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('START DATE', style: AppTextStyles.labelSmall.copyWith(color: AppColors.onSurface.withValues(alpha: 0.5))),
                  const SizedBox(height: AppSpacing.xs),
                  _DateBox(
                    text: formatter.format(startDate),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: startDate.isBefore(DateTime.now()) ? DateTime.now() : startDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        final normalized = DateTime(picked.year, picked.month, picked.day);
                        ref.read(rentalStartDateProvider.notifier).setDate(normalized);
                        if (endDate.isBefore(normalized.add(const Duration(days: 1)))) {
                          ref.read(rentalEndDateProvider.notifier).setDate(normalized.add(const Duration(days: 3)));
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('END DATE', style: AppTextStyles.labelSmall.copyWith(color: AppColors.onSurface.withValues(alpha: 0.5))),
                  const SizedBox(height: AppSpacing.xs),
                  _DateBox(
                    text: formatter.format(endDate),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: endDate.isBefore(startDate.add(const Duration(days: 1))) 
                            ? startDate.add(const Duration(days: 1)) 
                            : endDate,
                        firstDate: startDate.add(const Duration(days: 1)),
                        lastDate: startDate.add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        ref.read(rentalEndDateProvider.notifier).setDate(DateTime(picked.year, picked.month, picked.day));
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _TotalRentBanner(
          periodText: '${durationDays > 0 ? durationDays : 0} days', 
          totalAmount: totalRent,
        ),
      ],
    );
  }
}

class _TotalRentBanner extends StatelessWidget {
  const _TotalRentBanner({required this.periodText, required this.totalAmount});
  final String periodText;
  final double totalAmount;

  String _formatTotal(double p) {
    if (p == p.toInt()) {
      return p.toStringAsFixed(0);
    }
    return p.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rental Period: $periodText',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Total: \$${_formatTotal(totalAmount)}',
              style: AppTextStyles.headlineSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateBox extends StatelessWidget {
  const _DateBox({required this.text, this.onTap});
  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(text, style: AppTextStyles.bodyMedium),
            const Icon(Icons.calendar_today_outlined, size: 16),
          ],
        ),
      ),
    );
  }
}

class _StepperConfigurator extends ConsumerWidget {
  const _StepperConfigurator({
    required this.label, 
    required this.unit,
    required this.listing,
  });
  final String label;
  final String unit;
  final Listing listing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final duration = ref.watch(rentalDurationProvider);
    final rawStartDate = ref.watch(rentalStartDateProvider);
    final startDate = DateTime(rawStartDate.year, rawStartDate.month, rawStartDate.day);
    
    DateTime calculatedEndDate;
    double totalRent;
    int totalDays;
    
    if (unit == 'WEEK') {
      totalDays = 7 * duration;
      calculatedEndDate = startDate.add(Duration(days: totalDays));
      final weeklyPrice = listing.rentalWeeklyPrice ?? 0.0;
      totalRent = duration * weeklyPrice;
    } else {
      calculatedEndDate = DateTime(startDate.year, startDate.month + duration, startDate.day);
      totalDays = calculatedEndDate.difference(startDate).inDays;
      final monthlyPrice = listing.rentalMonthlyPrice ?? 0.0;
      totalRent = duration * monthlyPrice;
    }
    
    final formatter = DateFormat('MM/dd/yyyy');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('START DATE', style: AppTextStyles.labelSmall.copyWith(color: AppColors.onSurface.withValues(alpha: 0.5))),
                  const SizedBox(height: AppSpacing.xs),
                  _DateBox(
                    text: formatter.format(startDate),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: startDate.isBefore(DateTime.now()) ? DateTime.now() : startDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        ref.read(rentalStartDateProvider.notifier).setDate(DateTime(picked.year, picked.month, picked.day));
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTextStyles.labelSmall.copyWith(color: AppColors.onSurface.withValues(alpha: 0.5))),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => ref.read(rentalDurationProvider.notifier).decrement(),
                        child: _StepperButton(text: '-'),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Container(
                          height: 48,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                          ),
                          child: Text(duration.toString(), style: AppTextStyles.titleMedium),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      GestureDetector(
                        onTap: () => ref.read(rentalDurationProvider.notifier).increment(),
                        child: _StepperButton(text: '+'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _TotalRentBanner(
          periodText: '$totalDays days (${formatter.format(startDate)} to ${formatter.format(calculatedEndDate)})', 
          totalAmount: totalRent,
        ),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Text(text, style: AppTextStyles.headlineSmall.copyWith(color: AppColors.primary)),
    );
  }
}
