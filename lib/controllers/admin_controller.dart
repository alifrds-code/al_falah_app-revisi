import 'package:al_falah_app/database/sqflite_helper.dart';
import 'package:al_falah_app/models/model_user.dart';
import 'package:al_falah_app/services/firebase_service.dart';
import 'package:sqflite/sqflite.dart';

class AdminController {
  // CREATE (Tambah Akun Asisten Baru)
  static Future<void> tambahAsisten(UserModel asisten) async {
    final dbs = await DBHelper.db();

    final idUser = await dbs.insert('tb_users', asisten.toMap());

    await _sinkronUserKeFirebase({
      ...asisten.toMap(),
      'id_user': idUser,
    });

    print("Berhasil tambah asisten: ${asisten.toMap()}");
  }

  // READ (Tampilkan Semua Asisten)
  static Future<List<UserModel>> getSemuaAsisten() async {
    final dbs = await DBHelper.db();

    // filter where role = 'asisten'
    // agar Admin tidak ikut muncul di tampilan
    final List<Map<String, dynamic>> results = await dbs.query(
      'tb_users',
      where: 'role = ?',
      whereArgs: ['asisten'],
    );

    print("Data asisten ditarik: ${results.length} orang");
    return results.map((e) => UserModel.fromMap(e)).toList();
  }

  // UPDATE (Edit Data Asisten)
  static Future<int> updateAsisten(UserModel asisten) async {
    final dbs = await DBHelper.db();

    if (asisten.idUser == null) {
      throw Exception('ID Wajib ada untuk edit data!');
    }

    final result = await dbs.update(
      'tb_users',
      asisten.toMap(),
      where: 'id_user = ?',
      whereArgs: [asisten.idUser],
    );

    if (result > 0) {
      await _sinkronUserKeFirebase(asisten.toMap());
    }

    print("Asisten ID ${asisten.idUser} berhasil diupdate");
    return result;
  }

  // DELETE (Hapus Akun Asisten)
  static Future<int> hapusAsisten(int idUser) async {
    final dbs = await DBHelper.db();

    final result = await dbs.delete(
      'tb_users',
      where: 'id_user = ? AND role = ?',
      whereArgs: [idUser, 'asisten'],
    );

    if (result > 0) {
      await _hapusUserFirebase(idUser);
    }

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

  static Future<void> _sinkronUserKeFirebase(Map<String, dynamic> data) async {
    final idUser = data['id_user'];
    if (idUser == null) return;

    try {
      await FirebaseService.sinkronDokumen(
        collection: FirebaseService.koleksiSyncUsers,
        documentId: 'user_$idUser',
        data: data,
      );
    } catch (e) {
      print('Sinkron user ke Firebase gagal (diabaikan): $e');
    }
  }

  static Future<void> _hapusUserFirebase(int idUser) async {
    try {
      await FirebaseService.hapusDokumen(
        collection: FirebaseService.koleksiSyncUsers,
        documentId: 'user_$idUser',
      );
    } catch (e) {
      print('Hapus user Firebase gagal (diabaikan): $e');
    }
  }
}
