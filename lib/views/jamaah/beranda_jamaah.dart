import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../controllers/jamaah_controller.dart';
import '../../models/model_jadwal.dart';
import 'jadwal_jamaah.dart';
import 'info_yayasan.dart';
import 'bacaan_wirid.dart';
import '../auth/layar_login.dart';

// ini halaman utama buat jamaah, bisa dibuka siapa aja tanpa login
class BerandaJamaah extends StatefulWidget {
  const BerandaJamaah({super.key});

  @override
  State<BerandaJamaah> createState() => _BerandaJamaahState();
}

class _BerandaJamaahState extends State<BerandaJamaah> {
  final JamaahController _controller = JamaahController();
  int _currentIndex = 0; // buat nandain lagi di tab mana (beranda/jadwal/info)
  List<JadwalModel> _highlights = []; // buat nampung jadwal hari ini
  List<JadwalModel> _upcoming = []; // buat nampung 3 jadwal paling deket
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // pas buka aplikasi langsung gue tarik data jadwal terbaru
    _loadData();
  }

  // fungsi buat ambil data dari database lewat controller
  void _loadData() async {
    final highlights = await _controller.getTodayHighlights();
    final semua = await _controller.getMySchedules();

    // gue saring jadwal yang tanggalnya hari ini ke depan, maksimal 3 aja
    final today = DateTime.now().toIso8601String().split('T')[0];
    final upcomingList = semua
        .where((j) => j.tanggal.compareTo(today) >= 0)
        .take(3)
        .toList();

    setState(() {
      _highlights = highlights;
      _upcoming = upcomingList;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final hariList = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Ahad',
    ];
    final bulanList = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    
    // ngitung hari apa sekarang biar tampilannya keren
    final hariIndex = now.weekday == 7 ? 6 : now.weekday - 1;
    final tanggalStr =
        '${hariList[hariIndex]}, ${now.day} ${bulanList[now.month - 1]} ${now.year}';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // bagian kepala warna hijau, isinya nama aplikasi sama tanggal
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              color: AppColors.primary,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Ta'lim Al Falah",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        tanggalStr,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  // gembok buat login pengurus, tinggal tap aja buat masuk
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LayarLogin(),
                        ),
                      );
                    },
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock_outline,
                        color: Colors.white70,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // isi kontennya ada di dalem expanded biar bisa di-scroll
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        // kalo ada jadwal hari ini, gue kasih kotak spesial
                        if (_highlights.isNotEmpty) ...[
                          const Text(
                            'Jadwal Hari Ini',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _buildHighlightCard(_highlights.first),
                          const SizedBox(height: 20),
                        ],

                        // daftar jadwal yang bakalan dateng
                        const Text(
                          'Jadwal Terdekat',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.text,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (_upcoming.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: Text(
                                'Belum ada jadwal nih',
                                style: TextStyle(color: AppColors.muted),
                              ),
                            ),
                          )
                        else
                          ..._upcoming.map(
                            (j) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _buildSchedCard(j),
                            ),
                          ),

                        const SizedBox(height: 20),

                        // menu buat buka wirid atau quran
                        const Text(
                          'Akses Cepat',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.text,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _buildQuickBtn(
                                Icons.menu_book_rounded,
                                'Dzikir Wirid',
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const BacaanWirid(),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildQuickBtn(
                                Icons.import_contacts_rounded,
                                'Al-Quran',
                                () {
                                  // nanti ini ngarahin ke web quran kemenag
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Buka browser: quran.kemenag.go.id',
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
            ),

            // navigasi tab di bagian bawah
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: AppColors.border, width: 0.5),
                ),
              ),
              child: Row(
                children: [
                  _buildNavItem(0, Icons.home_rounded, 'Beranda'),
                  _buildNavItem(1, Icons.calendar_month_rounded, 'Jadwal'),
                  _buildNavItem(2, Icons.info_outline_rounded, 'Info'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // widget buat kotak jadwal hari ini yang warnanya ijo muda
  Widget _buildHighlightCard(JadwalModel jadwal) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'HARI INI ADA KAJIAN LHO!',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            jadwal.materiPembahasan ?? 'Kajian Rutin',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${jadwal.waktuMulai} – ${jadwal.waktuSelesai}  •  ${jadwal.namaPemateri}',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.primary,
              height: 1.5,
            ),
          ),
          if (jadwal.namaKelas != null) ...[
            const SizedBox(height: 4),
            Text(
              jadwal.namaKelas!,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.primaryDark,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // widget buat kotak list jadwal biasa
  Widget _buildSchedCard(JadwalModel jadwal) {
    final parts = jadwal.tanggal.split('-');
    final hari = parts.length >= 3 ? parts[2] : jadwal.tanggal;
    final bulanList = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final bulanIndex = parts.length >= 2 ? int.tryParse(parts[1]) ?? 0 : 0;
    final bulan = bulanIndex > 0 && bulanIndex < 13
        ? bulanList[bulanIndex]
        : '';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          // kotak penanda tanggal di samping kiri
          Container(
            width: 44,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  hari,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    height: 1,
                  ),
                ),
                Text(
                  bulan,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // isi detail kajiannya
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  jadwal.materiPembahasan ?? 'Kajian Rutin',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${jadwal.waktuMulai}  •  ${jadwal.namaPemateri}',
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
                if (jadwal.namaKelas != null)
                  Text(
                    jadwal.namaKelas!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // widget buat tombol menu wirid/quran
  Widget _buildQuickBtn(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // widget buat item menu di bawah (navigation bar)
  Widget _buildNavItem(int index, IconData icon, String label) {
    final isActive = _currentIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() => _currentIndex = index);
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const JadwalJamaah()),
            ).then((_) => setState(() => _currentIndex = 0));
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const InfoYayasan()),
            ).then((_) => setState(() => _currentIndex = 0));
          }
        },
        child: SizedBox(
          height: 68,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isActive ? AppColors.primary : AppColors.muted,
                size: 24,
              ),
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
