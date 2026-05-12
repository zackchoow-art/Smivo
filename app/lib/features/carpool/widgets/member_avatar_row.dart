import 'package:flutter/material.dart';
import 'package:smivo/data/models/carpool_member.dart';
import 'package:smivo/shared/widgets/smivo_user_avatar.dart';

/// 成员头像行，横排显示已加入成员的头像。
/// 未使用的座位用虚线圆圈占位。
class MemberAvatarRow extends StatelessWidget {
  const MemberAvatarRow({
    super.key,
    required this.members,
    required this.totalSeats,
  });

  final List<CarpoolMember> members;
  final int totalSeats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final joinedCount = members.length;

    return Row(
      children: [
        Expanded(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(totalSeats, (index) {
              if (index < joinedCount) {
                final user = members[index].user;
                if (user != null) {
                  return SmivoUserAvatar(
                    user: user,
                    radius: 20,
                    enableTap: false,
                  );
                }
                // Fallback if user profile not loaded
                return const CircleAvatar(
                  radius: 20,
                  child: Icon(Icons.person, size: 20),
                );
              } else {
                // Empty seat placeholder
                return Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.dividerColor,
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.person_outline,
                    color: theme.dividerColor,
                    size: 20,
                  ),
                );
              }
            }),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          '$joinedCount/$totalSeats 已加入',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
