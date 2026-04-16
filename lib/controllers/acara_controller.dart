import 'package:al_falah_app/services/firebase_service.dart';

class AcaraController {
  // ==================== CRUD ACARA ====================
  static Future<List<Map<String, dynamic>>> ambilSemuaAcara() async {
    try {
      return await FirebaseService.ambilSemuaAcara();
    } catch (e) {
      print('Error ambil acara: $e');
      return [];
    }
  }

  static Future<bool> tambahAcara({
    required String namaAcara,
    required DateTime tanggal,
    required String jam,
    required String lokasi,
    required String deskripsi,
    String? urlPoster,
  }) async {
    try {
      await FirebaseService.tambahAcara(
        namaAcara: namaAcara,
        tanggal: tanggal,
        jam: jam,
        lokasi: lokasi,
        deskripsi: deskripsi,
        urlPoster: urlPoster,
      );
      return true;
    } catch (e) {
      print('Error tambah acara: $e');
      return false;
    }
  }

  static Future<bool> updateAcara(
    String idAcara, {
    required String namaAcara,
    required DateTime tanggal,
    required String jam,
    required String lokasi,
    required String deskripsi,
    String? urlPoster,
  }) async {
    try {
      await FirebaseService.updateAcara(
        idAcara,
        namaAcara: namaAcara,
        tanggal: tanggal,
        jam: jam,
        lokasi: lokasi,
        deskripsi: deskripsi,
        urlPoster: urlPoster,
      );
      return true;
    } catch (e) {
      print('Error update acara: $e');
      return false;
    }
  }

  static Future<bool> hapusAcara(String idAcara) async {
    try {
      await FirebaseService.hapusAcara(idAcara);
      return true;
    } catch (e) {
      print('Error hapus acara: $e');
      return false;
    }
  }
}
