import 'package:flutter/material.dart';
import 'package:al_falah_app/views/auth/splash_screen.dart';
import 'package:al_falah_app/utils/app_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Ta'lim Al Falah",
      theme: ThemeData(
        fontFamily: 'Inter', // Assuming standard system font for now
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.primaryDark,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
