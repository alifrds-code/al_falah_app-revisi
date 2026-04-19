import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/model_user.dart';

class LocalStorageService {
  static const String _keyUser = 'auth_user';
  static const String _keyIsFirstTime = 'is_first_time';
  static const String _keySelectedClasses = 'selected_class_ids';

  // --- Session Management ---
  static Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUser, jsonEncode(user.toMap()));
  }

  static Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(_keyUser);
    if (userStr != null) {
      return UserModel.fromMap(jsonDecode(userStr));
    }
    return null;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUser);
  }

  // --- Onboarding Management ---
  static Future<bool> isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsFirstTime) ?? true;
  }

  static Future<void> setNotFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsFirstTime, false);
  }

  // --- Jamaah Preferences ---
  static Future<void> saveSelectedClasses(List<int> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keySelectedClasses, ids.map((e) => e.toString()).toList());
  }

  static Future<List<int>> getSelectedClasses() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keySelectedClasses) ?? [];
    return list.map((e) => int.parse(e)).toList();
  }
}
