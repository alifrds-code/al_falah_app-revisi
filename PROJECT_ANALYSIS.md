# 📋 Analisis Lengkap Projek Al Falah App

## 📱 Ringkasan Umum Projek

**Nama Projek:** Al Falah App  
**Versi:** 1.0.0+1  
**Platform:** Flutter (Android, iOS, Web, Windows, Linux, macOS)  
**Bahasa:** Dart  
**Tujuan:** Aplikasi manajemen kelas dan jamaah untuk institusi Ta'lim Al Falah

---

## 🎯 Deskripsi Aplikasi

Al Falah App adalah aplikasi mobile berbasis Flutter yang dirancang untuk mengelola:
- **Manajemen User** (Admin, Asisten, Jamaah)
- **Manajemen Kelas** dengan daftar jamaah
- **Pengelolaan Asisten Kelas** (pembagian mengajar)
- **Data Jamaah** (siswa/jemaah yang mengikuti pembelajaran)
- **Sistem Autentikasi** (Login dengan email dan password)

---

## 📦 Teknologi & Dependencies

### Framework & Core
- **Flutter** - Framework UI
- **Dart** ^3.10.8 - Bahasa pemrograman

### Backend & Database
- **Firebase Auth** ^6.4.0 - Autentikasi cloud
- **Cloud Firestore** ^6.3.0 - Database cloud
- **SQLite** (sqflite) ^2.4.2 - Database lokal

### UI & UX
- **Material Design** (Flutter default)
- **Persistent Bottom Navigation Bar** v2 ^6.3.0 - Bottom nav yang persisten
- **Google NavBar** ^5.0.7 - Custom navigation bar
- **Lottie** ^3.3.2 - Animasi JSON
- **Animate Do** ^4.2.0 - Animasi Flutter
- **Confetti** ^0.8.0 - Partikel confetti effect

### Storage & Utility
- **Shared Preferences** ^2.5.4 - Penyimpanan key-value lokal
- **Path Provider** ^2.1.5 - Akses direktori aplikasi
- **Intl** ^0.20.2 - Internasionalisasi
- **Firebase Core** ^4.7.0 - Inisialisasi Firebase

---

## 📂 Struktur Folder & Organisasi Kode

```
lib/
├── main.dart                      # Entry point aplikasi
├── firebase_options.dart          # Konfigurasi Firebase
├── controllers/                   # Business Logic Layer
│   ├── login_controller.dart     # Logika login
│   ├── admin_controller.dart     # Logika admin
│   ├── jamaah_controller.dart    # Logika jamaah
│   └── kelas_controller.dart     # Logika kelas
├── models/                        # Data Models
│   ├── model_user.dart           # User (Admin, Asisten)
│   ├── model_jamaah.dart         # Jamaah (Student)
│   ├── model_kelas.dart          # Kelas (Class)
│   └── model_asisten_kelas.dart  # Pivot table Asisten-Kelas
├── services/                      # Data Services
│   ├── firebase_service.dart     # Firebase operations
│   └── local_storage_service.dart# Shared preferences
├── database/                      # Database Layer
│   └── sqflite_helper.dart       # SQLite initialization & helpers
├── view/                          # UI Screens
│   ├── auth/
│   │   ├── layar_login.dart      # Login screen
│   │   └── splash_screen.dart    # Loading screen
│   ├── admin/                     # Admin dashboard & management
│   │   ├── beranda_admin.dart    # Admin home
│   │   ├── detail_kelas.dart     # Class details
│   │   ├── form_asisten.dart     # Add/edit asisten
│   │   ├── form_jamaah.dart      # Add/edit jamaah
│   │   ├── form_kelas.dart       # Add/edit kelas
│   │   ├── kelola_asisten.dart   # Manage asisten
│   │   ├── kelola_jamaah.dart    # Manage jamaah
│   │   └── kelola_kelas.dart     # Manage kelas
│   ├── asisten/                   # Asisten features
│   │   └── beranda_asisten.dart  # Asisten home
│   ├── jamaah/                    # Jamaah features
│   │   ├── beranda_jamaah.dart   # Jamaah home
│   │   └── layar_pilih_kelas.dart# Choose class screen
│   └── utils/ & widgets/          # Reusable components
├── extensions/                    # Dart extensions
│   └── navigator.dart            # Navigation helpers
└── utils/                         # Utility functions
```

