import '../database/sqflite_helper.dart';
import '../services/local_storage_service.dart';
import '../models/model_user.dart';

// ini kelas buat ngurusin orang yang mau login ke aplikasi
class LoginController {
  
  // fungsi buat ngecek email sama password di database, kalo bener ya login
  Future<UserModel?> login(String email, String password) async {
    final db = await DBHelper.db();
    final res = await db.query(
      'tb_users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    
    if (res.isNotEmpty) {
      // kalo ketemu datanya, kita simpen ke memori HP biar gampang dipanggil
      final user = UserModel.fromMap(res.first);
      await LocalStorageService.saveUser(user);
      return user;
    }
    // kalo gak ketemu, ya udah balikin kosong aja (null)
    return null;
  }

  // buat user yang mau keluar dari aplikasi
  Future<void> logout() async {
    await LocalStorageService.logout();
  }

  // buat ambil data orang yang lagi login sekarang, gak usah login ulang
  Future<UserModel?> getCurrentUser() async {
    return await LocalStorageService.getUser();
  }
}
