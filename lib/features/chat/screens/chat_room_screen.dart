import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/message.dart';
import '../providers/chat_providers.dart';
import '../widgets/message_bubble.dart';
import '../widgets/message_input_bar.dart';

class ChatRoomScreen extends ConsumerWidget {
  final String chatId;
  final String chatName;
  final String currentUserId;

  const ChatRoomScreen({
    super.key,
    required this.chatId,
    required this.chatName,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messagesAsync = ref.watch(messagesProvider(chatId));

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                chatName.isNotEmpty ? chatName[0] : '?',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(chatName, style: const TextStyle(fontSize: 16)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.archive_outlined),
            tooltip: '아카이브 보기',
            onPressed: () {
              // TODO: 아카이브 화면으로 이동
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('오류가 발생했습니다: $e')),
              data: (messages) => _MessageList(
                messages: messages,
                currentUserId: currentUserId,
                chatId: chatId,
              ),
            ),
          ),
          MessageInputBar(
            onSend: (text) {
              ref.read(chatNotifierProvider.notifier).sendMessage(
                    chatId: chatId,
                    senderId: currentUserId,
                    content: text,
                  );
            },
          ),
        ],
      ),
    );
  }
}

class _MessageList extends ConsumerWidget {
  final List<Message> messages;
  final String currentUserId;
  final String chatId;

  const _MessageList({
    required this.messages,
    required this.currentUserId,
    required this.chatId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (messages.isEmpty) {
      return const Center(
        child: Text(
          '첫 메시지를 보내보세요',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: messages.length,
      // 새 메시지가 아래에 쌓이므로 역순 렌더링
      reverse: false,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isMine = message.senderId == currentUserId;
        final showDateDivider = _shouldShowDate(messages, index);

        return Column(
          children: [
            if (showDateDivider) _DateDivider(date: message.timestamp),
            MessageBubble(
              message: message,
              isMine: isMine,
              onArchive: () {
                ref
                    .read(chatNotifierProvider.notifier)
                    .archiveMessage(chatId, message.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('아카이브에 저장했습니다')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  bool _shouldShowDate(List<Message> messages, int index) {
    if (index == 0) return true;
    final prev = messages[index - 1].timestamp;
    final curr = messages[index].timestamp;
    return prev.year != curr.year ||
        prev.month != curr.month ||
        prev.day != curr.day;
  }
}

class _DateDivider extends StatelessWidget {
  final DateTime date;

  const _DateDivider({required this.date});

  @override
  Widget build(BuildContext context) {
    final label =
        '${date.year}년 ${date.month}월 ${date.day}일 ${_weekday(date.weekday)}';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
          ),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }

  String _weekday(int w) {
    const days = ['월', '화', '수', '목', '금', '토', '일'];
    return '${days[w - 1]}요일';
  }
}