---

## 🗄️ Struktur Database SQLite

### Tabel: `tb_users`
```sql
CREATE TABLE tb_users (
    id_user INTEGER PRIMARY KEY AUTOINCREMENT,
    nama TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    role TEXT NOT NULL
)
```
**Deskripsi:** Menyimpan data user (Admin, Asisten)  
**Role:** 'admin', 'asisten'

### Tabel: `tb_kelas`
```sql
CREATE TABLE tb_kelas (
    id_kelas INTEGER PRIMARY KEY AUTOINCREMENT,
    nama_kelas TEXT NOT NULL
)
```
**Deskripsi:** Menyimpan data kelas/program pembelajaran

### Tabel: `tb_asisten_kelas` (Pivot Table)
```sql
CREATE TABLE tb_asisten_kelas (
    id_penugasan INTEGER PRIMARY KEY AUTOINCREMENT,
    id_user INTEGER NOT NULL,
    id_kelas INTEGER NOT NULL,
    UNIQUE(id_user, id_kelas),
    FOREIGN KEY (id_user) REFERENCES tb_users (id_user),
    FOREIGN KEY (id_kelas) REFERENCES tb_kelas (id_kelas)
)
```
**Deskripsi:** Relasi many-to-many antara asisten (user) dan kelas  
**Fitur:** UNIQUE constraint mencegah duplikasi penugasan

### Tabel: `tb_jamaah`
```sql
CREATE TABLE tb_jamaah (
    id_jamaah INTEGER PRIMARY KEY AUTOINCREMENT,
    nama_lengkap TEXT NOT NULL,
    jenis_kelamin TEXT NOT NULL,
    no_hp TEXT,
    alamat TEXT NOT NULL,
    status_jamaah INTEGER NOT NULL DEFAULT 1,
    id_kelas INTEGER,
    FOREIGN KEY (id_kelas) REFERENCES tb_kelas (id_kelas)
)
```
**Deskripsi:** Menyimpan data jamaah/murid  
**Status:** 1 = aktif, 0 = non-aktif (default 1)

### Tabel: `tb_jadwal`
```sql
CREATE TABLE tb_jadwal (
    id_jadwal INTEGER PRIMARY KEY AUTOINCREMENT,
    materi_pembahasan TEXT,
    ...
)
```
**Deskripsi:** Menyimpan jadwal pembelajaran

---

## 👥 Data Models

### 1. UserModel
```dart
class UserModel {
    int? idUser;
    String nama;
    String email;
    String password;
    String role;  // 'admin' atau 'asisten'
}
```

### 2. JamaahModel
```dart
class JamaahModel {
    int? idJamaah;
    String namaLengkap;
    String jenisKelamin;
    String? noHp;
    String alamat;
    int statusJamaah;  // 1 = aktif, 0 = non-aktif
    int? idKelas;      // Foreign key ke Kelas
}
```

### 3. KelasModel
```dart
class KelasModel {
    int? idKelas;
    String namaKelas;
    int? idAsisten;  // Placeholder untuk UI
}
```

### 4. AsistenKelasModel
```dart
class AsistenKelasModel {
    int? idPenugasan;
    int idUser;        // Foreign key ke User (Asisten)
    int idKelas;       // Foreign key ke Kelas
}
```

---

## 🔄 Alur Aplikasi (User Flow)

### 1️⃣ **Splash Screen → Login Screen**
```
Aplikasi Start
    ↓
Splash Screen (loading)
    ↓
Firebase Initialize
    ↓
Check Session (Shared Preferences)
    ↓
IF user sudah login → Dashboard (sesuai role)
IF user belum login → Login Screen
```

### 2️⃣ **Authentication Flow**
```
User Input (email + password)
    ↓
LoginController.loginUser()
    ↓
Query tb_users (email + password match)
    ↓
IF found:
    → Create UserModel
    → Save session ke SharedPreferences
    → Return UserModel
ELSE:
    → Show error "Email/Password salah"
    → Return null
```

### 3️⃣ **Role-Based Navigation**
Setelah login sukses, user diarahkan sesuai role:

