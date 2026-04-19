import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

// layar buat jamaah baca doa-doa dzikir atau wirid harian
class BacaanWirid extends StatelessWidget {
  const BacaanWirid({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // bagian kepala layar (AppBar)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
              color: AppColors.primary,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 32),
                  ),
                  const Text(
                    'Dzikir & Wirid',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // konten bacaan wiridnya di dalem listview biar bisa di-scroll
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(14),
                children: [
                  _buildWiridSec(
                    '1 · Al Fatihah',
                    'بِسْمِ اللهِ الرَّحْمَنِ الرَّحِيمِ',
                    'Dengan nama Allah Yang Maha Pengasih, Maha Penyayang.',
                  ),
                  _buildWiridSec(
                    '2 · Al Baqarah 1–5',
                    'الٓمٓ · ذَٰلِكَ الْكِتَٰبُ لَا رَيْبَ',
                    'Alif Lam Mim. Kitab ini tidak ada keraguan padanya...',
                  ),
                  _buildWiridSec(
                    '3 · Ayat Kursi (Al Baqarah 255)',
                    'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ',
                    'Allah, tidak ada tuhan selain Dia. Yang Maha Hidup, Yang terus-menerus mengurus makhluk-Nya.',
                  ),
                  _buildWiridSec(
                    '9 · Al Ikhlas',
                    'قُلْ هُوَ اللَّهُ أَحَدٌ',
                    'Katakanlah: Dialah Allah Yang Maha Esa.',
                  ),
                  _buildWiridSec(
                    '10 · An Naas',
                    'قُلْ أَعُوذُ بِرَبِّ النَّاسِ',
                    'Katakanlah: Aku berlindung kepada Tuhan manusia.',
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1, thickness: 0.5),
                  const SizedBox(height: 12),
                  
                  // tombol buat buka quran kemenag (siapa tau mau baca lebih banyak)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // buat sekarang munculin snackbar aja dulu ya
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Membuka Al-Qur\'an Kemenag...')),
                        );
                      },
                      icon: const Icon(Icons.menu_book_rounded, color: Colors.white),
                      label: const Text(
                        'Buka Al-Qur\'an Kemenag',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // widget buat bikin satu blok bacaan doa
  Widget _buildWiridSec(String num, String arab, String trl) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // nomor urut
          Text(
            num,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          // tulisan arabnya (rata kanan)
          Text(
            arab,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 26,
              color: AppColors.text,
              fontFamily: 'Roboto', // buat antisipasi font arab
              height: 2.0,
            ),
          ),
          const SizedBox(height: 8),
          // artinya
          Text(
            trl,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.muted,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}
