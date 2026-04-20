import 'package:flutter/material.dart';
import 'package:al_falah_app/controllers/admin_controller.dart';
import 'package:al_falah_app/services/firebase_service.dart';
import 'package:al_falah_app/utils/app_colors.dart';
import 'package:intl/intl.dart';

class TabAbsensi extends StatefulWidget {
  final String uid;

  const TabAbsensi({super.key, required this.uid});

  @override
  State<TabAbsensi> createState() => _TabAbsensiState();
}

class _TabAbsensiState extends State<TabAbsensi> {
  List<Map<String, dynamic>> _kelasSaya = [];
  bool _isLoading = true;

  // Toleransi setelah waktu selesai (menit)
  static const int _toleransiMenit = 30;

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

  // ==================== HITUNG STATUS WAKTU ====================
  /// Return: 'belum_mulai' | 'berlangsung' | 'toleransi' | 'selesai'
  String _hitungStatusWaktu(Map<String, dynamic> jadwal) {
    final now = DateTime.now();

    // Parse tanggal
    DateTime tglJadwal;
    try {
      tglJadwal = DateTime.parse(jadwal['tanggal']);
    } catch (_) {
      return 'belum_mulai';
    }

    // Parse waktu mulai
    final waktuMulaiStr = jadwal['waktu_mulai'] ?? '';
    final waktuSelesaiStr = jadwal['waktu_selesai'] ?? '';
    if (waktuMulaiStr.isEmpty || waktuSelesaiStr.isEmpty) return 'belum_mulai';

    final partsMulai = waktuMulaiStr.split(':');
    final partsSelesai = waktuSelesaiStr.split(':');
    if (partsMulai.length < 2 || partsSelesai.length < 2) return 'belum_mulai';

    final mulai = DateTime(
      tglJadwal.year, tglJadwal.month, tglJadwal.day,
      int.parse(partsMulai[0]), int.parse(partsMulai[1]),
    );
    final selesai = DateTime(
      tglJadwal.year, tglJadwal.month, tglJadwal.day,
      int.parse(partsSelesai[0]), int.parse(partsSelesai[1]),
    );
    final batasToleransi = selesai.add(const Duration(minutes: _toleransiMenit));

    if (now.isBefore(mulai)) return 'belum_mulai';
    if (!now.isBefore(mulai) && now.isBefore(selesai)) return 'berlangsung';
    if (!now.isBefore(selesai) && now.isBefore(batasToleransi)) return 'toleransi';
    return 'selesai';
  }

  String _labelWaktu(String statusWaktu) {
    switch (statusWaktu) {
      case 'berlangsung': return '🟢 Sedang Berlangsung';
      case 'toleransi': return '🟡 Toleransi ($_toleransiMenit mnt)';
      case 'selesai': return '🔴 Sudah Selesai';
      default: return '⏳ Belum Mulai';
    }
  }

  Color _warnaWaktu(String statusWaktu) {
    switch (statusWaktu) {
      case 'berlangsung': return const Color(0xFF4CAF50);
      case 'toleransi': return AppColors.warning;
      case 'selesai': return AppColors.danger;
      default: return AppColors.textSubtitle;
    }
  }

