import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _koleksiUsers = 'users';

  // Koleksi sinkronisasi data SQLite -> Firestore (fitur existing)
  static const String koleksiSyncUsers = 'sync_tb_users';
  static const String koleksiSyncKelas = 'sync_tb_kelas';
  static const String koleksiSyncJamaah = 'sync_tb_jamaah';
  static const String koleksiSyncAsistenKelas = 'sync_tb_asisten_kelas';

  static String _normalisasiEmail(String email) => email.trim().toLowerCase();

  static Future<UserCredential?> registerUser({
    required String email,
    required String password,
    required String nama,
    required String role,
    int? idUser,
  }) async {
    final emailFinal = _normalisasiEmail(email);

    // Create secondary app to avoid logging out the current user
    FirebaseApp tempApp = await Firebase.initializeApp(
      name: 'TempApp_${DateTime.now().millisecondsSinceEpoch}',
      options: Firebase.app().options,
    );

    try {
      final credential = await FirebaseAuth.instanceFor(app: tempApp)
          .createUserWithEmailAndPassword(
        email: emailFinal,
        password: password,
      );

      final user = credential.user;
      if (user != null &&
          (user.displayName == null || user.displayName!.isEmpty)) {
        await user.updateDisplayName(nama);
      }

      if (user != null) {
        await simpanProfilUser(
          uid: user.uid,
          nama: nama,
          email: emailFinal,
          role: role,
          idUser: idUser,
        );
      }

      return credential;
    } finally {
      await tempApp.delete();
    }
  }

  static Future<UserCredential> loginUser({
    required String email,
    required String password,
  }) async {
    return _auth.signInWithEmailAndPassword(
      email: _normalisasiEmail(email),
      password: password,
    );
  }

  static Future<void> simpanProfilUser({
    required String uid,
    required String nama,
    required String email,
    required String role,
    int? idUser,
  }) async {
    await _firestore.collection(_koleksiUsers).doc(uid).set({
      'nama': nama,
      'email': email,
      'role': role,
      'id_user': idUser,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  static Future<Map<String, dynamic>?> ambilProfilUser(String uid) async {
    final doc = await _firestore.collection(_koleksiUsers).doc(uid).get();
    return doc.exists ? doc.data() : null;
  }

  static Future<void> updateProfilUser(
    String uid,
    Map<String, dynamic> data,
  ) async {
    data['updated_at'] = FieldValue.serverTimestamp();
    await _firestore.collection(_koleksiUsers).doc(uid).update(data);
  }

  // ==================== CRUD KELAS ====================
  static const String _koleksiKelas = 'sync_tb_kelas';

  static Future<String> tambahKelas({
    required String namaKelas,
    String? deskripsi,
  }) async {
    final docRef = _firestore.collection(_koleksiKelas).doc();
    await docRef.set({
      'nama_kelas': namaKelas,
      'deskripsi': deskripsi ?? '',
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  static Future<List<Map<String, dynamic>>> ambilSemuaKelas() async {
    final snapshot = await _firestore
        .collection(_koleksiKelas)
        .orderBy('created_at')
        .get();
    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  static Stream<List<Map<String, dynamic>>> ambilSemuaKelasStream() {
    return _firestore
        .collection(_koleksiKelas)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
  }

  static Future<void> updateKelas(
    String idKelas,
    Map<String, dynamic> data,
  ) async {
    data['updated_at'] = FieldValue.serverTimestamp();
    await _firestore.collection(_koleksiKelas).doc(idKelas).update(data);
  }

  static Future<void> hapusKelas(String idKelas) async {
    await _firestore.collection(_koleksiKelas).doc(idKelas).delete();
  }

  // ==================== CRUD JAMAAH ====================
  static const String _koleksiJamaah = 'sync_tb_jamaah';

  static Future<String> tambahJamaah({
    required String namaLengkap,
    required String jenisKelamin,
    String? noHp,
    required String alamat,
    int statusJamaah = 1,
    String? idKelas,
  }) async {
    final docRef = _firestore.collection(_koleksiJamaah).doc();
    await docRef.set({
      'nama_lengkap': namaLengkap,
      'jenis_kelamin': jenisKelamin,
      'no_hp': noHp,
      'alamat': alamat,
      'status_jamaah': statusJamaah,
      'id_kelas': idKelas,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  static Future<List<Map<String, dynamic>>> ambilSemuaJamaah() async {
    final snapshot = await _firestore
        .collection(_koleksiJamaah)
        .orderBy('created_at')
        .get();
    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  static Stream<List<Map<String, dynamic>>> ambilSemuaJamaahStream() {
    return _firestore
        .collection(_koleksiJamaah)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
  }

  static Future<List<Map<String, dynamic>>> ambilJamaahByKelas(
    String idKelas,
  ) async {
    final snapshot = await _firestore
        .collection(_koleksiJamaah)
        .where('id_kelas', isEqualTo: idKelas)
        .where('status_jamaah', isEqualTo: 1)
        .get();
    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  static Stream<List<Map<String, dynamic>>> ambilJamaahByKelasStream(
    String idKelas,
  ) {
    return _firestore
        .collection(_koleksiJamaah)
        .where('id_kelas', isEqualTo: idKelas)
        .where('status_jamaah', isEqualTo: 1)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
  }

  static Future<void> updateJamaah(
    String idJamaah,
    Map<String, dynamic> data,
  ) async {
    data['updated_at'] = FieldValue.serverTimestamp();
    await _firestore.collection(_koleksiJamaah).doc(idJamaah).update(data);
  }

  static Future<void> hapusJamaah(String idJamaah) async {
    await _firestore.collection(_koleksiJamaah).doc(idJamaah).delete();
  }

  // ==================== CRUD ASISTEN KELAS ====================
  static const String _koleksiAsistenKelas = 'asisten_kelas';

  static Future<String> assignAsistenKeKelas({
    required String uidAsisten,
    required String idKelas,
  }) async {
    // Cek apakah sudah ada assignment
    final existing = await _firestore
        .collection(_koleksiAsistenKelas)
        .where('uid_asisten', isEqualTo: uidAsisten)
        .where('id_kelas', isEqualTo: idKelas)
        .get();

    if (existing.docs.isNotEmpty) {
      throw Exception('Asisten sudah di-assign ke kelas ini');
    }

    final docRef = _firestore.collection(_koleksiAsistenKelas).doc();
    await docRef.set({
      'uid_asisten': uidAsisten,
      'id_kelas': idKelas,
      'created_at': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  static Future<List<Map<String, dynamic>>> ambilAsistenByKelas(
    String idKelas,
  ) async {
    final snapshot = await _firestore
        .collection(_koleksiAsistenKelas)
        .where('id_kelas', isEqualTo: idKelas)
        .get();

    List<Map<String, dynamic>> result = [];
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final uidAsisten = data['uid_asisten'];
      final profilAsisten = await ambilProfilUser(uidAsisten);
      if (profilAsisten != null) {
        result.add({'id': doc.id, ...data, 'profil_asisten': profilAsisten});
      }
    }
    return result;
  }

  static Future<List<Map<String, dynamic>>> ambilKelasByAsisten(
    String uidAsisten,
  ) async {
    final snapshot = await _firestore
        .collection(_koleksiAsistenKelas)
        .where('uid_asisten', isEqualTo: uidAsisten)
        .get();

    List<Map<String, dynamic>> result = [];
    for (var doc in snapshot.docs) {
      final data = doc.data();
      final idKelas = data['id_kelas'];
      final dataKelas = await _firestore
          .collection(_koleksiKelas)
          .doc(idKelas)
          .get();
      if (dataKelas.exists) {
        result.add({
          'id': doc.id,
          ...data,
          'data_kelas': {'id': dataKelas.id, ...dataKelas.data()!},
        });
      }
    }
    return result;
  }

  static Future<void> hapusAsistenDariKelas(String idAssignment) async {
    await _firestore
        .collection(_koleksiAsistenKelas)
        .doc(idAssignment)
        .delete();
  }

  // ==================== UTILITY ====================
  static Future<void> logout() async {
    await _auth.signOut();
  }

  static User? get currentUser => _auth.currentUser;

  static Future<List<Map<String, dynamic>>> ambilSemuaUsersByRole(
    String role,
  ) async {
    final snapshot = await _firestore
        .collection(_koleksiUsers)
        .where('role', isEqualTo: role)
        .get();
    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  static Stream<List<Map<String, dynamic>>> ambilSemuaUsersByRoleStream(
    String role,
  ) {
    return _firestore
        .collection(_koleksiUsers)
        .where('role', isEqualTo: role)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
  }

  static Future<void> hapusUser(String uid) async {
    await _firestore.collection(_koleksiUsers).doc(uid).delete();
  }

  static Future<void> hapusDokumen({
    required String collection,
    required String documentId,
  }) async {
    await _firestore.collection(collection).doc(documentId).delete();
  }

  static Future<void> updateProfilUserBulk({
    required String uid,
    required String nama,
    required String email,
    required String role,
    int? idUser,
  }) async {
    final data = <String, dynamic>{
      'uid': uid,
      'nama': nama,
      'email': _normalisasiEmail(email),
      'role': role,
      'id_user': idUser,
      'updated_at': FieldValue.serverTimestamp(),
    };

    await _firestore
        .collection(_koleksiUsers)
        .doc(uid)
        .set(data, SetOptions(merge: true));
  }

  static Future<Map<String, dynamic>?> getProfilUserByUid(String uid) async {
    final snapshot = await _firestore.collection(_koleksiUsers).doc(uid).get();
    return snapshot.data();
  }

  static Future<void> sinkronDokumen({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
  }) async {
    final payload = <String, dynamic>{
      ...data,
      'updated_at': FieldValue.serverTimestamp(),
    };

    await _firestore
        .collection(collection)
        .doc(documentId)
        .set(payload, SetOptions(merge: true));
  }

  // ==================== CRUD PENGUMUMAN ====================
  static const String _koleksiPengumuman = 'pengumuman';

  static Future<List<Map<String, dynamic>>> ambilSemuaPengumuman() async {
    final snapshot = await _firestore
        .collection(_koleksiPengumuman)
        .orderBy('created_at', descending: true)
        .get();
    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  static Stream<List<Map<String, dynamic>>> ambilSemuaPengumumanStream() {
    return _firestore
        .collection(_koleksiPengumuman)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
  }

  static Future<String> tambahPengumuman({
    required String judul,
    required String isi,
  }) async {
    final docRef = _firestore.collection(_koleksiPengumuman).doc();
    await docRef.set({
      'judul': judul,
      'isi': isi,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  static Future<void> updatePengumuman(
    String idPengumuman, {
    required String judul,
    required String isi,
  }) async {
    await _firestore.collection(_koleksiPengumuman).doc(idPengumuman).update({
      'judul': judul,
      'isi': isi,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> hapusPengumuman(String idPengumuman) async {
    await _firestore.collection(_koleksiPengumuman).doc(idPengumuman).delete();
  }

  // ==================== CRUD ACARA ====================
  static const String _koleksiAcara = 'acara';

  static Future<List<Map<String, dynamic>>> ambilSemuaAcara() async {
    final snapshot = await _firestore
        .collection(_koleksiAcara)
        .orderBy('tanggal', descending: false)
        .get();
    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  static Stream<List<Map<String, dynamic>>> ambilSemuaAcaraStream() {
    return _firestore
        .collection(_koleksiAcara)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
  }

  static Future<String> tambahAcara({
    required String namaAcara,
    required DateTime tanggal,
    required String jam,
    required String lokasi,
    required String deskripsi,
    String? urlPoster,
  }) async {
    final docRef = _firestore.collection(_koleksiAcara).doc();
    await docRef.set({
      'nama_acara': namaAcara,
      'tanggal': tanggal.toIso8601String(),
      'jam': jam,
      'lokasi': lokasi,
      'deskripsi': deskripsi,
      'url_poster': urlPoster ?? '',
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  static Future<void> updateAcara(
    String idAcara, {
    required String namaAcara,
    required DateTime tanggal,
    required String jam,
    required String lokasi,
    required String deskripsi,
    String? urlPoster,
  }) async {
    await _firestore.collection(_koleksiAcara).doc(idAcara).update({
      'nama_acara': namaAcara,
      'tanggal': tanggal.toIso8601String(),
      'jam': jam,
      'lokasi': lokasi,
      'deskripsi': deskripsi,
      'url_poster': urlPoster ?? '',
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> hapusAcara(String idAcara) async {
    await _firestore.collection(_koleksiAcara).doc(idAcara).delete();
  }

  // ==================== CRUD JADWAL ====================
  static const String _koleksiJadwal = 'jadwal';

  static Future<List<Map<String, dynamic>>> ambilSemuaJadwal() async {
    final snapshot = await _firestore
        .collection(_koleksiJadwal)
        .orderBy('tanggal', descending: false)
        .get();
    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  static Stream<List<Map<String, dynamic>>> ambilSemuaJadwalStream() {
    return _firestore
        .collection(_koleksiJadwal)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
  }

  static Future<String> tambahJadwal({
    required String idKelas,
    required String idUser,
    required DateTime tanggal,
    required String waktuMulai,
    required String waktuSelesai,
    String? materiPembahasan,
    String? namaPemateri,
    int statusJadwal = 0,
    String? alasanPerubahan,
  }) async {
    final docRef = _firestore.collection(_koleksiJadwal).doc();
    await docRef.set({
      'id_kelas': idKelas,
      'id_user': idUser,
      'tanggal': tanggal.toIso8601String().split('T')[0],
      'waktu_mulai': waktuMulai,
      'waktu_selesai': waktuSelesai,
      'materi_pembahasan': materiPembahasan ?? '',
      'nama_pemateri': namaPemateri ?? '',
      'status_jadwal': statusJadwal,
      'alasan_perubahan': alasanPerubahan ?? '',
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  static Future<List<Map<String, dynamic>>> ambilJadwalByKelas(
    String idKelas,
  ) async {
    final snapshot = await _firestore
        .collection(_koleksiJadwal)
        .where('id_kelas', isEqualTo: idKelas)
        .orderBy('tanggal', descending: false)
        .get();
    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  static Stream<List<Map<String, dynamic>>> ambilJadwalByKelasStream(
    String idKelas,
  ) {
    return _firestore
        .collection(_koleksiJadwal)
        .where('id_kelas', isEqualTo: idKelas)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList());
  }

  static Future<List<Map<String, dynamic>>> ambilJadwalByAsisten(
    String uidAsisten,
  ) async {
    // Ambil kelas yang di-assign ke asisten
    final kelasAsisten = await ambilKelasByAsisten(uidAsisten);
    final idKelasList = kelasAsisten
        .map((k) => k['id_kelas'] as String)
        .toList();

    if (idKelasList.isEmpty) return [];

    final snapshot = await _firestore
        .collection(_koleksiJadwal)
        .where('id_kelas', whereIn: idKelasList)
        .orderBy('tanggal', descending: false)
        .get();
    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  static Future<void> updateJadwal(
    String idJadwal, {
    required String idKelas,
    required String idUser,
    required DateTime tanggal,
    required String waktuMulai,
    required String waktuSelesai,
    String? materiPembahasan,
    String? namaPemateri,
    int statusJadwal = 0,
    String? alasanPerubahan,
  }) async {
    await _firestore.collection(_koleksiJadwal).doc(idJadwal).update({
      'id_kelas': idKelas,
      'id_user': idUser,
      'tanggal': tanggal.toIso8601String().split('T')[0],
      'waktu_mulai': waktuMulai,
      'waktu_selesai': waktuSelesai,
      'materi_pembahasan': materiPembahasan ?? '',
      'nama_pemateri': namaPemateri ?? '',
      'status_jadwal': statusJadwal,
      'alasan_perubahan': alasanPerubahan ?? '',
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> updateStatusJadwal(
    String idJadwal, {
    required int statusJadwal,
    String? alasanPerubahan,
  }) async {
    await _firestore.collection(_koleksiJadwal).doc(idJadwal).update({
      'status_jadwal': statusJadwal,
      'alasan_perubahan': alasanPerubahan ?? '',
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> hapusJadwal(String idJadwal) async {
    await _firestore.collection(_koleksiJadwal).doc(idJadwal).delete();
  }

  // ==================== CRUD ABSENSI ====================
  static const String _koleksiAbsensi = 'absensi';

  static Future<String> simpanAbsensi({
    required String idJadwal,
    required String idJamaah,
    required String statusAbsen,
    String? catatan,
  }) async {
    // Cek apakah sudah ada absensi untuk jamaah ini di jadwal ini
    final existing = await _firestore
        .collection(_koleksiAbsensi)
        .where('id_jadwal', isEqualTo: idJadwal)
        .where('id_jamaah', isEqualTo: idJamaah)
        .get();

    final docRef = existing.docs.isNotEmpty
        ? _firestore.collection(_koleksiAbsensi).doc(existing.docs.first.id)
        : _firestore.collection(_koleksiAbsensi).doc();

    await docRef.set({
      'id_jadwal': idJadwal,
      'id_jamaah': idJamaah,
      'status_absen': statusAbsen,
      'catatan': catatan ?? '',
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return docRef.id;
  }

  static Future<List<Map<String, dynamic>>> ambilAbsensiByJadwal(
    String idJadwal,
  ) async {
    final snapshot = await _firestore
        .collection(_koleksiAbsensi)
        .where('id_jadwal', isEqualTo: idJadwal)
        .get();
    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  static Future<List<Map<String, dynamic>>> ambilAbsensiByJamaah(
    String idJamaah,
  ) async {
    final snapshot = await _firestore
        .collection(_koleksiAbsensi)
        .where('id_jamaah', isEqualTo: idJamaah)
        .orderBy('created_at', descending: true)
        .get();
    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  // ==================== LAPORAN ====================
  static Future<List<Map<String, dynamic>>> ambilDataLaporanAbsensi({
    required int bulan,
    required int tahun,
    String? idKelas,
  }) async {
    // Query jadwal dalam bulan dan tahun tertentu
    final startDate = DateTime(tahun, bulan, 1);
    final endDate = DateTime(tahun, bulan + 1, 0); // Akhir bulan

    var query = _firestore
        .collection(_koleksiJadwal)
        .where(
          'tanggal',
          isGreaterThanOrEqualTo: startDate.toIso8601String().split('T')[0],
        )
        .where(
          'tanggal',
          isLessThanOrEqualTo: endDate.toIso8601String().split('T')[0],
        );

    if (idKelas != null) {
      query = query.where('id_kelas', isEqualTo: idKelas);
    }

    final jadwalSnapshot = await query.get();

    List<Map<String, dynamic>> result = [];

    for (var jadwalDoc in jadwalSnapshot.docs) {
      final jadwalData = jadwalDoc.data();
      final idJadwal = jadwalDoc.id;

      // Ambil absensi untuk jadwal ini
      final absensiSnapshot = await _firestore
          .collection(_koleksiAbsensi)
          .where('id_jadwal', isEqualTo: idJadwal)
          .get();

      for (var absensiDoc in absensiSnapshot.docs) {
        final absensiData = absensiDoc.data();

        // Ambil data jamaah
        final jamaahDoc = await _firestore
            .collection(_koleksiJamaah)
            .doc(absensiData['id_jamaah'])
            .get();

        if (jamaahDoc.exists) {
          result.add({
            'tanggal': jadwalData['tanggal'],
            'nama_kelas': await _getNamaKelas(jadwalData['id_kelas']),
            'nama_jamaah': jamaahDoc.data()!['nama_lengkap'],
            'status_absen': absensiData['status_absen'],
            'catatan': absensiData['catatan'] ?? '',
          });
        }
      }
    }

    return result;
  }

  static Future<String> _getNamaKelas(String idKelas) async {
    final kelasDoc = await _firestore
        .collection(_koleksiKelas)
        .doc(idKelas)
        .get();
    return kelasDoc.exists
        ? kelasDoc.data()!['nama_kelas'] ?? 'Unknown'
        : 'Unknown';
  }
}
