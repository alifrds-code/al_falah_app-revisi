import 'package:sqflite/sqflite.dart';
import '../database/sqflite_helper.dart';
import '../models/model_user.dart';
import '../models/model_kelas.dart';
import '../models/model_jamaah.dart';
import '../models/model_pengumuman.dart';
import '../models/model_acara.dart';

// ini file buat ngatur semua data admin, gue mindahin logic sql kesini biar rapih
class AdminController {
  
  // buat ngitung jumlah jamaah, kelas sama asisten buat di beranda depan
  Future<Map<String, int>> getDashboardStats() async {
    final db = await DBHelper.db();
    
    final jamaah = await db.rawQuery('SELECT COUNT(*) as total FROM tb_jamaah');
    final kelas = await db.rawQuery('SELECT COUNT(*) as total FROM tb_kelas');
    final asisten = await db.query('tb_users', where: 'role = ?', whereArgs: ['asisten']);

    return {
      'jamaah': Sqflite.firstIntValue(jamaah) ?? 0,
      'kelas': Sqflite.firstIntValue(kelas) ?? 0,
      'asisten': asisten.length,
    };
  }

  // yang ini buat urusan asisten (tambah, hapus, gitu-gitu)
  Future<List<UserModel>> getAsistens() async {
    final db = await DBHelper.db();
    final data = await db.query('tb_users', where: 'role = ?', whereArgs: ['asisten']);
    return data.map((e) => UserModel.fromMap(e)).toList();
  }

  Future<void> addAsisten(UserModel user) async {
    final db = await DBHelper.db();
    await db.insert('tb_users', user.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateAsisten(UserModel user) async {
    final db = await DBHelper.db();
    await db.update('tb_users', user.toMap(), where: 'id_user = ?', whereArgs: [user.idUser]);
  }

  Future<void> deleteAsisten(int id) async {
    final db = await DBHelper.db();
    await db.delete('tb_users', where: 'id_user = ?', whereArgs: [id]);
  }

  // buat ngatur-ngatur kelas
  Future<List<KelasModel>> getClasses() async {
    final db = await DBHelper.db();
    final data = await db.query('tb_kelas', orderBy: 'nama_kelas ASC');
    return data.map((e) => KelasModel.fromMap(e)).toList();
  }

  Future<void> addClass(String name) async {
    final db = await DBHelper.db();
    await db.insert('tb_kelas', {'nama_kelas': name});
  }

  Future<void> updateClass(int id, String name) async {
    final db = await DBHelper.db();
    await db.update('tb_kelas', {'nama_kelas': name}, where: 'id_kelas = ?', whereArgs: [id]);
  }

  Future<void> deleteClass(int id) async {
    final db = await DBHelper.db();
    await db.delete('tb_kelas', where: 'id_kelas = ?', whereArgs: [id]);
  }

  // yang ini buat data jamaah, agak ribet soalnya join sama table kelas
  Future<List<JamaahModel>> getJamaah() async {
    final db = await DBHelper.db();
    final data = await db.rawQuery('''
      SELECT j.*, k.nama_kelas 
      FROM tb_jamaah j 
      LEFT JOIN tb_kelas k ON j.id_kelas = k.id_kelas
      ORDER BY j.nama_lengkap ASC
    ''');
    return data.map((e) => JamaahModel.fromMap(e)).toList();
  }

  Future<void> addJamaah(JamaahModel jamaah) async {
    final db = await DBHelper.db();
    final data = jamaah.toMap();
    data.remove('id_jamaah');
    await db.insert('tb_jamaah', data);
  }

  Future<void> updateJamaah(JamaahModel jamaah) async {
    final db = await DBHelper.db();
    final data = jamaah.toMap();
    data.remove('id_jamaah');
    data.remove('nama_kelas');
    await db.update('tb_jamaah', data, where: 'id_jamaah = ?', whereArgs: [jamaah.idJamaah]);
  }

  Future<void> deleteJamaah(int id) async {
    final db = await DBHelper.db();
    await db.delete('tb_jamaah', where: 'id_jamaah = ?', whereArgs: [id]);
  }

  // buat bikin pengumuman ke jamaah
  Future<List<PengumumanModel>> getPengumuman() async {
    final db = await DBHelper.db();
    final data = await db.query('tb_pengumuman', orderBy: 'tanggal_post DESC');
    return data.map((e) => PengumumanModel.fromMap(e)).toList();
  }

  Future<void> postAnnouncement(String title, String content) async {
    final db = await DBHelper.db();
    await db.insert('tb_pengumuman', {
      'judul': title,
      'isi_teks': content,
      'tanggal_post': DateTime.now().toIso8601String(),
    });
  }

  Future<void> updateAnnouncement(int id, String title, String content) async {
    final db = await DBHelper.db();
    await db.update(
      'tb_pengumuman',
      {'judul': title, 'isi_teks': content},
      where: 'id_pengumuman = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAnnouncement(int id) async {
    final db = await DBHelper.db();
    await db.delete('tb_pengumuman', where: 'id_pengumuman = ?', whereArgs: [id]);
  }

  // buat info acara yayasan, biar jamaah pada tau
  Future<List<AcaraModel>> getAcara() async {
    final db = await DBHelper.db();
    final data = await db.query('tb_acara', orderBy: 'tanggal_acara ASC');
    return data.map((e) => AcaraModel.fromMap(e)).toList();
  }

  Future<void> postEvent(AcaraModel event) async {
    final db = await DBHelper.db();
    final data = event.toMap();
    data.remove('id_acara');
    await db.insert('tb_acara', data);
  }

  Future<void> updateEvent(AcaraModel event) async {
    final db = await DBHelper.db();
    final data = event.toMap();
    data.remove('id_acara');
    await db.update('tb_acara', data, where: 'id_acara = ?', whereArgs: [event.idAcara]);
  }

  Future<void> deleteEvent(int id) async {
    final db = await DBHelper.db();
    await db.delete('tb_acara', where: 'id_acara = ?', whereArgs: [id]);
  }
}
