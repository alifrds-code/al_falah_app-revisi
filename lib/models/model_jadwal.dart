// Cetakan data jadwal - statusJadwal pakai String sesuai database
class JadwalModel {
  final int? idJadwal;
  final String? materiPembahasan; // Nullable karena bisa kosong
  final String namaPemateri;
  final String tanggal;
  final String waktuMulai;
  final String waktuSelesai;
  final String statusJadwal; // 'Sesuai Jadwal', 'Ditunda', 'Dibatalkan'
  final String? alasanPerubahan;
  final int idKelas;
  final int idUser;
  final String? namaKelas; // Dari JOIN, tidak disimpan ke database

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

  // Membuat JadwalModel dari data Map (dari database)
  factory JadwalModel.fromMap(Map<String, dynamic> map) {
    return JadwalModel(
      idJadwal: map['id_jadwal'],
      materiPembahasan: map['materi_pembahasan'],
      namaPemateri: map['nama_pemateri'] ?? '',
      tanggal: map['tanggal'] ?? '',
      waktuMulai: map['waktu_mulai'] ?? '',
      waktuSelesai: map['waktu_selesai'] ?? '',
      // Status jadwal bisa berupa String atau Integer dari versi lama
      statusJadwal: _parseStatus(map['status_jadwal']),
      alasanPerubahan: map['alasan_perubahan'],
      idKelas: map['id_kelas'] ?? 0,
      idUser: map['id_user'] ?? 0,
      namaKelas: map['nama_kelas'],
    );
  }

  // Fungsi bantu untuk parsing status (kalau data lama pakai Integer)
  static String _parseStatus(dynamic status) {
    if (status == null) return 'Sesuai Jadwal';
    if (status is String) return status;
    // Kalau masih Integer dari versi lama
    if (status == 0) return 'Sesuai Jadwal';
    if (status == 1) return 'Ditunda';
    if (status == 2) return 'Dibatalkan';
    return 'Sesuai Jadwal';
  }

  // Mengubah JadwalModel kembali jadi Map (untuk disimpan ke database)
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
