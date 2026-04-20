import 'package:flutter/material.dart';
import 'package:al_falah_app/utils/app_colors.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class DetailAcara extends StatelessWidget {
  final Map<String, dynamic> acara;

  const DetailAcara({super.key, required this.acara});

  @override
  Widget build(BuildContext context) {
    // Parsing Tanggal
    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(acara['tanggal']);
    } catch (e) {
      parsedDate = DateTime.now();
    }
    String tglStr = DateFormat('dd MMMM yyyy').format(parsedDate);
    String urlPoster = acara['url_poster'] ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Detail Acara',
          style: TextStyle(
            color: AppColors.textHeading,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textHeading),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.borderLight, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // BAGIAN POSTER ACARA
            if (urlPoster.isNotEmpty)
              urlPoster.startsWith('http')
                  ? Image.network(
                      urlPoster,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildPosterPlaceholder(),
                    )
                  : Image.memory(
                      base64Decode(urlPoster),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildPosterPlaceholder(),
                    )
            else
              _buildPosterPlaceholder(height: 250),

            // BAGIAN DETAIL ACARA
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    acara['nama_acara'] ?? 'Tanpa Judul',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textHeading,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Kotak Info (Waktu & Lokasi)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderLight),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          icon: Icons.calendar_today,
                          title: 'Tanggal',
                          value: tglStr,
                        ),
                        const Divider(height: 24, color: AppColors.borderLight),
                        _buildInfoRow(
                          icon: Icons.access_time,
                          title: 'Jam Acara',
                          value: '${acara['jam'] ?? '-'} WIB',
                        ),
                        const Divider(height: 24, color: AppColors.borderLight),
                        _buildInfoRow(
                          icon: Icons.location_on,
                          title: 'Lokasi',
                          value: acara['lokasi'] ?? 'Belum ditentukan',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Deskripsi
                  const Text(
                    'DESKRIPSI ACARA',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSubtitle,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    acara['deskripsi'] ?? 'Tidak ada deskripsi rinci untuk acara ini.',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textBody,
                      height: 1.6, // Biar lebih lega dibacanya
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

  // Komponen pembantu untuk baris info
  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF3E5F5), // Purple Light
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF9C27B0), size: 20), // Purple
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSubtitle,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textHeading,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Placeholder kalo ga ada poster
  Widget _buildPosterPlaceholder({double height = double.infinity}) {
    return Container(
      height: height,
      color: const Color(0xFFF3E5F5),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_available,
              color: Color(0xFF9C27B0),
              size: 64,
            ),
            SizedBox(height: 8),
            Text(
              'Tidak Ada Poster',
              style: TextStyle(
                color: Color(0xFF9C27B0),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
