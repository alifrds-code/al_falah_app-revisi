import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// ini kelas buat ngatur-ngatur database sqlite-nya
class DBHelper {
  // buat buka atau bikin databasenya pas pertama kali
  static Future<Database> db() async {
    final dbPath = await getDatabasesPath();
    return openDatabase(
      join(dbPath, 'al_falah.db'),
      version: 3, // gue naikin ke 3 soalnya ada tipe data yang gue benerin
      onCreate: (db, version) async {
        // biar kalo ada yang didelete, data nyambungnya juga ilang (cascade)
        await db.execute('PRAGMA foreign_keys = ON');

        // 1. tabel buat nyimpen data user (admin & asisten)
        await db.execute('''
          CREATE TABLE tb_users (
            id_user INTEGER PRIMARY KEY AUTOINCREMENT,
            nama TEXT NOT NULL,
            email TEXT UNIQUE NOT NULL,
            password TEXT NOT NULL,
            role TEXT NOT NULL
          )
        ''');

        // 2. tabel buat daftar kelas yang ada
        await db.execute('''
          CREATE TABLE tb_kelas (
            id_kelas INTEGER PRIMARY KEY AUTOINCREMENT,
            nama_kelas TEXT NOT NULL
          )
        ''');

        // 3. tabel penengah: admin bisa dikasih tugas di banyak kelas
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

        // 4. tabel buat nyimpen biodata jamaah
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

        // 5. tabel buat jadwal kegiatan ta'lim
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

        // 6. tabel buat nyatet siapa aja yang dateng pas ta'lim
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

        // 7. tabel buat naruh pengumuman penting
        await db.execute('''
          CREATE TABLE tb_pengumuman (
            id_pengumuman INTEGER PRIMARY KEY AUTOINCREMENT,
            judul TEXT NOT NULL,
            isi_teks TEXT NOT NULL,
            tanggal_post TEXT NOT NULL
          )
        ''');

        // 8. tabel buat daftar acara yayasan
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

        // gue bikinin akun admin default ya biar bisa login: email admin@alfalah.com, pass admin123
        await db.insert('tb_users', {
          'nama': 'Ketua Yayasan',
          'email': 'admin@alfalah.com',
          'password': 'admin123',
          'role': 'admin',
        });
      },

      // kalo gue mau upgrade skema tabel, pakenya ini
      onUpgrade: (db, oldVersion, newVersion) async {
        await db.execute('PRAGMA foreign_keys = ON');

        if (oldVersion < 3) {
          // bongkar dulu yang lanyambung biar gak error
          await db.execute('DROP TABLE IF EXISTS tb_absensi');
          await db.execute('DROP TABLE IF EXISTS tb_jadwal');

          // bikin ulang yang bener
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

      // pastiin foreign key aktip terus pas db dibuka
      onOpen: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }
}
