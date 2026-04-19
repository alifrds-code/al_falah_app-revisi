import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import '../database/sqflite_helper.dart';

// ini controller buat bikin laporan, gue pusing nulis query join-nya tapi akhirnya bisa
class LaporanController {
  
  // fungsi buat bikin file CSV biar data absen bisa dibuka di excel
  Future<String?> exportAttendanceToCSV(int idKelas, String className, String bulan) async {
    try {
      final db = await DBHelper.db();
      // format bulannya itu "2025-04" gitu ya
      final data = await db.rawQuery('''
        SELECT j.nama_lengkap, jd.tanggal, jd.materi_pembahasan, a.status_hadir
        FROM tb_absensi a
        JOIN tb_jamaah j ON a.id_jamaah = j.id_jamaah
        JOIN tb_jadwal jd ON a.id_jadwal = jd.id_jadwal
        WHERE jd.id_kelas = ? AND jd.tanggal LIKE ?
        ORDER BY jd.tanggal ASC, j.nama_lengkap ASC
      ''', [idKelas, '$bulan%']);
      
      if (data.isEmpty) return null;

      // bikin kepalanya (header) buat tabel CSV-nya
      List<List<dynamic>> rows = [];
      rows.add(["No", "Nama Jamaah", "Tanggal", "Status Hadir"]);

      // masukin data jamaah satu-satu ke baris tabel
      for (int i = 0; i < data.length; i++) {
        rows.add([
          i + 1,
          data[i]['nama_lengkap'],
          data[i]['tanggal'],
          data[i]['status_hadir'],
        ]);
      }

      // ngerubah dari list jadi teks CSV yang beneran
      String csvData = const ListToCsvConverter().convert(rows);

      // simpen filenya ke dalem memori HP (folder download aplikasi)
      final directory = await getExternalStorageDirectory(); 
      if (directory == null) return null;

      final path = "${directory.path}/Laporan_Absensi_${className}_$bulan.csv";
      final file = File(path);
      await file.writeAsString(csvData);

      return path; // balikin lokasi filenya biar bisa dibuka sama user
    } catch (e) {
      // kalo error ya udah deh balikin kosong aja
      return null;
    }
  }
}
