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
  static const String _uid = 'uid';
  static const String _role = 'role'; // 'admin' atau 'asisten'
  static const String _nama = 'nama';
  static const String _email = 'email';
  static const String _isOnboardingDone = 'isOnboardingDone';
  static const String _kelasJamaah = 'kelasJamaah';
  // CREATE / UPDATE: Simpan Sesi Pas Login Sukses
  Future<void> saveUserSession(bool isLogin, String uid, String role, String nama, String email) async {
    await _preferences.setBool(_isLogin, isLogin);
    await _preferences.setString(_uid, uid);
    await _preferences.setString(_role, role);
    await _preferences.setString(_nama, nama);
    await _preferences.setString(_email, email);
  }

  // GET: Ambil Status Login
  Future<bool?> getIsLogin() async {
    return _preferences.getBool(_isLogin);
  }

  // GET: Ambil ID User (Buat asisten pas mau bikin jadwal/absen)
  Future<String?> getUid() async {
    return _preferences.getString(_uid);
  }

  // GET: Ambil Role (Buat nentuin arah ke Beranda Admin / Asisten)
  Future<String?> getRole() async {
    return _preferences.getString(_role);
  }

  Future<String?> getNama() async {
    return _preferences.getString(_nama);
  }

  Future<String?> getEmail() async {
    return _preferences.getString(_email);
  }

  // DELETE: Hapus Sesi Pas Logout
  Future<void> logout() async {
    await _preferences.remove(_isLogin);
    await _preferences.remove(_uid);
    await _preferences.remove(_role);
    await _preferences.remove(_nama);
    await _preferences.remove(_email);
  }

  // ==================== JAMAAH (PUBLIK) ====================
  // Simpan preferensi pilihan kelas jamaah
  Future<void> saveKelasJamaah(List<String> idKelas) async {
    await _preferences.setStringList(_kelasJamaah, idKelas);
    await _preferences.setBool(_isOnboardingDone, true);
  }

  // Ambil daftar kelas yang dipilih jamaah
  Future<List<String>> getKelasJamaah() async {
    return _preferences.getStringList(_kelasJamaah) ?? [];
  }

  // Cek apakah orientasi/onboarding pilih kelas sudah pernah dilakukan
  Future<bool> getIsOnboardingDone() async {
    return _preferences.getBool(_isOnboardingDone) ?? false;
  }
}
