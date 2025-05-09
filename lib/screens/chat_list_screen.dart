// lib/screens/chat_list_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/auth_controller.dart';
import '../controllers/chat_list_controller.dart';
import '../models/chat.dart';
import '../routes/app_routes.dart';

class ChatListScreen extends GetView<ChatListController> {
  final AuthController _authController = Get.find<AuthController>();

  ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header with safe area for notch
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'CHAT',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _showProfileOptions(context),
                    child: Obx(() {
                      final user = _authController.currentUser.value;
                      return CircleAvatar(
                        radius: 16,
                        backgroundColor: Color(0xFF6C88D7),
                        child: Text(
                          user?.displayName.substring(0, 1).toUpperCase() ??
                              'U',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),

          // Chat list
          Expanded(
            child: Obx(() {
              print('Chat list UI update - ${controller.chats.length} chats, isLoading: ${controller.isLoading.value}');
              
              if (controller.isLoading.value && controller.chats.isEmpty) {
                return Center(child: CircularProgressIndicator());
              }

              if (controller.chats.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 80,
                        color: Colors.grey[300],
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No conversations yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Start a new chat by tapping the + button',
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.refreshChats,
                child: ListView.builder(
                  itemCount: controller.chats.length,
                  itemBuilder: (context, index) {
                    final chat = controller.chats[index];
                    print('Building chat item for chat ${chat.id}');
                    return _buildChatItem(chat);
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNewChatDialog(context),
        backgroundColor: Color(0xFF6C88D7),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildChatItem(Chat chat) {
    final otherUser = chat.otherUser;
    final lastMessage = chat.lastMessage;

    if (otherUser == null) {
      return SizedBox.shrink();
    }

    return InkWell(
      onTap: () {
        // Pass the chat and otherUser data to the chat detail screen
        Get.toNamed(
          '${AppRoutes.CHAT_DETAIL}/${chat.id}',
          arguments: { 'chat': chat, 'otherUser': otherUser },
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            // Profile image
            CircleAvatar(
              radius: 30,
              backgroundColor: Color(0xFF6C88D7),
              child: Text(
                otherUser.displayName.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(width: 16),

            // Message details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        otherUser.displayName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: otherUser.isOnline ? Colors.green : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    lastMessage != null
                        ? (lastMessage.senderId ==
                                _authController.currentUser.value?.id
                            ? 'You: ${lastMessage.content}'
                            : lastMessage.content)
                        : 'Start a conversation',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Time and unread count
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  lastMessage != null ? _formatTime(lastMessage.createdAt) : '',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
                SizedBox(height: 4),
                if (chat.unreadCount > 0)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Color(0xFF6C88D7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      chat.unreadCount.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final messageDate = DateTime(time.year, time.month, time.day);

    if (messageDate == today) {
      return DateFormat('HH:mm').format(time);
    } else if (messageDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('dd/MM').format(time);
    }
  }

  void _showProfileOptions(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              onTap: () {
                Get.back();
                // TODO: Navigate to profile screen
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                Get.back();
                _authController.logout();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showNewChatDialog(BuildContext context) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Start a new chat',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              FutureBuilder(
                future: Get.find<AuthController>().getAllUsers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Text('Error loading users');
                  }

                  final users = snapshot.data;
                  if (users == null || users.isEmpty) {
                    return Text('No users found');
                  }

                  // Filter out current user
                  final filteredUsers =
                      users
                          .where(
                            (user) =>
                                user.id !=
                                _authController.currentUser.value?.id,
                          )
                          .toList();

                  if (filteredUsers.isEmpty) {
                    return Text('No other users found');
                  }

                  return SizedBox(
                    height: 300,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = filteredUsers[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Color(0xFF6C88D7),
                            child: Text(
                              user.displayName.substring(0, 1).toUpperCase(),
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(user.displayName),
                          subtitle: Text('@${user.username}'),
                          onTap: () {
                            Get.back();
                            controller.createChat(user.id);
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
