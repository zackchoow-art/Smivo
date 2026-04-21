import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:smivo/core/theme/app_text_styles.dart';

Future<void> showChatPopup(BuildContext context) {
  return showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.black.withOpacity(0.2), // Dim background slightly
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return Center(
        child: Material(
          color: Colors.transparent,
          child: const ChatPopupWidget(),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return ScaleTransition(
        scale: CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        ),
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      );
    },
  );
}

class ChatPopupWidget extends StatefulWidget {
  const ChatPopupWidget({super.key});

  @override
  State<ChatPopupWidget> createState() => _ChatPopupWidgetState();
}

class _Message {
  final String text;
  final bool isMine;
  final String? avatarUrl;

  _Message({required this.text, required this.isMine, this.avatarUrl});
}

class _ChatPopupWidgetState extends State<ChatPopupWidget> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<_Message> _messages = [
    _Message(
      text: 'Hey! Are you still selling that textbook for Econ 101?',
      isMine: false,
      avatarUrl: 'https://i.pravatar.cc/150?u=alex',
    ),
    _Message(
      text: 'Yeah I am! It\'s in great condition.',
      isMine: true,
    ),
    _Message(
      text: 'Awesome. Can we meet up near the Quad around 2?',
      isMine: false,
      avatarUrl: 'https://i.pravatar.cc/150?u=alex2',
    ),
  ];

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    
    setState(() {
      _messages.add(_Message(text: _controller.text.trim(), isMine: true));
      _controller.clear();
    });

    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Colors from the screenshot
    const backgroundColor = Color(0xFFF5F4FA); // Light lavender/grey background
    const primaryBlue = Color(0xFF3B67FF); // Bright blue from buttons and right bubbles
    const headerBlue = Color(0xFF2B2A51); // Dark blue text
    const onlineGreen = Color(0xFF1E8E64);
    const bubbleLeftBg = Color(0xFFE2DDFA); // Light purple for left bubbles
    const callButtonBg = Color(0xFFDFDDFF); // Very light blue/purple

    return Container(
      width: MediaQuery.of(context).size.width * 0.85,
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: backgroundColor.withOpacity(0.9), // Slight transparency as requested
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 40,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      // Apply blur to the background for glass effect
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Column(
            children: [
              // --- Header ---
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Row(
                  children: [
                    // Avatar with online status
                    Stack(
                      children: [
                        const CircleAvatar(
                          radius: 24,
                          backgroundImage: NetworkImage(
                              'https://i.pravatar.cc/150?u=alex'), // Placeholder
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: onlineGreen,
                              shape: BoxShape.circle,
                              border: Border.all(color: backgroundColor, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    // Name and Status
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Alex',
                            style: AppTextStyles.titleMedium.copyWith(
                              color: headerBlue,
                              fontWeight: FontWeight.w800,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            'Online',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: onlineGreen,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Call Button
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: callButtonBg,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.phone_outlined,
                        color: primaryBlue,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Close Button
                    IconButton(
                      icon: const Icon(Icons.close, color: Color(0xFF546387)),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              // --- Item Card ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 32,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCDDDF),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.black12),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Econ 101 Textbook',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: headerBlue,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Text(
                        '\$45',
                        style: AppTextStyles.labelLarge.copyWith(
                          color: primaryBlue,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // --- Chat Messages Area ---
              Expanded(
                child: Container(
                  width: double.infinity,
                  color: backgroundColor.withOpacity(0.3),
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    itemCount: _messages.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE2DDFA),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Today',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: const Color(0xFF546387),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                      
                      final msg = _messages[index - 1];
                      if (msg.isMine) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildRightBubble(msg.text, primaryBlue, Colors.white),
                        );
                      } else {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildLeftBubble(
                            msg.text,
                            msg.avatarUrl ?? 'https://i.pravatar.cc/150?u=default',
                            bubbleLeftBg,
                            headerBlue,
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),

              // --- Bottom Input Area ---
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F4FA),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.add_circle_outline,
                        color: primaryBlue,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          onSubmitted: (_) => _sendMessage(),
                          decoration: InputDecoration(
                            hintText: 'Message Alex...',
                            hintStyle: AppTextStyles.bodyMedium.copyWith(
                              color: const Color(0xFF9EA3C0),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.only(bottom: 4),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: _sendMessage,
                        child: Container(
                          margin: const EdgeInsets.all(6),
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: primaryBlue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.send_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeftBubble(String text, String avatarUrl, Color bgColor, Color textColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        CircleAvatar(
          radius: 14,
          backgroundImage: NetworkImage(avatarUrl),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
                bottomLeft: Radius.circular(4),
              ),
            ),
            child: Text(
              text,
              style: AppTextStyles.bodyMedium.copyWith(
                color: textColor,
                height: 1.4,
              ),
            ),
          ),
        ),
        const SizedBox(width: 32), // space on the right
      ],
    );
  }

  Widget _buildRightBubble(String text, Color bgColor, Color textColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const SizedBox(width: 48), // space on the left
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(4),
              ),
            ),
            child: Text(
              text,
              style: AppTextStyles.bodyMedium.copyWith(
                color: textColor,
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
