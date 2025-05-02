import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'CHAT',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage('https://placehold.co/32x32'),
                  ),
                ],
              ),
            ),
            
            // Chat list
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildChatItem(
                    name: 'Mary Doe',
                    message: 'Wheres my ...',
                    time: '12:00 AM',
                    unreadCount: 3,
                    imageUrl: 'https://placehold.co/80x80',
                  ),
                  _buildChatItem(
                    name: 'John Doe',
                    message: 'You: Okay cool ...',
                    time: '12:00 AM',
                    unreadCount: 3,
                    imageUrl: 'https://placehold.co/80x80',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildChatItem({
    required String name,
    required String message,
    required String time,
    required int unreadCount,
    required String imageUrl,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          // Profile image
          CircleAvatar(
            radius: 30,
            backgroundImage: NetworkImage(imageUrl),
          ),
          SizedBox(width: 16),
          
          // Message details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  message,
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
                time,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
              SizedBox(height: 4),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Color(0xFF6C88D7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  unreadCount.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}