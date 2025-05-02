// lib/controllers/auth_controller.dart
import 'package:get/get.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../services/socket_service.dart';
import '../routes/app_routes.dart';

class AuthController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();
  final SocketService _socketService = Get.find<SocketService>();
  
  final Rx<User?> currentUser = Rx<User?>(null);
  final RxList<User> users = RxList<User>([]);
  final RxBool isLoading = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    _loadCurrentUser();
    _loadUsers();
  }
  
  // Load current user from storage
  void _loadCurrentUser() {
    final user = _storageService.getCurrentUser();
    if (user != null) {
      currentUser.value = user;
      _connectSocket(user.id);
      Get.offAllNamed(AppRoutes.CHAT_LIST);
    }
  }
  
  // Load all users from API
  Future<void> _loadUsers() async {
    try {
      isLoading.value = true;
      users.value = await _apiService.getAllUsers();
    } catch (e) {
      print('Error loading users: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  // Create a new user
  Future<void> createUser(String username, String displayName) async {
    try {
      isLoading.value = true;
      final user = await _apiService.createUser(username, displayName);
      await _storageService.saveCurrentUser(user);
      currentUser.value = user;
      _connectSocket(user.id);
      Get.offAllNamed(AppRoutes.CHAT_LIST);
    } catch (e) {
      Get.snackbar('Error', 'Failed to create user: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<User>> getAllUsers() async {
    try {
      isLoading.value = true;
      final usersList = await _apiService.getAllUsers();
      
      // Update the users list in memory
      users.value = usersList;
      
      return usersList;
    } catch (e) {
      print('Error loading users: $e');
      Get.snackbar('Error', 'Failed to load users');
      return [];
    } finally {
      isLoading.value = false;
    }
  }
  
  // Select a user from the list
  Future<void> selectUser(User user) async {
    await _storageService.saveCurrentUser(user);
    currentUser.value = user;
    _connectSocket(user.id);
    Get.offAllNamed(AppRoutes.CHAT_LIST);
  }
  
  // Connect to socket with user ID
  void _connectSocket(int userId) {
    _socketService.init(userId);
  }
  
  // Logout current user
  Future<void> logout() async {
    _socketService.disconnect();
    await _storageService.clearCurrentUser();
    currentUser.value = null;
    Get.offAllNamed(AppRoutes.LOGIN);
  }
}

