// WIDGET KARTU STATISTIK (Daur Ulang)
// Desain dirombak ngikutin referensi React Tailwind (Rounded 2xl, Shadow halus)
import 'package:flutter/material.dart';
import 'package:al_falah_app/utils/app_colors.dart'; // Manggil palet warna kita

class KartuStatistik extends StatelessWidget {
  final String title;
  final String count;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;

  const KartuStatistik({
    Key? key,
    required this.title,
    required this.count,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface, // Background putih
        borderRadius: BorderRadius.circular(16), // Rounded-2xl ala Tailwind
        border: Border.all(
          color: AppColors.borderLight,
        ), // Border tipis gray-100
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), // Shadow super halus
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lingkaran background untuk Ikon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: bgColor, // Warna background icon (misal: hijau muda)
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 20,
              color: iconColor,
            ), // Warna icon (misal: hijau tua)
          ),
          const SizedBox(height: 12),

          // Angka Statistik
          Text(
            count,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textHeading, // Warna gray-900
            ),
          ),
          const SizedBox(height: 4),

          // Judul / Keterangan Kartu
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSubtitle, // Warna gray-500
            ),
          ),
        ],
      ),
    );
  }
}
