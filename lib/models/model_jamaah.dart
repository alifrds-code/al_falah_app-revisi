import 'dart:convert';

class JamaahModel {
  final String? idJamaah;
  final String namaLengkap;
  final String jenisKelamin;
  final String? noHp;
  final String alamat;
  final int statusJamaah;
  final String? idKelas; 

  JamaahModel({
    this.idJamaah,
    required this.namaLengkap,
    required this.jenisKelamin,
    this.noHp,
    required this.alamat,
    this.statusJamaah = 1,
    this.idKelas,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id_jamaah': idJamaah,
      'nama_lengkap': namaLengkap,
      'jenis_kelamin': jenisKelamin,
      'no_hp': noHp,
      'alamat': alamat,
      'status_jamaah': statusJamaah,
      'id_kelas': idKelas,
    };
  }

  factory JamaahModel.fromMap(Map<String, dynamic> map) {
    return JamaahModel(
      idJamaah: map['id_jamaah'] ?? map['id'],
      namaLengkap: map['nama_lengkap'] as String,
      jenisKelamin: map['jenis_kelamin'] as String,
      noHp: map['no_hp'] != null ? map['no_hp'] as String : null,
      alamat: map['alamat'] as String,
      statusJamaah: map['status_jamaah'] != null ? int.tryParse(map['status_jamaah'].toString()) ?? 1 : 1,
      idKelas: map['id_kelas']?.toString(),
    );
  }

  String toJson() => json.encode(toMap());

  factory JamaahModel.fromJson(String source) =>
      JamaahModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
