// WIDGET AKSES CEPAT (Daur Ulang)
// Desain dirombak ngikutin referensi React Tailwind (Kotak Grid, Icon Tengah)
import 'package:flutter/material.dart';
import 'package:al_falah_app/utils/app_colors.dart'; // Palet warna kita

class TombolAksesCepat extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final VoidCallback onTap; // WAJIB ada biar tombolnya bisa dipencet

  const TombolAksesCepat({
    Key? key,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // Dekorasi kotak luar (Shadow dan Border tipis)
      decoration: BoxDecoration(
        color: AppColors.surface, // Putih bersih
        borderRadius: BorderRadius.circular(16), // Melengkung 2xl
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), // Shadow super halus
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      // Material & InkWell biar ada efek cipratan air (Ripple Effect) pas ditap
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center, // Bikin ke tengah persis
              children: [
                // Lingkaran Icon
                Container(
                  width: 48, // Lebar kotak icon
                  height: 48, // Tinggi kotak icon
                  decoration: BoxDecoration(
                    color: bgColor, // Warna hijau pudar / biru pudar
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(height: 12),

                // Teks Menu
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12, // Teks ukuran kecil (text-xs)
                    fontWeight: FontWeight.bold, // Teks tebal
                    color: AppColors.textBody, // Warna tulisan gray-600
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
