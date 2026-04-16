import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/chat.dart';
import '../../models/message.dart';

abstract class ChatRepository {
  Stream<List<Chat>> watchChats(String userId);
  Stream<List<Message>> watchMessages(String chatId);
  Future<void> sendMessage(Message message);
  Future<void> archiveMessage(String chatId, String messageId);
}

class FirebaseChatRepository implements ChatRepository {
  final FirebaseFirestore _db;

  FirebaseChatRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  @override
  Stream<List<Chat>> watchChats(String userId) {
    return _db
        .collection('chats')
        .where('participantIds', arrayContains: userId)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Chat.fromMap(d.id, d.data())).toList());
  }

  @override
  Stream<List<Message>> watchMessages(String chatId) {
    return _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Message.fromMap(d.id, d.data())).toList());
  }

  @override
  Future<void> sendMessage(Message message) async {
    final ref = _db
        .collection('chats')
        .doc(message.chatId)
        .collection('messages')
        .doc();

    final batch = _db.batch();
    batch.set(ref, message.toMap());
    batch.update(_db.collection('chats').doc(message.chatId), {
      'lastMessage': message.content,
      'lastMessageAt': Timestamp.fromDate(message.timestamp),
    });
    await batch.commit();
  }

  @override
  Future<void> archiveMessage(String chatId, String messageId) async {
    await _db
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .update({'archived': true});
  }
}
