import 'package:sqflite/sqflite.dart';
import '../database/sqflite_helper.dart';
import '../models/model_jadwal.dart';
import '../models/model_jamaah.dart';

// ini controller khusus asisten, buat ngatur jadwal sama absensi
class AsistenController {
  
  // ambil semua jadwal yang dibikin sama asisten ini
  Future<List<JadwalModel>> getMySchedules(int idUser) async {
    final db = await DBHelper.db();
    final data = await db.rawQuery('''
      SELECT j.*, k.nama_kelas 
      FROM tb_jadwal j 
      JOIN tb_kelas k ON j.id_kelas = k.id_kelas 
      WHERE j.id_user = ?
      ORDER BY j.tanggal DESC
    ''', [idUser]);
    return data.map((e) => JadwalModel.fromMap(e)).toList();
  }

  // buat ambil daftar jamaah di kelas tertentu biar asisten bisa absenin
  Future<List<JamaahModel>> getJamaahForClass(int idKelas) async {
    final db = await DBHelper.db();
    final data = await db.query(
      'tb_jamaah',
      where: 'id_kelas = ? AND status_jamaah = 1',
      whereArgs: [idKelas],
      orderBy: 'nama_lengkap ASC',
    );
    return data.map((e) => JamaahModel.fromMap(e)).toList();
  }

  // buat bikin jadwal kajian/ta'lim baru
  Future<void> createSchedule(JadwalModel jadwal) async {
    final db = await DBHelper.db();
    final data = jadwal.toMap();
    data.remove('id_jadwal');
    await db.insert('tb_jadwal', data);
  }

  // buat edit jadwal yang udah ada (misal ganti jam atau materi)
  Future<void> updateSchedule(JadwalModel jadwal) async {
    final db = await DBHelper.db();
    final data = jadwal.toMap();
    data.remove('id_jadwal');
    data.remove('nama_kelas');
    await db.update('tb_jadwal', data, where: 'id_jadwal = ?', whereArgs: [jadwal.idJadwal]);
  }

  // buat hapus jadwal kalo emang gak jadi
  Future<void> deleteSchedule(int idJadwal) async {
    final db = await DBHelper.db();
    await db.delete('tb_jadwal', where: 'id_jadwal = ?', whereArgs: [idJadwal]);
  }

  // buat ganti status jadwal, misal jadi ditunda atau dibatalin (ada alasannya juga)
  Future<void> updateScheduleStatus(int idJadwal, String status, String? alasan) async {
    final db = await DBHelper.db();
    await db.update(
      'tb_jadwal',
      {
        'status_jadwal': status,
        'alasan_perubahan': alasan,
      },
      where: 'id_jadwal = ?',
      whereArgs: [idJadwal],
    );
  }

  // buat simpen data absen jamaah sekaligus banyak biar gak capek
  Future<void> saveAttendance(int idJadwal, List<Map<String, dynamic>> batch) async {
    final db = await DBHelper.db();
    await db.transaction((txn) async {
      for (var item in batch) {
        await txn.insert(
          'tb_absensi',
          {
            'id_jadwal': idJadwal,
            'id_jamaah': item['id_jamaah'],
            'status_hadir': item['status_hadir'],
            'waktu_absen': DateTime.now().toIso8601String(),
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  // buat ambil data absen yang udah pernah diinput buat jadwal itu
  Future<List<Map<String, dynamic>>> getAttendanceRecords(int idJadwal) async {
    final db = await DBHelper.db();
    return await db.query('tb_absensi', where: 'id_jadwal = ?', whereArgs: [idJadwal]);
  }
}
