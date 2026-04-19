import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/model_user.dart';

// ini buat nyimpen-nyimpen data kecil di memori HP, kayak session login dsb
class LocalStorageService {
  static const String _keyUser = 'auth_user';
  static const String _keyIsFirstTime = 'is_first_time';
  static const String _keySelectedClasses = 'selected_class_ids';

  // buat nyimpen data user pas berhasil login
  static Future<void> saveUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUser, jsonEncode(user.toMap()));
  }

  // buat ambil data user yang lagi login sekarang
  static Future<UserModel?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(_keyUser);
    if (userStr != null) {
      return UserModel.fromMap(jsonDecode(userStr));
    }
    return null;
  }

  // buat hapus session pas user milih logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUser);
  }

  // buat ngecek ini orang baru pertama kali buka aplikasi apa bukan
  static Future<bool> isFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsFirstTime) ?? true;
  }

  // kalo udah lewat onboarding, tandain biar gak muncul lagi
  static Future<void> setNotFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsFirstTime, false);
  }

  // buat jamaah simpen daftar kelas yang mereka mau ikutin
  static Future<void> saveSelectedClasses(List<int> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keySelectedClasses, ids.map((e) => e.toString()).toList());
  }

  // ambil ID kelas-kelas yang dipilih jamaah tadi
  static Future<List<int>> getSelectedClasses() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_keySelectedClasses) ?? [];
    return list.map((e) => int.parse(e)).toList();
  }
}
