import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

// widget buat nampilin icon sama tulisan kalo emang datanya lagi kosong
class TampilanKosong extends StatelessWidget {
  final String pesan;
  final IconData icon;

  const TampilanKosong({
    super.key,
    required this.pesan,
    this.icon = Icons.inbox_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // icon gede biar keliatan hampa
          Icon(icon, size: 64, color: AppColors.border),
          const SizedBox(height: 16),
          // tulisan penjelasannya apa
          Text(
            pesan,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.muted,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
