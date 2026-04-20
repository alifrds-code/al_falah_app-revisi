import 'package:flutter/material.dart';
import 'package:al_falah_app/controllers/admin_controller.dart';
import 'package:al_falah_app/services/firebase_service.dart';
import 'package:al_falah_app/utils/app_colors.dart';
import 'package:intl/intl.dart';

/// Tab Beranda: Ringkasan kelas & jadwal hari ini
class TabBerandaAsisten extends StatefulWidget {
  final String uid;
  final String namaUser;

  const TabBerandaAsisten({
    super.key,
    required this.uid,
    required this.namaUser,
  });

  @override
  State<TabBerandaAsisten> createState() => _TabBerandaAsistenState();
}

class _TabBerandaAsistenState extends State<TabBerandaAsisten> {
  List<Map<String, dynamic>> _kelasSaya = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadKelas();
  }

  Future<void> _loadKelas() async {
    final allKelas = await AdminController.ambilSemuaKelas();
    setState(() {
      _kelasSaya = allKelas.where((k) => k['id_asisten'] == widget.uid).toList();
      _isLoading = false;
    });
  }

  Color _warnaStatus(int status) {
    switch (status) {
      case 1: return AppColors.warning;
      case 2: return AppColors.danger;
      default: return const Color(0xFF4CAF50);
    }
  }

  String _labelStatus(int status) {
    switch (status) {
      case 1: return '⏸ Ditunda';
      case 2: return '❌ Dibatalkan';
      default: return '✅ Sesuai Jadwal';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // GREETING
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, Color(0xFF1B5E20)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ahlan Wa Sahlan,',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.namaUser,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Mengelola ${_kelasSaya.length} kelas',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // DAFTAR KELAS
          const Text(
            'KELAS YANG DIKELOLA',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textSubtitle,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),

          if (_kelasSaya.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: const Text(
                'Anda belum ditugaskan ke kelas manapun.\nSilakan hubungi Admin.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSubtitle),
              ),
            )
          else
            ...List.generate(_kelasSaya.length, (index) {
              final kelas = _kelasSaya[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.class_, color: AppColors.primary, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        kelas['nama_kelas'] ?? '-',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.textHeading,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

          const SizedBox(height: 24),

          // JADWAL HARI INI
          const Text(
            'JADWAL HARI INI',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textSubtitle,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),

          if (_kelasSaya.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: const Text(
                'Tidak ada kelas yang dikelola.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSubtitle),
              ),
            )
          else
            ..._kelasSaya.map((kelas) {
              final idKelas = kelas['id'];
              final namaKelas = kelas['nama_kelas'] ?? '-';
              return StreamBuilder<List<Map<String, dynamic>>>(
                stream: FirebaseService.ambilJadwalByKelasStream(idKelas),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox.shrink();

                  final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
                  final jadwalHariIni = snapshot.data!
                      .where((j) => j['tanggal'] == todayStr)
                      .toList();

                  if (jadwalHariIni.isEmpty) return const SizedBox.shrink();

                  return Column(
                    children: jadwalHariIni.map((jadwal) {
                      final status = jadwal['status_jadwal'] ?? 0;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _warnaStatus(status), width: 2),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.warningLight,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.schedule, color: AppColors.warning, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        namaKelas,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textHeading,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        '${jadwal['waktu_mulai'] ?? '-'} - ${jadwal['waktu_selesai'] ?? '-'}',
                                        style: const TextStyle(fontSize: 12, color: AppColors.textSubtitle),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _warnaStatus(status).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    _labelStatus(status),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: _warnaStatus(status),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if ((jadwal['materi_pembahasan'] ?? '').isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Materi: ${jadwal['materi_pembahasan']}',
                                style: const TextStyle(fontSize: 12, color: AppColors.textBody),
                              ),
                            ],
                            if ((jadwal['nama_pemateri'] ?? '').isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Pemateri: ${jadwal['nama_pemateri']}',
                                style: const TextStyle(fontSize: 12, color: AppColors.textSubtitle),
                              ),
                            ],
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              );
            }),

          // Show fallback if no jadwal today found
          Builder(builder: (_) {
            // This just renders a message if ALL streams are empty for today
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }
}
