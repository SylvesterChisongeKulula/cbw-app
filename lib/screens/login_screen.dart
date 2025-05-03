// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../models/user.dart';

class LoginScreen extends StatelessWidget {
  final AuthController _authController = Get.find<AuthController>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _displayNameController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40),
              Text(
                'Welcome to CBW Chat',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6C88D7),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Select an existing account or create a new one',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              SizedBox(height: 40),

              // Existing users list
              Obx(() {
                if (_authController.isLoading.value) {
                  return Center(child: CircularProgressIndicator());
                }

                if (_authController.users.isEmpty) {
                  return Center(
                    child: Text('No users found. Create a new account below.'),
                  );
                }

                return Expanded(
                  child: ListView.builder(
                    itemCount: _authController.users.length,
                    itemBuilder: (context, index) {
                      final user = _authController.users[index];
                      return _buildUserItem(user);
                    },
                  ),
                );
              }),

              SizedBox(height: 24),
              Divider(),
              SizedBox(height: 24),

              // Create new user form
              Text(
                'Create New Account',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _displayNameController,
                decoration: InputDecoration(
                  labelText: 'Display Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    if (_usernameController.text.isEmpty ||
                        _displayNameController.text.isEmpty) {
                      Get.snackbar(
                        'Error',
                        'Please enter both username and display name',
                      );
                      return;
                    }

                    _authController.createUser(
                      _usernameController.text.trim(),
                      _displayNameController.text.trim(),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF6C88D7),
                  ),
                  child: Obx(
                    () =>
                        _authController.isLoading.value
                            ? CircularProgressIndicator(color: Colors.white)
                            : Text(
                              'Create Account',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserItem(User user) {
    return ListTile(
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: Color(0xFF6C88D7),
        child: Text(
          user.displayName.substring(0, 1).toUpperCase(),
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      title: Text(
        user.displayName,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text('@${user.username}'),
      onTap: () => _authController.selectUser(user),
    );
  }
}
