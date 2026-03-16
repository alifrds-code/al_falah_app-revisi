import 'package:al_falah_app/database/sqflite_helper.dart';
import 'package:al_falah_app/models/model_user.dart';
import 'package:sqflite/sqflite.dart';

class AdminController {
  // CREATE (Tambah Akun Asisten Baru)

  static Future<void> tambahAsisten(UserModel asisten) async {
    final dbs = await DBHelper.db();

    await dbs.insert('tb_users', asisten.toMap());
    print("Berhasil tambah asisten: ${asisten.toMap()}");
  }

  // READ (Tampilkan Semua Asisten)
  static Future<List<UserModel>> getSemuaAsisten() async {
    final dbs = await DBHelper.db();

    // filter where role = 'asisten'
    // agar Admin tidak ikut muncul di tampilan
    final List<Map<String, dynamic>> results = await dbs.query(
      "tb_users",
      where: "role = ?",
      whereArgs: ['asisten'],
    );

    print("Data asisten ditarik: ${results.length} orang");
    return results.map((e) => UserModel.fromMap(e)).toList();
  }

  // UPDATE (Edit Data Asisten)
  static Future<int> updateAsisten(UserModel asisten) async {
    final dbs = await DBHelper.db();

    if (asisten.idUser == null) {
      throw Exception("ID Wajib ada untuk edit data!");
    }

    int result = await dbs.update(
      'tb_users',
      asisten.toMap(),
      where: 'id_user = ?',
      whereArgs: [asisten.idUser],
    );

    print("Asisten ID ${asisten.idUser} berhasil diupdate");
    return result;
  }

  // DELETE (Hapus Akun Asisten)

  static Future<int> hapusAsisten(int idUser) async {
    final dbs = await DBHelper.db();

    int result = await dbs.delete(
      'tb_users',
      where: 'id_user = ? AND role = ?',
      whereArgs: [idUser, 'asisten'],
    );

    print("Asisten ID $idUser berhasil dihapus");
    return result;
  }

  // FUNGSI BARU: Hitung Total Asisten buat Dashboard
  static Future<int> getHitungTotalAsisten() async {
    final dbs = await DBHelper.db();
    final result = await dbs.rawQuery(
      "SELECT COUNT(*) FROM tb_users WHERE role = 'asisten'",
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
