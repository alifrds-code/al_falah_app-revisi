// // Lokasi: lib/views/auth/splash_screen.dart

// import 'package:flutter/material.dart';
// import '../../utils/app_colors.dart';
// // Import halaman Pilih Kelas (Onboarding) yang bakal jadi tujuan selanjutnya
// import '../jamaah/layar_pilih_kelas.dart';

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({Key? key}) : super(key: key);

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> {
//   @override
//   void initState() {
//     super.initState();
//     _pindahKeLayarBerikutnya();
//   }

//   // Fungsi timer untuk menahan Splash Screen selama 3 detik
//   Future<void> _pindahKeLayarBerikutnya() async {
//     // Kita kasih delay 3 detik biar jamaah bisa liat logo dan animasi kerennya dulu
//     await Future.delayed(const Duration(seconds: 3));

//     // Cek apakah widget masih aktif (mounted) sebelum pindah halaman
//     // Ini penting biar nggak error kalau usernya keburu nutup app pas lagi loading
//     if (!mounted) return;

//     /* -------------------------------------------------------------------------
//       CATATAN PENTING BUAT INTEGRASI DATABASE NANTI:
//       -------------------------------------------------------------------------
//       Pas database (SQLite) dan Shared Preferences udah siap, logika di bawah ini
//       nggak boleh asal 'loncat' ke LayarPilihKelas. 
      
//       Alurnya harusnya begini:
//       1. Cek Shared Preferences: "Apakah ini pertama kali aplikasi dibuka?" (isFirstTime).
//       2. Kalau TRUE: Navigasi ke LayarPilihKelas (Onboarding)[cite: 28, 90].
//       3. Kalau FALSE: Cek lagi, "Apakah user sudah login sebagai pengurus?" (isLogin).
//          - Kalau isLogin TRUE: Ke Dashboard Admin/Asisten[cite: 43, 53].
//          - Kalau isLogin FALSE: Langsung ke Beranda Jamaah[cite: 30].
      
//       KARENA SEKARANG KITA FOKUS UI:
//       Gua 'hardcode' dulu supaya dia otomatis pindah ke LayarPilihKelas.
//       Ini simulasi seolah-olah jamaah baru pertama kali install aplikasi ini.
//       -------------------------------------------------------------------------
//     */

//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => const LayarPilihKelas()),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // Background pake gradasi biar keliatan hidup dan nggak kaku [cite: 21]
//       body: Container(
//         width: double.infinity,
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               Color(0xFF0F172A), // Slate 900
//               Color(0xFF064E3B), // Emerald 900
//               Color(0xFF0F172A), // Slate 900
//             ],
//           ),
//         ),
//         child: Stack(
//           children: [
//             // Efek cahaya (Glow) di pojok kiri atas biar desainnya lebih modern
//             Positioned(
//               top: -50,
//               left: -50,
//               child: Container(
//                 width: 200,
//                 height: 200,
//                 decoration: BoxDecoration(
//                   shape: BoxShape.circle,
//                   color: AppColors.primaryEmerald.withOpacity(0.15),
//                 ),
//               ),
//             ),

//             Center(
//               child: TweenAnimationBuilder(
//                 duration: const Duration(milliseconds: 1500),
//                 curve: Curves.easeOutBack,
//                 tween: Tween<double>(begin: 0.5, end: 1.0),
//                 builder: (context, double value, child) {
//                   return Opacity(
//                     opacity: value.clamp(0.0, 1.0),
//                     child: Transform.scale(
//                       scale: value,
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           // Box Logo bergaya Glassmorphism
//                           Container(
//                             padding: const EdgeInsets.all(24),
//                             decoration: BoxDecoration(
//                               color: Colors.white.withOpacity(0.1),
//                               borderRadius: BorderRadius.circular(30),
//                               border: Border.all(
//                                 color: Colors.white.withOpacity(0.2),
//                                 width: 1.5,
//                               ),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: AppColors.primaryEmerald.withOpacity(
//                                     0.3,
//                                   ),
//                                   blurRadius: 30,
//                                   spreadRadius: 5,
//                                 ),
//                               ],
//                             ),
//                             child: const Icon(
//                               Icons.mosque_rounded,
//                               size: 64,
//                               color: Colors.white,
//                             ),
//                           ),
//                           const SizedBox(height: 32),

//                           const Text(
//                             "Ta'lim Al Falah",
//                             style: TextStyle(
//                               fontSize: 36,
//                               fontWeight: FontWeight.w800,
//                               color: Colors.white,
//                               letterSpacing: 1.2,
//                             ),
//                           ),
//                           const SizedBox(height: 8),

//                           Text(
//                             "SISTEM MANAJEMEN YAYASAN",
//                             style: TextStyle(
//                               fontSize: 12,
//                               fontWeight: FontWeight.w600,
//                               color: AppColors.primaryEmerald.withOpacity(0.9),
//                               letterSpacing: 3.0,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),

//             // Indikator loading kecil buat ngasih tau user kalau sistem lagi "berpikir"
//             Positioned(
//               bottom: 60,
//               left: 0,
//               right: 0,
//               child: Column(
//                 children: [
//                   SizedBox(
//                     width: 40,
//                     height: 40,
//                     child: CircularProgressIndicator(
//                       color: AppColors.primaryEmerald,
//                       strokeWidth: 3.5,
//                       backgroundColor: Colors.white.withOpacity(0.1),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
