import 'package:flutter/material.dart';
import 'package:al_falah_app/controllers/kelas_controller.dart';
import 'package:al_falah_app/view/admin/detail_kelas.dart';

import 'package:al_falah_app/utils/app_colors.dart';
import 'package:al_falah_app/view/admin/form_kelas.dart';

class KelolaKelas extends StatefulWidget {
  const KelolaKelas({super.key});

  @override
  State<KelolaKelas> createState() => _KelolaKelasState();
}

class _KelolaKelasState extends State<KelolaKelas> {
  // Fungsi untuk narik data dari controller
  Future<List<Map<String, dynamic>>> _loadDataKelas() async {
    return await KelasController.getDaftarKelasLengkap();
  }

  // FUNGSI 2: Pop-up Konfirmasi Hapus Kelas
  void _konfirmasiHapus(BuildContext context, Map<String, dynamic> kelas) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Hapus Kelas?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textHeading,
              fontSize: 18,
            ),
          ),
          content: Text(
            'Apakah Anda yakin ingin menghapus kelas ${kelas['nama_kelas']}? Data yang dihapus tidak dapat dikembalikan.',
            style: const TextStyle(color: AppColors.textBody, fontSize: 14),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Batal',
                style: TextStyle(
                  color: AppColors.textSubtitle,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                Navigator.pop(context); // Tutup dialognya dulu
                try {
                  // Panggil fungsi hapus dari controller
                  await KelasController.hapusKelas(kelas['id_kelas']);

                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Kelas berhasil dihapus!'),
                      backgroundColor: AppColors.primary,
                    ),
                  );

                  // Refresh layar biar kartunya hilang
                  setState(() {});
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal menghapus: $e'),
                      backgroundColor: AppColors.danger,
                    ),
                  );
                }
              },
              child: const Text(
                'Ya, Hapus',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Kelola Kelas',
          style: TextStyle(
            color: AppColors.textHeading,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textHeading),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.borderLight, height: 1),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          // Buka form nambah kelas baru
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FormKelas()),
          );
          setState(() {}); // Refresh setelah balik
        },
      ),
      body: Column(
        children: [
          // SEARCH BAR
          Container(
            padding: const EdgeInsets.all(20),
            color: AppColors.surface,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari nama kelas...',
                hintStyle: const TextStyle(
                  color: AppColors.textHint,
                  fontSize: 14,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.textHint,
                  size: 20,
                ),
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // LIST DATA KELAS
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _loadDataKelas(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Waduh error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'Belum ada data kelas nih, Bro.\nKlik tombol + buat nambah!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSubtitle,
                      ),
                    ),
                  );
                }

                final daftarKelas = snapshot.data!;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  itemCount: daftarKelas.length,
                  itemBuilder: (context, index) {
                    final kelas = daftarKelas[index];
                    String namaAsisten =
                        kelas['nama_asisten'] ?? "Belum ada asisten";

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderLight),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        // ==========================================
                        // KARTU DIKLIK MUNCUL HALAMAN FULL DETAIL KELAS
                        // ==========================================
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailKelas(kelas: kelas),
                            ),
                          );
                          setState(() {});
                        },
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: AppColors.warningLight,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.class_,
                            color: AppColors.warning,
                          ),
                        ),
                        title: Text(
                          kelas['nama_kelas'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.textHeading,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  // Warnanya beda kalau asisten belum diassign
                                  color: kelas['nama_asisten'] != null
                                      ? AppColors.primaryLight
                                      : AppColors.dangerLight,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  namaAsisten,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: kelas['nama_asisten'] != null
                                        ? AppColors.primaryDark
                                        : AppColors.danger,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // TOMBOL EDIT
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.infoLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.edit_outlined,
                                  color: AppColors.info,
                                  size: 20,
                                ),
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.all(8),
                                onPressed: () async {
                                  // Buka form edit
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          FormKelas(kelasLama: kelas),
                                    ),
                                  );
                                  setState(() {});
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            // ==========================================
                            // TOMBOL HAPUS (Panggil konfirmasiHapus)
                            // ==========================================
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.dangerLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: AppColors.danger,
                                  size: 20,
                                ),
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.all(8),
                                onPressed: () => _konfirmasiHapus(
                                  context,
                                  kelas,
                                ), // Panggil pop-up ke sini
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
