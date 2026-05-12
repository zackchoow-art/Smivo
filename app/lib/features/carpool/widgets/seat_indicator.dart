import 'package:flutter/material.dart';

/// 可视化指示器，用小圆点展示座位状态。
/// 实心圆表示已被占用的座位，空心圆表示可用座位。
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
