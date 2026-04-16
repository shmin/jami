import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  final String id;
  final List<String> participantIds;
  final String lastMessage;
  final DateTime lastMessageAt;
  final String? name; // 그룹 채팅용

  const Chat({
    required this.id,
    required this.participantIds,
    required this.lastMessage,
    required this.lastMessageAt,
    this.name,
  });

  factory Chat.fromMap(String id, Map<String, dynamic> map) {
    return Chat(
      id: id,
      participantIds: List<String>.from(map['participantIds'] as List),
      lastMessage: map['lastMessage'] as String? ?? '',
      lastMessageAt: (map['lastMessageAt'] as Timestamp).toDate(),
      name: map['name'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participantIds': participantIds,
      'lastMessage': lastMessage,
      'lastMessageAt': Timestamp.fromDate(lastMessageAt),
      if (name != null) 'name': name,
    };
  }
}
