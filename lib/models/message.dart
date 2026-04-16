import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { text, image, file }

class Message {
  final String id;
  final String chatId;
  final String senderId;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final bool archived;
  final List<String> tags;
  final String? summary;

  const Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.content,
    required this.type,
    required this.timestamp,
    this.archived = false,
    this.tags = const [],
    this.summary,
  });

  factory Message.fromMap(String id, Map<String, dynamic> map) {
    return Message(
      id: id,
      chatId: map['chatId'] as String,
      senderId: map['senderId'] as String,
      content: map['content'] as String,
      type: MessageType.values.byName(map['type'] as String? ?? 'text'),
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      archived: map['archived'] as bool? ?? false,
      tags: List<String>.from(map['tags'] as List? ?? []),
      summary: map['summary'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'chatId': chatId,
      'senderId': senderId,
      'content': content,
      'type': type.name,
      'timestamp': Timestamp.fromDate(timestamp),
      'archived': archived,
      'tags': tags,
      if (summary != null) 'summary': summary,
    };
  }

  Message copyWith({
    bool? archived,
    List<String>? tags,
    String? summary,
  }) {
    return Message(
      id: id,
      chatId: chatId,
      senderId: senderId,
      content: content,
      type: type,
      timestamp: timestamp,
      archived: archived ?? this.archived,
      tags: tags ?? this.tags,
      summary: summary ?? this.summary,
    );
  }
}
