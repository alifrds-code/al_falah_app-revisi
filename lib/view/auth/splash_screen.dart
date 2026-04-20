import 'package:flutter/material.dart';
import 'package:al_falah_app/services/local_storage_service.dart';
import 'package:al_falah_app/view/admin/beranda_admin.dart';
import 'package:al_falah_app/view/asisten/beranda_asisten.dart';
import 'package:al_falah_app/view/auth/layar_login.dart';
import 'package:al_falah_app/utils/app_colors.dart';
import 'package:al_falah_app/extensions/navigator.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    // Beri sedikit jeda biar splash screen kelihatan bentar
    await Future.delayed(const Duration(seconds: 2));

    final pref = PreferenceHandler();
    await pref.init();

    final isLogin = await pref.getIsLogin() ?? false;

    if (!mounted) return;

    if (isLogin) {
      final role = await pref.getRole();
      final uid = await pref.getUid();
      final namaUser = await pref.getNama() ?? 'User';
      final emailUser = await pref.getEmail() ?? '-';

      if (role == 'admin') {
        context.pushReplacement(BerandaAdmin(
          namaUser: namaUser,
          emailUser: emailUser,
        ));
      } else if (role == 'asisten') {
        context.pushReplacement(BerandaAsisten(
          uid: uid ?? '',
          namaUser: namaUser,
          emailUser: emailUser,
        ));
      } else {
        context.pushReplacement(const LayarLogin());
      }
    } else {
      context.pushReplacement(const LayarLogin());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/logoAlFalah.png',
              height: 150,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.mosque,
                size: 100,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }
}
