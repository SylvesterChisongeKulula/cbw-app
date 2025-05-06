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
    // Debug print to see the raw response
    
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
    try {
      final response = await _get('/chats/user/$userId');
      
      final List<dynamic> chatsData = response['data'];
      print('Extracted chats data: $chatsData');
      
      List<Chat> chatsList = [];
      for (var chat in chatsData) {
        try {
          print('Processing chat: $chat');
          chatsList.add(Chat.fromJson(chat));
        } catch (e) {
          print('Error parsing chat: $e');
          // Continue with next chat instead of failing the whole list
        }
      }
      
      return chatsList;
    } catch (e) {
      print('Error in getUserChats: $e');
      throw Exception('Failed to get user chats: $e');
    }
  }

  Future<Chat> getChatById(int chatId) async {
    final data = await _get('/chats/$chatId');
    return Chat.fromJson(data);
  }

  // Message APIs
  Future<List<Message>> getChatMessages(int chatId, {int limit = 50, int page = 1}) async {
    try {
      final data = await _get('/chats/$chatId/messages?limit=$limit&page=$page');
      
      // Debug the response structure
      print('Chat messages response: $data');
      
      // Check if data and data['data'] and data['data']['messages'] exist
      if (data == null || data['data'] == null || data['data']['messages'] == null) {
        print('Invalid response structure for chat messages');
        return [];
      }
      
      final List<dynamic> messagesData = data['data']['messages'];
      return List<Message>.from(messagesData.map((message) => Message.fromJson(message)));
    } catch (e) {
      print('Error in getChatMessages: $e');
      throw Exception('Failed to get chat messages: $e');
    }
  }
}

