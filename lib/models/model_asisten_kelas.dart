import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class AsistenKelasModel {
  final int? idPenugasan;
  final int idUser;
  final int idKelas;
  AsistenKelasModel({
    this.idPenugasan,
    required this.idUser,
    required this.idKelas,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'idPenugasan': idPenugasan,
      'idUser': idUser,
      'idKelas': idKelas,
    };
  }

  factory AsistenKelasModel.fromMap(Map<String, dynamic> map) {
    return AsistenKelasModel(
      idPenugasan: map['idPenugasan'] != null
          ? map['idPenugasan'] as int
          : null,
      idUser: map['idUser'] as int,
      idKelas: map['idKelas'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory AsistenKelasModel.fromJson(String source) =>
      AsistenKelasModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
