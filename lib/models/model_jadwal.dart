import 'dart:convert';

class JadwalModel {
  final String? id;
  final String uidAsisten;
  final String idKelas;
  final DateTime tanggal;
  final String waktuMulai;
  final String waktuSelesai;
  final String? materiPembahasan;
  final String? namaPemateri;
  final int statusJadwal; // 0 = sesuai, 1 = ditunda, 2 = dibatalkan
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
    this.materiPembahasan,
    this.namaPemateri,
    this.statusJadwal = 0,
    this.alasanPerubahan,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'uid_asisten': uidAsisten,
      'id_user': uidAsisten,
      'id_kelas': idKelas,
      'tanggal': tanggal.toIso8601String(),
      'waktu_mulai': waktuMulai,
      'waktu_selesai': waktuSelesai,
      'materi_pembahasan': materiPembahasan,
      'nama_pemateri': namaPemateri,
      'status_jadwal': statusJadwal,
      'alasan_perubahan': alasanPerubahan,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory JadwalModel.fromMap(Map<String, dynamic> map) {
    DateTime? parseDateTime(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value);
      try {
        return value.toDate() as DateTime;
      } catch (_) {}
      try {
        return DateTime.parse(value.toString());
      } catch (_) {
        return null;
      }
    }

    return JadwalModel(
      id: map['id'] != null ? map['id'] as String : null,
      uidAsisten: map['uid_asisten'] != null
          ? map['uid_asisten'] as String
          : (map['id_user'] != null ? map['id_user'] as String : ''),
      idKelas: map['id_kelas'] as String,
      tanggal: parseDateTime(map['tanggal'] as dynamic) ?? DateTime.now(),
      waktuMulai: map['waktu_mulai'] as String,
      waktuSelesai: map['waktu_selesai'] as String,
      materiPembahasan: map['materi_pembahasan'] != null
          ? map['materi_pembahasan'] as String
          : null,
      namaPemateri: map['nama_pemateri'] != null
          ? map['nama_pemateri'] as String
          : null,
      statusJadwal: map['status_jadwal'] is int
          ? map['status_jadwal'] as int
          : int.tryParse(map['status_jadwal']?.toString() ?? '') ?? 0,
      alasanPerubahan: map['alasan_perubahan'] != null
          ? map['alasan_perubahan'] as String
          : null,
      createdAt: parseDateTime(map['created_at'] as dynamic),
      updatedAt: parseDateTime(map['updated_at'] as dynamic),
    );
  }

  String toJson() => json.encode(toMap());

  factory JadwalModel.fromJson(String source) =>
      JadwalModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
