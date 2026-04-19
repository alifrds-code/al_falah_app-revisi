import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

// Tampilan kosong saat belum ada data
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
          Icon(icon, size: 64, color: AppColors.border),
          const SizedBox(height: 16),
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
