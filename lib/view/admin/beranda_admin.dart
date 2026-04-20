import 'package:flutter/material.dart';
import 'package:al_falah_app/widgets/drawer_admin.dart';
import 'package:al_falah_app/extensions/navigator.dart';
import 'package:al_falah_app/view/admin/kelola_kelas.dart';
import 'package:al_falah_app/view/admin/kelola_asisten.dart';
import 'package:al_falah_app/view/admin/kelola_jamaah.dart';
import 'package:al_falah_app/view/admin/kelola_acara.dart';
import 'package:al_falah_app/view/admin/kelola_pengumuman.dart';

import 'package:al_falah_app/controllers/admin_controller.dart';

// IMPORT GUDANG DESAIN KITA:
import 'package:al_falah_app/utils/app_colors.dart';
import 'package:al_falah_app/widgets/tombol_akses_cepat.dart';

class BerandaAdmin extends StatefulWidget {
  final String namaUser;
  final String emailUser;

  const BerandaAdmin({
    super.key,
    required this.namaUser,
    required this.emailUser,
  });

  @override
  State<BerandaAdmin> createState() => _BerandaAdminState();
}

class _BerandaAdminState extends State<BerandaAdmin> {
  // Fungsi gabungan buat narik semua total angka sekaligus
  Future<Map<String, int>> _loadStatistikDashboard() async {
    final kelasList = await AdminController.ambilSemuaKelas();
    final jamaahList = await AdminController.ambilSemuaJamaah();
    final asistenList = await AdminController.ambilSemuaAsisten();

    final totalKelas = kelasList.length;
    final totalJamaah = jamaahList.length;
    final totalAsisten = asistenList.length;
    // TODO: Nanti kalau jadwal udah jadi, tambahin hitung jadwal bulan ini di sini

    return {
      'kelas': totalKelas,
      'jamaah': totalJamaah,
      'asisten': totalAsisten,
      'jadwal': 0, // Hardcode dulu sementara
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Dashboard Admin",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textHeading,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textHeading),
        centerTitle: true,
      ),
      drawer: DrawerAdmin(
        namaUser: widget.namaUser,
        emailUser: widget.emailUser,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER WELCOME SECTION
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Assalamu'alaikum,",
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.namaUser,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Selamat datang di Sistem Al - Falah",
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // STATISTIK SECTION
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'RINGKASAN DATA',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textHeading,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Icon(
                    Icons.bar_chart,
                    color: AppColors.primaryLight.withValues(alpha: 0.8),
                    size: 24,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            FutureBuilder<Map<String, int>>(
              future: _loadStatistikDashboard(),
              builder: (context, snapshot) {
                int kelas = 0;
                int jamaah = 0;
                int asisten = 0;

                if (snapshot.hasData) {
                  kelas = snapshot.data!['kelas']!;
                  jamaah = snapshot.data!['jamaah']!;
                  asisten = snapshot.data!['asisten']!;
                }

                // Horizontal scrollable stats cards for modern look
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _buildModernStatCard(
                        title: 'Jamaah',
                        count: jamaah.toString(),
                        icon: Icons.people,
                        color: AppColors.primary,
                      ),
                      _buildModernStatCard(
                        title: 'Kelas',
                        count: kelas.toString(),
                        icon: Icons.class_,
                        color: AppColors.warning,
                      ),
                      _buildModernStatCard(
                        title: 'Asisten',
                        count: asisten.toString(),
                        icon: Icons.person_pin_circle,
                        color: AppColors.info,
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 32),

            // MENU UTAMA SECTION
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'MENU UTAMA',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textHeading,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // GRID MENU
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.0,
                children: [
                  TombolAksesCepat(
                    title: 'Data Jamaah',
                    icon: Icons.groups_rounded,
                    iconColor: AppColors.primary,
                    bgColor: AppColors.primaryLight,
                    onTap: () async {
                      await context.push(const KelolaJamaah());
                      setState(() {});
                    },
                  ),
                  TombolAksesCepat(
                    title: 'Master Kelas',
                    icon: Icons.school_rounded,
                    iconColor: AppColors.warning,
                    bgColor: AppColors.warningLight,
                    onTap: () async {
                      await context.push(const KelolaKelas());
                      setState(() {});
                    },
                  ),
                  TombolAksesCepat(
                    title: 'Akun Asisten',
                    icon: Icons.admin_panel_settings_rounded,
                    iconColor: AppColors.info,
                    bgColor: AppColors.infoLight,
                    onTap: () async {
                      await context.push(const KelolaAsisten());
                      setState(() {});
                    },
                  ),
                  TombolAksesCepat(
                    title: 'Pengumuman',
                    icon: Icons.campaign_rounded,
                    iconColor: const Color(0xFFE91E63), // Pink
                    bgColor: const Color(0xFFFCE4EC),
                    onTap: () async {
                      await context.push(const KelolaPengumuman());
                      setState(() {});
                    },
                  ),
                  TombolAksesCepat(
                    title: 'Acara & Event',
                    icon: Icons.event_available_rounded,
                    iconColor: const Color(0xFF9C27B0), // Purple
                    bgColor: const Color(0xFFF3E5F5),
                    onTap: () async {
                      await context.push(const KelolaAcara());
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48), // Padding bawah
          ],
        ),
      ),
    );
  }

  // Komponen Kartu Statistik Modern
  Widget _buildModernStatCard({
    required String title,
    required String count,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: 140,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 20),
          Text(
            count,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textHeading,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSubtitle,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
