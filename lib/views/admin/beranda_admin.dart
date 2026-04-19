import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

import '../../controllers/login_controller.dart';
import '../../controllers/admin_controller.dart';
import '../../models/model_user.dart';
import '../auth/splash_screen.dart';
import 'kelola_asisten.dart';
import 'kelola_kelas.dart';
import 'kelola_jamaah.dart';
import 'kelola_info.dart';
import 'laporan_absensi.dart';

// Dashboard Admin - halaman utama setelah admin login
class BerandaAdmin extends StatefulWidget {
  const BerandaAdmin({super.key});

  @override
  State<BerandaAdmin> createState() => _BerandaAdminState();
}

class _BerandaAdminState extends State<BerandaAdmin> {
  final LoginController _loginController = LoginController();
  final AdminController _adminController = AdminController();
  UserModel? _user;
  Map<String, int> _stats = {'jamaah': 0, 'kelas': 0, 'asisten': 0};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final user = await _loginController.getCurrentUser();
    final stats = await _adminController.getDashboardStats();
    setState(() {
      _user = user;
      _stats = stats;
      _isLoading = false;
    });
  }

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
            // Header hijau
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
                        'Panel Administrator',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        _user?.nama ?? 'Loading...',
                        style: const TextStyle(fontSize: 14, color: Colors.white70),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: _handleLogout,
                    icon: const Icon(Icons.logout_rounded, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Kartu statistik (3 kartu angka)
            Padding(
              padding: const EdgeInsets.all(18),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Row(
                      children: [
                        _buildStatCard('Jamaah', _stats['jamaah'].toString(), Icons.people_outline),
                        const SizedBox(width: 12),
                        _buildStatCard('Kelas', _stats['kelas'].toString(), Icons.school_outlined),
                        const SizedBox(width: 12),
                        _buildStatCard('Asisten', _stats['asisten'].toString(), Icons.badge_outlined),
                      ],
                    ),
            ),

            // Menu navigasi admin
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                children: [
                  const Text(
                    'Manajemen Data',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildMenuItem(
                    context,
                    Icons.badge_rounded,
                    'Kelola Asisten',
                    'Tambah dan hapus akun pengelola kelas',
                    const KelolaAsisten(),
                  ),
                  _buildMenuItem(
                    context,
                    Icons.school_rounded,
                    'Kelola Kelas',
                    'Atur daftar kelas di yayasan',
                    const KelolaKelas(),
                  ),
                  _buildMenuItem(
                    context,
                    Icons.people_alt_rounded,
                    'Kelola Jamaah',
                    'Daftar dan profil jamaah per kelas',
                    const KelolaJamaah(),
                  ),
                  _buildMenuItem(
                    context,
                    Icons.campaign_rounded,
                    'Info & Pengumuman',
                    'Update berita dan acara yayasan',
                    const KelolaInfo(),
                  ),
                  _buildMenuItem(
                    context,
                    Icons.analytics_rounded,
                    'Laporan Absensi',
                    'Ekspor data kehadiran ke CSV',
                    const LaporanAbsensi(),
                    onReturn: _loadData, // Refresh stats setelah kembali
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Kartu statistik kecil
  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }

  // Item menu navigasi
  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Widget destination, {
    VoidCallback? onReturn,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => destination),
          );
          // Kalau ada callback setelah kembali (misal refresh stats)
          if (onReturn != null) onReturn();
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 12, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}
