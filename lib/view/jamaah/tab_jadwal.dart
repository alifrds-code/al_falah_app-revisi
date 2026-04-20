import 'package:flutter/material.dart';
import 'package:al_falah_app/controllers/jamaah_controller.dart';
import 'package:al_falah_app/services/local_storage_service.dart';
import 'package:al_falah_app/utils/app_colors.dart';
import 'package:intl/intl.dart';

class TabJadwalJamaah extends StatefulWidget {
  const TabJadwalJamaah({super.key});

  @override
  State<TabJadwalJamaah> createState() => _TabJadwalJamaahState();
}

class _TabJadwalJamaahState extends State<TabJadwalJamaah> with SingleTickerProviderStateMixin {
  final PreferenceHandler _pref = PreferenceHandler();
  late TabController _tabController;
  
  List<Map<String, dynamic>> _jadwalMendatang = [];
  List<Map<String, dynamic>> _jadwalRiwayat = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    await _pref.init();
    final ids = await _pref.getKelasJamaah();
    
    if (ids.isEmpty) {
      if (mounted) setState(() { _isLoading = false; });
      return;
    }

    final data = await JamaahController.ambilSemuaJadwalKelas(ids);
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());

    List<Map<String, dynamic>> mendatang = [];
    List<Map<String, dynamic>> riwayat = [];

    for (var item in data) {
      final tgl = item['jadwal'].tanggal ?? '';
      if (tgl.compareTo(todayStr) >= 0) {
        mendatang.add(item);
      } else {
        riwayat.add(item);
      }
    }

    // Urutkan mendatang: terdekat dulu (ascending)
    mendatang.sort((a, b) => (a['jadwal'].tanggal ?? '').compareTo(b['jadwal'].tanggal ?? ''));
    // Urutkan riwayat: paling baru selesai dulu (descending)
    riwayat.sort((a, b) => (b['jadwal'].tanggal ?? '').compareTo(a['jadwal'].tanggal ?? ''));

    if (mounted) {
      setState(() {
        _jadwalMendatang = mendatang;
        _jadwalRiwayat = riwayat;
        _isLoading = false;
      });
    }
  }

  Color _warnaStatusJadwal(int status) {
    switch (status) {
      case 1: return AppColors.warning;
      case 2: return AppColors.danger;
      default: return const Color(0xFF4CAF50);
    }
  }

  String _labelStatusJadwal(int status) {
    switch (status) {
      case 1: return 'Ditunda';
      case 2: return 'Dibatalkan';
      default: return 'Sesuai Jadwal';
    }
  }

  IconData _ikonStatus(int status) {
    switch (status) {
      case 1: return Icons.pause_circle;
      case 2: return Icons.cancel;
      default: return Icons.check_circle;
    }
  }

  Widget _buildListJadwal(List<Map<String, dynamic>> listData, String emptyMessage) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadData,
      child: listData.isEmpty
          ? ListView(
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                const Icon(Icons.event_busy, size: 60, color: AppColors.border),
                const SizedBox(height: 16),
                Text(
                  emptyMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSubtitle),
                )
              ],
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: listData.length,
              itemBuilder: (context, index) {
                final item = listData[index];
                final jadwal = item['jadwal'];
                final kelas = item['kelas'];
                
                DateTime tgl;
                try { tgl = DateTime.parse(jadwal.tanggal); } catch (_) { tgl = DateTime.now(); }
                final tglStr = DateFormat('dd MMMM yyyy').format(tgl);
                final isHariIni = DateFormat('yyyy-MM-dd').format(tgl) == DateFormat('yyyy-MM-dd').format(DateTime.now());
                
                final status = jadwal.statusJadwal;
                final warna = _warnaStatusJadwal(status);

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isHariIni ? AppColors.primary : AppColors.borderLight, width: isHariIni ? 2 : 1),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Header Card
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isHariIni ? AppColors.primaryLight : AppColors.background,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                          border: const Border(bottom: BorderSide(color: AppColors.borderLight)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.class_, size: 16, color: isHariIni ? AppColors.primary : AppColors.textSubtitle),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                kelas['nama_kelas'] ?? '-',
                                style: TextStyle(fontWeight: FontWeight.bold, color: isHariIni ? AppColors.primaryDark : AppColors.textHeading, fontSize: 13),
                              ),
                            ),
                            if (isHariIni)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(6)),
                                child: const Text('HARI INI', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                          ],
                        ),
                      ),
                      
                      // Body Card
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Ikon & Garis Waktu
                            Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: warna.withOpacity(0.15),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(_ikonStatus(status), color: warna, size: 20),
                                ),
                              ],
                            ),
                            const SizedBox(width: 16),
                            // Info Detail
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          jadwal.namaPemateri ?? 'Tanpa Pemateri',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textHeading),
                                        ),
                                      ),
                                      Text(
                                        _labelStatusJadwal(status),
                                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: warna),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today, size: 12, color: AppColors.textSubtitle),
                                      const SizedBox(width: 4),
                                      Text(tglStr, style: const TextStyle(fontSize: 12, color: AppColors.textSubtitle)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.access_time, size: 12, color: AppColors.textSubtitle),
                                      const SizedBox(width: 4),
                                      Text('${jadwal.waktuMulai} - ${jadwal.waktuSelesai}', style: const TextStyle(fontSize: 12, color: AppColors.textSubtitle)),
                                    ],
                                  ),
                                  if ((jadwal.materiPembahasan ?? '').isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryLight,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Icon(Icons.menu_book, size: 14, color: AppColors.primary),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              jadwal.materiPembahasan!,
                                              style: const TextStyle(fontSize: 12, color: AppColors.primaryDark),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  if (status != 0 && (jadwal.alasanPerubahan ?? '').isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      'Alasan: ${jadwal.alasanPerubahan}',
                                      style: TextStyle(fontSize: 12, color: warna, fontStyle: FontStyle.italic),
                                    ),
                                  ]
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: AppColors.surface,
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textHint,
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(text: 'Mendatang'),
              Tab(text: 'Riwayat'),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildListJadwal(_jadwalMendatang, 'Tidak ada jadwal dalam waktu dekat.'),
                    _buildListJadwal(_jadwalRiwayat, 'Belum ada riwayat pertemuan.'),
                  ],
                ),
        ),
      ],
    );
  }
}
