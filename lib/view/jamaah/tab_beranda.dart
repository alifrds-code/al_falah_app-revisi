import 'dart:async';
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
  List<Map<String, dynamic>> _semuaKelas = [];
  bool _isLoading = true;
  List<Map<String, dynamic>> _pengumumanTerbaru = [];
  List<Map<String, dynamic>> _acaraTerbaru = [];

  // Realtime clock
  late Timer _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
    _loadData();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    await _pref.init();
    final ids = await _pref.getKelasJamaah();
    
    final semuaKelas = await JamaahController.ambilSemuaKelasUntukPilih();
    final pengumuman = await JamaahController.ambilPengumuman();
    final acara = await JamaahController.ambilAcara();

    if (mounted) {
      setState(() {
        _kelasDipilih = ids;
        _semuaKelas = semuaKelas.where((k) => ids.contains(k['id'])).toList();
        _pengumumanTerbaru = pengumuman.take(2).toList();
        _acaraTerbaru = acara.take(2).toList();
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



  String get _jamRealtime {
    return '${_now.hour.toString().padLeft(2, '0')}:'
        '${_now.minute.toString().padLeft(2, '0')}';
  }

  String get _tanggalHariIni {
    const hari = ['Senin','Selasa','Rabu','Kamis','Jumat','Sabtu','Ahad'];
    const bulan = ['Januari','Februari','Maret','April','Mei','Juni','Juli','Agustus','September','Oktober','November','Desember'];
    final h = hari[_now.weekday - 1];
    final b = bulan[_now.month - 1];
    return '$h, ${_now.day} $b ${_now.year}';
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER SECTION - berisi waktu realtime & sapa
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, Color(0xFF1B5E20)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Assalamu'alaikum,",
                              style: TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Jamaah Al-Falah',
                              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      // Tombol atur kelas
                      InkWell(
                        onTap: _bukaPengaturanKelas,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.tune, color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // JAM REALTIME
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time, color: Colors.white, size: 28),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _jamRealtime,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                            Text(
                              _tanggalHariIni,
                              style: const TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // KELAS YANG DIIKUTI
            if (_semuaKelas.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Text(
                  'KELAS YANG DIIKUTI',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSubtitle, letterSpacing: 1.2),
                ),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: _semuaKelas.map((kelas) {
                    return Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.class_, color: AppColors.primary, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            kelas['nama_kelas'] ?? '-',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark, fontSize: 13),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // INFO & KEGIATAN TERBARU
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'INFO & KEGIATAN TERBARU',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSubtitle, letterSpacing: 1.2),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            if (_pengumumanTerbaru.isEmpty && _acaraTerbaru.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.campaign_outlined, color: AppColors.border, size: 50),
                      SizedBox(height: 12),
                      Text('Belum ada info atau kegiatan terbaru.', style: TextStyle(color: AppColors.textSubtitle)),
                    ],
                  ),
                ),
              )
            else ...[
              // List Pengumuman
              if (_pengumumanTerbaru.isNotEmpty)
                ..._pengumumanTerbaru.map((item) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12, left: 20, right: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderLight),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.campaign, color: AppColors.primary, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['judul'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textHeading)),
                              const SizedBox(height: 4),
                              Text(item['isi'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: AppColors.textBody)),
                              const SizedBox(height: 6),
                              Text(item['tanggal_dibuat'] ?? '-', style: const TextStyle(fontSize: 10, color: AppColors.textSubtitle)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                
              // List Kegiatan/Acara
              if (_acaraTerbaru.isNotEmpty)
                ..._acaraTerbaru.map((item) {
                  DateTime pDate;
                  try { pDate = DateTime.parse(item['tanggal'] ?? ''); } catch (_) { pDate = DateTime.now(); }
                  final dateStr = DateFormat('dd MMM yyyy').format(pDate);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12, left: 20, right: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderLight),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: AppColors.warningLight, borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.event_available, color: AppColors.warning, size: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['nama_acara'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textHeading)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 10, color: AppColors.textSubtitle),
                                  const SizedBox(width: 4),
                                  Text(dateStr, style: const TextStyle(fontSize: 10, color: AppColors.textSubtitle)),
                                  const SizedBox(width: 12),
                                  const Icon(Icons.access_time, size: 10, color: AppColors.textSubtitle),
                                  const SizedBox(width: 4),
                                  Text(item['jam'] ?? '-', style: const TextStyle(fontSize: 10, color: AppColors.textSubtitle)),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 10, color: AppColors.danger),
                                  const SizedBox(width: 4),
                                  Expanded(child: Text(item['lokasi'] ?? '-', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, color: AppColors.textSubtitle))),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
