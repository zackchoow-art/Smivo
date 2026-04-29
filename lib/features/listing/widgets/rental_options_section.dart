import 'package:flutter/material.dart';
import 'package:smivo/core/theme/breakpoints.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:smivo/data/models/listing.dart';
import 'package:smivo/features/listing/providers/listing_detail_provider.dart';

class RentalOptionsSection extends ConsumerWidget {
  const RentalOptionsSection({super.key, required this.listing});
  final Listing listing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedRate = ref.watch(selectedRentalRateProvider);
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;
    final List<Widget> pricingCards = [];
    if ((listing.rentalDailyPrice ?? 0) > 0) {
      pricingCards.add(
        _PricingCard(
          label: 'DAY',
          price: listing.rentalDailyPrice!,
          isSelected: selectedRate == 'DAY',
          onTap:
              () =>
                  ref.read(selectedRentalRateProvider.notifier).setRate('DAY'),
        ),
      );
    }
    if ((listing.rentalWeeklyPrice ?? 0) > 0) {
      pricingCards.add(
        _PricingCard(
          label: 'WEEK',
          price: listing.rentalWeeklyPrice!,
          isSelected: selectedRate == 'WEEK',
          onTap:
              () =>
                  ref.read(selectedRentalRateProvider.notifier).setRate('WEEK'),
        ),
      );
    }
    if ((listing.rentalMonthlyPrice ?? 0) > 0) {
      pricingCards.add(
        _PricingCard(
          label: 'MONTH',
          price: listing.rentalMonthlyPrice!,
          isSelected: selectedRate == 'MONTH',
          onTap:
              () => ref
                  .read(selectedRentalRateProvider.notifier)
                  .setRate('MONTH'),
        ),
      );
    }
    final depositText =
        listing.depositAmount > 0
            ? '\$${listing.depositAmount.toStringAsFixed(0)} Deposit'
            : 'No deposit required';

    // NOTE: LayoutBuilder drives responsive layout — desktop puts pricing cards
    // and date picker side-by-side in a Row; mobile/tablet keeps Column layout.
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = Breakpoints.isDesktop(constraints.maxWidth);

        final Widget pricingRow = Row(
          children: [
            for (int i = 0; i < pricingCards.length; i++) ...[
              if (i > 0) const SizedBox(width: 12),
              pricingCards[i],
            ],
          ],
        );