#### **ADMIN**
```
Beranda Admin
├─ Kelola Kelas
│  ├─ Lihat list kelas
│  ├─ Add kelas
│  ├─ Edit kelas
│  └─ Delete kelas
├─ Kelola Asisten
│  ├─ Lihat list asisten
│  ├─ Form assign asisten ke kelas
│  └─ Delete penugasan
└─ Kelola Jamaah
   ├─ Lihat list jamaah
   ├─ Add jamaah
   ├─ Edit jamaah
   └─ Delete jamaah
```

#### **ASISTEN**
```
Beranda Asisten
├─ Lihat kelas yang di-assign
├─ Lihat jamaah di kelas tersebut
└─ Manage kehadiran/aktivitas (jika ada)
```

#### **JAMAAH**
```
Beranda Jamaah
├─ Pilih Kelas (dari list available)
└─ Lihat detail kelas

atau

Layar Pilih Kelas
├─ Browse available classes
└─ Register ke kelas
```

### 4️⃣ **Data Flow (Detailed)**
```
UI Form (Input Data)
    ↓
Controller
    ↓
DBHelper (SQLite)
    ↓
Local Database (tb_users, tb_jamaah, dll)
    ↓
Optional: FirebaseService (Cloud sync)
    ↓
Response ke UI
```

---

## 🎮 Controllers dan Responsibilitas

### LoginController
- **Fungsi:** Menangani proses login
- **Methods:**
  - `loginUser()` - Validasi email/password, buat session
  - `logout()` - Hapus session, clear data

### AdminController
- **Fungsi:** Mengelola operasi Admin
- **Operasi:**
  - Create, Read, Update, Delete Kelas
  - Create, Read, Update, Delete Jamaah
  - Assign Asisten ke Kelas

### KelasController
- **Fungsi:** Mengelola data Kelas
- **Operasi:**
  - CRUD Kelas
  - Fetch asisten yang di-assign
  - Fetch jamaah di kelas

### JamaahController
- **Fungsi:** Mengelola data Jamaah
- **Operasi:**
  - CRUD Jamaah
  - Assign jamaah ke kelas
  - Update status jamaah

---

## 🔌 Services & External APIs

### FirebaseService
```
Fungsi:
- registerUser() : Cloud registration
- Sync data ke Firestore
- Cloud Authentication (Firebase Auth)

Status: Partially implemented
(Beberapa fungsi belum fully integrate)
```

### LocalStorageService (local_storage_service.dart)
```
Fungsi:
- saveUserSession() : Simpan login session
- getUserSession() : Ambil session data
- clearSession() : Hapus session
- Menggunakan SharedPreferences
```

---

## 🖥️ UI/UX Components

### Navigation Structure
- **Primary Navigation:** Persistent Bottom Navigation atau Google NavBar
- **Transitions:** Menggunakan Flutter Navigator
- **Custom Extensions:** navigator.dart untuk kemudahan routing

### UI Elements
- **Material Design** components
- **Lottie Animations** untuk loading/success states
- **Confetti Effect** untuk reward/success
- **Form Widgets** untuk input data

### Screens
- **Login Screen:** Email, Password input + validation
- **Splash Screen:** Loading state dengan lottie
- **Admin Screens:** Management CRUD interface
- **Asisten Screens:** Dashboard & class view
- **Jamaah Screens:** Class selection & details

---

## 🔐 Security & Best Practices

### Implemented
- ✅ Session management dengan SharedPreferences
- ✅ Role-based access control (admin, asisten, jamaah)
- ✅ Database foreign key relationships
- ✅ Unique constraint pada tb_asisten_kelas

### Recommendations
- 🔒 **Password Hashing:** Gunakan bcrypt/argon2 bukan plain text
- 🔒 **Firebase Authentication:** Leverage Firebase Auth instead of local password
- 🔒 **Data Validation:** Input validation di UI dan server-side
- 🔒 **Error Handling:** Better error messages dan logging
- 🔒 **API Security:** Jika ada backend, gunakan JWT tokens

---

## 📊 Entity Relationship Diagram (ERD)

