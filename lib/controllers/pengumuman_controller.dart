import 'package:al_falah_app/services/firebase_service.dart';

class PengumumanController {
  // ==================== CRUD PENGUMUMAN ====================
  static Future<List<Map<String, dynamic>>> ambilSemuaPengumuman() async {
    try {
      return await FirebaseService.ambilSemuaPengumuman();
    } catch (e) {
      print('Error ambil pengumuman: $e');
      return [];
    }
  }

  static Future<bool> tambahPengumuman({
    required String judul,
    required String isi,
  }) async {
    try {
      await FirebaseService.tambahPengumuman(judul: judul, isi: isi);
      return true;
    } catch (e) {
      print('Error tambah pengumuman: $e');
      return false;
    }
  }

  static Future<bool> updatePengumuman(
    String idPengumuman, {
    required String judul,
    required String isi,
  }) async {
    try {
      await FirebaseService.updatePengumuman(
        idPengumuman,
        judul: judul,
        isi: isi,
      );
      return true;
    } catch (e) {
      print('Error update pengumuman: $e');
      return false;
    }
  }

  static Future<bool> hapusPengumuman(String idPengumuman) async {
    try {
      await FirebaseService.hapusPengumuman(idPengumuman);
      return true;
    } catch (e) {
      print('Error hapus pengumuman: $e');
      return false;
    }
  }
}
