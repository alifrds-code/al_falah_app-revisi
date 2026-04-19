import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../controllers/jamaah_controller.dart';
import '../../models/model_pengumuman.dart';
import '../../models/model_acara.dart';
import 'detail_info.dart';
import 'jadwal_jamaah.dart';

// layar buat jamaah liat info-info penting atau acara yang mau diadain yayasan
class InfoYayasan extends StatefulWidget {
  const InfoYayasan({super.key});

  @override
  State<InfoYayasan> createState() => _InfoYayasanState();
}

class _InfoYayasanState extends State<InfoYayasan> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final JamaahController _controller = JamaahController();
  List<PengumumanModel> _pengumuman = [];
  List<AcaraModel> _acara = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // bikin tab buat misahin antara pengumuman biasa sama agenda kegiatan
    _tabController = TabController(length: 2, vsync: this);
    // ambil datanya dari database
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // fungsi buat tarik data pengumuman sama acara sekaligus
  void _loadData() async {
    final dataPengumuman = await _controller.getPengumuman();
    final dataAcara = await _controller.getAcara();
    setState(() {
      _pengumuman = dataPengumuman;
      _acara = dataAcara;
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
            // bagian kepala layar warna hijau, ada tab-nya juga
            Container(
              color: AppColors.primary,
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    child: Center(
                      child: Text(
                        'Info Yayasan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.white,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white70,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    tabs: const [
                      Tab(text: 'Pengumuman'),
                      Tab(text: 'Kegiatan'),
                    ],
                  ),
                ],
              ),
            ),

            // isi kontennya ganti-ganti tergantung tab yang dipilih
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildPengumumanTab(),
                        _buildKegiatanTab(),
                      ],
                    ),
            ),
          ],
        ),
      ),

      // menu navigasi di bagian bawah
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border, width: 0.5)),
        ),
        child: Row(
          children: [
            _buildNavItem(context, 0, Icons.home_rounded, 'Beranda'),
            _buildNavItem(context, 1, Icons.calendar_month_rounded, 'Jadwal'),
            _buildNavItem(context, 2, Icons.info_outline_rounded, 'Info', isActive: true),
          ],
        ),
      ),
    );
  }

  // widget buat nampilin daftar pengumuman
  Widget _buildPengumumanTab() {
    if (_pengumuman.isEmpty) {
      return const Center(
        child: Text('Belum ada pengumuman nih', style: TextStyle(color: AppColors.muted)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: _pengumuman.length,
      itemBuilder: (context, index) {
        final p = _pengumuman[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildInfoCard(
            title: p.judul,
            date: p.tanggalPost.length >= 10 ? p.tanggalPost.substring(0, 10) : p.tanggalPost,
            preview: p.isiTeks.length > 100 ? '${p.isiTeks.substring(0, 100)}...' : p.isiTeks,
            onTap: () => _toDetail(p.judul, p.isiTeks, p.tanggalPost),
          ),
        );
      },
    );
  }

  // widget buat nampilin daftar kegiatan/agenda
  Widget _buildKegiatanTab() {
    if (_acara.isEmpty) {
      return const Center(
        child: Text('Belum ada kegiatan buat sekarang', style: TextStyle(color: AppColors.muted)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(14),
      itemCount: _acara.length,
      itemBuilder: (context, index) {
        final e = _acara[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildEventCard(
            title: e.namaAcara,
            meta: '${e.tanggalAcara}  •  ${e.lokasi}  •  ${e.waktu}',
            onTap: () => _toDetail(e.namaAcara, e.deskripsi, e.tanggalAcara),
          ),
        );
      },
    );
  }

  // fungsi buat pindah ke layar detail pas salah satu info diklik
  void _toDetail(String title, String body, String date) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailInfo(title: title, body: body, date: date),
      ),
    );
  }

  // widget buat kotak satu pengumuman
  Widget _buildInfoCard({
    required String title,
    required String date,
    required String preview,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date,
              style: const TextStyle(fontSize: 12, color: AppColors.muted),
            ),
            const SizedBox(height: 8),
            Text(
              preview,
              style: const TextStyle(fontSize: 14, color: AppColors.muted, height: 1.5),
            ),
            const SizedBox(height: 8),
            const Text(
              'Baca Selengkapnya →',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // widget buat kotak satu kegiatan/agenda
  Widget _buildEventCard({
    required String title,
    required String meta,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(
          children: [
            // ikon penanda kegiatan
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.event_available_rounded, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    meta,
                    style: const TextStyle(fontSize: 12, color: AppColors.muted),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
          ],
        ),
      ),
    );
  }

  // buat bikin item navigasi yang ada di bawah layar
  Widget _buildNavItem(
    BuildContext context,
    int index,
    IconData icon,
    String label, {
    bool isActive = false,
  }) {
    return Expanded(
      child: InkWell(
        onTap: () {
          if (index == 0) {
            // balik ke beranda utama
            Navigator.popUntil(context, (route) => route.isFirst);
          } else if (index == 1) {
            // pindah ke halaman jadwal
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const JadwalJamaah()),
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
