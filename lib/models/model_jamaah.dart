import 'dart:convert';

class JamaahModel {
  final int? idJamaah;
  final String namaLengkap;
  final String jenisKelamin;
  final String? noHp;
  final String alamat;
  final int statusJamaah;
  final int? idKelas; // KASIH TANDA TANYA BIAR BOLEH KOSONG

  JamaahModel({
    this.idJamaah,
    required this.namaLengkap,
    required this.jenisKelamin,
    this.noHp,
    required this.alamat,
    this.statusJamaah = 1,
    this.idKelas, // HAPUS KATA 'required' DI SINI
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
      idJamaah: map['id_jamaah'] != null ? map['id_jamaah'] as int : null,
      namaLengkap: map['nama_lengkap'] as String,
      jenisKelamin: map['jenis_kelamin'] as String,
      noHp: map['no_hp'] != null ? map['no_hp'] as String : null,
      alamat: map['alamat'] as String,
      statusJamaah: map['status_jamaah'] as int,
      // PENGAMAN BIAR GAK ERROR KALAU NULL
      idKelas: map['id_kelas'] != null ? map['id_kelas'] as int : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory JamaahModel.fromJson(String source) =>
      JamaahModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
