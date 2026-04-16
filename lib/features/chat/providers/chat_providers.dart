import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/chat.dart';
import '../../../models/message.dart';
import '../../../services/firebase/chat_repository.dart';

// ── Repository ──────────────────────────────────────────────────────────────

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return FirebaseChatRepository();
});

// ── 채팅 목록 ────────────────────────────────────────────────────────────────

final chatListProvider =
    StreamProvider.family<List<Chat>, String>((ref, userId) {
  return ref.watch(chatRepositoryProvider).watchChats(userId);
});

// ── 메시지 목록 (채팅방별) ──────────────────────────────────────────────────

final messagesProvider =
    StreamProvider.family<List<Message>, String>((ref, chatId) {
  return ref.watch(chatRepositoryProvider).watchMessages(chatId);
});

// ── 메시지 전송 ────────────────────────────────────────────────────────────

class ChatNotifier extends Notifier<void> {
  @override
  void build() {}

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String content,
  }) async {
    final message = Message(
      id: '',
      chatId: chatId,
      senderId: senderId,
      content: content,
      type: MessageType.text,
      timestamp: DateTime.now(),
    );
    await ref.read(chatRepositoryProvider).sendMessage(message);
  }

  Future<void> archiveMessage(String chatId, String messageId) async {
    await ref.read(chatRepositoryProvider).archiveMessage(chatId, messageId);
  }
}

final chatNotifierProvider = NotifierProvider<ChatNotifier, void>(ChatNotifier.new);
