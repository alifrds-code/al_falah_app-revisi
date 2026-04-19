// ini cetakan buat nyimpen data biodata lengkap jamaah
class JamaahModel {
  final int? idJamaah;
  final String namaLengkap;
  final String jenisKelamin;
  final String? noHp;
  final String alamat;
  final int statusJamaah; // ini statusnya: 1 kalo aktif, 0 kalo udah gak aktif
  final int? idKelas;
  // ini tambahan buat nampilin nama kelasnya aja, gak usah disimpen ke tabel jamaah
  final String? namaKelas; 

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

  // fungsi buat ngerubah data dari database jadi objek jamaah
  factory JamaahModel.fromMap(Map<String, dynamic> map) {
    return JamaahModel(
      idJamaah: map['id_jamaah'],
      namaLengkap: map['nama_lengkap'] ?? '',
      jenisKelamin: map['jenis_kelamin'] ?? '',
      noHp: map['no_hp'],
      alamat: map['alamat'] ?? '',
      statusJamaah: map['status_jamaah'] ?? 1,
      idKelas: map['id_kelas'],
      namaKelas: map['nama_kelas'], // ini dapet dari JOIN biasanya
    );
  }

  // fungsi buat ngerubah objek jamaah balik jadi map biar bisa disimpen
  // oiya, nama_kelas sengaja gak gue masukin karena emang gak ada kolomnya di tabel
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

  // ini alias aja sih biar kalo ada kode lama yang manggil 'telepon' masih nyambung
  String? get telepon => noHp;
}
