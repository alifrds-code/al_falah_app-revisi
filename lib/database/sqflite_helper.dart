import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static Future<Database> db() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'al_falah.db'),
      version: 2,
      onCreate: (db, version) async {
        // 1. Tabel Users
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

        // 3. Tabel Pivot Asisten Kelas (Gembok Unique)
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

        // 5. Tabel Jadwal
        await db.execute('''
          CREATE TABLE tb_jadwal (
            id_jadwal INTEGER PRIMARY KEY AUTOINCREMENT,
            materi_pembahasan TEXT,
            nama_pemateri TEXT NOT NULL,
            tanggal TEXT NOT NULL,
            waktu_mulai TEXT NOT NULL,
            waktu_selesai TEXT NOT NULL,
            status_jadwal INTEGER NOT NULL DEFAULT 0,
            alasan_perubahan TEXT,
            id_kelas INTEGER NOT NULL,
            id_user INTEGER NOT NULL,
            FOREIGN KEY (id_kelas) REFERENCES tb_kelas (id_kelas) ON DELETE CASCADE,
            FOREIGN KEY (id_user) REFERENCES tb_users (id_user) ON DELETE CASCADE
          )
        ''');

        // 6. Tabel Absensi (Gembok Unique Jadwal + Jamaah)
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

        // SEEDING: Menanamkan Akun Super Admin Pertama
        await db.insert('tb_users', {
          'nama': 'Ketua Yayasan',
          'email': 'admin@alfalah.com',
          'password': 'admin123',
          'role': 'admin',
        });
      },
      // TAMBAHKAN FUNGSI onUpgrade untuk MENANAMKAN AKUN ADMIN KE-2
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          // KITA INJECT ADMIN BARUNYA DI SINI
          await db.insert('tb_users', {
            'nama': 'Sekretaris Yayasan',
            'email': 'sekretaris@alfalah.com',
            'password': 'admin123',
            'role': 'admin',
          });
          print("Upgrade sukses: Akun Admin ke-2 berhasil ditanam!");
        }
      },
    );
  }
}
