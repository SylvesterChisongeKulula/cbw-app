// lib/widgets/chat_item.dart
import 'package:flutter/material.dart';
import '../models/chat.dart';
import '../utils/date_formatter.dart';
import '../routes/app_routes.dart';
import 'package:get/get.dart';

class ChatItem extends StatelessWidget {
  final Chat chat;
  final int currentUserId;
  
  const ChatItem({
    Key? key,
    required this.chat,
    required this.currentUserId,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final otherUser = chat.otherUser;
    final lastMessage = chat.lastMessage;
    
    if (otherUser == null) {
      return SizedBox.shrink();
    }
    
    return InkWell(
      onTap: () => Get.toNamed('${AppRoutes.CHAT_DETAIL}/${chat.id}'),
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
                      if (otherUser.isOnline)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    lastMessage != null
                        ? (lastMessage.senderId == currentUserId
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
                  lastMessage != null
                      ? DateFormatter.getFormattedTime(lastMessage.createdAt)
                      : '',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
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
}
