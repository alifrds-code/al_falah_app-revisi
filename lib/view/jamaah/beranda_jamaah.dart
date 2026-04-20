import 'package:flutter/material.dart';
import 'package:al_falah_app/utils/app_colors.dart';
import 'package:al_falah_app/view/jamaah/tab_beranda.dart';
import 'package:al_falah_app/view/jamaah/tab_jadwal.dart';
import 'package:al_falah_app/view/jamaah/tab_pengumuman.dart';
import 'package:al_falah_app/view/jamaah/tab_wirid.dart';

import 'package:al_falah_app/services/local_storage_service.dart';
import 'package:al_falah_app/extensions/navigator.dart';
import 'package:al_falah_app/view/auth/layar_login.dart';
import 'package:al_falah_app/view/admin/beranda_admin.dart';
import 'package:al_falah_app/view/asisten/beranda_asisten.dart';

class BerandaJamaah extends StatefulWidget {
  const BerandaJamaah({super.key});

  @override
  State<BerandaJamaah> createState() => _BerandaJamaahState();
}

class _BerandaJamaahState extends State<BerandaJamaah> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    TabBerandaJamaah(),
    TabJadwalJamaah(),
    TabPengumumanJamaah(),
    TabWiridJamaah(),
  ];

  final List<String> _titles = [
    'Ta\'lim Al Falah',
    'Jadwal Kelas Saya',
    'Pengumuman & Kegiatan',
    'Wirid Rutin',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          _titles[_currentIndex],
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textHeading,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.lock_outline, color: AppColors.primary),
            tooltip: 'Akses Pengurus',
            onPressed: () async {
              final pref = PreferenceHandler();
              await pref.init();
              final isLogin = await pref.getIsLogin() ?? false;

              if (!context.mounted) return;

              if (isLogin) {
                final role = await pref.getRole();
                final uid = await pref.getUid() ?? '';
                final namaUser = await pref.getNama() ?? 'User';
                final emailUser = await pref.getEmail() ?? '-';

                if (role == 'admin') {
                  context.push(BerandaAdmin(namaUser: namaUser, emailUser: emailUser));
                } else if (role == 'asisten') {
                  context.push(BerandaAsisten(uid: uid, namaUser: namaUser, emailUser: emailUser));
                }
              } else {
                context.push(const LayarLogin());
              }
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.borderLight, height: 1),
        ),
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.borderLight, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textHint,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.event_outlined),
              activeIcon: Icon(Icons.event),
              label: 'Jadwal',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.campaign_outlined),
              activeIcon: Icon(Icons.campaign),
              label: 'Info',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined),
              activeIcon: Icon(Icons.menu_book),
              label: 'Wirid',
            ),
          ],
        ),
      ),
    );
  }
}
