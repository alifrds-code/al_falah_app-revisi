import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../services/local_storage_service.dart';
import '../jamaah/beranda_jamaah.dart';
import '../jamaah/layar_pilih_kelas.dart';
import '../admin/beranda_admin.dart';
import '../asisten/beranda_asisten.dart';

// layar loading pertama kali pas app dibuka (splash screen)
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // langsung gue suruh pindah ke layar berikutnya seabis nunggu bentar
    _navigateToNext();
  }

  // fungsi buat nentuin abis ini pindah ke layar mana
  void _navigateToNext() async {
    // nunggu 3 detik biar logonya keliatan dulu
    await Future.delayed(const Duration(seconds: 3));
    
    if (!mounted) return;

    // cek dulu ini orang baru install apa udah pernah buka
    final isFirst = await LocalStorageService.isFirstTime();
    if (!mounted) return;

    if (isFirst) {
      // kalo baru pertama kali, suruh pilih kelas dulu
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LayarPilihKelas()),
      );
      return;
    }

    // kalo udah pernah buka, cek apa dia punya session login pengurus
    final user = await LocalStorageService.getUser();
    if (!mounted) return;

    if (user != null) {
      // kalo ada data user, lempar ke dashboard yang sesuai rolenya
      if (user.role == 'admin') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const BerandaAdmin()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const BerandaAsisten()));
      }
    } else {
      // kalo gak ada login, lempar ke beranda jamaah aja
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
            // kotak logo di tengah
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
            // tulisan nama aplikasinya
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
