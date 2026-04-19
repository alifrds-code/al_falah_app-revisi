// Cetakan data biodata jamaah pengajian
class JamaahModel {
  final int? idJamaah;
  final String namaLengkap;
  final String jenisKelamin;
  final String? noHp;
  final String alamat;
  final int statusJamaah; // 1 = Aktif, 0 = Nonaktif
  final int? idKelas;
  final String? namaKelas; // Dari JOIN dengan tb_kelas, tidak disimpan ke database

  JamaahModel({
    this.idJamaah,
    required this.namaLengkap,
    required this.jenisKelamin,
    this.noHp,
    required this.alamat,
    this.statusJamaah = 1,
    this.idKelas,
    this.namaKelas,
  });

  // Membuat JamaahModel dari data Map (dari database)
  factory JamaahModel.fromMap(Map<String, dynamic> map) {
    return JamaahModel(
      idJamaah: map['id_jamaah'],
      namaLengkap: map['nama_lengkap'] ?? '',
      jenisKelamin: map['jenis_kelamin'] ?? '',
      noHp: map['no_hp'],
      alamat: map['alamat'] ?? '',
      statusJamaah: map['status_jamaah'] ?? 1,
      idKelas: map['id_kelas'],
      namaKelas: map['nama_kelas'], // Dari LEFT JOIN
    );
  }

  // Mengubah JamaahModel kembali jadi Map (untuk disimpan ke database)
  // PENTING: namaKelas tidak ikut disimpan karena bukan kolom di tabel
  Map<String, dynamic> toMap() {
    return {
      'nama_lengkap': namaLengkap,
      'jenis_kelamin': jenisKelamin,
      'no_hp': noHp,
      'alamat': alamat,
      'status_jamaah': statusJamaah,
      'id_kelas': idKelas,
    };
  }

  // Getter alias untuk kompatibilitas dengan kode lama
  String? get telepon => noHp;
}
