import '../database/sqflite_helper.dart';
import '../models/model_jadwal.dart';
import '../models/model_pengumuman.dart';
import '../models/model_acara.dart';
import '../services/local_storage_service.dart';

// Otak logika untuk layar publik jamaah (tanpa login)
class JamaahController {
  // Ambil id kelas yang dipilih jamaah dari memori HP
  Future<List<int>> getSelectedClassIds() async {
    return await LocalStorageService.getSelectedClasses();
  }

  // Ambil semua jadwal kelas yang dipilih jamaah
  Future<List<JadwalModel>> getMySchedules() async {
    final ids = await LocalStorageService.getSelectedClasses();
    if (ids.isEmpty) {
      // Kalau belum pilih kelas, tampilkan semua jadwal
      final semua = await DBHelper.getJadwalByKelas([]);
      if (semua.isEmpty) return [];
    }
    final data = await DBHelper.getJadwalByKelas(ids.isEmpty ? [] : ids);
    return data.map((e) => JadwalModel.fromMap(e)).toList();
  }

  // Ambil jadwal hari ini saja (untuk highlight di beranda)
  Future<List<JadwalModel>> getTodayHighlights() async {
    final ids = await LocalStorageService.getSelectedClasses();
    final today = DateTime.now().toIso8601String().split('T')[0]; // format: 2026-04-20

    List<Map<String, dynamic>> data;
    if (ids.isEmpty) {
      data = await DBHelper.getJadwalByKelas([]);
    } else {
      data = await DBHelper.getJadwalByKelas(ids);
    }

    // Filter hanya yang tanggalnya hari ini
    final todayList = data.where((j) => (j['tanggal'] as String) == today).toList();
    return todayList.map((e) => JadwalModel.fromMap(e)).toList();
  }

  // Ambil semua pengumuman
  Future<List<PengumumanModel>> getPengumuman() async {
    final data = await DBHelper.getAllPengumuman();
    return data.map((e) => PengumumanModel.fromMap(e)).toList();
  }

  // Ambil semua acara
  Future<List<AcaraModel>> getAcara() async {
    final data = await DBHelper.getAllAcara();
    return data.map((e) => AcaraModel.fromMap(e)).toList();
  }
}