```
                    tb_users
                   ┌─────────────┐
                   │ id_user (PK)│
                   │ nama        │
                   │ email (UNQ) │
                   │ password    │
                   │ role        │
                   └──────┬──────┘
                          │
                ┌─────────┴─────────┐
                │                   │
    ┌───────────▼───────┐  ┌────────▼──────────────┐
    │   tb_jamaah       │  │ tb_asisten_kelas     │
    ├──────────────────┤  ├─────────────────────┤
    │ id_jamaah (PK)   │  │ id_penugasan (PK)   │
    │ nama_lengkap     │  │ id_user (FK)        │
    │ jenis_kelamin    │  │ id_kelas (FK)       │
    │ no_hp            │  │ [UNQ: user+kelas]  │
    │ alamat           │  └──────────┬──────────┘
    │ status_jamaah    │             │
    │ id_kelas (FK)────┼─────┐       │
    └──────────────────┘     │       │
                             │       │
                    ┌────────▼────────▼────────┐
                    │     tb_kelas            │
                    ├────────────────────────┤
                    │ id_kelas (PK)          │
                    │ nama_kelas             │
                    └────────────────────────┘
```

---

## 🚀 Alur Development & Deployment

### Dependencies Management
- `pubspec.yaml` - Semua dependencies sudah terdaftar
- `firebase.json` - Konfigurasi Firebase
- `analysis_options.yaml` - Linting rules

### Build Configuration
- **Android:** `build.gradle.kts`, `local.properties`, `google-services.json`
- **iOS:** Xcode project dengan Swift
- **Web:** HTML & manifest
- **Windows/Linux/macOS:** CMake configuration

### App Identifiers
- Android: Defined in gradle
- iOS: Defined in Xcode
- Firebase: Connected via `firebase_options.dart`

---

## 📝 Development Workflow

### Setup
```bash
flutter pub get
flutter pub upgrade (optional)
```

### Running
```bash
flutter run              # Android emulator default
flutter run -d windows   # Run di Windows
flutter run -d web       # Run di web browser
```

### Building
```bash
flutter build apk      # Build Android APK
flutter build aab      # Build Android App Bundle
flutter build ios      # Build iOS
flutter build web      # Build web
```

---

## 🐛 Known Issues & Future Improvements

### Potential Issues
- ⚠️ Password disimpan plain text (security risk)
- ⚠️ Firebase integration belum fully implemented
- ⚠️ Error handling bisa lebih robust
- ⚠️ Belum ada input validation di beberapa forms

### Rekomendasi Perbaikan
1. **Authentication:**
   - Gunakan Firebase Auth penuh (buang local password)
   - Implement password reset functionality
   - 2FA untuk admin

2. **Database:**
   - Migrate ke true cloud (Firestore)
   - Implement data backup
   - Add data migration tools

3. **UI/UX:**
   - Add loading indicators
   - Better error dialogs
   - Offline mode support
   - Responsive design

4. **Performance:**
   - Optimize database queries (pagination)
   - Implement caching
   - Lazy loading untuk list

5. **Testing:**
   - Unit tests untuk controllers
   - Widget tests untuk UI
   - Integration tests

---

## 📱 Platform Support

| Platform | Status | Min Version |
|----------|--------|-------------|
| Android  | ✅ Supported | API 21+ (gradle min_sdk) |
| iOS      | ✅ Supported | iOS 11.0+ |
| Web      | ✅ Supported | Modern browsers |
| Windows  | ✅ Supported | Windows 10+ |
| Linux    | ✅ Supported | Ubuntu 16.04+ |
| macOS    | ✅ Supported | 10.12+ |

---

## 📦 App Configuration

### App Name & Version
- **Name:** Ta'lim Al Falah
- **Version:** 1.0.0
- **Build Number:** 1
- **Debug Mode:** Enabled (debugShowCheckedModeBanner: false)

### Assets
- **Logo:** `assets/logo/logoalfalah.png`
- **Images:** `assets/images/`
- **Material Icons:** Enabled

### Theme
- Material Design 3 compatible
- Font family dapat dikustomisasi di `main.dart`
- Color scheme dapat ditambahkan di theme data

---

## 📞 Contact & References

**Projek:** Al Falah App  
**Framework:** Flutter  
**Database:** SQLite + Firebase  
**Status:** Active Development

### File Utama untuk Reference
- 📄 [pubspec.yaml](pubspec.yaml) - Dependencies
- 📄 [main.dart](lib/main.dart) - Entry point
- 📄 [firebase_options.dart](lib/firebase_options.dart) - Firebase config
- 📄 [sqflite_helper.dart](lib/database/sqflite_helper.dart) - Database schema

---

## 📌 Kesimpulan

