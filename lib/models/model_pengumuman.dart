// Cetakan data pengumuman
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

  factory PengumumanModel.fromMap(Map<String, dynamic> map) {
    return PengumumanModel(
      idPengumuman: map['id_pengumuman'],
      judul: map['judul'],
      isiTeks: map['isi_teks'],
      tanggalPost: map['tanggal_post'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_pengumuman': idPengumuman,
      'judul': judul,
      'isi_teks': isiTeks,
      'tanggal_post': tanggalPost,
    };
  }
}
