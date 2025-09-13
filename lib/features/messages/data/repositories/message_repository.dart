// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tapway/data/services/firestore_service.dart';
import 'package:tapway/features/messages/data/models/message.dart';

class MessageRepository {
  final FirestoreService _fs;
  MessageRepository(this._fs);

  String buildConversationId(String userId, String responderId) {
    return _fs.conversationIdFor(userId, responderId);
  }

  Future<String> createOrGetConversation({
    required String userId,
    required String responderId,
  }) async {
    final id = buildConversationId(userId, responderId);
    await _fs.ensureConversation(
      conversationId: id,
      participants: [userId, responderId],
    );
    return id;
  }

  Stream<List<Message>> streamMessages(String conversationId) {
    return _fs.messagesStream(conversationId).map((snap) {
      return snap.docs.map((d) {
        final data = d.data();
        // FirestoreService added 'id' in sendConversationMessage
        data['id'] = d.id;
        data['conversationId'] = conversationId;
        return Message.fromMap(data);
      }).toList();
    });
  }

  Future<void> sendMessage({
    required String conversationId,
    required Message message,
  }) async {
    await _fs.sendConversationMessage(
      conversationId: conversationId,
      messageData: message.toMapForCreate(),
    );
  }

  Stream<List<Map<String, dynamic>>> streamUserConversations(String userId) {
    return _fs.userConversations(userId).map((snap) {
      return snap.docs.map((d) {
        final data = d.data();
        data['id'] = d.id;
        return data;
      }).toList();
    });
  }
}
