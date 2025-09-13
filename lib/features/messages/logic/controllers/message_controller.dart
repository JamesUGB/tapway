// C:\Users\Zino\Documents\tapway\lib\features\messages\logic\controllers\message_controller.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tapway/features/messages/data/models/message.dart';
import 'package:tapway/features/messages/data/repositories/message_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class MessageController extends GetxController {
  final MessageRepository _repo;
  MessageController(this._repo);

  late final String responderId;
  String? responderName;

  String currentUserId = '';
  late final String conversationId;

  final messages = <Message>[].obs;
  final textCtrl = TextEditingController();
  final scrollCtrl = ScrollController();
  StreamSubscription<List<Message>>? _sub;

  @override
  void onInit() {
    super.onInit();

    // Ensure user is logged in
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Get.offAllNamed('/login');
      return;
    }
    currentUserId = user.uid;

    // Get arguments safely
final rawArgs = Get.arguments ?? {};
final args = Map<String, dynamic>.from(rawArgs as Map);
    responderId = args['responderId']?.toString() ?? '';
    responderName = args['responderName']?.toString();

    if (responderId.isEmpty) {
      Get.snackbar('Error', 'Responder ID is required');
      Get.back();
      return;
    }

    conversationId = _repo.buildConversationId(currentUserId, responderId);

    // Ensure conversation exists
    _repo.createOrGetConversation(
      userId: currentUserId,
      responderId: responderId,
    );

    // Start listening
    _sub = _repo.streamMessages(conversationId).listen((list) {
      messages.assignAll(list);
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollCtrl.hasClients) {
        scrollCtrl.animateTo(
          scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> sendText() async {
    final text = textCtrl.text.trim();
    if (text.isEmpty) return;

    final msg = Message(
      id: 'temp',
      conversationId: conversationId,
      senderId: currentUserId,
      receiverId: responderId,
      text: text,
      sentAt: Timestamp.now(),
    );

    textCtrl.clear();
    await _repo.sendMessage(conversationId: conversationId, message: msg);
  }

  @override
  void onClose() {
    _sub?.cancel();
    textCtrl.dispose();
    scrollCtrl.dispose();
    super.onClose();
  }
}
