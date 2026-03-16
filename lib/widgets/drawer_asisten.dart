import 'package:flutter/material.dart';
import 'package:al_falah_app/controllers/login_controller.dart';
import 'package:al_falah_app/extensions/navigator.dart';
import 'package:al_falah_app/view/auth/layar_login.dart';
import 'package:al_falah_app/utils/app_colors.dart';

class DrawerAsisten extends StatelessWidget {
  final String namaUser;
  final String emailUser;

  const DrawerAsisten({
    Key? key,
    required this.namaUser,
    required this.emailUser,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.background,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primary),
            accountName: Text(
              namaUser,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(emailUser),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.admin_panel_settings,
                size: 40,
                color: AppColors.primary,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard, color: AppColors.textBody),
            title: const Text(
              'Beranda',
              style: TextStyle(color: AppColors.textHeading),
            ),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(
              Icons.calendar_today,
              color: AppColors.textBody,
            ),
            title: const Text(
              'Jadwal Kajian',
              style: TextStyle(color: AppColors.textHeading),
            ),
            onTap: () {
              // Nanti arahin ke menu kelola jadwal
              print("Ke Menu Jadwal Asisten");
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.fact_check_outlined,
              color: AppColors.textBody,
            ),
            title: const Text(
              'Absensi Jamaah',
              style: TextStyle(color: AppColors.textHeading),
            ),
            onTap: () {
              // Nanti arahin ke menu absensi
              print("Ke Menu Absensi");
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
              await LoginController.logout(); // Panggil fungsi logout lu
              if (context.mounted) {
                context.pushAndRemoveAll(const LayarLogin());
              }
            },
          ),
        ],
      ),
    );
  }
}
