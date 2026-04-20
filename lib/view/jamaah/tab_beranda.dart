import 'package:flutter/material.dart';
import 'package:al_falah_app/controllers/jamaah_controller.dart';
import 'package:al_falah_app/services/local_storage_service.dart';
import 'package:al_falah_app/utils/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:al_falah_app/extensions/navigator.dart';
import 'package:al_falah_app/view/jamaah/layar_pilih_kelas.dart';

class TabBerandaJamaah extends StatefulWidget {
  const TabBerandaJamaah({super.key});

  @override
  State<TabBerandaJamaah> createState() => _TabBerandaJamaahState();
}

class _TabBerandaJamaahState extends State<TabBerandaJamaah> {
  final PreferenceHandler _pref = PreferenceHandler();
  List<String> _kelasDipilih = [];
  bool _isLoading = true;

  Map<String, dynamic>? _highlight;
  List<dynamic> _jadwalTerdekat = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _pref.init();
    final ids = await _pref.getKelasJamaah();
    
    if (ids.isEmpty) {
      if (mounted) setState(() { _isLoading = false; });
      return;
    }

    final highlight = await JamaahController.ambilHighlightHariIni(ids);
    final jadwalDkt = await JamaahController.ambilJadwalTerbaru(ids);

    if (mounted) {
      setState(() {
        _kelasDipilih = ids;
        _highlight = highlight;
        _jadwalTerdekat = jadwalDkt;
        _isLoading = false;
      });
    }
  }

  void _bukaPengaturanKelas() async {
    final result = await context.push(const LayarPilihKelas(isEditMode: true));
    if (result == true) {
      setState(() => _isLoading = true);
      _loadData();
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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER & PENGATURAN KELAS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Assalamu\'alaikum,',
                      style: TextStyle(color: AppColors.textSubtitle, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Jamaah Al-Falah',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.textHeading),
                    ),
                  ],
                ),
                InkWell(
                  onTap: _bukaPengaturanKelas,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.tune, color: AppColors.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),


            // JADWAL TERDEKAT
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'JADWAL TERDEKAT',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSubtitle, letterSpacing: 1.2),
                ),
                if (_kelasDipilih.isEmpty)
                  const SizedBox()
                else
                  Text(
                    '${_kelasDipilih.length} Kelas',
                    style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            if (_kelasDipilih.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.class_outlined, color: AppColors.textHint, size: 40),
                    const SizedBox(height: 12),
                    const Text(
                      'Anda belum memilih kelas yang diikuti.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSubtitle),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _bukaPengaturanKelas,
                      child: const Text('Pilih Kelas Sekarang'),
                    )
                  ],
                ),
              )
            else if (_jadwalTerdekat.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text('Belum ada jadwal dalam waktu dekat.', style: TextStyle(color: AppColors.textSubtitle)),
                ),
              )
            else
              ..._jadwalTerdekat.map((jadwalObj) {
                DateTime tgl;
                try { tgl = DateTime.parse(jadwalObj.tanggal); } catch (_) { tgl = DateTime.now(); }
                final isHariIni = DateFormat('yyyy-MM-dd').format(tgl) == DateFormat('yyyy-MM-dd').format(DateTime.now());
                
                final status = jadwalObj.statusJadwal;
                final warna = _warnaStatusJadwal(status);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderLight),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 4, height: 40,
                        decoration: BoxDecoration(color: warna, borderRadius: BorderRadius.circular(4)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isHariIni ? 'HARI INI' : DateFormat('dd MMM yyyy').format(tgl),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isHariIni ? AppColors.primary : AppColors.textSubtitle,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Pemateri: ${jadwalObj.namaPemateri ?? '-'}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textHeading),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${jadwalObj.waktuMulai} - ${jadwalObj.waktuSelesai}',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSubtitle),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: warna.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _labelStatusJadwal(status),
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: warna),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }
}