**Al Falah App** adalah aplikasi Flutter yang menggunakan arsitektur **MVC (Model-View-Controller)** dengan:
- **Local Database:** SQLite untuk data local
- **Cloud Sync:** Firebase untuk backup & sync
- **Role-Based Access:** Admin, Asisten, Jamaah
- **Persistent Navigation:** Bottom nav yang user-friendly

Aplikasi ini siap untuk dikembangkan lebih lanjut dengan fitur-fitur tambahan seperti attendance tracking, scheduling, dan analytics.

---

*Dokumen ini di-generate untuk analisis struktur dan alur aplikasi Al Falah*  
*Last Updated: 2026*

---

## 📋 Analisis Dokumen Kebutuhan & Spesifikasi

### 📄 Ringkasan Dokumen yang Diberikan

1. **`kebutuhan.txt`** - Daftar fitur lengkap (80+ item) dibagi berdasarkan role: Jamaah (publik), Asisten (login), Admin (login), dan Sistem (otomatis).

2. **`penjelasan aja.txt`** - Penjelasan pribadi tentang pengalaman di Yayasan Al Falah, struktur kelas, jadwal tidak menentu, absensi manual, dan pertanyaan fitur wirid/Al-Qur'an.

3. **`deskripsi keknya.txt`** - Deskripsi projek, transformasi masalah ke fitur sistem, dan penjelasan arsitektur teknis (MVC, SQLite, dll.).

4. **`kondisi.txt`** - Kondisi-kondisi sistem seperti login, ustadz, kelas, jamaah, jadwal, acara, notifikasi, dan masalah teknis (upload gambar, state management).

5. **`struktur folder.txt`** - Struktur folder Flutter yang diusulkan dengan penjelasan detail setiap komponen.

### ✅ Analisis: Apa yang Bagus & Penting

#### **Kebutuhan.txt** (Sangat Bagus)
- **Detail & Terstruktur**: Membagi fitur berdasarkan role user (Jamaah, Asisten, Admin) memudahkan prioritas dan implementasi.
- **Relevan dengan Masalah Nyata**: Fitur seperti onboarding pilih kelas, filter jadwal, status jadwal (Hijau/Kuning/Merah), absensi digital, dan pengumuman/acara langsung mengatasi masalah manual (absen kertas, jadwal WA mendadak).
- **User-Centric**: Fokus pada pengalaman user, seperti highlight hari ini, maksimal 3 jadwal di beranda, dan wirid statis.
- **Sistem Otomatis**: Notifikasi FCM untuk perubahan jadwal/pengumuman (meski di-hold untuk offline).

#### **Penjelasan aja.txt** (Bagus untuk Konteks)
- **Real-World Context**: Memberikan gambaran langsung tentang struktur yayasan, jadwal tidak menentu, dan transisi absensi dari kertas ke digital.
- **Validasi Kebutuhan**: Menunjukkan aplikasi ini bukan "bikin-bikinan" tapi solusi nyata untuk masalah yang dialami.
- **Pertanyaan Kritis**: Diskusi tentang wirid dan Al-Qur'an membantu memutuskan fitur mana yang di-skip (Al-Qur'an di-skip untuk menghindari kompleksitas).

#### **Deskripsi keknya.txt** (Bagus untuk Arsitektur)
- **Transformasi Masalah ke Solusi**: Menjelaskan bagaimana pengalaman user (jadwal nggak nentu, absensi kertas) diterjemahkan ke fitur teknis (status jadwal, absensi digital).
- **Analog Analog Mudah**: Penjelasan arsitektur dengan analogi restoran (database = dapur, UI = meja) membantu pemahaman non-teknis.
- **Offline-First Mindset**: Penekanan SQLite lokal dengan Firebase hold baik untuk MVP.

#### **Kondisi.txt** (Bagus untuk Aturan Main)
- **Keputusan Jelas**: Email vs username, tidak ada tabel ustadz, 1 asisten bisa megang banyak kelas, beda jadwal vs acara.
- **Solusi Teknis**: Penanganan upload gambar (copy ke internal storage), state management dengan setState saja.
- **Realistis**: Hold FCM untuk offline, reset password via admin, bukan OTP.

