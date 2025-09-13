// lib/features/messages/presentation/screens/messages_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tapway/features/messages/logic/controllers/message_controller.dart';
import 'package:tapway/features/messages/data/repositories/message_repository.dart';
import 'package:tapway/data/services/firestore_service.dart';
import 'package:tapway/features/messages/data/models/message.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> 
    with AutomaticKeepAliveClientMixin {
  late final MessageController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(
      MessageController(MessageRepository(FirestoreService())),
      permanent: true, // Changed to permanent since we want to preserve state
    );
  }

  @override
  void dispose() {
    // Don't delete the controller since it's permanent and we want to preserve state
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    return Container(
      color: const Color(0xFFF5F5F5),
      child: Column(
        children: [
          // Messages list
          Expanded(
            child: Obx(() {
              final list = controller.messages;
              if (list.isEmpty) {
                return const Center(
                  child: Text(
                    'Say hello 👋',
                    style: TextStyle(color: Color(0xFF6C757D)),
                  ),
                );
              }
              return ListView.builder(
                controller: controller.scrollCtrl,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final Message msg = list[index];
                  final bool isMine =
                      msg.senderId == controller.currentUserId;
                  return Align(
                    alignment: isMine
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      constraints: BoxConstraints(
                        maxWidth:
                            MediaQuery.of(context).size.width * 0.74,
                      ),
                      decoration: BoxDecoration(
                        color: isMine
                            ? const Color(0xFF0D6EFD)
                            : const Color(0xFFE9ECEF),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        msg.text,
                        style: TextStyle(
                          color: isMine
                              ? Colors.white
                              : const Color(0xFF212529),
                          fontSize: 15,
                          height: 1.25,
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),

          // Input bar
          SafeArea(
            top: false,
            child: Container(
              color: const Color(0xFFF5F5F5),
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.textCtrl,
                      minLines: 1,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: 'Type a message…',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFFDEE2E6),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFFDEE2E6),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Color(0xFFADB5BD),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: controller.sendText,
                    icon: const Icon(Icons.send),
                    color: const Color(0xFF0D6EFD),
                    tooltip: 'Send',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}