import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String conversationId;
  final String senderId;
  final String receiverId;
  final String text;
  final String? imageUrl;
  final Timestamp sentAt;
  final bool seen;

  Message({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.receiverId,
    required this.text,
    this.imageUrl,
    required this.sentAt,
    this.seen = false,
  });

  Map<String, dynamic> toMapForCreate() {
    // sentAt is set server-side in FirestoreService
    return {
      'conversationId': conversationId,
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'imageUrl': imageUrl,
      'seen': seen,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] as String,
      conversationId: map['conversationId'] as String,
      senderId: map['senderId'] as String,
      receiverId: map['receiverId'] as String,
      text: map['text'] as String? ?? '',
      imageUrl: map['imageUrl'] as String?,
      sentAt: (map['sentAt'] as Timestamp?) ?? Timestamp.now(),
      seen: map['seen'] as bool? ?? false,
    );
  }
}
