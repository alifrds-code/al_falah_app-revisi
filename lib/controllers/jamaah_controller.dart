import '../database/sqflite_helper.dart';
import '../models/model_jadwal.dart';
import '../models/model_pengumuman.dart';
import '../models/model_acara.dart';
import '../services/local_storage_service.dart';

// ini controller buat layar jamaah yang biasa, yang gak butuh login
class JamaahController {
  // buat ambil ID kelas apa aja yang udah dipilih jamaah di HP-nya
  Future<List<int>> getSelectedClassIds() async {
    return await LocalStorageService.getSelectedClasses();
  }

  // buat ambil semua jadwal kajian buat kelas yang dipili jamaah
  Future<List<JadwalModel>> getMySchedules() async {
    final ids = await LocalStorageService.getSelectedClasses();
    final db = await DBHelper.db();
    
    List<Map<String, dynamic>> data;
    if (ids.isEmpty) {
      // kalo belum pilih kelas, ya udah gue tampilin semua aja deh
      data = await db.rawQuery('''
        SELECT j.*, k.nama_kelas 
        FROM tb_jadwal j 
        JOIN tb_kelas k ON j.id_kelas = k.id_kelas 
        ORDER BY j.tanggal ASC, j.waktu_mulai ASC
      ''');
    } else {
      // kalo udah pilih, gue filter jadwalnya biar sesuai pilihan jamaah
      String placeholders = List.filled(ids.length, '?').join(',');
      data = await db.rawQuery('''
        SELECT j.*, k.nama_kelas 
        FROM tb_jadwal j 
        JOIN tb_kelas k ON j.id_kelas = k.id_kelas 
        WHERE j.id_kelas IN ($placeholders)
        ORDER BY j.tanggal ASC, j.waktu_mulai ASC
      ''', ids);
    }
    
    return data.map((e) => JadwalModel.fromMap(e)).toList();
  }

  // buat ambil jadwal khusus hari ini aja buat dipajang di depan
  Future<List<JadwalModel>> getTodayHighlights() async {
    final ids = await LocalStorageService.getSelectedClasses();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final db = await DBHelper.db();

    List<Map<String, dynamic>> data;
    if (ids.isEmpty) {
      data = await db.rawQuery('''
        SELECT j.*, k.nama_kelas 
        FROM tb_jadwal j 
        JOIN tb_kelas k ON j.id_kelas = k.id_kelas 
        WHERE j.tanggal = ?
        ORDER BY j.waktu_mulai ASC
      ''', [today]);
    } else {
      String placeholders = List.filled(ids.length, '?').join(',');
      data = await db.rawQuery('''
        SELECT j.*, k.nama_kelas 
        FROM tb_jadwal j 
        JOIN tb_kelas k ON j.id_kelas = k.id_kelas 
        WHERE j.tanggal = ? AND j.id_kelas IN ($placeholders)
        ORDER BY j.waktu_mulai ASC
      ''', [today, ...ids]);
    }

    return data.map((e) => JadwalModel.fromMap(e)).toList();
  }

  // buat ambil daftar pengumuman biar jamaah gak ketinggalan info
  Future<List<PengumumanModel>> getPengumuman() async {
    final db = await DBHelper.db();
    final data = await db.query('tb_pengumuman', orderBy: 'tanggal_post DESC');
    return data.map((e) => PengumumanModel.fromMap(e)).toList();
  }

  // buat ambil info acara yayasan yang mau diadain
  Future<List<AcaraModel>> getAcara() async {
    final db = await DBHelper.db();
    final data = await db.query('tb_acara', orderBy: 'tanggal_acara ASC');
    return data.map((e) => AcaraModel.fromMap(e)).toList();
  }

  // buat ambil daftar semua kelas biar jamaah bisa milih pas awal buka app
  Future<List<Map<String, dynamic>>> getAllKelas() async {
    final db = await DBHelper.db();
    return await db.query('tb_kelas', orderBy: 'nama_kelas ASC');
  }
}
