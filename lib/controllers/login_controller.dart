import 'package:al_falah_app/database/sqflite_helper.dart';
import 'package:al_falah_app/models/model_user.dart';
import 'package:al_falah_app/services/firebase_service.dart';
import 'package:al_falah_app/services/local_storage_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sqflite/sqflite.dart';

class LoginController {
  // Fungsi untuk memproses Login
  static Future<UserModel?> loginUser({
    required String email,
    required String password,
  }) async {
    final emailFinal = email.trim().toLowerCase();
    final passwordFinal = password.trim();

    // 1. Buka koneksi ke database
    final dbs = await DBHelper.db();

    // 2. Siapkan fallback user lokal (buat akun lama yang belum sinkron ke Firebase)
    final userLokalByCredential = await _cariUserLokal(
      dbs,
      email: emailFinal,
      password: passwordFinal,
    );

    try {
      // 3. Coba login via Firebase Auth dulu
      final credential = await FirebaseService.loginUser(
        email: emailFinal,
        password: passwordFinal,
      );

      final dataUser = await _sinkronisasiUserSetelahFirebaseLogin(
        dbs: dbs,
        credential: credential,
        email: emailFinal,
        password: passwordFinal,
        fallbackUserLokal: userLokalByCredential,
      );

      if (dataUser != null) {
        print("Login Firebase Sukses: ${dataUser.email} | Role: ${dataUser.role}");
        await _sinkronUserLokalKeFirestore(dataUser);
        await _simpanSesi(dataUser);
        return dataUser;
      }
    } on FirebaseAuthException catch (e) {
      print(
        "Login Firebase gagal (${e.code}). Coba fallback SQLite untuk akun lama.",
      );

      if (userLokalByCredential != null) {
        // Migrasi akun lama ke Firebase secara otomatis saat berhasil login lokal
        await _cobaMigrasiUserLokalKeFirebase(userLokalByCredential);
        await _sinkronUserLokalKeFirestore(userLokalByCredential);
        await _simpanSesi(userLokalByCredential);
        print(
          "Login Lokal Sukses (fallback): ${userLokalByCredential.email} | Role: ${userLokalByCredential.role}",
        );
        return userLokalByCredential;
      }

      print("Login Gagal: Email atau Password salah");
      return null;
    } catch (e) {
      // Kalau ada error non-Firebase, kita tetap kasih kesempatan login lokal
      print("Error saat login Firebase/non-Firebase: $e");
      if (userLokalByCredential != null) {
        await _sinkronUserLokalKeFirestore(userLokalByCredential);
        await _simpanSesi(userLokalByCredential);
        print(
          "Login Lokal Sukses setelah error Firebase: ${userLokalByCredential.email} | Role: ${userLokalByCredential.role}",
        );
        return userLokalByCredential;
      }
      rethrow;
    }

    // Jika entah kenapa tidak ada user dari Firebase, coba fallback terakhir
    if (userLokalByCredential != null) {
      await _sinkronUserLokalKeFirestore(userLokalByCredential);
      await _simpanSesi(userLokalByCredential);
      return userLokalByCredential;
    }

    print("Login Gagal: Email atau Password salah");
    return null;
  }

  static Future<UserModel?> _sinkronisasiUserSetelahFirebaseLogin({
    required Database dbs,
    required UserCredential credential,
    required String email,
    required String password,
    required UserModel? fallbackUserLokal,
  }) async {
    final uid = credential.user?.uid;
    if (uid == null) return fallbackUserLokal;

    final profilFirebase = await FirebaseService.getProfilUserByUid(uid);

    // Prioritaskan user lokal jika ada (biar id_user tetap konsisten dengan relasi tabel lain)
    final userLokal =
        fallbackUserLokal ?? await _cariUserLokal(dbs, email: email);

    if (userLokal != null) {
      await FirebaseService.simpanProfilUser(
        uid: uid,
        nama: userLokal.nama,
        email: userLokal.email,
        role: userLokal.role,
        idUser: userLokal.idUser,
      );
      await _sinkronUserLokalKeFirestore(userLokal);
      return userLokal;
    }

    // Kalau user belum ada di SQLite, bentuk dulu dari profil Firebase
    final namaFirebase = (profilFirebase?['nama'] as String?)?.trim();
    final roleFirebase = (profilFirebase?['role'] as String?)?.trim();

    final namaFinal =
        (namaFirebase == null || namaFirebase.isEmpty)
            ? email.split('@').first
            : namaFirebase;

    final roleFinal =
        (roleFirebase == 'admin' || roleFirebase == 'asisten')
            ? roleFirebase!
            : 'asisten';

    final idBaru = await dbs.insert('tb_users', {
      'nama': namaFinal,
      'email': email,
      // Simpan password terakhir sukses login agar fallback lokal tetap bisa dipakai
      'password': password,
      'role': roleFinal,
    });

    final userBaru = UserModel(
      idUser: idBaru,
      nama: namaFinal,
      email: email,
      password: password,
      role: roleFinal,
    );

    await FirebaseService.simpanProfilUser(
      uid: uid,
      nama: userBaru.nama,
      email: userBaru.email,
      role: userBaru.role,
      idUser: userBaru.idUser,
    );
    await _sinkronUserLokalKeFirestore(userBaru);

    return userBaru;
  }

  static Future<void> _cobaMigrasiUserLokalKeFirebase(UserModel userLokal) async {
    try {
      await FirebaseService.registerUser(
        email: userLokal.email,
        password: userLokal.password,
        nama: userLokal.nama,
        role: userLokal.role,
        idUser: userLokal.idUser,
      );
      return;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        try {
          await FirebaseService.loginUser(
            email: userLokal.email,
            password: userLokal.password,
          );
        } catch (_) {
          // Kalau gagal login ulang, kita cukup lewati agar login lokal tetap lanjut.
        }

        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null) {
          await FirebaseService.simpanProfilUser(
            uid: uid,
            nama: userLokal.nama,
            email: userLokal.email,
            role: userLokal.role,
            idUser: userLokal.idUser,
          );
        }
        await _sinkronUserLokalKeFirestore(userLokal);
        return;
      }

      print("Migrasi user lokal ke Firebase gagal (${e.code}): ${e.message}");
    } catch (e) {
      print("Migrasi user lokal ke Firebase gagal: $e");
    }
  }

  static Future<void> _sinkronUserLokalKeFirestore(UserModel user) async {
    if (user.idUser == null) return;

    try {
      await FirebaseService.sinkronDokumen(
        collection: FirebaseService.koleksiSyncUsers,
        documentId: 'user_${user.idUser}',
        data: user.toMap(),
      );
    } catch (e) {
      print('Sinkron user lokal ke Firestore gagal (diabaikan): $e');
    }
  }

  static Future<UserModel?> _cariUserLokal(
    Database dbs, {
    required String email,
    String? password,
  }) async {
    final where = password == null ? 'email = ?' : 'email = ? AND password = ?';

    final whereArgs =
        password == null ? <Object?>[email] : <Object?>[email, password];

    final results = await dbs.query(
      'tb_users',
      where: where,
      whereArgs: whereArgs,
      limit: 1,
    );

    if (results.isEmpty) return null;
    return UserModel.fromMap(results.first);
  }

  static Future<void> _simpanSesi(UserModel dataUser) async {
    final pref = PreferenceHandler();
    await pref.init();
    await pref.saveUserSession(
      true,
      dataUser.idUser ?? 0,
      dataUser.role,
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
