// lib/controllers/chat_detail_controller.dart
import 'package:get/get.dart';
import 'dart:async';
import '../models/chat.dart';
import '../models/message.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';
import 'auth_controller.dart';

class ChatDetailController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final SocketService _socketService = Get.find<SocketService>();
  
  final User currentUser = Get.find<AuthController>().currentUser.value!;
  final RxInt chatId = 0.obs;
  final Rx<Chat?> chat = Rx<Chat?>(null);
  final RxList<Message> messages = RxList<Message>([]);
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isTyping = false.obs;
  final RxString messageText = ''.obs;
  
  // Pagination
  int currentPage = 1;
  final int messagesPerPage = 20;
  final RxBool hasMoreMessages = true.obs;
  
  // Typing timer
  Timer? _typingTimer;
  
  @override
  void onInit() {
    super.onInit();
    chatId.value = int.parse(Get.parameters['id']!);
    loadChatDetails();
    loadMessages();
    _setupSocketListeners();
  }
  
  @override
  void onClose() {
    _typingTimer?.cancel();
    super.onClose();
  }
  
  // Load chat details from API
  Future<void> loadChatDetails() async {
    try {
      isLoading.value = true;
      chat.value = await _apiService.getChatById(chatId.value);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load chat details: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Load messages from API
  Future<void> loadMessages({bool loadMore = false}) async {
    if (loadMore) {
      if (!hasMoreMessages.value || isLoadingMore.value) return;
      isLoadingMore.value = true;
      currentPage++;
    } else {
      isLoading.value = true;
      currentPage = 1;
      messages.clear();
    }
    
    try {
      final newMessages = await _apiService.getChatMessages(
        chatId.value,
        limit: messagesPerPage,
        page: currentPage,
      );
      
      if (newMessages.length < messagesPerPage) {
        hasMoreMessages.value = false;
      }
      
      if (loadMore) {
        messages.addAll(newMessages);
      } else {
        messages.value = newMessages;
      }
      
      // Sort messages by creation date (newest at the bottom)
      messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } catch (e) {
      Get.snackbar('Error', 'Failed to load messages: $e');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }
  
  // Setup socket listeners
  void _setupSocketListeners() {
    // Listen for new messages
    _socketService.onMessage((data) {
      if (data != null && data['chatId'] == chatId.value) {
        final message = Message.fromJson(data);
        messages.add(message);
      }
    });
    
    // Listen for typing indicators
    _socketService.onTyping((data) {
      if (data != null && data['chatId'] == chatId.value) {
        final int userId = data['userId'];
        final bool typing = data['typing'];
        
        // Only show typing indicator if it's the other user
        if (userId != currentUser.id) {
          isTyping.value = typing;
        }
      }
    });
  }
  
  // Send a message
  void sendMessage() {
    if (messageText.value.trim().isEmpty) return;
    
    _socketService.sendMessage(
      chatId.value,
      currentUser.id,
      messageText.value.trim(),
    );
    
    // Clear message text
    messageText.value = '';
    
    // Reset typing indicator
    _stopTyping();
  }
  
  // Handle typing events
  void onTyping(String text) {
    messageText.value = text;
    
    // Cancel previous timer
    _typingTimer?.cancel();
    
    // Start typing
    _socketService.startTyping(chatId.value, currentUser.id);
    
    // Set timer to stop typing after 2 seconds
    _typingTimer = Timer(const Duration(seconds: 2), _stopTyping);
  }
  
  // Stop typing
  void _stopTyping() {
    _typingTimer?.cancel();
    _socketService.stopTyping(chatId.value, currentUser.id);
  }
}