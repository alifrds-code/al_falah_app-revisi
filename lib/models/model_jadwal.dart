// ini cetakan buat data jadwal kajian
class JadwalModel {
  final int? idJadwal;
  final String? materiPembahasan; // ini boleh kosong kalo emang belum nentuin materi
  final String namaPemateri;
  final String tanggal;
  final String waktuMulai;
  final String waktuSelesai;
  final String statusJadwal; // isinya: 'Sesuai Jadwal', 'Ditunda', atau 'Dibatalkan'
  final String? alasanPerubahan;
  final int idKelas;
  final int idUser;
  // buat nampilin nama kelas pas di-JOIN doang, gak disimpen ke tabel asli
  final String? namaKelas; 

  JadwalModel({
    this.idJadwal,
    this.materiPembahasan,
    required this.namaPemateri,
    required this.tanggal,
    required this.waktuMulai,
    required this.waktuSelesai,
    required this.statusJadwal,
    this.alasanPerubahan,
    required this.idKelas,
    required this.idUser,
    this.namaKelas,
  });

  // fungsi buat ngerubah data dari database jadi objek jadwal biar enak diolah
  factory JadwalModel.fromMap(Map<String, dynamic> map) {
    return JadwalModel(
      idJadwal: map['id_jadwal'],
      materiPembahasan: map['materi_pembahasan'],
      namaPemateri: map['nama_pemateri'] ?? '',
      tanggal: map['tanggal'] ?? '',
      waktuMulai: map['waktu_mulai'] ?? '',
      waktuSelesai: map['waktu_selesai'] ?? '',
      // ini gue kasih fungsi pembantu biar statusnya gak error pas dibaca
      statusJadwal: _parseStatus(map['status_jadwal']),
      alasanPerubahan: map['alasan_perubahan'],
      idKelas: map['id_kelas'] ?? 0,
      idUser: map['id_user'] ?? 0,
      namaKelas: map['nama_kelas'],
    );
  }

  // fungsi buat mastiin status jadwal bentuknya string, antisipasi data versi lama
  static String _parseStatus(dynamic status) {
    if (status == null) return 'Sesuai Jadwal';
    if (status is String) return status;
    // kalo ternyata isinya angka (versi jadul), gue terjemahin dulu
    if (status == 0) return 'Sesuai Jadwal';
    if (status == 1) return 'Ditunda';
    if (status == 2) return 'Dibatalkan';
    return 'Sesuai Jadwal';
  }

  // fungsi buat ngerubah objek jadwal balik jadi map biar bisa disimpen ke database
  Map<String, dynamic> toMap() {
    return {
      'materi_pembahasan': materiPembahasan,
      'nama_pemateri': namaPemateri,
      'tanggal': tanggal,
      'waktu_mulai': waktuMulai,
      'waktu_selesai': waktuSelesai,
      'status_jadwal': statusJadwal,
      'alasan_perubahan': alasanPerubahan,
      'id_kelas': idKelas,
      'id_user': idUser,
    };
  }
}
