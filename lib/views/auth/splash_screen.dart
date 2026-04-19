import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../services/local_storage_service.dart';
import '../jamaah/beranda_jamaah.dart';
import '../jamaah/layar_pilih_kelas.dart';
import '../admin/beranda_admin.dart';
import '../asisten/beranda_asisten.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNext();
  }

  void _navigateToNext() async {
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;

    final isFirst = await LocalStorageService.isFirstTime();
    if (!mounted) return;

    if (isFirst) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LayarPilihKelas()),
      );
      return;
    }

    final user = await LocalStorageService.getUser();
    if (!mounted) return;

    if (user != null) {
      if (user.role == 'admin') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const BerandaAdmin()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const BerandaAsisten()));
      }
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const BerandaJamaah()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.primary,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  'AF',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Al Falah',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
