// lib/services/socket_service.dart
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../utils/constants.dart';

class SocketService extends GetxService {
  late IO.Socket socket;
  final RxBool isConnected = false.obs;
  int? _userId;

  // Initialize and connect to socket
  Future<SocketService> init(int userId) async {
    _userId = userId;
    _connectSocket(userId);
    return this;
  }

  void _connectSocket(int userId) {
    socket = IO.io(ApiConstants.socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'reconnection': true,
      'reconnectionAttempts': 10,
      'reconnectionDelay': 1000,
      'reconnectionDelayMax': 5000,
      'timeout': 20000,
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
      // Try to reconnect
      Future.delayed(Duration(seconds: 3), () {
        if (!isConnected.value) {
          print('Attempting to reconnect socket...');
          socket.connect();
        }
      });
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
      socket.emit('message:send', {'chatId': chatId, 'content': content});
    }
  }

  // Start typing indicator
  void startTyping(int chatId, int userId) {
    if (isConnected.value) {
      socket.emit('typing:start', {'chatId': chatId});
    }
  }

  // Stop typing indicator
  void stopTyping(int chatId, int userId) {
    if (isConnected.value) {
      socket.emit('typing:stop', {'chatId': chatId});
    }
  }

  // Listen for new messages
  void onMessage(Function(dynamic) callback) {
    socket.off('message:new');
    socket.on('message:new', (data) {
      print('Socket received new message: $data');
      callback(data);
    });
  }

  // Listen for message sent
  void onMessageSent(Function(dynamic) callback) {
    socket.off('message:sent');
    socket.on('message:sent', callback);
  }

  // Listen for chat updates
  void onChatUpdated(Function(dynamic) callback) {
    socket.off('chat:updated');
    socket.on('chat:updated', callback);
  }

  // Listen for user online
  void onUserOnline(Function(dynamic) callback) {
    socket.off('user:online');
    socket.on('user:online', callback);
  }

  // Listen for user offline
  void onUserOffline(Function(dynamic) callback) {
    socket.off('user:offline');
    socket.on('user:offline', callback);
  }

  // Listen for error events
  void onErrorEvent(Function(dynamic) callback) {
    socket.off('error');
    socket.on('error', callback);
  }

  // Listen for typing events (start/stop)
  void onTyping(Function(dynamic) callback) {
    socket.off('typing:start');
    socket.on('typing:start', (data) {
      data['typing'] = true;
      callback(data);
    });
    socket.off('typing:stop');
    socket.on('typing:stop', (data) {
      data['typing'] = false;
      callback(data);
    });
  }

  // Disconnect socket
  void disconnect() {
    if (_userId != null && isConnected.value) {
      socket.emit('user:leave', _userId);
    }
    socket.disconnect();
  }
}
