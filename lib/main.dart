import 'package:flutter/material.dart';
import 'package:al_falah_app/views/auth/splash_screen.dart';
import 'package:al_falah_app/utils/app_colors.dart';

// ini fungsi utama yang pertama kali dipanggil pas aplikasi dinyalain
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // buang tulisan 'debug' di pojok kanan atas biar cakep
      title: "Ta'lim Al Falah",
      theme: ThemeData(
        fontFamily: 'Inter', // gue pake font Inter biar tampilannya modern
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.primaryDark,
        ),
      ),
      // halaman pertama yang muncul itu splash screen
      home: const SplashScreen(),
    );
  }
}
