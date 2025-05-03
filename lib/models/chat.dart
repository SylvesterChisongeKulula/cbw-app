// lib/models/chat.dart
import 'user.dart';
import 'message.dart';

class Chat {
  final int id;
  final int user1Id;
  final int user2Id;
  final User? otherUser;
  final Message? lastMessage;
  final int unreadCount;
  final DateTime createdAt;

  Chat({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    this.otherUser,
    this.lastMessage,
    this.unreadCount = 0,
    required this.createdAt,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      id: json['id'],
      user1Id: json['user1Id'],
      user2Id: json['user2Id'],
      otherUser: json['otherUser'] != null ? User.fromJson(json['otherUser']) : null,
      lastMessage: json['latestMessage'] != null ? Message.fromJson(json['latestMessage']) : null,
      unreadCount: json['unreadCount'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user1Id': user1Id,
      'user2Id': user2Id,
      'otherUser': otherUser?.toJson(),
      'lastMessage': lastMessage?.toJson(),
      'unreadCount': unreadCount,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}