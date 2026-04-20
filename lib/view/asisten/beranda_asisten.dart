import 'package:flutter/material.dart';
import 'package:al_falah_app/controllers/login_controller.dart';
import 'package:al_falah_app/extensions/navigator.dart';
import 'package:al_falah_app/view/auth/layar_login.dart';
import 'package:al_falah_app/utils/app_colors.dart';
import 'package:al_falah_app/view/asisten/tab_beranda_asisten.dart';
import 'package:al_falah_app/view/asisten/tab_jadwal.dart';
import 'package:al_falah_app/view/asisten/tab_absensi.dart';

class BerandaAsisten extends StatefulWidget {
  final String uid;
  final String namaUser;
  final String emailUser;

  const BerandaAsisten({
    super.key,
    required this.uid,
    required this.namaUser,
    required this.emailUser,
  });

  @override
  State<BerandaAsisten> createState() => _BerandaAsistenState();
}

class _BerandaAsistenState extends State<BerandaAsisten> {
  int _currentIndex = 0;

  late final List<Widget> _pages;
  final List<String> _titles = ['Beranda', 'Jadwal Kelas', 'Absensi Jamaah'];

  @override
  void initState() {
    super.initState();
    _pages = [
      TabBerandaAsisten(uid: widget.uid, namaUser: widget.namaUser),
      TabJadwal(uid: widget.uid),
      TabAbsensi(uid: widget.uid),
    ];
  }

  void _konfirmasiLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Keluar?',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textHeading),
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari akun ini?',
          style: TextStyle(color: AppColors.textBody, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Batal',
              style: TextStyle(color: AppColors.textSubtitle, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(context);
              await LoginController.logout();
              if (context.mounted) {
                context.pushAndRemoveAll(const LayarLogin());
              }
            },
            child: const Text(
              'Ya, Keluar',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

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
            icon: const Icon(Icons.logout, color: AppColors.danger),
            tooltip: 'Keluar',
            onPressed: _konfirmasiLogout,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.borderLight, height: 1),
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
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
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined),
              activeIcon: Icon(Icons.calendar_month),
              label: 'Jadwal',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fact_check_outlined),
              activeIcon: Icon(Icons.fact_check),
              label: 'Absensi',
            ),
          ],
        ),
      ),
    );
  }
}
