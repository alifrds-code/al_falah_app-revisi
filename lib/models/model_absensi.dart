import 'dart:convert';

class AbsensiModel {
  final String? id;
  final String idJadwal;
  final String idJamaah;
  final String statusAbsen; // 'hadir', 'izin', 'sakit', 'alpa'
  final String? catatan;
  final DateTime? waktuAbsen;
  final DateTime? updatedAt;

  AbsensiModel({
    this.id,
    required this.idJadwal,
    required this.idJamaah,
    required this.statusAbsen,
    this.catatan,
    this.waktuAbsen,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'id_jadwal': idJadwal,
      'id_jamaah': idJamaah,
      'status_absen': statusAbsen,
      'catatan': catatan,
      'waktu_absen': waktuAbsen?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory AbsensiModel.fromMap(Map<String, dynamic> map) {
    return AbsensiModel(
      id: map['id'] != null ? map['id'] as String : null,
      idJadwal: map['id_jadwal'] as String,
      idJamaah: map['id_jamaah'] as String,
      statusAbsen: map['status_absen'] as String,
      catatan: map['catatan'] != null ? map['catatan'] as String : null,
      waktuAbsen: map['waktu_absen'] != null
          ? DateTime.parse(map['waktu_absen'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory AbsensiModel.fromJson(String source) =>
      AbsensiModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
