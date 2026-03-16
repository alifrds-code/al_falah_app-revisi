import 'package:al_falah_app/database/sqflite_helper.dart';
import 'package:al_falah_app/models/model_kelas.dart';
import 'package:sqflite/sqflite.dart';

class KelasController {
  // CREATE: Tambah Kelas Baru (Cuma nama kelasnya aja, asistennya belakangan)
  static Future<void> tambahKelas(KelasModel kelas) async {
    final dbs = await DBHelper.db();
    await dbs.insert('tb_kelas', kelas.toMap());
    print("Berhasil buat kelas: ${kelas.namaKelas}");
  }

  // READ: Tampilkan Semua Kelas + Nama Asisten (Logika LEFT JOIN)
  static Future<List<Map<String, dynamic>>> getDaftarKelasLengkap() async {
    final dbs = await DBHelper.db();

    // PERBAIKAN: Kita SELECT tb_asisten_kelas.id_user as id_asisten
    // Biar form Edit tau ustadz mana yang harus ditampilin di Dropdown!
    final String sql = '''
      SELECT 
        tb_kelas.id_kelas, 
        tb_kelas.nama_kelas, 
        tb_asisten_kelas.id_user AS id_asisten, 
        tb_users.nama AS nama_asisten 
      FROM tb_kelas
      LEFT JOIN tb_asisten_kelas ON tb_kelas.id_kelas = tb_asisten_kelas.id_kelas
      LEFT JOIN tb_users ON tb_asisten_kelas.id_user = tb_users.id_user
    ''';

    final List<Map<String, dynamic>> results = await dbs.rawQuery(sql);
    return results;
  }

  // UPDATE: Edit Nama Kelas & Assign Ustadz ke Tabel Pivot
  static Future<void> updateKelas(KelasModel kelas) async {
    final dbs = await DBHelper.db();

    if (kelas.idKelas == null) return;

    // 1. Update nama kelasnya dulu di tb_kelas
    await dbs.update(
      'tb_kelas',
      kelas.toMap(),
      where: 'id_kelas = ?',
      whereArgs: [kelas.idKelas],
    );

    // 2. Ngurusin Penugasan Ustadz di tb_asisten_kelas
    if (kelas.idAsisten != null) {
      // Cek dulu, kelas ini udah pernah ditugasin ustadz belom?
      final List<Map<String, dynamic>> cekPenugasan = await dbs.query(
        'tb_asisten_kelas',
        where: 'id_kelas = ?',
        whereArgs: [kelas.idKelas],
      );

      if (cekPenugasan.isEmpty) {
        // Kalau belom ada, kita INSERT penugasan baru
        await dbs.insert('tb_asisten_kelas', {
          'id_kelas': kelas.idKelas,
          'id_user': kelas.idAsisten,
        });
        print("Ustadz baru berhasil di-assign ke kelas!");
      } else {
        // Kalau udah ada ustadznya sebelumnya, kita UPDATE (ganti ustadz)
        await dbs.update(
          'tb_asisten_kelas',
          {'id_user': kelas.idAsisten},
          where: 'id_kelas = ?',
          whereArgs: [kelas.idKelas],
        );
        print("Ustadz pengajar berhasil diganti!");
      }
    } else {
      // Kalau idAsisten nya null, berarti kita copot aja ustadznya dari kelas ini tanpa harus hapus kelasnya. Jadi kita DELETE penugasan di tb_asisten_kelas.
      await dbs.delete(
        'tb_asisten_kelas',
        where: 'id_kelas = ?',
        whereArgs: [kelas.idKelas],
      );
      print("Ustadz pengajar berhasil dikosongkan dari kelas!");
    }
  }

  // DELETE: Hapus Kelas (tb_asisten_kelas otomatis kehapus karena ON DELETE CASCADE lu)
  static Future<int> hapusKelas(int idKelas) async {
    final dbs = await DBHelper.db();
    return dbs.delete('tb_kelas', where: 'id_kelas = ?', whereArgs: [idKelas]);
  }

  // FUNGSI BARU: Copot Asisten dari Kelas
  static Future<void> copotAsisten(int idKelas) async {
    final dbs = await DBHelper.db();
    await dbs.delete(
      'tb_asisten_kelas',
      where: 'id_kelas = ?',
      whereArgs: [idKelas],
    );
  }

  // FUNGSI BARU: Hitung Total Kelas buat Dashboard
  static Future<int> getHitungTotalKelas() async {
    final dbs = await DBHelper.db();
    final result = await dbs.rawQuery('SELECT COUNT(*) FROM tb_kelas');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // FUNGSI BARU: Ambil kelas KHUSUS buat Asisten yang lagi login
  static Future<List<Map<String, dynamic>>> getKelasByAsisten(
    int idUserAsisten,
  ) async {
    final dbs = await DBHelper.db();

    // Kita pakai INNER JOIN buat nyari kelas yang cocok sama ID Asisten ini
    final String sql = '''
      SELECT tb_kelas.id_kelas, tb_kelas.nama_kelas 
      FROM tb_kelas
      INNER JOIN tb_asisten_kelas ON tb_kelas.id_kelas = tb_asisten_kelas.id_kelas
      WHERE tb_asisten_kelas.id_user = ?
    ''';

    return await dbs.rawQuery(sql, [idUserAsisten]);
  }
}
