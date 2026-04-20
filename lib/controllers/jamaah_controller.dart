import 'package:al_falah_app/models/model_jadwal.dart';
import 'package:al_falah_app/services/firebase_service.dart';

class JamaahController {
  // ==================== BERANDA JAMAAH ====================
  static Future<List<JadwalModel>> ambilJadwalTerbaru(
    List<String> idKelasDipilih,
  ) async {
    try {
      if (idKelasDipilih.isEmpty) return [];

      final today = DateTime.now();
      final todayStr = today.toIso8601String().split('T')[0];
      final dataJadwal = await FirebaseService.ambilSemuaJadwal();
      
      // Filter: kelas yang dipilih AND belum dibatalkan (status 2)
      final filtered = dataJadwal
          .where((j) => idKelasDipilih.contains(j['id_kelas']))
          .where((j) => (j['status_jadwal'] as int? ?? 0) != 2)
          .where((j) => (j['tanggal'] ?? '') >= todayStr) // hanya jadwal mendatang/hari ini
          .toList();

      // Urutkan terdekat dulu
      filtered.sort((a, b) => (a['tanggal'] ?? '').compareTo(b['tanggal'] ?? ''));

      return filtered.take(3).map((data) => JadwalModel.fromMap(data)).toList();
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
      final list = await FirebaseService.ambilSemuaPengumuman();
      // Konvert created_at (Timestamp Firestore) ke string yang readable
      return list.map((item) {
        final raw = item['created_at'];
        String tglStr = '-';
        if (raw != null) {
          try {
            // Firestore Timestamp memiliki method toDate()
            final dt = (raw as dynamic).toDate() as DateTime;
            tglStr = '${dt.day.toString().padLeft(2,'0')} '
                '${['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'][dt.month - 1]} '
                '${dt.year}';
          } catch (_) {}
        }
        return {...item, 'tanggal_dibuat': tglStr};
      }).toList();
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
(Shalawat Nabi)

سُبْحَانَ اللَّهِ وَالْحَمْدُ لِلَّهِ وَلَا إِلَهَ إِلَّا اللَّهُ وَاللَّهُ أَكْبَرُ
(Kalimat Thayyibah)

لَا إِلَهَ إِلَّا أَنْتَ سُبْحَانَكَ إِنِّي كُنْتُ مِنَ الظَّالِمِينَ
(Do'a Nabi Yunus - QS. Al-Anbiya: 87)

الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ (٢) الرَّحْمَنِ الرَّحِيمِ (٣) مَالِكِ يَوْمِ الدِّينِ (٤) إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ (٥) اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ (٦) صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ (٧)
(QS. Al-Fatihah: 2-7)
      ''',
    };
  }
}
