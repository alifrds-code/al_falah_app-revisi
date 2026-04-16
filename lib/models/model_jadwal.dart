import 'dart:convert';

class JadwalModel {
  final String? id;
  final String uidAsisten;
  final String idKelas;
  final DateTime tanggal;
  final String waktuMulai;
  final String waktuSelesai;
  final String? materi;
  final String? catatan;
  final String statusJadwal; // 'sesuai', 'ditunda', 'dibatalkan'
  final String? alasanPerubahan;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  JadwalModel({
    this.id,
    required this.uidAsisten,
    required this.idKelas,
    required this.tanggal,
    required this.waktuMulai,
    required this.waktuSelesai,
    this.materi,
    this.catatan,
    this.statusJadwal = 'sesuai',
    this.alasanPerubahan,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'uid_asisten': uidAsisten,
      'id_kelas': idKelas,
      'tanggal': tanggal.toIso8601String(),
      'waktu_mulai': waktuMulai,
      'waktu_selesai': waktuSelesai,
      'materi': materi,
      'catatan': catatan,
      'status_jadwal': statusJadwal,
      'alasan_perubahan': alasanPerubahan,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory JadwalModel.fromMap(Map<String, dynamic> map) {
    return JadwalModel(
      id: map['id'] != null ? map['id'] as String : null,
      uidAsisten: map['uid_asisten'] as String,
      idKelas: map['id_kelas'] as String,
      tanggal: DateTime.parse(map['tanggal'] as String),
      waktuMulai: map['waktu_mulai'] as String,
      waktuSelesai: map['waktu_selesai'] as String,
      materi: map['materi'] != null ? map['materi'] as String : null,
      catatan: map['catatan'] != null ? map['catatan'] as String : null,
      statusJadwal: map['status_jadwal'] as String? ?? 'sesuai',
      alasanPerubahan: map['alasan_perubahan'] != null
          ? map['alasan_perubahan'] as String
          : null,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory JadwalModel.fromJson(String source) =>
      JadwalModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