        final Widget datePicker = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rental Period', style: typo.headlineSmall),
            const SizedBox(height: 16),
            if (selectedRate == 'DAY')
              _DateRangePicker(listing: listing)
            else
              _StepperConfigurator(
                label:
                    selectedRate == 'WEEK'
                        ? 'NUMBER OF WEEKS'
                        : 'NUMBER OF MONTHS',
                unit: selectedRate,
                listing: listing,
              ),
          ],
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isDesktop) ...
            // Desktop: pricing cards and date picker side-by-side
            [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: pricingRow),
                  const SizedBox(width: 24),
                  Expanded(child: datePicker),
                ],
              ),
            ] else ...
            // Mobile/tablet: vertical stack
            [pricingRow, const SizedBox(height: 24), datePicker],
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(radius.md),
              ),
              child: Row(
                children: [
                  Icon(Icons.shield_outlined, color: colors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'SECURITY DEPOSIT',
                          style: typo.labelSmall.copyWith(
                            color: colors.onSurface.withValues(alpha: 0.5),
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(depositText, style: typo.titleMedium),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.info_outline,
                    color: colors.onSurface.withValues(alpha: 0.5),
                    size: 20,
                  ),
                ],
              ),
            ),
          ],
        );
      },
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

  String _formatPrice(double p) =>
      p == p.toInt() ? p.toStringAsFixed(0) : p.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color:
                isSelected ? colors.priceAccent : colors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(radius.md),
            border: Border.all(
              color:
                  isSelected
                      ? colors.priceAccent
                      : colors.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: typo.labelSmall.copyWith(
                  color:
                      isSelected
                          ? Colors.white70
                          : colors.onSurface.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '\$${_formatPrice(price)}',
                style: typo.titleMedium.copyWith(
                  color: isSelected ? Colors.white : colors.priceAccent,
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
    final startDate = DateTime(
      rawStartDate.year,
      rawStartDate.month,
      rawStartDate.day,
    );
    final endDate = DateTime(rawEndDate.year, rawEndDate.month, rawEndDate.day);
    final formatter = DateFormat('MM/dd/yyyy');
    final durationDays = endDate.difference(startDate).inDays;
    final dailyPrice = listing.rentalDailyPrice ?? 0.0;
    final totalRent = dailyPrice * (durationDays > 0 ? durationDays : 0);
    final colors = context.smivoColors;
    final typo = context.smivoTypo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'START DATE',
                    style: typo.labelSmall.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 4),
                  _DateBox(
                    text: formatter.format(startDate),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate:
                            startDate.isBefore(DateTime.now())
                                ? DateTime.now()
                                : startDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        final normalized = DateTime(
                          picked.year,
                          picked.month,
                          picked.day,
                        );
                        ref
                            .read(rentalStartDateProvider.notifier)
                            .setDate(normalized);
                        if (endDate.isBefore(
                          normalized.add(const Duration(days: 1)),
                        )) {
                          ref
                              .read(rentalEndDateProvider.notifier)
                              .setDate(normalized.add(const Duration(days: 3)));
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'END DATE',
                    style: typo.labelSmall.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 4),
                  _DateBox(
                    text: formatter.format(endDate),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate:
                            endDate.isBefore(
                                  startDate.add(const Duration(days: 1)),
                                )
                                ? startDate.add(const Duration(days: 1))
                                : endDate,
                        firstDate: startDate.add(const Duration(days: 1)),
                        lastDate: startDate.add(const Duration(days: 365)),
                      );
                      if (picked != null)
                        ref
                            .read(rentalEndDateProvider.notifier)
                            .setDate(
                              DateTime(picked.year, picked.month, picked.day),
                            );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
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
  String _formatTotal(double p) =>
      p == p.toInt() ? p.toStringAsFixed(0) : p.toStringAsFixed(2);

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(radius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rental Period: $periodText',
            style: typo.bodyMedium.copyWith(color: colors.onSurface),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Total: \$${_formatTotal(totalAmount)}',
              style: typo.headlineSmall.copyWith(
                color: colors.primary,
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
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(radius.input),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(text, style: typo.bodyMedium),
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
    final startDate = DateTime(
      rawStartDate.year,
      rawStartDate.month,
      rawStartDate.day,
    );
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;
    DateTime calculatedEndDate;
    double totalRent;
    int totalDays;
    if (unit == 'WEEK') {
      totalDays = 7 * duration;
      calculatedEndDate = startDate.add(Duration(days: totalDays));
      totalRent = duration * (listing.rentalWeeklyPrice ?? 0.0);
    } else {
      calculatedEndDate = DateTime(
        startDate.year,
        startDate.month + duration,
        startDate.day,
      );
      totalDays = calculatedEndDate.difference(startDate).inDays;
      totalRent = duration * (listing.rentalMonthlyPrice ?? 0.0);
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
                  Text(
                    'START DATE',
                    style: typo.labelSmall.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 4),
                  _DateBox(
                    text: formatter.format(startDate),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate:
                            startDate.isBefore(DateTime.now())
                                ? DateTime.now()
                                : startDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (picked != null)
                        ref
                            .read(rentalStartDateProvider.notifier)
                            .setDate(
                              DateTime(picked.year, picked.month, picked.day),
                            );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: typo.labelSmall.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      GestureDetector(
                        onTap:
                            () =>
                                ref
                                    .read(rentalDurationProvider.notifier)
                                    .decrement(),
                        child: _StepperButton(text: '-'),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          height: 48,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: colors.outlineVariant.withValues(
                                alpha: 0.3,
                              ),
                            ),
                            borderRadius: BorderRadius.circular(radius.input),
                          ),
                          child: Text(
                            duration.toString(),
                            style: typo.titleMedium,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap:
                            () =>
                                ref
                                    .read(rentalDurationProvider.notifier)
                                    .increment(),
                        child: _StepperButton(text: '+'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _TotalRentBanner(
          periodText:
              '$totalDays days (${formatter.format(startDate)} to ${formatter.format(calculatedEndDate)})',
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
    final colors = context.smivoColors;
    final typo = context.smivoTypo;
    final radius = context.smivoRadius;
    return Container(
      width: 40,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(radius.button),
      ),
      child: Text(
        text,
        style: typo.headlineSmall.copyWith(color: colors.primary),
      ),
    );
  }
}
