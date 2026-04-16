import 'package:al_falah_app/models/model_jadwal.dart';
import 'package:al_falah_app/services/firebase_service.dart';

class JamaahControllerFirebase {
  // ==================== BERANDA JAMAAH ====================
  static Future<List<JadwalModel>> ambilJadwalTerbaru(
    List<String> idKelasDipilih,
  ) async {
    try {
      if (idKelasDipilih.isEmpty) return [];

      final dataJadwal = await FirebaseService.ambilSemuaJadwal();
      final filteredJadwal = dataJadwal
          .where((jadwal) => idKelasDipilih.contains(jadwal['id_kelas']))
          .where((jadwal) => jadwal['status_jadwal'] != 'dibatalkan')
          .take(3)
          .toList();

      return filteredJadwal.map((data) => JadwalModel.fromMap(data)).toList();
    } catch (e) {
      print('Error ambil jadwal terbaru: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> ambilHighlightHariIni(
    List<String> idKelasDipilih,
  ) async {
    try {
      if (idKelasDipilih.isEmpty) return null;

      final today = DateTime.now();
      final todayString = today.toIso8601String().split('T')[0];

      final dataJadwal = await FirebaseService.ambilSemuaJadwal();
      final todayJadwal = dataJadwal
          .where((jadwal) => idKelasDipilih.contains(jadwal['id_kelas']))
          .where((jadwal) => jadwal['tanggal'] == todayString)
          .where((jadwal) => jadwal['status_jadwal'] != 'dibatalkan')
          .toList();

      if (todayJadwal.isNotEmpty) {
        final jadwal = todayJadwal.first;
        final kelasData = await FirebaseService.ambilSemuaKelas();
        final kelas = kelasData.firstWhere(
          (k) => k['id'] == jadwal['id_kelas'],
          orElse: () => <String, dynamic>{},
        );

        return {'jadwal': JadwalModel.fromMap(jadwal), 'kelas': kelas};
      }
      return null;
    } catch (e) {
      print('Error ambil highlight hari ini: $e');
      return null;
    }
  }

  // ==================== JADWAL KELAS SAYA ====================
  static Future<List<Map<String, dynamic>>> ambilSemuaJadwalKelas(
    List<String> idKelasDipilih,
  ) async {
    try {
      if (idKelasDipilih.isEmpty) return [];

      final dataJadwal = await FirebaseService.ambilSemuaJadwal();
      final filteredJadwal = dataJadwal
          .where((jadwal) => idKelasDipilih.contains(jadwal['id_kelas']))
          .toList();

      final dataKelas = await FirebaseService.ambilSemuaKelas();

      List<Map<String, dynamic>> result = [];
      for (var jadwal in filteredJadwal) {
        final kelas = dataKelas.firstWhere(
          (k) => k['id'] == jadwal['id_kelas'],
          orElse: () => <String, dynamic>{},
        );

        result.add({'jadwal': JadwalModel.fromMap(jadwal), 'kelas': kelas});
      }

      return result;
    } catch (e) {
      print('Error ambil semua jadwal kelas: $e');
      return [];
    }
  }

  // ==================== PENGATURAN KELAS ====================
  static Future<List<Map<String, dynamic>>> ambilSemuaKelasUntukPilih() async {
    try {
      return await FirebaseService.ambilSemuaKelas();
    } catch (e) {
      print('Error ambil semua kelas: $e');
      return [];
    }
  }

  // ==================== PENGUMUMAN & ACARA ====================
  static Future<List<Map<String, dynamic>>> ambilPengumuman() async {
    try {
      return await FirebaseService.ambilSemuaPengumuman();
    } catch (e) {
      print('Error ambil pengumuman: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> ambilAcara() async {
    try {
      return await FirebaseService.ambilSemuaAcara();
    } catch (e) {
      print('Error ambil acara: $e');
      return [];
    }
  }

  // ==================== WIRID ====================
  static Future<Map<String, dynamic>> ambilBacaanWirid() async {
    // Untuk MVP, return data statis
    return {
      'judul': 'Bacaan Wirid Rutin',
      'isi': '''
بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ

اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ كَمَا صَلَّيْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ إِنَّكَ حَمِيدٌ مَجِيدٌ

اللَّهُمَّ بَارِكْ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ كَمَا بَارَكْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ إِنَّكَ حَمِيدٌ مَجِيدٌ

سُبْحَانَ اللَّهِ وَالْحَمْدُ لِلَّهِ وَلَا إِلَهَ إِلَّا اللَّهُ وَاللَّهُ أَكْبَرُ

لَا إِلَهَ إِلَّا أَنْتَ سُبْحَانَكَ إِنِّي كُنْتُ مِنَ الظَّالِمِينَ

الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ

الرَّحْمَنِ الرَّحِيمِ

مَالِكِ يَوْمِ الدِّينِ

إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ

اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ

صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ

آمِينَ
      ''',
    };
  }
}
