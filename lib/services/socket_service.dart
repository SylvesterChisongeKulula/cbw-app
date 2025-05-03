// lib/services/socket_service.dart
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../utils/constants.dart';

class SocketService extends GetxService {
  late IO.Socket socket;
  final RxBool isConnected = false.obs;

  // Initialize and connect to socket
  Future<SocketService> init(int userId) async {
    _connectSocket(userId);
    return this;
  }

  void _connectSocket(int userId) {
    socket = IO.io(ApiConstants.socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    // Socket connection events
    socket.onConnect((_) {
      isConnected.value = true;
      print('Socket connected');

      // Join as user
      joinAsUser(userId);
    });

    socket.onDisconnect((_) {
      isConnected.value = false;
      print('Socket disconnected');
    });

    socket.onError((error) {
      print('Socket error: $error');
    });

    socket.onConnectError((error) {
      print('Socket connection error: $error');
    });
  }

  // Join as user
  void joinAsUser(int userId) {
    if (isConnected.value) {
      socket.emit('user:join', userId);
    }
  }

  // Send a message
  void sendMessage(int chatId, int senderId, String content) {
    if (isConnected.value) {
      socket.emit('message:send', {
        'chatId': chatId,
        'senderId': senderId,
        'content': content,
      });
    }
  }

  // Start typing indicator
  void startTyping(int chatId, int userId) {
    if (isConnected.value) {
      socket.emit('typing:start', {'chatId': chatId, 'userId': userId});
    }
  }

  // Stop typing indicator
  void stopTyping(int chatId, int userId) {
    if (isConnected.value) {
      socket.emit('typing:stop', {'chatId': chatId, 'userId': userId});
    }
  }

  // Listen for new messages
  void onMessage(Function(dynamic) callback) {
    socket.on('message', (data) {
      callback(data);
    });
  }

  // Listen for typing indicators
  void onTyping(Function(dynamic) callback) {
    socket.on('typing', (data) {
      callback(data);
    });
  }

  // Listen for user status changes
  void onUserStatusChange(Function(dynamic) callback) {
    socket.on('user', (data) {
      callback(data);
    });
  }

  // Disconnect socket
  void disconnect() {
    socket.disconnect();
  }
}
