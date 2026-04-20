import 'package:flutter/material.dart';
import 'package:al_falah_app/widgets/drawer_admin.dart';
import 'package:al_falah_app/extensions/navigator.dart';
import 'package:al_falah_app/view/admin/kelola_kelas.dart';
import 'package:al_falah_app/view/admin/kelola_asisten.dart';
import 'package:al_falah_app/view/admin/kelola_jamaah.dart';
import 'package:al_falah_app/view/admin/kelola_acara.dart';
import 'package:al_falah_app/view/admin/kelola_pengumuman.dart';

import 'package:al_falah_app/view/jamaah/beranda_jamaah.dart';
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
        actions: [
          IconButton(
            icon: const Icon(Icons.people_outline, color: AppColors.primary),
            tooltip: 'Lihat Sisi Jamaah',
            onPressed: () {
              context.push(const BerandaJamaah());
            },
          ),
        ],
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
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
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

                // Clean statistic view instead of cards
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                      border: Border(
                        top: BorderSide(color: AppColors.borderLight, width: 1),
                        bottom: BorderSide(color: AppColors.borderLight, width: 1),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatText('Jamaah', jamaah.toString(), AppColors.primary),
                        Container(height: 40, width: 1, color: AppColors.borderLight),
                        _buildStatText('Kelas', kelas.toString(), AppColors.warning),
                        Container(height: 40, width: 1, color: AppColors.borderLight),
                        _buildStatText('Asisten', asisten.toString(), AppColors.info),
                      ],
                    ),
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

  // Komponen Teks Statistik (bukan card)
  Widget _buildStatText(String title, String count, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count,
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w900,
            color: color,
            height: 1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: AppColors.textSubtitle,
          ),
        ),
      ],
    );
  }
}
