import 'package:flutter/material.dart';
import 'package:al_falah_app/controllers/admin_controller.dart';
import 'package:al_falah_app/models/model_jamaah.dart';
import 'package:al_falah_app/utils/app_colors.dart';
import 'package:al_falah_app/view/admin/form_jamaah.dart';

class KelolaJamaah extends StatefulWidget {
  const KelolaJamaah({super.key});

  @override
  State<KelolaJamaah> createState() => _KelolaJamaahState();
}

class _KelolaJamaahState extends State<KelolaJamaah> {
  // FUNGSI: Pop-up Detail Jamaah
  void _tampilDetailJamaah(BuildContext context, JamaahModel jamaah, Map<String, String> mapKelas) {
    bool isLaki = jamaah.jenisKelamin == 'Laki-laki';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              // Foto Profil Dinamis (Warna & Icon Beda Tergantung Gender)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isLaki ? Colors.blue[50] : Colors.pink[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isLaki ? Icons.face : Icons.face_3,
                  color: isLaki ? Colors.blue : Colors.pink,
                  size: 48,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                jamaah.namaLengkap,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textHeading,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warningLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Kelas: ${jamaah.idKelas != null ? (mapKelas[jamaah.idKelas] ?? jamaah.idKelas) : 'Belum ada kelas'}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.warning,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Kotak Detail Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  children: [
                    _buildInfoRow(
                      Icons.wc,
                      'Jenis Kelamin',
                      jamaah.jenisKelamin,
                    ),
                    const Divider(height: 24, color: AppColors.borderLight),
                    _buildInfoRow(
                      Icons.phone,
                      'Nomor WhatsApp',
                      jamaah.noHp ?? 'Tidak ada data',
                    ),
                    const Divider(height: 24, color: AppColors.borderLight),
                    _buildInfoRow(Icons.home, 'Alamat', jamaah.alamat),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Tutup',
                    style: TextStyle(
                      color: AppColors.textSubtitle,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper untuk baris info di Pop-up
  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textSubtitle, size: 20),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSubtitle,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textHeading,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // FUNGSI: Konfirmasi Hapus
  void _konfirmasiHapus(BuildContext context, String? idJamaah, String nama) {
    if (idJamaah == null) return;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Hapus Jamaah?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textHeading,
              fontSize: 18,
            ),
          ),
          content: Text(
            'Hapus $nama dari daftar?',
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
              Navigator.pop(context);
              try {
                await AdminController.hapusJamaah(idJamaah);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(

                    const SnackBar(
                      content: Text('Jamaah berhasil dihapus!'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
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
          'Data Jamaah (Real-time)',
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
        child: const Icon(Icons.person_add, color: Colors.white),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FormJamaah()),
          );
        },
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            color: AppColors.surface,
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari nama jamaah...',
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

          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: AdminController.ambilSemuaKelasStream(),
              builder: (context, snapshotKelas) {
                if (snapshotKelas.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }

                // Update Map Kelas secara LIVE dari Stream
                Map<String, String> mapKelasLive = {};
                if (snapshotKelas.hasData) {
                  for (var k in snapshotKelas.data!) {
                    mapKelasLive[k['id']] = k['nama_kelas'];
                  }
                }

                return StreamBuilder<List<Map<String, dynamic>>>(
                  stream: AdminController.ambilSemuaJamaahStream(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'Belum ada jamaah terdaftar.\nSilahkan daftar jamaah baru dengan tombol + di bawah.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSubtitle,
                      ),
                    ),
                  );
                }

                final daftarJamaah = snapshot.data!;

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  itemCount: daftarJamaah.length,
                  itemBuilder: (context, index) {
                    final jamaah = daftarJamaah[index];
                    bool isLaki = jamaah['jenis_kelamin'] == 'Laki-laki';

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
                        onTap: () {
                          // Manual mapping to avoid model integer errors with string IDs
                          final model = JamaahModel(
                            namaLengkap: jamaah['nama_lengkap'] ?? '',
                            jenisKelamin: jamaah['jenis_kelamin'] ?? 'Laki-laki',
                            alamat: jamaah['alamat'] ?? '',
                            noHp: jamaah['no_hp'],
                            statusJamaah: jamaah['status_jamaah'] is int 
                                ? jamaah['status_jamaah'] 
                                : int.tryParse(jamaah['status_jamaah']?.toString() ?? '1') ?? 1,
                            idKelas: jamaah['id_kelas']?.toString(), // Use the valid string id
                          );
                          _tampilDetailJamaah(context, model, mapKelasLive);
                        },
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isLaki ? Colors.blue[50] : Colors.pink[50],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isLaki ? Icons.person : Icons.person_3,
                            color: isLaki ? Colors.blue : Colors.pink,
                          ),
                        ),
                        title: Text(
                          jamaah['nama_lengkap'] ?? 'Tanpa Nama',
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
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.warningLight,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    mapKelasLive[jamaah['id_kelas']] ?? 'Belum ada kelas',
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.warning,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
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
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          FormJamaah(jamaahLama: jamaah),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
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
                                  jamaah['id'],
                                  jamaah['nama_lengkap'] ?? '',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
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
