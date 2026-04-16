import 'package:al_falah_app/services/firebase_service.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class LaporanController {
  // ==================== EKSPOR LAPORAN ABSENSI ====================
  static Future<String?> eksporLaporanAbsensi({
    required int bulan,
    required int tahun,
    String? idKelas,
  }) async {
    try {
      // 1. Ambil data absensi dari Firebase
      final dataAbsensi = await _ambilDataAbsensiUntukLaporan(
        bulan: bulan,
        tahun: tahun,
        idKelas: idKelas,
      );

      if (dataAbsensi.isEmpty) {
        return null; // Tidak ada data
      }

      // 2. Generate CSV content
      final csvContent = _generateCSVContent(dataAbsensi);

      // 3. Simpan ke file
      final filePath = await _simpanKeFileCSV(
        csvContent,
        bulan,
        tahun,
        idKelas,
      );

      return filePath;
    } catch (e) {
      print('Error ekspor laporan: $e');
      return null;
    }
  }

  static Future<List<Map<String, dynamic>>> _ambilDataAbsensiUntukLaporan({
    required int bulan,
    required int tahun,
    String? idKelas,
  }) async {
    try {
      return await FirebaseService.ambilDataLaporanAbsensi(
        bulan: bulan,
        tahun: tahun,
        idKelas: idKelas,
      );
    } catch (e) {
      print('Error ambil data absensi: $e');
      return [];
    }
  }

  static String _generateCSVContent(List<Map<String, dynamic>> data) {
    final headers = ['Tanggal', 'Kelas', 'Nama Jamaah', 'Status', 'Catatan'];
    final csvRows = [headers.join(',')];

    for (var row in data) {
      final csvRow = [
        row['tanggal'],
        row['nama_kelas'],
        '"${row['nama_jamaah']}"', // Quote untuk nama yang mungkin ada koma
        row['status_absen'],
        '"${row['catatan']}"',
      ];
      csvRows.add(csvRow.join(','));
    }

    return csvRows.join('\n');
  }

  static Future<String> _simpanKeFileCSV(
    String csvContent,
    int bulan,
    int tahun,
    String? idKelas,
  ) async {
    final directory = await getExternalStorageDirectory();
    final folderPath = '${directory!.path}/Laporan_Absensi';
    await Directory(folderPath).create(recursive: true);

    final namaKelas = idKelas != null ? '_Kelas_$idKelas' : '_Semua_Kelas';
    final fileName =
        'Laporan_Absensi_${tahun}_${bulan.toString().padLeft(2, '0')}$namaKelas.csv';
    final filePath = '$folderPath/$fileName';

    final file = File(filePath);
    await file.writeAsString(csvContent);

    return filePath;
  }
}
