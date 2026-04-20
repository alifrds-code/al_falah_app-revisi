import 'package:al_falah_app/services/firebase_service.dart';

class AsistenController {
  // ==================== CRUD JADWAL ====================
  static Future<List<Map<String, dynamic>>> ambilJadwalByAsistenRaw(
    String uidAsisten,
  ) async {
    try {
      return await FirebaseService.ambilJadwalByAsisten(uidAsisten);
    } catch (e) {
      print('Error ambil jadwal: $e');
      return [];
    }
  }

  static Future<bool> tambahJadwal({
    required String idKelas,
    required String idUser,
    required DateTime tanggal,
    required String waktuMulai,
    required String waktuSelesai,
    String? materiPembahasan,
    String? namaPemateri,
  }) async {
    try {
      await FirebaseService.tambahJadwal(
        idKelas: idKelas,
        idUser: idUser,
        tanggal: tanggal,
        waktuMulai: waktuMulai,
        waktuSelesai: waktuSelesai,
        materiPembahasan: materiPembahasan,
        namaPemateri: namaPemateri,
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
    required String idUser,
    required DateTime tanggal,
    required String waktuMulai,
    required String waktuSelesai,
    String? materiPembahasan,
    String? namaPemateri,
    int statusJadwal = 0,
    String? alasanPerubahan,
  }) async {
    try {
      await FirebaseService.updateJadwal(
        idJadwal,
        idKelas: idKelas,
        idUser: idUser,
        tanggal: tanggal,
        waktuMulai: waktuMulai,
        waktuSelesai: waktuSelesai,
        materiPembahasan: materiPembahasan,
        namaPemateri: namaPemateri,
        statusJadwal: statusJadwal,
        alasanPerubahan: alasanPerubahan,
      );
      return true;
    } catch (e) {
      print('Error update jadwal: $e');
      return false;
    }
  }

  static Future<bool> updateStatusJadwal(
    String idJadwal, {
    required int statusJadwal,
    String? alasanPerubahan,
  }) async {
    try {
      await FirebaseService.updateStatusJadwal(
        idJadwal,
        statusJadwal: statusJadwal,
        alasanPerubahan: alasanPerubahan,
      );
      return true;
    } catch (e) {
      print('Error update status jadwal: $e');
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
  static Future<List<Map<String, dynamic>>> ambilAbsensiByJadwal(
    String idJadwal,
  ) async {
    try {
      return await FirebaseService.ambilAbsensiByJadwal(idJadwal);
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
