import 'package:flutter/material.dart';
import 'package:al_falah_app/controllers/login_controller.dart';
import 'package:al_falah_app/extensions/navigator.dart';
import 'package:al_falah_app/view/auth/layar_login.dart';
import 'package:al_falah_app/view/admin/kelola_kelas.dart';
import 'package:al_falah_app/view/admin/kelola_asisten.dart';
import 'package:al_falah_app/view/admin/kelola_jamaah.dart';
import 'package:al_falah_app/view/admin/kelola_acara.dart';
import 'package:al_falah_app/view/admin/kelola_pengumuman.dart';
import 'package:al_falah_app/utils/app_colors.dart'; // Biar warnanya nyambung

class DrawerAdmin extends StatelessWidget {
  // 1. BIKIN KANTONG PENAMPUNG DATA
  final String namaUser;
  final String emailUser;

  const DrawerAdmin({Key? key, required this.namaUser, required this.emailUser})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.background,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Bagian Header Drawer
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              color: AppColors.primary,
            ), // Pake Emerald
            accountName: Text(
              namaUser, // 2. TAMPILIN NAMA ASLI DI SINI
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(emailUser), // 3. TAMPILIN EMAIL ASLI DI SINI
          ),

          // Menu-menu (Kodingan bawahnya tetep sama persis)
          ListTile(
            leading: const Icon(Icons.dashboard, color: AppColors.textBody),
            title: const Text(
              'Beranda',
              style: TextStyle(color: AppColors.textHeading),
            ),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.people, color: AppColors.textBody),
            title: const Text(
              'Kelola Asisten',
              style: TextStyle(color: AppColors.textHeading),
            ),
            onTap: () {
              Navigator.pop(context);
              context.push(const KelolaAsisten());
            },
          ),
          ListTile(
            leading: const Icon(Icons.class_, color: AppColors.textBody),
            title: const Text(
              'Kelola Kelas',
              style: TextStyle(color: AppColors.textHeading),
            ),
            onTap: () {
              Navigator.pop(context);
              context.push(const KelolaKelas());
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.family_restroom,
              color: AppColors.textBody,
            ),
            title: const Text(
              'Kelola Jamaah',
              style: TextStyle(color: AppColors.textHeading),
            ),
            onTap: () {
              Navigator.pop(context); // Tutup menu sampingnya dulu
              context.push(const KelolaJamaah()); // Baru pindah halaman
            },
          ),
          ListTile(
            leading: const Icon(Icons.event_available, color: AppColors.textBody),
            title: const Text(
              'Kelola Acara',
              style: TextStyle(color: AppColors.textHeading),
            ),
            onTap: () {
              Navigator.pop(context);
              context.push(const KelolaAcara());
            },
          ),
          ListTile(
            leading: const Icon(Icons.campaign, color: AppColors.textBody),
            title: const Text(
              'Pengumuman',
              style: TextStyle(color: AppColors.textHeading),
            ),
            onTap: () {
              Navigator.pop(context);
              context.push(const KelolaPengumuman());
            },
          ),
          const Divider(color: AppColors.borderLight),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.danger),
            title: const Text(
              'Keluar',
              style: TextStyle(
                color: AppColors.danger,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () async {
              await LoginController.logout();
              context.pushAndRemoveAll(const LayarLogin());
            },
          ),
        ],
      ),
    );
  }
}
