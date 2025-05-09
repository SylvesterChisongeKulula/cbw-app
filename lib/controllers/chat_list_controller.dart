// lib/controllers/chat_list_controller.dart
import 'package:get/get.dart';
import '../models/chat.dart';
import '../models/user.dart';
import '../models/message.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';
import 'auth_controller.dart';

class ChatListController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final SocketService _socketService = Get.find<SocketService>();

  final User currentUser = Get.find<AuthController>().currentUser.value!;
  final RxList<Chat> chats = RxList<Chat>([]);
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadChats();
    _setupSocketListeners();
  }

  // Load user's chats from API
  Future<void> loadChats() async {
    try {
      isLoading.value = true;
      final chatsList = await _apiService.getUserChats(currentUser.id);
      print('Loaded ${chatsList.length} chats from API');

      // Make sure to update the observable list properly
      chats.clear();
      chats.addAll(chatsList);

      // Sort chats by latest message
      if (chats.isNotEmpty) {
        chats.sort(
          (a, b) => (a.lastMessage?.createdAt ?? a.createdAt).compareTo(
            b.lastMessage?.createdAt ?? b.createdAt,
          ),
        );
      }
    } catch (e) {
      print('Error loading chats: $e');
      Get.snackbar('Error', 'Failed to load chats: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Refresh chats (for pull-to-refresh)
  Future<void> refreshChats() async {
    try {
      isRefreshing.value = true;
      await loadChats();
    } finally {
      isRefreshing.value = false;
    }
  }

  // Create a new chat
  Future<void> createChat(int otherUserId) async {
    try {
      final chat = await _apiService.createChat(currentUser.id, otherUserId);

      // Check if the chat already exists in the list
      final existingIndex = chats.indexWhere((c) => c.id == chat.id);
      if (existingIndex >= 0) {
        chats[existingIndex] = chat;
      } else {
        chats.add(chat);
        chats.sort(
          (a, b) => (a.lastMessage?.createdAt ?? a.createdAt).compareTo(
            b.lastMessage?.createdAt ?? b.createdAt,
          ),
        );
      }

      // Navigate to chat detail screen
      Get.toNamed('/chat/${chat.id}');
    } catch (e) {
      Get.snackbar('Error', 'Failed to create chat: $e');
    }
  }

  // Setup socket listeners
  void _setupSocketListeners() {
    // Listen for new messages
    _socketService.onMessage((data) {
      if (data != null) {
        _updateChatWithNewMessage(data);
      }
    });

    // Listen for user online/offline events
    _socketService.onUserOnline((data) {
      print('Socket event user:online: $data');
      if (data != null) _updateUserStatus(data);
    });
    _socketService.onUserOffline((data) {
      print('Socket event user:offline: $data');
      if (data != null) _updateUserStatus(data);
    });
  }

  // Update chat with new message
  void _updateChatWithNewMessage(dynamic messageData) {
    try {
      // Handle message update logic
      final int chatId = messageData['chatId'];
      final chatIndex = chats.indexWhere((c) => c.id == chatId);

      if (chatIndex >= 0) {
        // Update lastMessage using the incoming messageData
        final existing = chats[chatIndex];
        final newMessage = Message.fromJson(messageData);
        final updatedChat = Chat(
          id: existing.id,
          user1Id: existing.user1Id,
          user2Id: existing.user2Id,
          otherUser: existing.otherUser,
          lastMessage: newMessage,
          unreadCount:
              existing.unreadCount +
              (messageData['senderId'] != currentUser.id ? 1 : 0),
          createdAt: existing.createdAt,
        );
        chats[chatIndex] = updatedChat;

        // Sort chats by latest message
        chats.sort(
          (a, b) => (a.lastMessage?.createdAt ?? a.createdAt).compareTo(
            b.lastMessage?.createdAt ?? b.createdAt,
          ),
        );
      }
    } catch (e) {
      print('Error updating chat with new message: $e');
    }
  }

  // Update user status
  void _updateUserStatus(dynamic userData) {
    try {
      final int userId = userData['userId'];
      final bool isOnline = userData['isOnline'];

      // Update user status in chats
      for (int i = 0; i < chats.length; i++) {
        if (chats[i].otherUser?.id == userId) {
          final updatedUser = User(
            id: chats[i].otherUser!.id,
            username: chats[i].otherUser!.username,
            displayName: chats[i].otherUser!.displayName,
            profilePicture: chats[i].otherUser!.profilePicture,
            isOnline: isOnline,
            lastSeen: isOnline ? null : DateTime.now(),
          );

          chats[i] = Chat(
            id: chats[i].id,
            user1Id: chats[i].user1Id,
            user2Id: chats[i].user2Id,
            otherUser: updatedUser,
            lastMessage: chats[i].lastMessage,
            unreadCount: chats[i].unreadCount,
            createdAt: chats[i].createdAt,
          );
        }
      }
      // Refresh to ensure UI updates
      chats.refresh();
      print(
        'Chat list after status update: ${chats.map((c) => c.otherUser?.id != null ? '${c.id}:${c.otherUser!.isOnline}' : '').toList()}',
      );
    } catch (e) {
      print('Error updating user status: $e');
    }
  }
}
