import 'package:flutter/material.dart';
import 'package:al_falah_app/controllers/jamaah_controller.dart';
import 'package:al_falah_app/utils/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class TabWiridJamaah extends StatefulWidget {
  const TabWiridJamaah({super.key});

  @override
  State<TabWiridJamaah> createState() => _TabWiridJamaahState();
}

class _TabWiridJamaahState extends State<TabWiridJamaah> {
  Map<String, dynamic>? _wiridData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await JamaahController.ambilBacaanWirid();
    if (mounted) {
      setState(() {
        _wiridData = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _bukaQuran() async {
    final Uri url = Uri.parse('https://quran.kemenag.go.id/');
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Tidak dapat membuka Web Browser');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuka Al-Qur\'an: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    return Column(
      children: [
        // TOMBOL AL-QURAN
        Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(bottom: BorderSide(color: AppColors.borderLight)),
          ),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B5E20), // Hijau nuansa islami
              minimumSize: const Size.fromHeight(50),
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _bukaQuran,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.menu_book, color: Colors.white),
                SizedBox(width: 12),
                Text(
                  'BUKA AL-QUR\'AN KEMENAG',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
                SizedBox(width: 4),
                Icon(Icons.open_in_new, color: Colors.white70, size: 16),
              ],
            ),
          ),
        ),

        // KONTEN WIRID
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(Icons.mosque, size: 40, color: AppColors.primaryLight),
                const SizedBox(height: 16),
                Text(
                  _wiridData!['judul'] ?? 'Wirid Rutin',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
                const SizedBox(height: 32),
                Text(
                  _wiridData!['isi'] ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 22, // Ukuran besar untuk dibaca
                    color: AppColors.textHeading,
                    height: 2.2, // Jarak antar baris lebar
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  '--- Selesai ---',
                  style: TextStyle(color: AppColors.textSubtitle),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        )
      ],
    );
  }
}
