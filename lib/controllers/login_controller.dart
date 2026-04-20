import 'package:al_falah_app/models/model_user.dart';
import 'package:al_falah_app/services/firebase_service.dart';
import 'package:al_falah_app/services/local_storage_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginController {
  // Fungsi untuk memproses Login
  static Future<UserModel?> loginUser({
    required String email,
    required String password,
  }) async {
    final emailFinal = email.trim().toLowerCase();
    final passwordFinal = password.trim();

    try {
      // Coba login via Firebase Auth
      final credential = await FirebaseService.loginUser(
        email: emailFinal,
        password: passwordFinal,
      );

      final uid = credential.user?.uid;
      if (uid == null) {
        return null; // Should not happen if successful
      }

      // Ambil data profil dari Firestore
      final profilFirebase = await FirebaseService.getProfilUserByUid(uid);
      
      if (profilFirebase != null) {
        final userBaru = UserModel.fromMap({
          ...profilFirebase,
          'uid': uid,
          'password': passwordFinal,
        });

        print("Login Firebase Sukses: ${userBaru.email} | Role: ${userBaru.role}");
        await _simpanSesi(userBaru);
        return userBaru;
      } else {
         print("Login Gagal: Data profil tidak ditemukan di database.");
         return null;
      }
    } on FirebaseAuthException catch (e) {
      print("Login Firebase gagal (${e.code}): ${e.message}");
      return null;
    } catch (e) {
      print("Error saat login: $e");
      return null;
    }
  }

  static Future<void> _simpanSesi(UserModel dataUser) async {
    final pref = PreferenceHandler();
    await pref.init();
    await pref.saveUserSession(
      true,
      dataUser.uid ?? '',
      dataUser.role,
      dataUser.nama,
      dataUser.email,
    );
  }

  // Fungsi untuk Logout (Keluar)
  static Future<void> logout() async {
    final pref = PreferenceHandler();
    await pref.init();
    await pref.logout();

    try {
      await FirebaseService.logout();
    } catch (e) {
      print("Gagal logout Firebase (diabaikan): $e");
    }

    print("Berhasil Logout dan hapus sesi");
  }
}
