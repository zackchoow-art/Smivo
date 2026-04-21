import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smivo/core/router/app_routes.dart';

class MessageBadgeIcon extends StatelessWidget {
  final int unreadCount;

  const MessageBadgeIcon({
    super.key,
    this.unreadCount = 3,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        // Since this is a global icon without specific context,
        // we navigate to the chat list tab instead of opening a specific popup.
        context.go(AppRoutes.chatListPath);
      },
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(
            Icons.chat_bubble_outline,
            color: Color(0xFF013DFD), // Blue icon as per screenshot
            size: 28,
          ),
          if (unreadCount > 0)
            Positioned(
              right: -4,
              top: -6,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFFCC3300), // Red/Orange badge color
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2), // White border around badge
                ),
                constraints: const BoxConstraints(
                  minWidth: 22,
                  minHeight: 22,
                ),
                child: Center(
                  child: Text(
                    unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
