class KelasModel {
  final int? idKelas;
  final String namaKelas;

  KelasModel({
    this.idKelas,
    required this.namaKelas,
  });

  factory KelasModel.fromMap(Map<String, dynamic> map) {
    return KelasModel(
      idKelas: map['id_kelas'],
      namaKelas: map['nama_kelas'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id_kelas': idKelas,
      'nama_kelas': namaKelas,
    };
  }
}
