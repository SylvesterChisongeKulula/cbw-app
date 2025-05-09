// lib/controllers/chat_detail_controller.dart
import 'package:get/get.dart';
import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
// file_picker removed to fix build issues
import 'package:path/path.dart' as path;
import '../models/chat.dart';
import '../models/message.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/socket_service.dart';
import 'auth_controller.dart';
import '../controllers/chat_list_controller.dart';

class ChatDetailController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final SocketService _socketService = Get.find<SocketService>();
  final ImagePicker _imagePicker = ImagePicker();
  
  final User currentUser = Get.find<AuthController>().currentUser.value!;
  final RxInt chatId = 0.obs;
  final Rx<Chat?> chat = Rx<Chat?>(null);
  final RxList<Message> messages = RxList<Message>([]);
  final RxBool isLoading = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool isTyping = false.obs;
  final RxString messageText = ''.obs;
  
  // For file attachments
  final Rx<File?> selectedFile = Rx<File?>(null);
  final RxString selectedFileName = ''.obs;
  final RxBool isAttachmentSelected = false.obs;
  
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
    
    // Check if we have arguments with chat and otherUser data
    if (Get.arguments != null) {
      final args = Get.arguments as Map<String, dynamic>;
      if (args.containsKey('chat')) {
        chat.value = args['chat'] as Chat;
        print('DEBUG: Chat set from arguments: ${chat.value?.toJson()}');
      } else {
        // If no chat in arguments, load from API
        loadChatDetails();
      }
    } else {
      // If no arguments, load from API
      loadChatDetails();
    }
    
    loadMessages();
    _setupSocketListeners();
  }
  
  @override
  void onReady() {
    super.onReady();
    _markMessagesAsRead();
    // Reattach socket listeners to resume real-time updates
    _setupSocketListeners();
  }

  @override
  void onClose() {
    _typingTimer?.cancel();
    // Unsubscribe socket events to prevent duplicate handling
    _socketService.socket.off('message:new');
    _socketService.socket.off('message:sent');
    _socketService.socket.off('chat:updated');
    _socketService.socket.off('typing:start');
    _socketService.socket.off('typing:stop');
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
        // Use update() to trigger UI refresh
        messages.add(message);
        messages.refresh();
        print('New message received: ${message.content}');
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
    
    // Listen for chat updates (fallback for new messages)
    _socketService.onChatUpdated((data) {
      if (data != null && data['chatId'] == chatId.value) {
        final message = Message.fromJson(data);
        messages.add(message);
        messages.refresh();
        print('Chat updated, new message: ${message.content}');
      }
    });
  }
  
  // Send a message
  Future<void> sendMessage({String? customContent}) async {
    // If custom content is provided, use it; otherwise, use the messageText
    final content = customContent ?? messageText.value.trim();
    
    if (content.isEmpty) return;
    
    // Create a temporary message to show immediately in UI
    final tempMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch, // Temporary ID
      chatId: chatId.value,
      senderId: currentUser.id,
      content: content,
      createdAt: DateTime.now(),
      isRead: false,
    );
    
    // Add to messages list immediately for UI update
    messages.add(tempMessage);
    // Force UI refresh
    messages.refresh();
    
    // Only clear message text if we're not sending a custom content (like a file)
    if (customContent == null) {
      messageText.value = '';
    }
    
    // Send via socket
    _socketService.sendMessage(
      chatId.value,
      currentUser.id,
      content,
    );
    
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
  
  // Pick a file from gallery (replacement for file_picker)
  Future<void> pickFile() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      
      if (image != null) {
        final file = File(image.path);
        selectedFile.value = file;
        selectedFileName.value = path.basename(file.path);
        isAttachmentSelected.value = true;
        
        // For now, just send the file name as a message
        // In a real app, you would upload the file to a server
        final content = "🖼️ Attached image: ${selectedFileName.value}";
        await sendMessage(customContent: content);
        
        // Reset after sending
        _resetAttachment();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image: $e');
    }
  }
  
  // Take a photo using the camera
  Future<void> takePhoto() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      
      if (photo != null) {
        final file = File(photo.path);
        selectedFile.value = file;
        selectedFileName.value = path.basename(file.path);
        isAttachmentSelected.value = true;
        
        // For now, just send a message indicating a photo was taken
        // In a real app, you would upload the photo to a server
        final content = "📷 Photo captured";
        await sendMessage(customContent: content);
        
        // Reset after sending
        _resetAttachment();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to capture photo: $e');
    }
  }
  
  // Reset attachment selection
  void _resetAttachment() {
    selectedFile.value = null;
    selectedFileName.value = '';
    isAttachmentSelected.value = false;
  }
  
  // Clear unread count in chat list when opening detail
  void _markMessagesAsRead() {
    final chatListCtrl = Get.find<ChatListController>();
    final idx = chatListCtrl.chats.indexWhere((c) => c.id == chatId.value);
    if (idx >= 0) {
      final chatItem = chatListCtrl.chats[idx];
      chatListCtrl.chats[idx] = Chat(
        id: chatItem.id,
        user1Id: chatItem.user1Id,
        user2Id: chatItem.user2Id,
        otherUser: chatItem.otherUser,
        lastMessage: chatItem.lastMessage,
        unreadCount: 0,
        createdAt: chatItem.createdAt,
      );
    }
  }
}
