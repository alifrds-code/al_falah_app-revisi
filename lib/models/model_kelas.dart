import 'dart:convert';

class KelasModel {
  final int? idKelas;
  final String namaKelas;
  final int? idAsisten; // Biarin di sini buat numpang lewat dari UI

  KelasModel({this.idKelas, required this.namaKelas, this.idAsisten});

  Map<String, dynamic> toMap() {
    // JANGAN MASUKIN id_asisten DI SINI! Karena emang ga ada di tb_kelas
    return {'id_kelas': idKelas, 'nama_kelas': namaKelas};
  }

  factory KelasModel.fromMap(Map<String, dynamic> map) {
    return KelasModel(
      idKelas: map['id_kelas'] != null ? map['id_kelas'] as int : null,
      namaKelas: map['nama_kelas'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory KelasModel.fromJson(String source) =>
      KelasModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
