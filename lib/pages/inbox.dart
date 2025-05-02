import 'package:flutter/material.dart';

class ChatDetailScreen extends StatelessWidget {
  const ChatDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Chat messages area
            Expanded(
              child: _buildChatMessages(),
            ),
            
            // Message input field
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 1.0,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile image
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage("https://placehold.co/40x40"),
          ),
          SizedBox(width: 12),
          
          // Name and status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Mary Doe',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Active',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          
          // Close button
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {},
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildChatMessages() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListView(
        reverse: true, // To show latest messages at the bottom
        children: [
          SizedBox(height: 16), // Space at the top (bottom when reversed)
          
          // User message (left aligned)
          _buildUserMessage("Am fine thanks and you ?"),
          SizedBox(height: 16),
          
          // Their message (right aligned)
          _buildTheirMessage("Hi, How have you being ?"),
          
          // Add more messages here
        ],
      ),
    );
  }
  
  Widget _buildUserMessage(String message) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          constraints: BoxConstraints(maxWidth: 260),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Color(0xFFF1EFEF),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            message,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildTheirMessage(String message) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          constraints: BoxConstraints(maxWidth: 260),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Color(0xFFF2EFEF),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            message,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildMessageInput() {
    return Container(
      padding: EdgeInsets.all(16.0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: Color(0xFFF2EFEF),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Type A Message',
                  hintStyle: TextStyle(
                    color: Colors.black54,
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.attach_file,
                size: 20,
                color: Colors.black54,
              ),
              onPressed: () {},
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
            ),
            SizedBox(width: 8),
            IconButton(
              icon: Icon(
                Icons.camera_alt,
                size: 20,
                color: Colors.black54,
              ),
              onPressed: () {},
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }
}