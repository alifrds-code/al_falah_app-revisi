import 'package:al_falah_app/models/model_jadwal.dart';
import 'package:al_falah_app/models/model_absensi.dart';
import 'package:al_falah_app/services/firebase_service.dart';

class AsistenController {
  // ==================== CRUD JADWAL ====================
  static Future<List<JadwalModel>> ambilJadwalByAsisten(
    String uidAsisten,
  ) async {
    try {
      final dataJadwal = await FirebaseService.ambilJadwalByAsisten(uidAsisten);
      return dataJadwal.map((data) => JadwalModel.fromMap(data)).toList();
    } catch (e) {
      print('Error ambil jadwal: $e');
      return [];
    }
  }

  static Future<bool> tambahJadwal({
    required String idKelas,
    required DateTime tanggal,
    required String tema,
    String? deskripsi,
  }) async {
    try {
      await FirebaseService.tambahJadwal(
        idKelas: idKelas,
        tanggal: tanggal,
        tema: tema,
        deskripsi: deskripsi,
      );
      return true;
    } catch (e) {
      print('Error tambah jadwal: $e');
      return false;
    }
  }

  static Future<bool> updateJadwal(
    String idJadwal, {
    required String idKelas,
    required DateTime tanggal,
    required String tema,
    String? deskripsi,
  }) async {
    try {
      await FirebaseService.updateJadwal(
        idJadwal,
        idKelas: idKelas,
        tanggal: tanggal,
        tema: tema,
        deskripsi: deskripsi,
      );
      return true;
    } catch (e) {
      print('Error update jadwal: $e');
      return false;
    }
  }

  static Future<bool> hapusJadwal(String idJadwal) async {
    try {
      await FirebaseService.hapusJadwal(idJadwal);
      return true;
    } catch (e) {
      print('Error hapus jadwal: $e');
      return false;
    }
  }

  // ==================== ABSENSI ====================
  static Future<List<AbsensiModel>> ambilAbsensiByJadwal(
    String idJadwal,
  ) async {
    try {
      final dataAbsensi = await FirebaseService.ambilAbsensiByJadwal(idJadwal);
      return dataAbsensi.map((data) => AbsensiModel.fromMap(data)).toList();
    } catch (e) {
      print('Error ambil absensi: $e');
      return [];
    }
  }

  static Future<bool> simpanAbsensi({
    required String idJadwal,
    required String idJamaah,
    required String statusAbsen,
    String? catatan,
  }) async {
    try {
      await FirebaseService.simpanAbsensi(
        idJadwal: idJadwal,
        idJamaah: idJamaah,
        statusAbsen: statusAbsen,
        catatan: catatan,
      );
      return true;
    } catch (e) {
      print('Error simpan absensi: $e');
      return false;
    }
  }

  // ==================== UTILITY ====================
  static Future<List<Map<String, dynamic>>> ambilJamaahByKelas(
    String idKelas,
  ) async {
    try {
      return await FirebaseService.ambilJamaahByKelas(idKelas);
    } catch (e) {
      print('Error ambil jamaah by kelas: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> ambilKelasByAsisten(
    String uidAsisten,
  ) async {
    try {
      return await FirebaseService.ambilKelasByAsisten(uidAsisten);
    } catch (e) {
      print('Error ambil kelas by asisten: $e');
      return [];
    }
  }
}
