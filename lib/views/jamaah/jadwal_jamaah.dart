import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../widgets/label_status.dart';
import '../../widgets/tampilan_kosong.dart';
import '../../controllers/jamaah_controller.dart';
import '../../models/model_jadwal.dart';
import 'layar_pilih_kelas.dart';
import 'info_yayasan.dart';

// layar buat jamaah liat semua jadwal kajian buat kelas yang dia pilih
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
    // pas pertama masuk, langsung tarik data jadwalnya
    _loadData();
  }

  // fungsi buat minta list jadwal dari database
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
            // bagian kepala layar biar tau lagi di mana
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

            // nampilin list jadwalnya
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _jadwal.isEmpty
                      ? const TampilanKosong(
                          pesan: 'Belum ada jadwal nih buat kelas pilihan lu.\nCoba ganti pilihan kelasnya deh.',
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

            // tombol melayang buat ganti kelas, ditaruh di bawah tengah
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
                        ).then((_) => _loadData()); // refresh data pas balik dari sana
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

      // menu navigasi di bawah layar
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

  // widget buat kotak satu baris jadwal
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
              // nampilin tanggal kajiannya
              Text(
                j.tanggal,
                style: const TextStyle(fontSize: 13, color: AppColors.muted),
              ),
              const SizedBox(height: 4),
              // nampilin nama guru/pematerinya
              Text(
                j.namaPemateri,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 2),
              // nampilin detail jam sama materinya
              Text(
                '${j.waktuMulai} – ${j.waktuSelesai}  •  ${j.materiPembahasan ?? "Kajian Rutin"}',
                style: const TextStyle(fontSize: 13, color: AppColors.muted, height: 1.4),
              ),
              // nampilin kelasnya biar gak ketuker
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
              // kalo jadwalnya telat atau batal, ada alasannya di sini
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
          // label status (sesuai jadwal/ditunda/batal) di pojok kanan
          Positioned(
            top: 0,
            right: 0,
            child: LabelStatus(status: j.statusJadwal),
          ),
        ],
      ),
    );
  }

  // buat bikin item menu navigasi bawah
  Widget _buildNavItem(BuildContext context, int index, IconData icon, String label, {bool isActive = false}) {
    return Expanded(
      child: InkWell(
        onTap: () {
          if (index == 0) {
            // kalo ke beranda balik sampe awal
            Navigator.popUntil(context, (route) => route.isFirst);
          } else if (index == 2) {
            // kalo ke info, ganti halamannya
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
