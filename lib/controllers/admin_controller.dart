import 'package:al_falah_app/models/model_jamaah.dart';
import 'package:al_falah_app/models/model_kelas.dart';
import 'package:al_falah_app/models/model_user.dart';
import 'package:al_falah_app/services/firebase_service.dart';

class AdminController {
  // ==================== CRUD KELAS ====================
  static Future<List<Map<String, dynamic>>> ambilSemuaKelas() async {
    try {
      return await FirebaseService.ambilSemuaKelas();
    } catch (e) {
      print('Error ambil kelas: $e');
      return [];
    }
  }

  static Stream<List<Map<String, dynamic>>> ambilSemuaKelasStream() {
    return FirebaseService.ambilSemuaKelasStream();
  }

  static Future<bool> tambahKelas(KelasModel kelas) async {
    try {
      await FirebaseService.tambahKelas(namaKelas: kelas.namaKelas);
      return true;
    } catch (e) {
      print('Error tambah kelas: $e');
      return false;
    }
  }

  static Future<bool> updateKelas(String idKelas, KelasModel kelas) async {
    try {
      await FirebaseService.updateKelas(idKelas, {
        'nama_kelas': kelas.namaKelas,
      });
      return true;
    } catch (e) {
      print('Error update kelas: $e');
      return false;
    }
  }

  static Future<bool> hapusKelas(String idKelas) async {
    try {
      await FirebaseService.hapusKelas(idKelas);
      return true;
    } catch (e) {
      print('Error hapus kelas: $e');
      return false;
    }
  }

  // ==================== CRUD JAMAAH ====================
  static Future<List<Map<String, dynamic>>> ambilSemuaJamaah() async {
    try {
      return await FirebaseService.ambilSemuaJamaah();
    } catch (e) {
      print('Error ambil jamaah: $e');
      return [];
    }
  }

  static Stream<List<Map<String, dynamic>>> ambilSemuaJamaahStream() {
    return FirebaseService.ambilSemuaJamaahStream();
  }

  static Stream<List<Map<String, dynamic>>> ambilJamaahByKelasStream(
    String idKelas,
  ) {
    return FirebaseService.ambilJamaahByKelasStream(idKelas);
  }

