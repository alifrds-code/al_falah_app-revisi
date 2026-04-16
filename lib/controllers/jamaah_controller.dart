import 'package:al_falah_app/database/sqflite_helper.dart';
import 'package:al_falah_app/models/model_jamaah.dart';
import 'package:al_falah_app/services/firebase_service.dart';
import 'package:sqflite/sqflite.dart';

class JamaahController {
  // 1. CREATE: Tambah Jamaah Baru
  static Future<void> tambahJamaah(JamaahModel jamaah) async {
    final dbs = await DBHelper.db();
    final idJamaah = await dbs.insert('tb_jamaah', jamaah.toMap());

    await _sinkronJamaahKeFirebase({
      ...jamaah.toMap(),
      'id_jamaah': idJamaah,
    });

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
    final result = await dbs.update(
      'tb_jamaah',
      jamaah.toMap(),
      where: 'id_jamaah = ?',
      whereArgs: [jamaah.idJamaah],
    );

    if (result > 0) {
      await _sinkronJamaahKeFirebase(jamaah.toMap());
    }

    return result;
  }

  // 4. DELETE: Hapus Jamaah
  static Future<int> hapusJamaah(int idJamaah) async {
    final dbs = await DBHelper.db();
    final result = await dbs.delete(
      'tb_jamaah',
      where: 'id_jamaah = ?',
      whereArgs: [idJamaah],
    );

    if (result > 0) {
      await _hapusJamaahFirebase(idJamaah);
    }

    return result;
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

    await _sinkronSebagianJamaahKeFirebase(idJamaah, {'id_kelas': null});
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

    await _sinkronSebagianJamaahKeFirebase(idJamaah, {'id_kelas': idKelas});
  }

  // FUNGSI BARU: Hitung Total Jamaah buat Dashboard
  static Future<int> getHitungTotalJamaah() async {
    final dbs = await DBHelper.db();
    final result = await dbs.rawQuery('SELECT COUNT(*) FROM tb_jamaah');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  static Future<void> _sinkronJamaahKeFirebase(Map<String, dynamic> data) async {
    final idJamaah = data['id_jamaah'];
    if (idJamaah == null) return;

    try {
      await FirebaseService.sinkronDokumen(
        collection: FirebaseService.koleksiSyncJamaah,
        documentId: 'jamaah_$idJamaah',
        data: data,
      );
    } catch (e) {
      print('Sinkron jamaah ke Firebase gagal (diabaikan): $e');
    }
  }

  static Future<void> _sinkronSebagianJamaahKeFirebase(
    int idJamaah,
    Map<String, dynamic> data,
  ) async {
    try {
      await FirebaseService.sinkronDokumen(
        collection: FirebaseService.koleksiSyncJamaah,
        documentId: 'jamaah_$idJamaah',
        data: {
          'id_jamaah': idJamaah,
          ...data,
        },
      );
    } catch (e) {
      print('Sinkron sebagian data jamaah ke Firebase gagal (diabaikan): $e');
    }
  }

  static Future<void> _hapusJamaahFirebase(int idJamaah) async {
    try {
      await FirebaseService.hapusDokumen(
        collection: FirebaseService.koleksiSyncJamaah,
        documentId: 'jamaah_$idJamaah',
      );
    } catch (e) {
      print('Hapus jamaah di Firebase gagal (diabaikan): $e');
    }
  }
}
