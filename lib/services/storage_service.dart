// lib/services/storage_service.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class StorageService extends GetxService {
  late SharedPreferences _prefs;
  
  // Keys for SharedPreferences
  static const String userKey = 'current_user';
  
  // Initialize SharedPreferences
  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }
  
  // Save current user
  Future<bool> saveCurrentUser(User user) async {
    return await _prefs.setString(userKey, jsonEncode(user.toJson()));
  }
  
  // Get current user
  User? getCurrentUser() {
    final userStr = _prefs.getString(userKey);
    if (userStr != null) {
      try {
        return User.fromJson(jsonDecode(userStr));
      } catch (e) {
        print('Error parsing user: $e');
        return null;
      }
    }
    return null;
  }
  
  // Clear current user
  Future<bool> clearCurrentUser() async {
    return await _prefs.remove(userKey);
  }
}
