import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

// ini widget buat nampilin status jadwal pake warna-warni (hijau/kuning/merah)
class LabelStatus extends StatelessWidget {
  final String status;

  const LabelStatus({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    // nentuin warna sama ikonnya apa berdasarkan status yang dikirim
    Color backgroundColor;
    Color textColor;
    IconData icon;

    if (status == 'Ditunda') {
      backgroundColor = AppColors.yellowLight;
      textColor = AppColors.yellow;
      icon = Icons.pause_circle_outline_rounded;
    } else if (status == 'Dibatalkan') {
      backgroundColor = AppColors.redLight;
      textColor = AppColors.red;
      icon = Icons.cancel_outlined;
    } else {
      // default-nya ya 'Sesuai Jadwal' warna ijo
      backgroundColor = AppColors.primaryLight;
      textColor = AppColors.primary;
      icon = Icons.check_circle_outline_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
