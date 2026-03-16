import 'package:shared_preferences/shared_preferences.dart';

class PreferenceHandler {
  static final PreferenceHandler _instance = PreferenceHandler._internal();
  late SharedPreferences _preferences;

  factory PreferenceHandler() => _instance;
  PreferenceHandler._internal();

  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  // Key untuk nyimpen data
  static const String _isLogin = 'isLogin';
  static const String _idUser = 'idUser';
  static const String _role = 'role'; // 'admin' atau 'asisten'

  // CREATE / UPDATE: Simpan Sesi Pas Login Sukses
  Future<void> saveUserSession(bool isLogin, int idUser, String role) async {
    await _preferences.setBool(_isLogin, isLogin);
    await _preferences.setInt(_idUser, idUser);
    await _preferences.setString(_role, role);
  }

  // GET: Ambil Status Login
  Future<bool?> getIsLogin() async {
    return _preferences.getBool(_isLogin);
  }

  // GET: Ambil ID User (Buat asisten pas mau bikin jadwal/absen)
  Future<int?> getIdUser() async {
    return _preferences.getInt(_idUser);
  }

  // GET: Ambil Role (Buat nentuin arah ke Beranda Admin / Asisten)
  Future<String?> getRole() async {
    return _preferences.getString(_role);
  }

  // DELETE: Hapus Sesi Pas Logout
  Future<void> logout() async {
    await _preferences.remove(_isLogin);
    await _preferences.remove(_idUser);
    await _preferences.remove(_role);
  }
}
