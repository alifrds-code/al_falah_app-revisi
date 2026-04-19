import '../database/sqflite_helper.dart';
import '../models/model_jadwal.dart';
import '../models/model_jamaah.dart';

// Otak logika khusus Asisten: kelola jadwal dan absensi
class AsistenController {
  // Ambil semua jadwal yang dibuat oleh asisten ini
  Future<List<JadwalModel>> getMySchedules(int idUser) async {
    final data = await DBHelper.getJadwalByAsisten(idUser);
    return data.map((e) => JadwalModel.fromMap(e)).toList();
  }

  // Ambil daftar jamaah di kelas tertentu untuk absensi
  Future<List<JamaahModel>> getJamaahForClass(int idKelas) async {
    final data = await DBHelper.getJamaahByKelas(idKelas);
    return data.map((e) => JamaahModel.fromMap(e)).toList();
  }

  // Buat jadwal baru
  Future<void> createSchedule(JadwalModel jadwal) async {
    await DBHelper.insertJadwal(jadwal.toMap());
  }

  // Edit jadwal (ubah tanggal, jam, materi)
  Future<void> updateSchedule(JadwalModel jadwal) async {
    await DBHelper.updateJadwal(jadwal.idJadwal!, jadwal.toMap());
  }

  // Hapus jadwal
  Future<void> deleteSchedule(int idJadwal) async {
    await DBHelper.deleteJadwal(idJadwal);
  }

  // Ubah status jadwal jadi Ditunda atau Dibatalkan
  Future<void> updateScheduleStatus(int idJadwal, String status, String? alasan) async {
    await DBHelper.updateStatusJadwal(idJadwal, status, alasan);
  }

  // Simpan absensi batch (sekaligus banyak jamaah)
  Future<void> saveAttendance(int idJadwal, List<Map<String, dynamic>> batch) async {
    await DBHelper.recordAbsen(idJadwal, batch);
  }

  // Ambil catatan absensi yang sudah ada untuk jadwal tertentu
  Future<List<Map<String, dynamic>>> getAttendanceRecords(int idJadwal) async {
    return await DBHelper.getAbsensiByJadwal(idJadwal);
  }
}
