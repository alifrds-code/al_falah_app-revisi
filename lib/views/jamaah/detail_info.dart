import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

// layar buat nampilin detail pengumuman atau acara biar puas bacanya
class DetailInfo extends StatefulWidget {
  final String title;
  final String body;
  final String date;

  const DetailInfo({
    super.key,
    required this.title,
    required this.body,
    required this.date,
  });

  @override
  State<DetailInfo> createState() => _DetailInfoState();
}

class _DetailInfoState extends State<DetailInfo> {
  // ukuran huruf bawaan, biar bisa digedein kecilin sama jamaah
  double _fontSize = 15.0;

  // fungsi buat nambah atau ngurangin ukuran huruf
  void _changeFontSize(double delta) {
    setState(() {
      _fontSize = (_fontSize + delta).clamp(13.0, 22.0); // gue batesin biar gak kegedean banget
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // bagian kepala layar (AppBar) custom
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
                    'Detail Info',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // bagian isi beritanya
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(14),
                children: [
                  // gambar dekorasi di atas judul
                  Container(
                    height: 110,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.event_note_rounded,
                        size: 48,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // alat buat ngatur ukuran huruf biar bacanya enak
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Ukuran Huruf', style: TextStyle(fontSize: 13, color: AppColors.muted)),
                        Row(
                          children: [
                            _buildFsBtn('A−', () => _changeFontSize(-1)),
                            const SizedBox(width: 8),
                            _buildFsBtn('A+', () => _changeFontSize(1)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // judul beritanya
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: _fontSize + 5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1, thickness: 0.5),

                  // barisan info tambahan (kayak tanggal)
                  _buildMetaRow('Tanggal', widget.date),
                  const Divider(height: 1, thickness: 0.5),
                  const SizedBox(height: 14),

                  // teks isi beritanya
                  Text(
                    widget.body,
                    style: TextStyle(
                      fontSize: _fontSize,
                      color: const Color(0xFF3C3C3C),
                      height: 1.8,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // widget buat bikin tombol A+ atau A- tadi
  Widget _buildFsBtn(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 44,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
    );
  }

  // widget buat baris info metadata biar rapi
  Widget _buildMetaRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.muted)),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.text)),
        ],
      ),
    );
  }
}
