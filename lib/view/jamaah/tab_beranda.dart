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
  List<dynamic> _jadwalTerdekat = [];

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
    
    if (ids.isEmpty) {
      if (mounted) setState(() { _isLoading = false; });
      return;
    }

    final semuaKelas = await JamaahController.ambilSemuaKelasUntukPilih();
    final jadwalDkt = await JamaahController.ambilJadwalTerbaru(ids);

    if (mounted) {
      setState(() {
        _kelasDipilih = ids;
        _semuaKelas = semuaKelas.where((k) => ids.contains(k['id'])).toList();
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

            // JADWAL TERDEKAT
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'JADWAL MENDATANG',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSubtitle, letterSpacing: 1.2),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Navigasi ke tab Jadwal
                    },
                    child: const Text('Lihat Semua', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            if (_kelasDipilih.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
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
                      const Text('Anda belum memilih kelas yang diikuti.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSubtitle)),
                      const SizedBox(height: 12),
                      TextButton(onPressed: _bukaPengaturanKelas, child: const Text('Pilih Kelas Sekarang')),
                    ],
                  ),
                ),
              )
            else if (_jadwalTerdekat.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.event_available, color: AppColors.border, size: 50),
                      SizedBox(height: 12),
                      Text('Tidak ada jadwal mendatang.', style: TextStyle(color: AppColors.textSubtitle)),
                    ],
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: _jadwalTerdekat.map((jadwalObj) {
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
                        border: Border.all(color: isHariIni ? AppColors.primary : AppColors.borderLight, width: isHariIni ? 2 : 1),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 4, height: 55,
                            decoration: BoxDecoration(color: warna, borderRadius: BorderRadius.circular(4)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      isHariIni ? '● HARI INI' : DateFormat('dd MMM yyyy', 'id').format(tgl),
                                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isHariIni ? AppColors.primary : AppColors.textSubtitle),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                                      decoration: BoxDecoration(color: warna.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                                      child: Text(_labelStatusJadwal(status), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: warna)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  jadwalObj.namaPemateri?.isNotEmpty == true ? jadwalObj.namaPemateri! : 'Ta\'lim',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textHeading),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    const Icon(Icons.access_time, size: 12, color: AppColors.textSubtitle),
                                    const SizedBox(width: 4),
                                    Text('${jadwalObj.waktuMulai} - ${jadwalObj.waktuSelesai}', style: const TextStyle(fontSize: 12, color: AppColors.textSubtitle)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