  // ==================== BUKA HALAMAN ABSENSI ====================
  void _bukaHalamanAbsensi(Map<String, dynamic> jadwal, String namaKelas) async {
    final idKelas = jadwal['id_kelas'];
    final idJadwal = jadwal['id'];
    final statusWaktu = _hitungStatusWaktu(jadwal);

    // Kalau belum mulai → tolak
    if (statusWaktu == 'belum_mulai') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⛔ Jadwal belum mulai! Absensi dibuka saat waktu mulai.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    // Kalau sudah selesai (lewat toleransi) → konfirmasi dulu
    if (statusWaktu == 'selesai') {
      final lanjut = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Jadwal Sudah Lewat', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: const Text(
            'Jadwal ini sudah melewati batas toleransi.\n\nApakah Anda yakin mau buka absensi? (Misal: lupa absen)',
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal', style: TextStyle(color: AppColors.textSubtitle)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Ya, Buka', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
      if (lanjut != true) return;
    }

    // Ambil jamaah & absensi existing
    final jamaahList = await AdminController.ambilJamaahByKelas(idKelas);
    final absensiExisting = await FirebaseService.ambilAbsensiByJadwal(idJadwal);

    // Map id_jamaah -> status
    final Map<String, String> mapAbsensi = {};
    for (var a in absensiExisting) {
      mapAbsensi[a['id_jamaah']] = a['status_absen'];
    }

    if (!mounted) return;

    String searchQuery = '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            // Filter jamaah berdasarkan search
            final filteredJamaah = jamaahList.where((j) {
              if (searchQuery.isEmpty) return true;
              return (j['nama_lengkap'] ?? '').toLowerCase().contains(searchQuery.toLowerCase());
            }).toList();

            // Count
            int sudahAbsen = 0;
            for (var j in jamaahList) {
              final s = mapAbsensi[j['id']];
              if (s != null && s != 'belum') sudahAbsen++;
            }

            return Container(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.92),
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40, height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(10)),
                    ),
                  ),

                  // Header
                  Text(
                    'Absensi — $namaKelas',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textHeading),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${jadwal['nama_pemateri'] ?? '-'}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSubtitle),
                      ),
                      const SizedBox(width: 8),
                      Text('•', style: TextStyle(color: AppColors.textHint)),
                      const SizedBox(width: 8),
                      Text(
                        '${jadwal['waktu_mulai'] ?? '-'} — ${jadwal['waktu_selesai'] ?? '-'}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSubtitle),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Progress bar
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: jamaahList.isEmpty ? 0 : sudahAbsen / jamaahList.length,
                            backgroundColor: AppColors.borderLight,
                            color: AppColors.primary,
                            minHeight: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '$sudahAbsen / ${jamaahList.length}',
                        style: const TextStyle(fontSize: 12, color: AppColors.info, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Search
                  TextField(
                    onChanged: (val) => setModalState(() => searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'Cari nama jamaah...',
                      hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 13),
                      prefixIcon: const Icon(Icons.search, color: AppColors.textHint, size: 18),
                      filled: true, fillColor: AppColors.background,
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Daftar Jamaah
                  if (jamaahList.isEmpty)
                    const Expanded(
                      child: Center(
                        child: Text('Belum ada jamaah di kelas ini.', style: TextStyle(color: AppColors.textSubtitle)),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: filteredJamaah.length,
                        itemBuilder: (context, index) {
                          final jamaah = filteredJamaah[index];
                          final idJamaah = jamaah['id'];
                          final nama = jamaah['nama_lengkap'] ?? '-';
                          final isLaki = jamaah['jenis_kelamin'] == 'Laki-laki';
                          final status = mapAbsensi[idJamaah] ?? 'belum';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: _bgAbsensi(status),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: status == 'belum' ? AppColors.borderLight : _statusColor(status),
                                width: status == 'belum' ? 1 : 1.5,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Nama & Status
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(7),
                                      decoration: BoxDecoration(
                                        color: isLaki ? Colors.blue[50] : Colors.pink[50],
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        isLaki ? Icons.person : Icons.person_3,
                                        color: isLaki ? Colors.blue : Colors.pink,
                                        size: 16,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(nama, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textHeading)),
                                          Text(
                                            _statusLabel(status),
                                            style: TextStyle(fontSize: 11, color: _statusColor(status), fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),

                                // Tombol Status: Hadir | Tidak Hadir | Izin | Telat
                                Row(
                                  children: [
                                    _buildStatusBtn('Hadir', Icons.check_circle, const Color(0xFF4CAF50), status == 'Hadir', () async {
                                      await FirebaseService.simpanAbsensi(idJadwal: idJadwal, idJamaah: idJamaah, statusAbsen: 'Hadir');
                                      setModalState(() => mapAbsensi[idJamaah] = 'Hadir');
                                    }),
                                    const SizedBox(width: 5),
                                    _buildStatusBtn('Tidak\nHadir', Icons.cancel, AppColors.danger, status == 'Tidak Hadir', () async {
                                      await FirebaseService.simpanAbsensi(idJadwal: idJadwal, idJamaah: idJamaah, statusAbsen: 'Tidak Hadir');
                                      setModalState(() => mapAbsensi[idJamaah] = 'Tidak Hadir');
                                    }),
                                    const SizedBox(width: 5),
                                    _buildStatusBtn('Izin', Icons.info_outline, const Color(0xFFFFC107), status == 'Izin', () async {
                                      await FirebaseService.simpanAbsensi(idJadwal: idJadwal, idJamaah: idJamaah, statusAbsen: 'Izin');
                                      setModalState(() => mapAbsensi[idJamaah] = 'Izin');
                                    }),
                                    const SizedBox(width: 5),
                                    _buildStatusBtn('Telat', Icons.timer, const Color(0xFFFF9800), status == 'Telat', () async {
                                      await FirebaseService.simpanAbsensi(idJadwal: idJadwal, idJamaah: idJamaah, statusAbsen: 'Telat');
                                      setModalState(() => mapAbsensi[idJamaah] = 'Telat');
                                    }),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                  const SizedBox(height: 12),

                  // TOMBOL SELESAI: Auto-mark belum diabsen sebagai "Tidak Hadir"
                  SizedBox(
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.check_circle, color: Colors.white, size: 20),
                      label: const Text(
                        'SELESAI & SIMPAN',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                      onPressed: () async {
                        // Hitung yang belum diabsen
                        int belumAbsen = 0;
                        for (var j in jamaahList) {
                          final s = mapAbsensi[j['id']];
                          if (s == null || s == 'belum') belumAbsen++;
                        }

                        if (belumAbsen > 0) {
                          // Konfirmasi auto-mark
                          final konfirmasi = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              title: const Text('Ada Jamaah Belum Diabsen', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              content: Text(
                                '$belumAbsen jamaah belum diabsen.\n\nJamaah yang belum dicentang akan otomatis ditandai sebagai "Tidak Hadir".\n\nLanjutkan?',
                                style: const TextStyle(fontSize: 14),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Kembali', style: TextStyle(color: AppColors.textSubtitle)),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('Ya, Simpan', style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          );
                          if (konfirmasi != true) return;

                          // Auto-mark yang belum → "Tidak Hadir"
                          for (var j in jamaahList) {
                            final s = mapAbsensi[j['id']];
                            if (s == null || s == 'belum') {
                              await FirebaseService.simpanAbsensi(
                                idJadwal: idJadwal,
                                idJamaah: j['id'],
                                statusAbsen: 'Tidak Hadir',
                              );
                            }
                          }
                        }

                        if (!context.mounted) return;
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✅ Absensi berhasil disimpan!'),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ==================== UI HELPERS ====================
  Widget _buildStatusBtn(String label, IconData icon, Color color, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            color: isActive ? color.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isActive ? color : AppColors.borderLight, width: isActive ? 2 : 1),
          ),
          child: Column(
            children: [
              Icon(icon, color: isActive ? color : AppColors.textHint, size: 18),
              const SizedBox(height: 2),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 9, color: isActive ? color : AppColors.textHint, fontWeight: FontWeight.bold, height: 1.2),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _bgAbsensi(String status) {
    switch (status) {
      case 'Hadir': return const Color(0xFFF1F8E9);
      case 'Tidak Hadir': return const Color(0xFFFDE8E8);
      case 'Izin': return const Color(0xFFFFF8E1);
      case 'Telat': return const Color(0xFFFFF3E0);
      default: return AppColors.background;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'Hadir': return '✅ Hadir';
      case 'Tidak Hadir': return '❌ Tidak Hadir';
      case 'Izin': return '⚠️ Izin';
      case 'Telat': return '⏰ Telat';
      default: return '⏳ Belum diabsen';
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Hadir': return const Color(0xFF4CAF50);
      case 'Izin': return const Color(0xFFFFC107);
      case 'Telat': return const Color(0xFFFF9800);
      case 'Tidak Hadir': return AppColors.danger;
      default: return AppColors.textSubtitle;
    }
  }


  // ==================== BUILD ====================
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_kelasSaya.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'Anda belum ditugaskan ke kelas manapun.\nSilakan hubungi Admin.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSubtitle, fontSize: 14),
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _kelasSaya.length,
      itemBuilder: (context, index) {
        final kelas = _kelasSaya[index];
        final idKelas = kelas['id'];
        final namaKelas = kelas['nama_kelas'] ?? 'Tanpa Nama';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Kelas
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.warningLight, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.class_, color: AppColors.warning, size: 20),
                ),
                const SizedBox(width: 12),
                Text(namaKelas, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textHeading)),
              ],
            ),
            const SizedBox(height: 12),

            // Stream jadwal
            StreamBuilder<List<Map<String, dynamic>>>(
              stream: FirebaseService.ambilJadwalByKelasStream(idKelas),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
                  );
                }
                final jadwalList = snapshot.data ?? [];

                // Sort terbaru dulu
                jadwalList.sort((a, b) => (b['tanggal'] ?? '').compareTo(a['tanggal'] ?? ''));

                if (jadwalList.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: const Text(
                      'Belum ada jadwal. Buat jadwal dulu di tab Jadwal.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSubtitle, fontSize: 13),
                    ),
                  );
                }

                return Column(
                  children: jadwalList.map((jadwal) {
                    DateTime tgl;
                    try { tgl = DateTime.parse(jadwal['tanggal']); }
                    catch (_) { tgl = DateTime.now(); }
                    final tglStr = DateFormat('dd MMM yyyy').format(tgl);
                    final int statusJadwal = jadwal['status_jadwal'] ?? 0;

                    // Compute time-based status
                    final statusWaktu = _hitungStatusWaktu(jadwal);
                    final warnaWaktu = _warnaWaktu(statusWaktu);

                    // Jadwal dibatalkan → tidak bisa absen
                    final bool jadwalDibatalkan = statusJadwal == 2;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: jadwalDibatalkan ? AppColors.danger : warnaWaktu,
                          width: statusWaktu == 'berlangsung' ? 2 : 1,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top row: Pemateri + Status waktu badge
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: warnaWaktu.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(Icons.fact_check, color: warnaWaktu, size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        jadwal['nama_pemateri'] ?? '-',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textHeading),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '$tglStr  •  ${jadwal['waktu_mulai'] ?? '-'} — ${jadwal['waktu_selesai'] ?? '-'}',
                                        style: const TextStyle(fontSize: 11, color: AppColors.textSubtitle),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            // Status badges row
                            Row(
                              children: [
                                // Status waktu
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: warnaWaktu.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    jadwalDibatalkan ? '🚫 Dibatalkan' : _labelWaktu(statusWaktu),
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: jadwalDibatalkan ? AppColors.danger : warnaWaktu),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if ((jadwal['materi_pembahasan'] ?? '').isNotEmpty)
                                  Expanded(
                                    child: Text(
                                      '📖 ${jadwal['materi_pembahasan']}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 11, color: AppColors.textSubtitle),
                                    ),
                                  ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Tombol Absen
                            if (jadwalDibatalkan)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.dangerLight,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  'Jadwal dibatalkan — tidak bisa melakukan absensi',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 12, color: AppColors.danger, fontWeight: FontWeight.bold),
                                ),
                              )
                            else
                              SizedBox(
                                width: double.infinity,
                                height: 40,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: statusWaktu == 'belum_mulai'
                                        ? AppColors.textHint
                                        : statusWaktu == 'berlangsung'
                                            ? const Color(0xFF4CAF50)
                                            : statusWaktu == 'toleransi'
                                                ? AppColors.warning
                                                : AppColors.textSubtitle,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  icon: Icon(
                                    statusWaktu == 'belum_mulai' ? Icons.lock : Icons.edit_note,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    statusWaktu == 'belum_mulai'
                                        ? 'Belum Bisa Absen'
                                        : statusWaktu == 'berlangsung'
                                            ? 'Buka Absensi'
                                            : statusWaktu == 'toleransi'
                                                ? 'Buka Absensi (Toleransi)'
                                                : 'Buka Absensi (Lewat)',
                                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                  onPressed: () => _bukaHalamanAbsensi(jadwal, namaKelas),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),

            if (index < _kelasSaya.length - 1)
              const Divider(height: 32, color: AppColors.borderLight),
          ],
        );
      },
    );
  }
}
