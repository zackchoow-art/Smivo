import 'package:flutter/material.dart';

/// Visual indicator showing seat status with small dots.
/// Solid circles represent occupied seats, hollow circles represent available seats.
class SeatIndicator extends StatelessWidget {
  const SeatIndicator({
    super.key,
    required this.available,
    required this.total,
  });

  final int available;
  final int total;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final occupied = total - available;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (index) {
        final isOccupied = index < occupied;
        return Padding(
          padding: const EdgeInsets.only(right: 4.0),
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isOccupied ? theme.colorScheme.primary : Colors.transparent,
              border: Border.all(
                color: theme.colorScheme.primary,
                width: 1.5,
              ),
            ),
          ),
        );
      }),
    );
  }
}
