import 'package:flutter/material.dart';
import 'package:al_falah_app/controllers/jamaah_controller.dart';
import 'package:al_falah_app/services/local_storage_service.dart';
import 'package:al_falah_app/utils/app_colors.dart';
import 'package:al_falah_app/extensions/navigator.dart';
import 'package:al_falah_app/view/jamaah/beranda_jamaah.dart';
import 'package:al_falah_app/view/auth/layar_login.dart';

class LayarPilihKelas extends StatefulWidget {
  final bool isEditMode;

  const LayarPilihKelas({super.key, this.isEditMode = false});

  @override
  State<LayarPilihKelas> createState() => _LayarPilihKelasState();
}

class _LayarPilihKelasState extends State<LayarPilihKelas> {
  final PreferenceHandler _pref = PreferenceHandler();
  List<Map<String, dynamic>> _semuaKelas = [];
  List<String> _kelasDipilih = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await _pref.init();
    final allKelas = await JamaahController.ambilSemuaKelasUntukPilih();
    final savedKelas = await _pref.getKelasJamaah();

    if (mounted) {
      setState(() {
        _semuaKelas = allKelas;
        _kelasDipilih = widget.isEditMode ? savedKelas : [];
        _isLoading = false;
      });
    }
  }

  void _simpanPilihan() async {
    if (_kelasDipilih.isEmpty && !widget.isEditMode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih minimal satu kelas untuk melanjutkan!'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    await _pref.saveKelasJamaah(_kelasDipilih);

    if (!mounted) return;

    if (widget.isEditMode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilihan kelas berhasil diperbarui!'),
          backgroundColor: AppColors.primary,
        ),
      );
      Navigator.pop(context, true); // Return true to trigger refresh
    } else {
      context.pushReplacement(const BerandaJamaah());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: widget.isEditMode
          ? AppBar(
              title: const Text(
                'Pengaturan Kelas',
                style: TextStyle(color: AppColors.textHeading, fontWeight: FontWeight.bold, fontSize: 18),
              ),
              backgroundColor: AppColors.surface,
              elevation: 0,
              iconTheme: const IconThemeData(color: AppColors.textHeading),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(color: AppColors.borderLight),
              ),
            )
          : null, // Kalau mode onboarding (awal), gak usah ada tulisan judul di header standar.
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : Column(
                children: [
                  // HEADER ONBOARDING (hanya kalau initial mode)
                  if (!widget.isEditMode)
                    Container(
                      padding: const EdgeInsets.all(24),
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(32),
                          bottomRight: Radius.circular(32),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Icon(Icons.mosque, color: Colors.white, size: 40),
                              // TOMBOL RAHASIA LOGIN ADMIN
                              IconButton(
                                icon: const Icon(Icons.admin_panel_settings, color: Colors.white54),
                                tooltip: 'Masuk Admin / Asisten',
                                onPressed: () {
                                  context.push(const LayarLogin());
                                },
                              )
                            ],
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Ahlan wa Sahlan',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Pilih Kelas Anda',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Pilih kelas-kelas yang sering Anda hadiri agar kami bisa menampilkan jadwal secara otomatis di Beranda Anda.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (widget.isEditMode)
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'Pilih kelas-kelas yang sering Anda hadiri agar kami bisa menampilkan jadwal secara otomatis di Beranda Anda.',
                        style: TextStyle(color: AppColors.textSubtitle, fontSize: 14),
                      ),
                    ),

                  // LIST KELAS
                  Expanded(
                    child: _semuaKelas.isEmpty
                        ? const Center(
                            child: Text(
                              'Belum ada data kelas dari Yayasan.',
                              style: TextStyle(color: AppColors.textSubtitle),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            itemCount: _semuaKelas.length,
                            itemBuilder: (context, index) {
                              final kelas = _semuaKelas[index];
                              final idKelas = kelas['id'];
                              final isSelected = _kelasDipilih.contains(idKelas);

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.primaryLight : AppColors.surface,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected ? AppColors.primary : AppColors.borderLight,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: CheckboxListTile(
                                  value: isSelected,
                                  activeColor: AppColors.primary,
                                  checkColor: Colors.white,
                                  title: Text(
                                    kelas['nama_kelas'] ?? '-',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? AppColors.primaryDark : AppColors.textHeading,
                                      fontSize: 15,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${kelas['deskripsi']?.isNotEmpty == true ? kelas['deskripsi'] : 'Kelas Terbuka'}',
                                    style: const TextStyle(fontSize: 12, color: AppColors.textSubtitle),
                                  ),
                                  controlAffinity: ListTileControlAffinity.leading,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  onChanged: (bool? value) {
                                    setState(() {
                                      if (value == true) {
                                        _kelasDipilih.add(idKelas);
                                      } else {
                                        _kelasDipilih.remove(idKelas);
                                      }
                                    });
                                  },
                                ),
                              );
                            },
                          ),
                  ),

                  // TOMBOL SIMPAN
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      border: const Border(top: BorderSide(color: AppColors.borderLight)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _kelasDipilih.isEmpty && !widget.isEditMode
                              ? AppColors.textHint
                              : AppColors.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _simpanPilihan,
                        child: Text(
                          widget.isEditMode ? 'SIMPAN PERUBAHAN' : 'LANJUT KE BERANDA',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
