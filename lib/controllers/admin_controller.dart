import '../database/sqflite_helper.dart';
import '../models/model_user.dart';
import '../models/model_kelas.dart';
import '../models/model_jamaah.dart';
import '../models/model_pengumuman.dart';
import '../models/model_acara.dart';

// Otak logika khusus Admin: CRUD semua data
class AdminController {
  // ============================================================
  //  DASHBOARD STATISTIK
  // ============================================================

  // Ambil angka statistik untuk ditampilkan di dashboard
  Future<Map<String, int>> getDashboardStats() async {
    final jamaah = await DBHelper.getAllJamaah();
    final kelas = await DBHelper.getAllKelas();
    final asisten = await DBHelper.getAllAsistens();

    return {
      'jamaah': jamaah.length,
      'kelas': kelas.length,
      'asisten': asisten.length,
    };
  }

  // ============================================================
  //  KELOLA ASISTEN
  // ============================================================

  Future<List<UserModel>> getAsistens() async {
    final data = await DBHelper.getAllAsistens();
    return data.map((e) => UserModel.fromMap(e)).toList();
  }

  Future<void> addAsisten(UserModel user) async {
    await DBHelper.insertUser(user.toMap());
  }

  Future<void> updateAsisten(UserModel user) async {
    await DBHelper.updateUser(user.idUser!, user.toMap());
  }

  Future<void> deleteAsisten(int id) async {
    await DBHelper.deleteAsisten(id);
  }

  // ============================================================
  //  KELOLA KELAS
  // ============================================================

  Future<List<KelasModel>> getClasses() async {
    final data = await DBHelper.getAllKelas();
    return data.map((e) => KelasModel.fromMap(e)).toList();
  }

  Future<void> addClass(String name) async {
    await DBHelper.insertKelas(name);
  }

  Future<void> updateClass(int id, String name) async {
    await DBHelper.updateKelas(id, name);
  }

  Future<void> deleteClass(int id) async {
    await DBHelper.deleteKelas(id);
  }

  // ============================================================
  //  KELOLA JAMAAH
  // ============================================================

  Future<List<JamaahModel>> getJamaah() async {
    final data = await DBHelper.getAllJamaah();
    return data.map((e) => JamaahModel.fromMap(e)).toList();
  }

  Future<void> addJamaah(JamaahModel jamaah) async {
    await DBHelper.insertJamaah(jamaah.toMap());
  }

  Future<void> updateJamaah(JamaahModel jamaah) async {
    await DBHelper.updateJamaah(jamaah.idJamaah!, jamaah.toMap());
  }

  Future<void> deleteJamaah(int id) async {
    await DBHelper.deleteJamaah(id);
  }

  // ============================================================
  //  KELOLA PENGUMUMAN
  // ============================================================

  Future<List<PengumumanModel>> getPengumuman() async {
    final data = await DBHelper.getAllPengumuman();
    return data.map((e) => PengumumanModel.fromMap(e)).toList();
  }

  Future<void> postAnnouncement(String title, String content) async {
    await DBHelper.insertPengumuman(title, content);
  }

  Future<void> updateAnnouncement(int id, String title, String content) async {
    await DBHelper.updatePengumuman(id, title, content);
  }

  Future<void> deleteAnnouncement(int id) async {
    await DBHelper.deletePengumuman(id);
  }

  // ============================================================
  //  KELOLA ACARA
  // ============================================================

  Future<List<AcaraModel>> getAcara() async {
    final data = await DBHelper.getAllAcara();
    return data.map((e) => AcaraModel.fromMap(e)).toList();
  }

  Future<void> postEvent(AcaraModel event) async {
    await DBHelper.insertAcara(event.toMap());
  }

  Future<void> updateEvent(AcaraModel event) async {
    await DBHelper.updateAcara(event.idAcara!, event.toMap());
  }

  Future<void> deleteEvent(int id) async {
    await DBHelper.deleteAcara(id);
  }
}
