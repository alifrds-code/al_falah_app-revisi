import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import '../database/sqflite_helper.dart';

class LaporanController {
  // Generate CSV data for a specific class and month
  Future<String?> exportAttendanceToCSV(int idKelas, String className, String bulan) async {
    try {
      final data = await DBHelper.getReportData(idKelas, bulan);
      
      if (data.isEmpty) return null;

      // Header CSV
      List<List<dynamic>> rows = [];
      rows.add(["No", "Nama Jamaah", "Tanggal", "Status Hadir"]);

      // Data rows
      for (int i = 0; i < data.length; i++) {
        rows.add([
          i + 1,
          data[i]['nama_lengkap'],
          data[i]['tanggal'],
          data[i]['status_hadir'],
        ]);
      }

      String csvData = const ListToCsvConverter().convert(rows);

      // Save to device
      final directory = await getExternalStorageDirectory(); // For Android Downloads/App folder
      if (directory == null) return null;

      final path = "${directory.path}/Laporan_Absensi_${className}_$bulan.csv";
      final file = File(path);
      await file.writeAsString(csvData);

      return path;
    } catch (e) {
      print("Export Error: $e");
      return null;
    }
  }
}
