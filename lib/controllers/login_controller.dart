import 'package:al_falah_app/database/sqflite_helper.dart';
import 'package:al_falah_app/models/model_user.dart';
import 'package:al_falah_app/services/local_storage_service.dart';

class LoginController {
  // Fungsi untuk memproses Login
  static Future<UserModel?> loginUser({
    required String email,
    required String password,
  }) async {
    // 1. Buka koneksi ke database
    final dbs = await DBHelper.db();

    // 2. Cari data di tb_users yang email dan password-nya cocok
    final List<Map<String, dynamic>> results = await dbs.query(
      "tb_users",
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    // 3. Cek apakah datanya ketemu (isNotEmpty)
    if (results.isNotEmpty) {
      // 4. Ubah data mentah dari database jadi UserModel yang rapi
      final dataUser = UserModel.fromMap(results.first);

      // Print buat bantu debug di console
      print("Login Sukses: ${dataUser.email} | Role: ${dataUser.role}");

      // 5. Simpan sesi ke memori HP, tidak perlu login terus ketika buka app
      final pref = PreferenceHandler();
      await pref.init();
      await pref.saveUserSession(
        true,
        dataUser.idUser ?? 0, // Kalau idUser null, kasih 0 aja biar gak crash
        dataUser.role,
      );

      // 6. Kembalikan data usernya buat diproses sama UI (Layar Login)
      return dataUser;
    }

    // jika salah email/password, kembalikan null
    print("Login Gagal: Email atau Password salah");
    return null;
  }

  // Fungsi untuk Logout (Keluar)
  static Future<void> logout() async {
    final pref = PreferenceHandler();
    await pref.init();
    await pref.logout();
    print("Berhasil Logout dan hapus sesi");
  }
}
