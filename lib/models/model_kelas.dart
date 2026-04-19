// ini cetakan buat data Master Kelas yang ada di aplikasi
class KelasModel {
  final int? idKelas;
  final String namaKelas;

  KelasModel({
    this.idKelas,
    required this.namaKelas,
  });

  // fungsi buat ngerubah data mentah dari database jadi objek Kelas
  factory KelasModel.fromMap(Map<String, dynamic> map) {
    return KelasModel(
      idKelas: map['id_kelas'],
      namaKelas: map['nama_kelas'],
    );
  }

  // fungsi buat ngerubah objek Kelas balik jadi map biar bisa dimasukin ke database
  Map<String, dynamic> toMap() {
    return {
      'id_kelas': idKelas,
      'nama_kelas': namaKelas,
    };
  }
}
