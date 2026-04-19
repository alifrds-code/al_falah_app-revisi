class AcaraModel {
  final int? idAcara;
  final String namaAcara;
  final String deskripsi;
  final String tanggalAcara;
  final String waktu;
  final String lokasi;
  final String namaPemateri;
  final String? fotoPoster;

  AcaraModel({
    this.idAcara,
    required this.namaAcara,
    required this.deskripsi,
    required this.tanggalAcara,
    required this.waktu,
    required this.lokasi,
    required this.namaPemateri,
    this.fotoPoster,
  });

  factory AcaraModel.fromMap(Map<String, dynamic> map) {
    return AcaraModel(
      idAcara: map['id_acara'],
      namaAcara: map['nama_acara'],
      deskripsi: map['deskripsi'],
      tanggalAcara: map['tanggal_acara'],
      waktu: map['waktu'],
      lokasi: map['lokasi'],
      namaPemateri: map['nama_pemateri'],
      fotoPoster: map['foto_poster'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_acara': idAcara,
      'nama_acara': namaAcara,
      'deskripsi': deskripsi,
      'tanggal_acara': tanggalAcara,
      'waktu': waktu,
      'lokasi': lokasi,
      'nama_pemateri': namaPemateri,
      'foto_poster': fotoPoster,
    };
  }
}
