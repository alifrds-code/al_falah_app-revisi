import 'package:al_falah_app/models/model_jamaah.dart';
import 'package:al_falah_app/models/model_kelas.dart';
import 'package:al_falah_app/models/model_user.dart';
import 'package:al_falah_app/services/firebase_service.dart';

class AdminControllerFirebase {
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
    try {
      await FirebaseService.registerUser(
        email: email,
        password: password,
        nama: nama,
        role: 'asisten',
      );
      return true;
    } catch (e) {
      print('Error tambah asisten: $e');
      return false;
    }
  }

  static Future<bool> updateAsisten(
    String uid,
    Map<String, dynamic> data,
  ) async {
    try {
      await FirebaseService.updateProfilUser(uid, data);
      return true;
    } catch (e) {
      print('Error update asisten: $e');
      return false;
    }
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
}
