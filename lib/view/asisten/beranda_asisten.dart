import 'package:flutter/material.dart';
import 'package:al_falah_app/controllers/kelas_controller.dart';
import 'package:al_falah_app/widgets/drawer_asisten.dart';
import 'package:al_falah_app/utils/app_colors.dart';

class BerandaAsisten extends StatefulWidget {
  final int idUser; // PENTING: Buat nyari kelas yang dia pegang
  final String namaUser;
  final String emailUser;

  const BerandaAsisten({
    super.key,
    required this.idUser,
    required this.namaUser,
    required this.emailUser,
  });

  @override
  State<BerandaAsisten> createState() => _BerandaAsistenState();
}

class _BerandaAsistenState extends State<BerandaAsisten> {
  // Panggil fungsi controller yang baru lu buat di Langkah 1
  Future<List<Map<String, dynamic>>> _loadKelasSaya() async {
    return await KelasController.getKelasByAsisten(widget.idUser);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Ahlan Wa Sahlan,",
              style: TextStyle(fontSize: 12, color: AppColors.textSubtitle),
            ),
            Text(
              widget.namaUser,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textHeading,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textHeading),
      ),
      drawer: DrawerAsisten(
        namaUser: widget.namaUser,
        emailUser: widget.emailUser,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BAGIAN 1: DAFTAR KELAS YANG DIPEGANG (ASLI DARI SQLITE)
            const Text(
              'KELAS YANG DIKELOLA',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textSubtitle,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),

            FutureBuilder<List<Map<String, dynamic>>>(
              future: _loadKelasSaya(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                final listKelas = snapshot.data ?? [];

                if (listKelas.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: const Text(
                      'Anda belum ditugaskan sebagai asisten di kelas manapun.\nSilakan hubungi Admin.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSubtitle),
                    ),
                  );
                }

                // Tampilin list kelas
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: listKelas.length,
                  itemBuilder: (context, index) {
                    final kelas = listKelas[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.class_, color: Colors.white),
                        ),
                        title: Text(
                          kelas['nama_kelas'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        subtitle: const Text(
                          'Ketuk untuk kelola absensi & jadwal',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        trailing: const Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.white,
                        ),
                        onTap: () {
                          // Nanti kalau di-klik masuk ke detail manajemen kelas buat asisten
                          print(
                            "Buka manajemen absensi kelas: ${kelas['nama_kelas']}",
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 32),

            // jadwal
            const Text(
              'JADWAL HARI INI',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textSubtitle,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.warningLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.schedule,
                          color: AppColors.warning,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Fiqih Muamalah',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textHeading,
                              ),
                            ),
                            Text(
                              'Ustadz Fulan (18:30 - 20:00)',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSubtitle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.info,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(
                        Icons.fact_check,
                        color: Colors.white,
                        size: 18,
                      ),
                      label: const Text(
                        'Mulai Absensi',
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        print("Mulai Absen");
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
