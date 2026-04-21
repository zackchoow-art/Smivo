import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smivo/core/theme/app_spacing.dart';
import 'package:smivo/core/theme/app_text_styles.dart';
import 'package:smivo/features/chat/providers/chat_provider.dart';
import 'package:smivo/features/chat/widgets/chat_list_item.dart';

import 'package:smivo/features/chat/widgets/chat_popup.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatList = ref.watch(chatListProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.md),
              // Title
              Text(
                'Chat',
                style: AppTextStyles.displayLarge.copyWith(
                  color: const Color(0xFF2B2A51),
                  letterSpacing: -1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              
              // Search Bar
              TextField(
                style: AppTextStyles.bodyLarge.copyWith(
                  color: const Color(0xFF2B2A51),
                ),
                decoration: InputDecoration(
                  hintText: 'Search conversations...',
                  hintStyle: AppTextStyles.bodyLarge.copyWith(
                    color: const Color(0xFF585781).withOpacity(0.6),
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: const Color(0xFF585781).withOpacity(0.6),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF2EFFF),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.sm,
                    horizontal: AppSpacing.md,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              
              // Chat List
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: chatList.length,
                  itemBuilder: (context, index) {
                    final conversation = chatList[index];
                    return ChatListItem(
                      conversation: conversation,
                      onTap: () {
                        showChatPopup(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
