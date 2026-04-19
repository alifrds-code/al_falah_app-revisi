import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../widgets/label_status.dart';
import '../../widgets/tampilan_kosong.dart';
import '../../controllers/jamaah_controller.dart';
import '../../models/model_jadwal.dart';
import 'layar_pilih_kelas.dart';
import 'info_yayasan.dart';

// Layar daftar semua jadwal dari kelas yang dipilih jamaah
class JadwalJamaah extends StatefulWidget {
  const JadwalJamaah({super.key});

  @override
  State<JadwalJamaah> createState() => _JadwalJamaahState();
}

class _JadwalJamaahState extends State<JadwalJamaah> {
  final JamaahController _controller = JamaahController();
  List<JadwalModel> _jadwal = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final data = await _controller.getMySchedules();
    setState(() {
      _jadwal = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              color: AppColors.primary,
              child: const Center(
                child: Text(
                  'Jadwal Saya',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // Daftar jadwal
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _jadwal.isEmpty
                      ? const TampilanKosong(
                          pesan: 'Belum ada jadwal untuk kelas pilihan Anda.\nCoba ubah pilihan kelas.',
                          icon: Icons.calendar_month_outlined,
                        )
                      : RefreshIndicator(
                          onRefresh: () async => _loadData(),
                          child: ListView.builder(
                            padding: const EdgeInsets.all(14),
                            itemCount: _jadwal.length,
                            itemBuilder: (context, index) {
                              final j = _jadwal[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildJadwalCard(j),
                              );
                            },
                          ),
                        ),
            ),

            // Tombol ubah pilihan kelas
            if (!_isLoading)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LayarPilihKelas(),
                          ),
                        ).then((_) => _loadData());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(16),
                        elevation: 4,
                      ),
                      child: const Icon(Icons.edit_note_rounded, color: Colors.white, size: 28),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Ubah pilihan kelas',
                      style: TextStyle(fontSize: 12, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),

      // Nav bar bawah
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
        ),
        child: Row(
          children: [
            _buildNavItem(context, 0, Icons.home_rounded, 'Beranda'),
            _buildNavItem(context, 1, Icons.calendar_month_rounded, 'Jadwal', isActive: true),
            _buildNavItem(context, 2, Icons.info_outline_rounded, 'Info'),
          ],
        ),
      ),
    );
  }

  // Kartu satu jadwal
  Widget _buildJadwalCard(JadwalModel j) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tanggal
              Text(
                j.tanggal,
                style: const TextStyle(fontSize: 13, color: AppColors.muted),
              ),
              const SizedBox(height: 4),
              // Nama pemateri
              Text(
                j.namaPemateri,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 2),
              // Detail waktu dan materi
              Text(
                '${j.waktuMulai} – ${j.waktuSelesai}  •  ${j.materiPembahasan ?? "Kajian Rutin"}',
                style: const TextStyle(fontSize: 13, color: AppColors.muted, height: 1.4),
              ),
              // Nama kelas
              if (j.namaKelas != null) ...[
                const SizedBox(height: 4),
                Text(
                  j.namaKelas!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
              // Alasan penundaan/pembatalan
              if (j.alasanPerubahan != null && j.alasanPerubahan!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded, color: AppColors.yellow, size: 14),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        j.alasanPerubahan!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.yellow,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          // Badge status di pojok kanan atas
          Positioned(
            top: 0,
            right: 0,
            child: LabelStatus(status: j.statusJadwal),
          ),
        ],
      ),
    );
  }

  // Item navigasi bawah
  Widget _buildNavItem(BuildContext context, int index, IconData icon, String label, {bool isActive = false}) {
    return Expanded(
      child: InkWell(
        onTap: () {
          if (index == 0) {
            Navigator.popUntil(context, (route) => route.isFirst);
          } else if (index == 2) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const InfoYayasan()),
            );
          }
        },
        child: SizedBox(
          height: 68,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isActive ? AppColors.primary : AppColors.muted, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isActive ? AppColors.primary : AppColors.muted,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
