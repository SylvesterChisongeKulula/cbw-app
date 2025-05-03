// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import '../models/user.dart';
import '../models/chat.dart';
import '../models/message.dart';
import '../utils/constants.dart';

class ApiService extends GetxService {
  final http.Client _httpClient = http.Client();
  
  // Base URL for the API
  static const String baseUrl = ApiConstants.baseUrl;

  // Headers used for all requests
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // GET request helper
  Future<dynamic> _get(String endpoint) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
      );
      
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to perform GET request: $e');
    }
  }

  // POST request helper
  Future<dynamic> _post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
        body: jsonEncode(data),
      );
      
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to perform POST request: $e');
    }
  }

  // Handle HTTP response
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      throw Exception('HTTP Error: ${response.statusCode}, ${response.body}');
    }
  }

  // User APIs
  Future<List<User>> getAllUsers() async {
    final response = await _get('/users');
    // Extract the data array from the response
    final List<dynamic> usersData = response['data'];
    return List<User>.from(usersData.map((user) => User.fromJson(user)));
  }

  Future<User> getUserById(int userId) async {
    final data = await _get('/users/$userId');
    return User.fromJson(data);
  }

  Future<User> createUser(String username, String displayName) async {
    final data = await _post('/users', {
      'username': username,
      'displayName': displayName,
    });
    return User.fromJson(data);
  }

  // Chat APIs
  Future<Chat> createChat(int user1Id, int user2Id) async {
    final response = await _post('/chats', {
      'user1Id': user1Id,
      'user2Id': user2Id,
    });
    return Chat.fromJson(response['data']);
  }

  Future<List<Chat>> getUserChats(int userId) async {
    final response = await _get('/chats/user/$userId');
    final List<dynamic> chatsData = response['data'];
    return List<Chat>.from(chatsData.map((chat) => Chat.fromJson(chat)));
  }

  Future<Chat> getChatById(int chatId) async {
    final data = await _get('/chats/$chatId');
    return Chat.fromJson(data);
  }

  // Message APIs
  Future<List<Message>> getChatMessages(int chatId, {int limit = 50, int page = 1}) async {
    final data = await _get('/chats/$chatId/messages?limit=$limit&page=$page');
    return List<Message>.from(data['messages'].map((message) => Message.fromJson(message)));
  }
}


