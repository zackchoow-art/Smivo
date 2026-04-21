import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'chat_provider.g.dart';

class ChatConversation {
  final String id;
  final String name;
  final String latestMessage;
  final String time;
  final bool hasUnread;
  final String? avatarUrl; // null means use initials
  final String? initials;

  ChatConversation({
    required this.id,
    required this.name,
    required this.latestMessage,
    required this.time,
    this.hasUnread = false,
    this.avatarUrl,
    this.initials,
  });
}

@riverpod
class ChatList extends _$ChatList {
  @override
  List<ChatConversation> build() {
    return [
      ChatConversation(
        id: '1',
        name: 'Alex Rivera',
        latestMessage: 'Hey! Are you still selling that Eco...',
        time: '2m ago',
        hasUnread: true,
        avatarUrl: 'https://i.pravatar.cc/150?u=alex', // Mock avatar
      ),
      ChatConversation(
        id: '2',
        name: 'Jordan Lee',
        latestMessage: "Sweet, I'll meet you at the quad at...",
        time: '1h ago',
        avatarUrl: 'https://i.pravatar.cc/150?u=jordan',
      ),
      ChatConversation(
        id: '3',
        name: 'Samira Patel',
        latestMessage: 'Thanks for the notes! Lifesaver.',
        time: 'Yesterday',
        avatarUrl: 'https://i.pravatar.cc/150?u=samira',
      ),
      ChatConversation(
        id: '4',
        name: 'Campus Housing',
        latestMessage: 'Your maintenance request has be...',
        time: 'Tuesday',
        initials: 'CH',
      ),
      ChatConversation(
        id: '5',
        name: 'Emma Wright',
        latestMessage: 'Is the price negotiable?',
        time: 'Monday',
        avatarUrl: 'https://i.pravatar.cc/150?u=emma',
      ),
      ChatConversation(
        id: '6',
        name: 'Michael Chen',
        latestMessage: "Thanks. I'll pick it up tomorrow m...",
        time: 'Sun',
        hasUnread: true,
        avatarUrl: 'https://i.pravatar.cc/150?u=michael',
      ),
      ChatConversation(
        id: '7',
        name: 'David Lee',
        latestMessage: 'Just returned the calculus book.',
        time: 'Last week',
        avatarUrl: 'https://i.pravatar.cc/150?u=david',
      ),
      ChatConversation(
        id: '8',
        name: 'Sarah Jenkins',
        latestMessage: 'The apartment looks great! Looki...',
        time: 'Last week',
        avatarUrl: 'https://i.pravatar.cc/150?u=sarah',
      ),
      ChatConversation(
        id: '9',
        name: 'Anna F.',
        latestMessage: 'Will you take \$35?',
        time: 'Sep 20',
        avatarUrl: 'https://i.pravatar.cc/150?u=anna',
      ),
      ChatConversation(
        id: '10',
        name: 'James K.',
        latestMessage: 'Is the fridge still available?',
        time: 'Sep 15',
        avatarUrl: 'https://i.pravatar.cc/150?u=james',
      ),
    ];
  }
}
