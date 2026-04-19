// ini cetakan buat data pengumuman yayasan
class PengumumanModel {
  final int? idPengumuman;
  final String judul;
  final String isiTeks;
  final String tanggalPost;

  PengumumanModel({
    this.idPengumuman,
    required this.judul,
    required this.isiTeks,
    required this.tanggalPost,
  });

  // ngerubah data dari database jadi objek biar gampang dipake di flutter
  factory PengumumanModel.fromMap(Map<String, dynamic> map) {
    return PengumumanModel(
      idPengumuman: map['id_pengumuman'],
      judul: map['judul'],
      isiTeks: map['isi_teks'],
      tanggalPost: map['tanggal_post'],
    );
  }

  // ngerubah objek balik jadi map biar bisa disimpen
  Map<String, dynamic> toMap() {
    return {
      'id_pengumuman': idPengumuman,
      'judul': judul,
      'isi_teks': isiTeks,
      'tanggal_post': tanggalPost,
    };
  }
}
