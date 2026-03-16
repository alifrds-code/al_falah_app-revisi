import 'package:al_falah_app/database/sqflite_helper.dart';
import 'package:al_falah_app/models/model_jamaah.dart';
import 'package:sqflite/sqflite.dart';

class JamaahController {
  // 1. CREATE: Tambah Jamaah Baru
  static Future<void> tambahJamaah(JamaahModel jamaah) async {
    final dbs = await DBHelper.db();
    await dbs.insert('tb_jamaah', jamaah.toMap());
    print("Berhasil tambah jamaah: ${jamaah.namaLengkap}");
  }

  // 2. READ: Tampilkan Semua Jamaah + Nama Kelasnya
  static Future<List<Map<String, dynamic>>> getSemuaJamaah() async {
    final dbs = await DBHelper.db();

    final String sql = '''
      SELECT 
        tb_jamaah.*, 
        tb_kelas.nama_kelas 
      FROM tb_jamaah
      LEFT JOIN tb_kelas ON tb_jamaah.id_kelas = tb_kelas.id_kelas
    ''';

    return await dbs.rawQuery(sql);
  }

  // 3. UPDATE: Edit Biodata Jamaah
  static Future<int> updateJamaah(JamaahModel jamaah) async {
    final dbs = await DBHelper.db();
    return dbs.update(
      'tb_jamaah',
      jamaah.toMap(),
      where: 'id_jamaah = ?',
      whereArgs: [jamaah.idJamaah],
    );
  }

  // 4. DELETE: Hapus Jamaah
  static Future<int> hapusJamaah(int idJamaah) async {
    final dbs = await DBHelper.db();
    return dbs.delete(
      'tb_jamaah',
      where: 'id_jamaah = ?',
      whereArgs: [idJamaah],
    );
  }

  // 5. READ KHUSUS: Tarik Jamaah berdasarkan ID Kelas
  static Future<List<Map<String, dynamic>>> getJamaahBerdasarkanKelas(
    int idKelas,
  ) async {
    final dbs = await DBHelper.db();
    return await dbs.query(
      'tb_jamaah',
      where: 'id_kelas = ?',
      whereArgs: [idKelas],
    );
  }

  // FUNGSI BARU: Keluarkan Jamaah dari Kelas (Set id_kelas jadi null)
  static Future<void> keluarkanDariKelas(int idJamaah) async {
    final dbs = await DBHelper.db();
    await dbs.update(
      'tb_jamaah',
      {'id_kelas': null},
      where: 'id_jamaah = ?',
      whereArgs: [idJamaah],
    );
  }

  // FUNGSI BARU 1: Ambil daftar jamaah yang id_kelas-nya kosong (Nganggur)
  static Future<List<Map<String, dynamic>>> getJamaahTanpaKelas() async {
    final dbs = await DBHelper.db();
    return await dbs.query(
      'tb_jamaah',
      where: 'id_kelas IS NULL', // Cuma narik yang belum punya kelas
    );
  }

  // FUNGSI BARU 2: Update id_kelas jamaah buat dimasukin ke kelas
  static Future<void> assignKelas(int idJamaah, int idKelas) async {
    final dbs = await DBHelper.db();
    await dbs.update(
      'tb_jamaah',
      {'id_kelas': idKelas},
      where: 'id_jamaah = ?',
      whereArgs: [idJamaah],
    );
  }

  // FUNGSI BARU: Hitung Total Jamaah buat Dashboard
  static Future<int> getHitungTotalJamaah() async {
    final dbs = await DBHelper.db();
    final result = await dbs.rawQuery('SELECT COUNT(*) FROM tb_jamaah');
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