  static Future<List<Map<String, dynamic>>> ambilJamaahByKelas(String idKelas) async {
    try {
      final allJamaah = await FirebaseService.ambilSemuaJamaah();
      return allJamaah.where((jamaah) => jamaah['id_kelas'] == idKelas).toList();
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  static Future<List<Map<String, dynamic>>> getJamaahTanpaKelas() async {
    try {
      final allJamaah = await FirebaseService.ambilSemuaJamaah();
      return allJamaah.where((jamaah) => jamaah['id_kelas'] == null || jamaah['id_kelas'] == '').toList();
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  static Future<int> getHitungTotalJamaah() async {
     try {
        final allJamaah = await FirebaseService.ambilSemuaJamaah();
        return allJamaah.length;
     } catch (e) {
        return 0;
     }
  }

  static Future<bool> assignKelas(String idJamaah, String idKelas) async {
    try {
      await FirebaseService.updateJamaah(idJamaah, {
        'id_kelas': idKelas,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> keluarkanDariKelas(String idJamaah) async {
    try {
      await FirebaseService.updateJamaah(idJamaah, {
        'id_kelas': null,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> assignAsistenKelas(String idKelas, String idAsisten, String namaAsisten) async {
    try {
      await FirebaseService.updateKelas(idKelas, {
         'id_asisten': idAsisten,
         'nama_asisten': namaAsisten,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> copotAsisten(String idKelas) async {
    try {
      await FirebaseService.updateKelas(idKelas, {
         'id_asisten': null,
         'nama_asisten': null,
      });
      return true;
    } catch (e) {
      return false;
    }
  }


  static Future<bool> tambahJamaah(JamaahModel jamaah) async {
    try {
      await FirebaseService.tambahJamaah(
        namaLengkap: jamaah.namaLengkap,
        jenisKelamin: jamaah.jenisKelamin,
        noHp: jamaah.noHp,
        alamat: jamaah.alamat,
        statusJamaah: jamaah.statusJamaah,
        idKelas: jamaah.idKelas?.toString(),
      );
      return true;
    } catch (e) {
      print('Error tambah jamaah: $e');
      return false;
    }
  }

  static Future<bool> updateJamaah(String idJamaah, JamaahModel jamaah) async {
    try {
      await FirebaseService.updateJamaah(idJamaah, {
        'nama_lengkap': jamaah.namaLengkap,
        'jenis_kelamin': jamaah.jenisKelamin,
        'no_hp': jamaah.noHp,
        'alamat': jamaah.alamat,
        'status_jamaah': jamaah.statusJamaah,
        'id_kelas': jamaah.idKelas?.toString(),
      });
      return true;
    } catch (e) {
      print('Error update jamaah: $e');
      return false;
    }
  }

  static Future<bool> hapusJamaah(String idJamaah) async {
    try {
      await FirebaseService.hapusJamaah(idJamaah);
      return true;
    } catch (e) {
      print('Error hapus jamaah: $e');
      return false;
    }
  }

  // ==================== CRUD ASISTEN ====================
  static Future<List<UserModel>> ambilSemuaAsisten() async {
    try {
      final allUsers = await FirebaseService.ambilSemuaUsersByRole('asisten');
      return allUsers.map((data) => UserModel.fromMap(data)).toList();
    } catch (e) {
      print('Error ambil asisten: $e');
      return [];
    }
  }

  static Stream<List<UserModel>> ambilSemuaAsistenStream() {
    return FirebaseService.ambilSemuaUsersByRoleStream('asisten').map((list) =>
        list.map((data) => UserModel.fromMap({
          ...data,
          'uid': data['id'], // Ensure UID is mapped from document ID
        })).toList());
  }

  static Future<bool> tambahAsisten({
    required String email,
    required String password,
    required String nama,
  }) async {
    await FirebaseService.registerUser(
      email: email,
      password: password,
      nama: nama,
      role: 'asisten',
    );
    return true;
  }

  static Future<bool> updateAsisten(
    String uid,
    Map<String, dynamic> data,
  ) async {
    await FirebaseService.updateProfilUser(uid, data);
    return true;
  }

  static Future<bool> hapusAsisten(String uid) async {
    try {
      await FirebaseService.hapusUser(uid);
      return true;
    } catch (e) {
      print('Error hapus asisten: $e');
      return false;
    }
  }

  // ==================== ASISTEN KELAS ASSIGNMENT ====================
  static Future<List<Map<String, dynamic>>> ambilAsistenByKelas(
    String idKelas,
  ) async {
    try {
      return await FirebaseService.ambilAsistenByKelas(idKelas);
    } catch (e) {
      print('Error ambil asisten by kelas: $e');
      return [];
    }
  }

  static Future<bool> assignAsistenKeKelas(
    String uidAsisten,
    String idKelas,
  ) async {
    try {
      await FirebaseService.assignAsistenKeKelas(
        uidAsisten: uidAsisten,
        idKelas: idKelas,
      );
      return true;
    } catch (e) {
      print('Error assign asisten: $e');
      return false;
    }
  }

  static Future<bool> hapusAsistenDariKelas(String idAssignment) async {
    try {
      await FirebaseService.hapusAsistenDariKelas(idAssignment);
      return true;
    } catch (e) {
      print('Error hapus assignment: $e');
      return false;
    }
  }
  // ==================== CRUD ACARA ====================
  static Future<List<Map<String, dynamic>>> ambilSemuaAcara() async {
    try {
      return await FirebaseService.ambilSemuaAcara();
    } catch (e) {
      print('Error ambil acara: $e');
      return [];
    }
  }

  static Stream<List<Map<String, dynamic>>> ambilSemuaAcaraStream() {
    return FirebaseService.ambilSemuaAcaraStream();
  }

  static Future<bool> tambahAcara({
    required String namaAcara,
    required DateTime tanggal,
    required String jam,
    required String lokasi,
    required String deskripsi,
    String? urlPoster,
  }) async {
    try {
      await FirebaseService.tambahAcara(
        namaAcara: namaAcara,
        tanggal: tanggal,
        jam: jam,
        lokasi: lokasi,
        deskripsi: deskripsi,
        urlPoster: urlPoster,
      );
      return true;
    } catch (e) {
      print('Error tambah acara: $e');
      return false;
    }
  }

  static Future<bool> updateAcara(
    String idAcara, {
    required String namaAcara,
    required DateTime tanggal,
    required String jam,
    required String lokasi,
    required String deskripsi,
    String? urlPoster,
  }) async {
    try {
      await FirebaseService.updateAcara(
        idAcara,
        namaAcara: namaAcara,
        tanggal: tanggal,
        jam: jam,
        lokasi: lokasi,
        deskripsi: deskripsi,
        urlPoster: urlPoster,
      );
      return true;
    } catch (e) {
      print('Error update acara: $e');
      return false;
    }
  }

  static Future<bool> hapusAcara(String idAcara) async {
    try {
      await FirebaseService.hapusAcara(idAcara);
      return true;
    } catch (e) {
      print('Error hapus acara: $e');
      return false;
    }
  }
}
