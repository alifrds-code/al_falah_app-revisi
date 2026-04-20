import 'dart:convert';

class KelasModel {
  final String? idKelas;
  final String namaKelas;
  final String? idAsisten; 

  KelasModel({this.idKelas, required this.namaKelas, this.idAsisten});

  Map<String, dynamic> toMap() {
    return {'id_kelas': idKelas, 'nama_kelas': namaKelas, 'id_asisten': idAsisten};
  }

  factory KelasModel.fromMap(Map<String, dynamic> map) {
    return KelasModel(
      idKelas: map['id_kelas'] ?? map['id'],
      namaKelas: map['nama_kelas'] as String,
      idAsisten: map['id_asisten'],
    );
  }

  String toJson() => json.encode(toMap());

  factory KelasModel.fromJson(String source) =>
      KelasModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
