import 'package:flutter/material.dart';
import 'package:al_falah_app/controllers/pengumuman_controller.dart';
import 'package:al_falah_app/utils/app_colors.dart';
import 'package:al_falah_app/view/admin/form_pengumuman.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class KelolaPengumuman extends StatefulWidget {
  const KelolaPengumuman({super.key});

  @override
  State<KelolaPengumuman> createState() => _KelolaPengumumanState();
}

class _KelolaPengumumanState extends State<KelolaPengumuman> {
  String _searchQuery = '';

  // Pop-up Konfirmasi Hapus
  void _konfirmasiHapus(BuildContext context, Map<String, dynamic> pengumuman) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Hapus Pengumuman?',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textHeading,
              fontSize: 18,
            ),
          ),
          content: Text(
            'Hapus pengumuman "${pengumuman['judul']}"?',
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
                  await PengumumanController.hapusPengumuman(pengumuman['id']);

                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pengumuman berhasil dihapus!'),
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
          'Kelola Pengumuman',
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
        backgroundColor: const Color(0xFFE91E63), // Pink for Pengumuman
        elevation: 4,
        child: const Icon(Icons.campaign, color: Colors.white),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FormPengumuman()),
          );
        },
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            color: AppColors.surface,
            child: TextField(
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              decoration: InputDecoration(
                hintText: 'Cari pengumuman...',
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
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: PengumumanController.ambilSemuaPengumumanStream(),
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
                      'Belum ada pengumuman hari ini.\nKlik tombol toa biru buat nambah!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSubtitle,
                      ),
                    ),
                  );
                }

                final daftarP = snapshot.data!.where((p) {
                  if (_searchQuery.isEmpty) return true;
                  return (p['judul'] ?? '').toLowerCase().contains(_searchQuery.toLowerCase()) || 
                         (p['isi'] ?? '').toLowerCase().contains(_searchQuery.toLowerCase());
                }).toList();

                if (daftarP.isEmpty) {
                  return const Center(child: Text("Pengumuman tidak ditemukan"));
                }

                return ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 20,
            ),
            itemCount: daftarP.length,
            itemBuilder: (context, index) {
              final item = daftarP[index];
              
              String dateStr = '';
              if (item['created_at'] != null && item['created_at'] is Timestamp) {
                DateTime dt = (item['created_at'] as Timestamp).toDate();
                dateStr = DateFormat('dd MMM yyyy, HH:mm').format(dt);
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Judul & Tgl
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFCE4EC), // Pink Light
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.campaign, color: Color(0xFFE91E63)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item['judul'] ?? 'Tanpa Judul',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: AppColors.textHeading,
                                  ),
                                ),
                                if (dateStr.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      dateStr,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSubtitle,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // Isi
                      Text(
                        item['isi'] ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textBody,
                          height: 1.5,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      const Divider(height: 1, color: AppColors.borderLight),
                      const SizedBox(height: 12),

                      // Tombol Aksi
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FormPengumuman(
                                    pengumumanLama: item,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.edit, size: 16, color: AppColors.info),
                            label: const Text('Edit', style: TextStyle(color: AppColors.info)),
                          ),
                          TextButton.icon(
                            onPressed: () => _konfirmasiHapus(context, item),
                            icon: const Icon(Icons.delete, size: 16, color: AppColors.danger),
                            label: const Text('Hapus', style: TextStyle(color: AppColors.danger)),
                          ),
                        ],
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
