import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

import '../../controllers/login_controller.dart';
import '../../controllers/admin_controller.dart';
import '../../models/model_user.dart';
import '../../models/model_kelas.dart';
import '../auth/splash_screen.dart';
import 'kelola_jadwal.dart';
import 'layar_absen.dart';

// dashboard buat asisten atau pengelola kelas kalo udah login
class BerandaAsisten extends StatefulWidget {
  const BerandaAsisten({super.key});

  @override
  State<BerandaAsisten> createState() => _BerandaAsistenState();
}

class _BerandaAsistenState extends State<BerandaAsisten> {
  final LoginController _loginController = LoginController();
  final AdminController _adminController = AdminController();
  UserModel? _user;
  List<KelasModel> _classes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // pas buka halaman langsung tarik data user sama daftar kelasnya
    _loadData();
  }

  // fungsi buat ambil data user yang login sama kelas-kelas yang ada
  void _loadData() async {
    final user = await _loginController.getCurrentUser();
    final classes = await _adminController.getClasses(); // gue tampilin semua kelas dulu ya biar gampang
    setState(() {
      _user = user;
      _classes = classes;
      _isLoading = false;
    });
  }

  // fungsi pas asisten mau logout, bersihin session terus balik ke splash
  void _handleLogout() async {
    await _loginController.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SplashScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // bagian kepala dashboard warna hijau
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
              color: AppColors.primary,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Dashboard Asisten',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        _user?.nama ?? 'Loading...',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  // tombol logout di pojok kanan atas
                  IconButton(
                    onPressed: _handleLogout,
                    icon: const Icon(Icons.logout_rounded, color: Colors.white),
                  ),
                ],
              ),
            ),

            // bagian isi list kelasnya
            Expanded(
              child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  const Text(
                    'Kelas Kelolaan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // kalo belum ada kelas dari admin, kasih tau
                  if (_classes.isEmpty)
                    const Center(child: Text('Belum ada kelas yang dibuat oleh Admin'))
                  else
                    ..._classes.map((k) => Column(
                      children: [
                        _buildClassCard(context, k),
                        const SizedBox(height: 12),
                      ],
                    )).toList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // widget buat bikin kotak kelasnya
  Widget _buildClassCard(BuildContext context, KelasModel kelas) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // ikon topi wisuda/sekolah
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.school_rounded, color: AppColors.primary, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      kelas.namaKelas,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                    const Text(
                      'Pilih aksi untuk kelas ini',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          // barisan tombol buat milih mau jadwal atau absen
          Row(
            children: [
              // tombol buat ngatur jadwal kajian
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => KelolaJadwal(idKelas: kelas.idKelas!),
                      ),
                    );
                  },
                  icon: const Icon(Icons.event_note_rounded, size: 18),
                  label: const Text('Jadwal'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // tombol buat mulai absensi jamaah
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LayarAbsen(idKelas: kelas.idKelas!),
                      ),
                    );
                  },
                  icon: const Icon(Icons.fact_check_rounded, size: 18),
                  label: const Text('Absensi'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