#### **Struktur Folder.txt** (Bagus untuk Organisasi)
- **MVC Pattern**: Memisahkan models, controllers, views dengan jelas.
- **Komprehensif**: Menambahkan model baru (model_jadwal.dart, model_absensi.dart) yang belum ada di kode saat ini.
- **Bahasa Indonesia**: Penjelasan dalam bahasa Indonesia memudahkan pemahaman.
- **Widget Reusable**: Folder widgets/ untuk komponen daur ulang seperti tombol_utama.dart.

### ❌ Analisis: Apa yang Tidak Penting atau Masalah

#### **Kebutuhan.txt** (Beberapa Overkill)
- **Fitur Advanced yang Bisa Di-skip untuk MVP**: Push Notification FCM (karena offline-first, data update saat buka app saja). Ekspor laporan Excel (.csv) mungkin tidak prioritas jika tidak ada kebutuhan segera.
- **Fitur yang Di-skip**: Al-Qur'an (sudah diputuskan skip untuk menghindari kompleksitas).
- **Duplikasi**: Beberapa fitur mungkin overlap atau terlalu detail untuk fase awal.

#### **Penjelasan aja.txt** (Kurang Teknis)
- **Tidak Ada Masalah Besar**: Bagus untuk konteks, tapi kurang teknis. Pertanyaan tentang notifikasi berisik perlu diperhatikan (solusi: filter berdasarkan kelas pilihan).

#### **Deskripsi keknya.txt** (Perlu Sinkronisasi)
- **Mismatch dengan Kode Saat Ini**: Menyebutkan 8 tabel, tapi kode saat ini hanya 5 tabel (users, kelas, asisten_kelas, jamaah, jadwal). Perlu update struktur database.
- **Firebase Hold**: Baik, tapi perlu jelaskan kapan diaktifkan.

#### **Kondisi.txt** (Beberapa Prematur)
- **State Management**: Menggunakan setState saja cukup untuk awal, tidak perlu library tambahan seperti Provider.
- **Foto Poster**: Solusi copy gambar baik, tapi implementasi perlu testing untuk error handling.

#### **Struktur Folder.txt** (Perlu Sinkronisasi dengan Kode)
- **File yang Belum Ada**: Banyak file seperti model_jadwal.dart, model_absensi.dart, controller baru (asisten_controller.dart, dll.) belum ada di kode saat ini. Struktur ini lebih seperti blueprint untuk pengembangan penuh.
- **Folder Fonts**: Mungkin tidak perlu jika tidak ada font custom.
- **Over-Engineering**: Untuk MVP, beberapa controller bisa digabung (misal admin_controller.dart sudah ada, tapi ditambah lagi).

### 🎯 Rekomendasi Implementasi

#### **Prioritas Tinggi (MVP Core)**
1. **Onboarding & Filter Kelas**: layar_pilih_kelas.dart, penyimpanan SharedPreferences.
2. **Beranda Jamaah**: Highlight hari ini, 3 jadwal terdekat, filter berdasarkan kelas pilihan.
3. **Login Asisten/Admin**: Form email/password, validasi role.
4. **Kelola Jadwal Asisten**: Buat/edit jadwal, status (Sesuai/Ditunda/Dibatalkan).
5. **Absensi**: Layar checkbox nama jamaah, simpan ke database.
6. **Pengumuman & Acara Admin**: CRUD teks dan gambar (dengan copy internal).

#### **Prioritas Menengah**
- Status jadwal dengan indikator warna.
- Menu wirid statis.
- Reset password via admin.
- Filter tampilan berdasarkan role asisten.

#### **Skip untuk MVP**
- Push Notification FCM (ganti dengan update real-time saat buka app).
- Ekspor laporan Excel.
- Fitur Al-Qur'an.
- Menu profil untuk ganti password mandiri.

#### **Sinkronisasi Kode**
- Tambahkan model dan controller yang hilang sesuai struktur folder.
- Update database schema untuk tabel tambahan (pengumuman, acara, absensi).
- Implementasi copy gambar untuk acara.

#### **Risiko & Mitigasi**
- **Over-Engineering**: Fokus MVP dulu, hindari fitur yang tidak esensial.
- **Mismatch Dokumen-Kode**: Sinkronkan semua dokumen dengan kode yang ada.
- **Offline-First**: Pastikan semua fitur bekerja tanpa internet.

---

*Analisis ini membantu memprioritaskan pengembangan berdasarkan dokumen spesifikasi yang diberikan.*
