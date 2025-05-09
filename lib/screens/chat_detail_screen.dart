// lib/screens/chat_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/chat_detail_controller.dart';
import '../controllers/auth_controller.dart';
import '../models/message.dart';

class ChatDetailScreen extends GetView<ChatDetailController> {
  final AuthController _authController = Get.find<AuthController>();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  ChatDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),

              // Chat messages area
              Expanded(child: _buildChatMessages()),

              // Typing indicator
              Obx(
                () =>
                    controller.isTyping.value
                        ? Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Typing...',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        )
                        : SizedBox.shrink(),
              ),

              // Message input field
              _buildMessageInput(),
            ],
          ),
        ),
      );
  }

  Widget _buildHeader() {
    return Obx(() {
      final chat = controller.chat.value;
      print('DEBUG: Chat object: ${chat?.toJson()}');

      final otherUser = chat?.otherUser;
      print('DEBUG: Other user: ${otherUser?.toJson()}');

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 1.0,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            // Back button
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () => Get.back(),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
            ),
            SizedBox(width: 12),

            // Profile image
            CircleAvatar(
              radius: 20,
              backgroundColor: Color(0xFF6C88D7),
              child: Text(
                otherUser?.displayName.substring(0, 1).toUpperCase() ?? '?',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 12),

            // Name and status
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    otherUser?.displayName ?? 'Loading...',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    otherUser?.isOnline == true ? 'Active' : 'Offline',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildChatMessages() {
    return Obx(() {
      // Auto-scroll to latest message
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
      if (controller.isLoading.value && controller.messages.isEmpty) {
        return Center(child: CircularProgressIndicator());
      }

      final messagesList = controller.messages.toList();
      print('Building message list with ${messagesList.length} messages');

      return NotificationListener<ScrollNotification>(
        onNotification: (scrollInfo) {
          // Load more messages when reaching the top
          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
              controller.hasMoreMessages.value &&
              !controller.isLoadingMore.value) {
            controller.loadMessages(loadMore: true);
          }
          return false;
        },
        child: ListView.builder(
          controller: _scrollController,
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          itemCount:
              messagesList.length +
              (controller.isLoadingMore.value ? 1 : 0),
          itemBuilder: (context, index) {
            // Show loading indicator at the end when loading more
            if (controller.isLoadingMore.value &&
                index == messagesList.length) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            }

            final message = messagesList[index];
            final isMyMessage =
                message.senderId == _authController.currentUser.value!.id;

            return Padding(
              padding: EdgeInsets.only(bottom: 16),
              child:
                  isMyMessage
                      ? _buildMyMessage(message)
                      : _buildTheirMessage(message),
            );
          },
        ),
      );
    });
  }

  Widget _buildMyMessage(Message message) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          constraints: BoxConstraints(maxWidth: Get.width * 0.75),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Color(0xFFF2EFEF),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                message.content,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 4),
              Text(
                DateFormat('HH:mm').format(message.createdAt),
                style: TextStyle(fontSize: 10, color: Colors.black54),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTheirMessage(Message message) {
    // Get the other user from the chat object
    final otherUser = controller.chat.value?.otherUser;
    final displayName = otherUser?.displayName ?? 'User';
    
    print('DEBUG: Building their message: ${message.toJson()}');
    print('DEBUG: Using display name: $displayName');
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          constraints: BoxConstraints(maxWidth: Get.width * 0.75),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Color(0xFFF1EFEF),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display sender's name
              Text(
                displayName,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 4),
              Text(
                message.content,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 4),
              Text(
                DateFormat('HH:mm').format(message.createdAt),
                style: TextStyle(fontSize: 10, color: Colors.black54),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: Color(0xFFF2EFEF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Obx(() {
                      // Update the controller text when the observable value changes
                      if (_messageController.text !=
                          controller.messageText.value) {
                        _messageController.text = controller.messageText.value;
                      }
                      return TextField(
                        controller: _messageController,
                        onChanged: controller.onTyping,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Type A Message',
                          hintStyle: TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      );
                    }),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.attach_file,
                      size: 20,
                      color: Colors.black54,
                    ),
                    onPressed: () => controller.pickFile(),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    tooltip: 'Attach File',
                  ),
                  SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      Icons.camera_alt,
                      size: 20,
                      color: Colors.black54,
                    ),
                    onPressed: () => controller.takePhoto(),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                    tooltip: 'Take Photo',
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 8),
          GestureDetector(
            onTap: () async {
              await controller.sendMessage();
            },
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Color(0xFF6C88D7),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.send, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
