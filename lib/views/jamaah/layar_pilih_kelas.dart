import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../services/local_storage_service.dart';
import '../../controllers/jamaah_controller.dart';
import '../../widgets/tombol_utama.dart';
import 'beranda_jamaah.dart';

// layar yang muncul pas pertama kali buka app, buat suruh jamaah milih kelas
class LayarPilihKelas extends StatefulWidget {
  const LayarPilihKelas({super.key});

  @override
  State<LayarPilihKelas> createState() => _LayarPilihKelasState();
}

class _LayarPilihKelasState extends State<LayarPilihKelas> {
  final JamaahController _controller = JamaahController();
  // daftar kelas yang gue ambil dari database
  List<Map<String, dynamic>> _daftarKelas = [];
  // nyimpen id kelas mana aja yang dicentang sama jamaah
  final Set<int> _selectedIds = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // langsung tarik daftar kelasnya pas layar kebuka
    _loadKelas();
  }

  // fungsi buat minta list semua kelas ke database
  void _loadKelas() async {
    final data = await _controller.getAllKelas();
    setState(() {
      _daftarKelas = data;
      _isLoading = false;
    });
  }

  // fungsi pas jamaah udah selese milih terus pencet lanjut
  void _handleLanjut() async {
    // simpen pilihan kelasnya ke memori hp
    await LocalStorageService.saveSelectedClasses(_selectedIds.toList());
    // tandain kalo user udah pernah buka app biar gak muncul layar ini lagi
    await LocalStorageService.setNotFirstTime();

    if (mounted) {
      // langsung pindah ke halaman utama jamaah
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const BerandaJamaah()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            // bagian atas (header) ada sapaan sama instruksi
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // logo bulet kecil di pojok
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        'AF',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Pilih Kelas Anda',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Centang kelas yang Anda ikuti ya.\nNanti jadwalnya bakal otomatis nyesuain.',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white70,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            // bagian list kelasnya pake background putih biar bersih
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _daftarKelas.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32),
                              child: Text(
                                'Belum ada kelas nih.\nCoba kontak pengurus yayasan deh.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppColors.muted, fontSize: 15),
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: _daftarKelas.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final kelas = _daftarKelas[index];
                              final id = kelas['id_kelas'] as int;
                              final isSelected = _selectedIds.contains(id);

                              return InkWell(
                                borderRadius: BorderRadius.circular(14),
                                onTap: () {
                                  setState(() {
                                    // kalo di-tap ganti status centangnya
                                    if (isSelected) {
                                      _selectedIds.remove(id);
                                    } else {
                                      _selectedIds.add(id);
                                    }
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primaryLight
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.border,
                                      width: isSelected ? 1.5 : 0.5,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      // ikon sekolah di samping nama kelas
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppColors.primary
                                              : AppColors.background,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                          Icons.school_rounded,
                                          color: isSelected
                                              ? Colors.white
                                              : AppColors.muted,
                                          size: 22,
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      // nama kelasnya
                                      Expanded(
                                        child: Text(
                                          kelas['nama_kelas'] as String,
                                          style: TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w600,
                                            color: isSelected
                                                ? AppColors.primary
                                                : AppColors.text,
                                          ),
                                        ),
                                      ),
                                      // kotak centang di ujung kanan
                                      Container(
                                        width: 26,
                                        height: 26,
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppColors.primary
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(
                                            color: isSelected
                                                ? AppColors.primary
                                                : AppColors.border,
                                            width: 2,
                                          ),
                                        ),
                                        child: isSelected
                                            ? const Icon(
                                                Icons.check,
                                                color: Colors.white,
                                                size: 16,
                                              )
                                            : null,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ),

            // tombol buat lanjut ke beranda di bagian paling bawah
            Container(
              color: AppColors.background,
              padding: const EdgeInsets.all(16),
              child: TombolUtama(
                text: _selectedIds.isEmpty
                    ? 'Lewati aja (Lihat Semua)'
                    : 'Ayo Mulai!',
                onPressed: _handleLanjut,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
