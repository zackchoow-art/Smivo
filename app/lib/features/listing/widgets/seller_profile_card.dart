import 'package:flutter/material.dart';
import 'package:smivo/data/models/user_profile.dart';
import 'package:smivo/shared/widgets/smivo_user_identity.dart';

class SellerProfileCard extends StatelessWidget {
  const SellerProfileCard({
    super.key,
    required this.user,
    this.label,
    this.onMessageTap,
  });

  final UserProfile user;
  final String? label;
  final VoidCallback? onMessageTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SmivoUserIdentity(
        user: user,
        trailingText: label,
        role: 'seller',
        showMessageButton: onMessageTap != null,
        onMessageTap: onMessageTap,
      ),
    );
  }
}
