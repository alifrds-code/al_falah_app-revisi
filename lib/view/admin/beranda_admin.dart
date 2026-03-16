import 'package:flutter/material.dart';
import 'package:al_falah_app/widgets/drawer_admin.dart';
import 'package:al_falah_app/extensions/navigator.dart';
import 'package:al_falah_app/view/admin/kelola_kelas.dart';
import 'package:al_falah_app/view/admin/kelola_asisten.dart';
import 'package:al_falah_app/view/admin/kelola_jamaah.dart';

// IMPORT CONTROLLER BUAT NARIK TOTAL ANGKA
import 'package:al_falah_app/controllers/kelas_controller.dart';
import 'package:al_falah_app/controllers/jamaah_controller.dart';
import 'package:al_falah_app/controllers/admin_controller.dart';

// IMPORT GUDANG DESAIN KITA:
import 'package:al_falah_app/utils/app_colors.dart';
import 'package:al_falah_app/widgets/kartu_statistik.dart';
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
    final totalKelas = await KelasController.getHitungTotalKelas();
    final totalJamaah = await JamaahController.getHitungTotalJamaah();
    final totalAsisten = await AdminController.getHitungTotalAsisten();
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Assalamu'alaikum,",
              style: TextStyle(fontSize: 12, color: AppColors.textSubtitle),
            ),
            Text(
              widget.namaUser,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textHeading,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textHeading),
      ),
      drawer: DrawerAdmin(
        namaUser: widget.namaUser,
        emailUser: widget.emailUser,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'RINGKASAN DATA',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textSubtitle,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),

            // FUTURE BUILDER BUAT KARTU STATISTIK
            FutureBuilder<Map<String, int>>(
              future: _loadStatistikDashboard(),
              builder: (context, snapshot) {
                int kelas = 0;
                int jamaah = 0;
                int asisten = 0;
                int jadwal = 0;

                if (snapshot.hasData) {
                  kelas = snapshot.data!['kelas']!;
                  jamaah = snapshot.data!['jamaah']!;
                  asisten = snapshot.data!['asisten']!;
                  jadwal = snapshot.data!['jadwal']!;
                }

                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: KartuStatistik(
                            title: 'Total Kelas',
                            count: kelas.toString(),
                            icon: Icons.class_,
                            iconColor: AppColors.warning, // ORANYE
                            bgColor: AppColors.warningLight,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: KartuStatistik(
                            title: 'Total Jamaah',
                            count: jamaah.toString(),
                            icon: Icons.people,
                            iconColor: AppColors.primary, // HIJAU
                            bgColor: AppColors.primaryLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: KartuStatistik(
                            title: 'Asisten Aktif',
                            count: asisten.toString(),
                            icon: Icons.person_pin_circle,
                            iconColor: AppColors.info, // BIRU
                            bgColor: AppColors.infoLight,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: KartuStatistik(
                            title: 'Jadwal Bulan Ini',
                            count: jadwal.toString(),
                            icon: Icons.calendar_month,
                            iconColor: Colors.purple[600]!, // UNGU
                            bgColor: Colors.purple[50]!,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 32),
            const Text(
              'AKSES CEPAT',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textSubtitle,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),

            // MENU JALAN PINTAS
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
              children: [
                TombolAksesCepat(
                  title: 'Kelola Data Jamaah',
                  icon: Icons.people,
                  iconColor: AppColors.primary, // HIJAU
                  bgColor: AppColors.primaryLight,
                  onTap: () async {
                    await context.push(const KelolaJamaah());
                    setState(() {});
                  },
                ),
                TombolAksesCepat(
                  title: 'Master Kelas',
                  icon: Icons.class_,
                  iconColor: AppColors.warning, // ORANYE
                  bgColor: AppColors.warningLight,
                  onTap: () async {
                    await context.push(const KelolaKelas());
                    setState(() {});
                  },
                ),
                TombolAksesCepat(
                  title: 'Akun Asisten',
                  icon: Icons.person_pin_circle, // IKON DISAMAIN
                  iconColor: AppColors.info, // BIRU
                  bgColor: AppColors.infoLight,
                  onTap: () async {
                    await context.push(const KelolaAsisten());
                    setState(() {});
                  },
                ),
                TombolAksesCepat(
                  title: 'Cetak Laporan',
                  icon: Icons.file_download,
                  iconColor: AppColors.danger, // MERAH
                  bgColor: AppColors.dangerLight,
                  onTap: () {
                    print("Ke Laporan");
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
