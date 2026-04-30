import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/core/theme/theme_extensions.dart';
import 'package:smivo/shared/widgets/message_badge_icon.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showBackButton;
  final bool showActions;
  final int unreadMessageCount;

  const CustomAppBar({
    super.key,
    this.title,
    this.showBackButton = true,
    this.showActions = true,
    this.unreadMessageCount = 3, // Default to 3 for demonstration
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.smivoColors;
    final typo = context.smivoTypo;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading:
          showBackButton
              ? IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  color: colors.onSurface,
                  size: 20,
                ),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  }
                },
              )
              : null,
      title:
          title != null
              ? Text(
                title!,
                style: typo.headlineSmall.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              )
              : null,
      actions:
          showActions
              ? [
                MessageBadgeIcon(unreadCount: unreadMessageCount),
                const SizedBox(width: 8),
              ]
              : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
