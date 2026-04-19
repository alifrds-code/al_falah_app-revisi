import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// Kelas utama pengatur database SQLite
class DBHelper {
  // Membuka / membuat database
  static Future<Database> db() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'al_falah.db'),
      version: 3, // Naik versi karena ada perbaikan tipe data
      onCreate: (db, version) async {
        // Aktifkan foreign key agar ON DELETE CASCADE bisa jalan
        await db.execute('PRAGMA foreign_keys = ON');

        // 1. Tabel Users (Admin & Asisten)
        await db.execute('''
          CREATE TABLE tb_users (
            id_user INTEGER PRIMARY KEY AUTOINCREMENT,
            nama TEXT NOT NULL,
            email TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL,
            role TEXT NOT NULL
          )
        ''');

        // 2. Tabel Kelas
        await db.execute('''
          CREATE TABLE tb_kelas (
            id_kelas INTEGER PRIMARY KEY AUTOINCREMENT,
            nama_kelas TEXT NOT NULL
          )
        ''');

        // 3. Tabel Pivot: Asisten bisa megang banyak kelas
        await db.execute('''
          CREATE TABLE tb_asisten_kelas (
            id_penugasan INTEGER PRIMARY KEY AUTOINCREMENT,
            id_user INTEGER NOT NULL,
            id_kelas INTEGER NOT NULL,
            UNIQUE(id_user, id_kelas),
            FOREIGN KEY (id_user) REFERENCES tb_users (id_user) ON DELETE CASCADE,
            FOREIGN KEY (id_kelas) REFERENCES tb_kelas (id_kelas) ON DELETE CASCADE
          )
        ''');

        // 4. Tabel Jamaah
        await db.execute('''
          CREATE TABLE tb_jamaah (
            id_jamaah INTEGER PRIMARY KEY AUTOINCREMENT,
            nama_lengkap TEXT NOT NULL,
            jenis_kelamin TEXT NOT NULL,
            no_hp TEXT,
            alamat TEXT NOT NULL,
            status_jamaah INTEGER NOT NULL DEFAULT 1,
            id_kelas INTEGER,
            FOREIGN KEY (id_kelas) REFERENCES tb_kelas (id_kelas) ON DELETE CASCADE
          )
        ''');

        // 5. Tabel Jadwal (status pakai TEXT)
        await db.execute('''
          CREATE TABLE tb_jadwal (
            id_jadwal INTEGER PRIMARY KEY AUTOINCREMENT,
            materi_pembahasan TEXT,
            nama_pemateri TEXT NOT NULL,
            tanggal TEXT NOT NULL,
            waktu_mulai TEXT NOT NULL,
            waktu_selesai TEXT NOT NULL,
            status_jadwal TEXT NOT NULL DEFAULT 'Sesuai Jadwal',
            alasan_perubahan TEXT,
            id_kelas INTEGER NOT NULL,
            id_user INTEGER NOT NULL,
            FOREIGN KEY (id_kelas) REFERENCES tb_kelas (id_kelas) ON DELETE CASCADE,
            FOREIGN KEY (id_user) REFERENCES tb_users (id_user) ON DELETE CASCADE
          )
        ''');

        // 6. Tabel Absensi (1 jamaah tidak bisa diabsen 2x di jadwal yang sama)
        await db.execute('''
          CREATE TABLE tb_absensi (
            id_absensi INTEGER PRIMARY KEY AUTOINCREMENT,
            id_jadwal INTEGER NOT NULL,
            id_jamaah INTEGER NOT NULL,
            status_hadir TEXT NOT NULL,
            waktu_absen TEXT NOT NULL,
            UNIQUE(id_jadwal, id_jamaah),
            FOREIGN KEY (id_jadwal) REFERENCES tb_jadwal (id_jadwal) ON DELETE CASCADE,
            FOREIGN KEY (id_jamaah) REFERENCES tb_jamaah (id_jamaah) ON DELETE CASCADE
          )
        ''');

        // 7. Tabel Pengumuman
        await db.execute('''
          CREATE TABLE tb_pengumuman (
            id_pengumuman INTEGER PRIMARY KEY AUTOINCREMENT,
            judul TEXT NOT NULL,
            isi_teks TEXT NOT NULL,
            tanggal_post TEXT NOT NULL
          )
        ''');

        // 8. Tabel Acara
        await db.execute('''
          CREATE TABLE tb_acara (
            id_acara INTEGER PRIMARY KEY AUTOINCREMENT,
            nama_acara TEXT NOT NULL,
            deskripsi TEXT NOT NULL,
            tanggal_acara TEXT NOT NULL,
            waktu TEXT NOT NULL,
            lokasi TEXT NOT NULL,
            nama_pemateri TEXT NOT NULL,
            foto_poster TEXT
          )
        ''');

        // SEEDING: Tanam akun Super Admin pertama otomatis
        await db.insert('tb_users', {
          'nama': 'Ketua Yayasan',
          'email': 'admin@alfalah.com',
          'password': 'admin123',
          'role': 'admin',
        });
      },

      // Kalau ada upgrade versi database
      onUpgrade: (db, oldVersion, newVersion) async {
        await db.execute('PRAGMA foreign_keys = ON');

        // Upgrade dari versi 1 atau 2 ke 3:
        // Hapus tabel jadwal lama dan buat ulang dengan tipe TEXT yang benar
        if (oldVersion < 3) {
          // Drop tabel yang bergantung dulu (karena foreign key)
          await db.execute('DROP TABLE IF EXISTS tb_absensi');
          await db.execute('DROP TABLE IF EXISTS tb_jadwal');

          // Buat ulang tabel jadwal dengan status TEXT
          await db.execute('''
            CREATE TABLE tb_jadwal (
              id_jadwal INTEGER PRIMARY KEY AUTOINCREMENT,
              materi_pembahasan TEXT,
              nama_pemateri TEXT NOT NULL,
              tanggal TEXT NOT NULL,
              waktu_mulai TEXT NOT NULL,
              waktu_selesai TEXT NOT NULL,
              status_jadwal TEXT NOT NULL DEFAULT 'Sesuai Jadwal',
              alasan_perubahan TEXT,
              id_kelas INTEGER NOT NULL,
              id_user INTEGER NOT NULL,
              FOREIGN KEY (id_kelas) REFERENCES tb_kelas (id_kelas) ON DELETE CASCADE,
              FOREIGN KEY (id_user) REFERENCES tb_users (id_user) ON DELETE CASCADE
            )
          ''');

          // Buat ulang tabel absensi
          await db.execute('''
            CREATE TABLE tb_absensi (
              id_absensi INTEGER PRIMARY KEY AUTOINCREMENT,
              id_jadwal INTEGER NOT NULL,
              id_jamaah INTEGER NOT NULL,
              status_hadir TEXT NOT NULL,
              waktu_absen TEXT NOT NULL,
              UNIQUE(id_jadwal, id_jamaah),
              FOREIGN KEY (id_jadwal) REFERENCES tb_jadwal (id_jadwal) ON DELETE CASCADE,
              FOREIGN KEY (id_jamaah) REFERENCES tb_jamaah (id_jamaah) ON DELETE CASCADE
            )
          ''');
        }
      },

      // Aktifkan foreign key setiap kali database dibuka
      onOpen: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  // ============================================================
  //  USERS & LOGIN
  // ============================================================

  // Login: cek email dan password
  static Future<Map<String, dynamic>?> login(String email, String password) async {
    final db = await DBHelper.db();
    final res = await db.query(
      'tb_users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );
    return res.isNotEmpty ? res.first : null;
  }

  // Simpan user baru (Admin/Asisten)
  static Future<int> insertUser(Map<String, dynamic> data) async {
    final db = await DBHelper.db();
    return db.insert('tb_users', data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Ambil semua akun Asisten
  static Future<List<Map<String, dynamic>>> getAllAsistens() async {
    final db = await DBHelper.db();
    return db.query('tb_users', where: 'role = ?', whereArgs: ['asisten']);
  }

  // Update data user
  static Future<int> updateUser(int id, Map<String, dynamic> data) async {
    final db = await DBHelper.db();
    return db.update('tb_users', data, where: 'id_user = ?', whereArgs: [id]);
  }

  // Hapus akun Asisten
  static Future<int> deleteAsisten(int id) async {
    final db = await DBHelper.db();
    return db.delete('tb_users', where: 'id_user = ?', whereArgs: [id]);
  }

  // ============================================================
  //  KELAS
  // ============================================================

  static Future<int> insertKelas(String nama) async {
    final db = await DBHelper.db();
    return db.insert('tb_kelas', {'nama_kelas': nama});
  }

  static Future<List<Map<String, dynamic>>> getAllKelas() async {
    final db = await DBHelper.db();
    return db.query('tb_kelas', orderBy: 'nama_kelas ASC');
  }

  static Future<int> updateKelas(int id, String nama) async {
    final db = await DBHelper.db();
    return db.update(
      'tb_kelas',
      {'nama_kelas': nama},
      where: 'id_kelas = ?',
      whereArgs: [id],
    );
  }

  static Future<int> deleteKelas(int id) async {
    final db = await DBHelper.db();
    return db.delete('tb_kelas', where: 'id_kelas = ?', whereArgs: [id]);
  }

  // ============================================================
  //  JAMAAH
  // ============================================================

  static Future<int> insertJamaah(Map<String, dynamic> data) async {
    final db = await DBHelper.db();
    // Jangan ikutkan id_jamaah (biar auto increment)
    data.remove('id_jamaah');
    return db.insert('tb_jamaah', data);
  }

  // Ambil jamaah berdasarkan kelas tertentu
  static Future<List<Map<String, dynamic>>> getJamaahByKelas(int idKelas) async {
    final db = await DBHelper.db();
    return db.query(
      'tb_jamaah',
      where: 'id_kelas = ? AND status_jamaah = 1',
      whereArgs: [idKelas],
      orderBy: 'nama_lengkap ASC',
    );
  }

  // Ambil semua jamaah beserta nama kelasnya (pakai JOIN)
  static Future<List<Map<String, dynamic>>> getAllJamaah() async {
    final db = await DBHelper.db();
    return db.rawQuery('''
      SELECT j.*, k.nama_kelas 
      FROM tb_jamaah j 
      LEFT JOIN tb_kelas k ON j.id_kelas = k.id_kelas
      ORDER BY j.nama_lengkap ASC
    ''');
  }

  // Update data jamaah
  static Future<int> updateJamaah(int id, Map<String, dynamic> data) async {
    final db = await DBHelper.db();
    data.remove('id_jamaah');
    data.remove('nama_kelas');
    return db.update('tb_jamaah', data, where: 'id_jamaah = ?', whereArgs: [id]);
  }

  // Hapus jamaah
  static Future<int> deleteJamaah(int id) async {
    final db = await DBHelper.db();
    return db.delete('tb_jamaah', where: 'id_jamaah = ?', whereArgs: [id]);
  }

  // ============================================================
  //  JADWAL
  // ============================================================

  static Future<int> insertJadwal(Map<String, dynamic> data) async {
    final db = await DBHelper.db();
    data.remove('id_jadwal');
    return db.insert('tb_jadwal', data);
  }

  // Ambil jadwal berdasarkan list id kelas (untuk tampilan jamaah)
  static Future<List<Map<String, dynamic>>> getJadwalByKelas(List<int> ids) async {
    final db = await DBHelper.db();
    if (ids.isEmpty) return [];
    String tanda = List.filled(ids.length, '?').join(',');
    return db.rawQuery('''
      SELECT j.*, k.nama_kelas 
      FROM tb_jadwal j 
      JOIN tb_kelas k ON j.id_kelas = k.id_kelas 
      WHERE j.id_kelas IN ($tanda)
      ORDER BY j.tanggal ASC, j.waktu_mulai ASC
    ''', ids);
  }

  // Ambil semua jadwal yang dibuat oleh asisten tertentu
  static Future<List<Map<String, dynamic>>> getJadwalByAsisten(int idUser) async {
    final db = await DBHelper.db();
    return db.rawQuery('''
      SELECT j.*, k.nama_kelas 
      FROM tb_jadwal j 
      JOIN tb_kelas k ON j.id_kelas = k.id_kelas 
      WHERE j.id_user = ?
      ORDER BY j.tanggal DESC
    ''', [idUser]);
  }

  // Update status jadwal (Ditunda/Dibatalkan)
  static Future<int> updateStatusJadwal(int id, String status, String? alasan) async {
    final db = await DBHelper.db();
    return db.update(
      'tb_jadwal',
      {
        'status_jadwal': status,
        'alasan_perubahan': alasan,
      },
      where: 'id_jadwal = ?',
      whereArgs: [id],
    );
  }

  // Update jadwal lengkap (edit semua field)
  static Future<int> updateJadwal(int id, Map<String, dynamic> data) async {
    final db = await DBHelper.db();
    data.remove('id_jadwal');
    data.remove('nama_kelas');
    return db.update('tb_jadwal', data, where: 'id_jadwal = ?', whereArgs: [id]);
  }

  // Hapus jadwal
  static Future<int> deleteJadwal(int id) async {
    final db = await DBHelper.db();
    return db.delete('tb_jadwal', where: 'id_jadwal = ?', whereArgs: [id]);
  }

  // ============================================================
  //  ABSENSI
  // ============================================================

  // Simpan absensi secara batch (sekaligus banyak jamaah)
  static Future<void> recordAbsen(int idJadwal, List<Map<String, dynamic>> batch) async {
    final db = await DBHelper.db();
    await db.transaction((txn) async {
      for (var item in batch) {
        await txn.insert(
          'tb_absensi',
          {
            'id_jadwal': idJadwal,
            'id_jamaah': item['id_jamaah'],
            'status_hadir': item['status_hadir'],
            'waktu_absen': DateTime.now().toIso8601String(),
          },
          // Kalau sudah ada, ganti (update)
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  // Ambil data absensi berdasarkan jadwal tertentu
  static Future<List<Map<String, dynamic>>> getAbsensiByJadwal(int idJadwal) async {
    final db = await DBHelper.db();
    return db.query('tb_absensi', where: 'id_jadwal = ?', whereArgs: [idJadwal]);
  }

  // ============================================================
  //  PENGUMUMAN
  // ============================================================

  static Future<List<Map<String, dynamic>>> getAllPengumuman() async {
    final db = await DBHelper.db();
    return db.query('tb_pengumuman', orderBy: 'tanggal_post DESC');
  }

  static Future<int> insertPengumuman(String judul, String isi) async {
    final db = await DBHelper.db();
    return db.insert('tb_pengumuman', {
      'judul': judul,
      'isi_teks': isi,
      'tanggal_post': DateTime.now().toIso8601String(),
    });
  }

  static Future<int> updatePengumuman(int id, String judul, String isi) async {
    final db = await DBHelper.db();
    return db.update(
      'tb_pengumuman',
      {'judul': judul, 'isi_teks': isi},
      where: 'id_pengumuman = ?',
      whereArgs: [id],
    );
  }

  static Future<int> deletePengumuman(int id) async {
    final db = await DBHelper.db();
    return db.delete('tb_pengumuman', where: 'id_pengumuman = ?', whereArgs: [id]);
  }

  // ============================================================
  //  ACARA
  // ============================================================

  static Future<List<Map<String, dynamic>>> getAllAcara() async {
    final db = await DBHelper.db();
    return db.query('tb_acara', orderBy: 'tanggal_acara ASC');
  }

  static Future<int> insertAcara(Map<String, dynamic> data) async {
    final db = await DBHelper.db();
    data.remove('id_acara');
    return db.insert('tb_acara', data);
  }

  static Future<int> updateAcara(int id, Map<String, dynamic> data) async {
    final db = await DBHelper.db();
    data.remove('id_acara');
    return db.update('tb_acara', data, where: 'id_acara = ?', whereArgs: [id]);
  }

  static Future<int> deleteAcara(int id) async {
    final db = await DBHelper.db();
    return db.delete('tb_acara', where: 'id_acara = ?', whereArgs: [id]);
  }

  // ============================================================
  //  LAPORAN
  // ============================================================

  // Ambil data absensi untuk keperluan export (filter bulan & kelas)
  static Future<List<Map<String, dynamic>>> getReportData(int idKelas, String bulan) async {
    final db = await DBHelper.db();
    // bulan format: "2025-04"
    return db.rawQuery('''
      SELECT j.nama_lengkap, jd.tanggal, jd.materi_pembahasan, a.status_hadir
      FROM tb_absensi a
      JOIN tb_jamaah j ON a.id_jamaah = j.id_jamaah
      JOIN tb_jadwal jd ON a.id_jadwal = jd.id_jadwal
      WHERE jd.id_kelas = ? AND jd.tanggal LIKE ?
      ORDER BY jd.tanggal ASC, j.nama_lengkap ASC
    ''', [idKelas, '$bulan%']);
  }
}
