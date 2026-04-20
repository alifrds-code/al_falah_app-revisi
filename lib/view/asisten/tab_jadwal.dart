import 'package:flutter/material.dart';
import 'package:al_falah_app/controllers/admin_controller.dart';
import 'package:al_falah_app/services/firebase_service.dart';
import 'package:al_falah_app/utils/app_colors.dart';
import 'package:intl/intl.dart';

class TabJadwal extends StatefulWidget {
  final String uid;

  const TabJadwal({super.key, required this.uid});

  @override
  State<TabJadwal> createState() => _TabJadwalState();
}

class _TabJadwalState extends State<TabJadwal> {
  List<Map<String, dynamic>> _kelasSaya = [];
  bool _isLoading = true;

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

  // ==================== FORM TAMBAH/EDIT JADWAL ====================
  void _tampilFormJadwal(String idKelas, String namaKelas, {Map<String, dynamic>? jadwalLama}) {
    final materiCtrl = TextEditingController(text: jadwalLama?['materi_pembahasan'] ?? '');
    final pemateriCtrl = TextEditingController(text: jadwalLama?['nama_pemateri'] ?? '');
    final waktuMulaiCtrl = TextEditingController(text: jadwalLama?['waktu_mulai'] ?? '');
    final waktuSelesaiCtrl = TextEditingController(text: jadwalLama?['waktu_selesai'] ?? '');
    DateTime? selectedDate;
    if (jadwalLama != null) {
      try { selectedDate = DateTime.parse(jadwalLama['tanggal']); } catch (_) {}
    }

    final isEdit = jadwalLama != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> pilihWaktu(TextEditingController ctrl) async {
              final picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (picked != null) {
                final formatted = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
                setModalState(() => ctrl.text = formatted);
              }
            }

            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 40, height: 4,
                          margin: const EdgeInsets.only(bottom: 20),
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      Text(
                        isEdit ? 'Edit Jadwal — $namaKelas' : 'Buat Jadwal — $namaKelas',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textHeading),
                      ),
                      const SizedBox(height: 20),

                      // Tanggal
                      InkWell(
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate ?? DateTime.now(),
                            firstDate: DateTime(2024),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setModalState(() => selectedDate = picked);
                          }
                        },
                        child: _buildReadOnlyField(
                          icon: Icons.calendar_today,
                          text: selectedDate != null
                              ? DateFormat('dd MMMM yyyy').format(selectedDate!)
                              : 'Pilih Tanggal...',
                          hasValue: selectedDate != null,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Waktu Mulai & Selesai
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => pilihWaktu(waktuMulaiCtrl),
                              child: _buildReadOnlyField(
                                icon: Icons.access_time,
                                text: waktuMulaiCtrl.text.isNotEmpty ? waktuMulaiCtrl.text : 'Waktu Mulai',
                                hasValue: waktuMulaiCtrl.text.isNotEmpty,
                              ),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text('—', style: TextStyle(color: AppColors.textHint, fontSize: 18)),
                          ),
                          Expanded(
                            child: InkWell(
                              onTap: () => pilihWaktu(waktuSelesaiCtrl),
                              child: _buildReadOnlyField(
                                icon: Icons.access_time,
                                text: waktuSelesaiCtrl.text.isNotEmpty ? waktuSelesaiCtrl.text : 'Waktu Selesai',
                                hasValue: waktuSelesaiCtrl.text.isNotEmpty,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Nama Pemateri
                      _buildTextField(pemateriCtrl, 'Nama Pemateri / Ustadz', Icons.person),
                      const SizedBox(height: 12),

                      // Materi Pembahasan
                      _buildTextField(materiCtrl, 'Materi Pembahasan (Opsional)', Icons.subject),
                      const SizedBox(height: 24),

                      SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () async {
                            if (selectedDate == null || waktuMulaiCtrl.text.isEmpty || waktuSelesaiCtrl.text.isEmpty || pemateriCtrl.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Tanggal, Waktu, & Pemateri wajib diisi!')),
                              );
                              return;
                            }
                            Navigator.pop(context);

                            if (isEdit) {
                              await FirebaseService.updateJadwal(
                                jadwalLama['id'],
                                idKelas: idKelas,
                                idUser: widget.uid,
                                tanggal: selectedDate!,
                                waktuMulai: waktuMulaiCtrl.text,
                                waktuSelesai: waktuSelesaiCtrl.text,
                                materiPembahasan: materiCtrl.text.trim(),
                                namaPemateri: pemateriCtrl.text.trim(),
                                statusJadwal: jadwalLama['status_jadwal'] ?? 0,
                                alasanPerubahan: jadwalLama['alasan_perubahan'],
                              );
                            } else {
                              await FirebaseService.tambahJadwal(
                                idKelas: idKelas,
                                idUser: widget.uid,
                                tanggal: selectedDate!,
                                waktuMulai: waktuMulaiCtrl.text,
                                waktuSelesai: waktuSelesaiCtrl.text,
                                materiPembahasan: materiCtrl.text.trim(),
                                namaPemateri: pemateriCtrl.text.trim(),
                              );
                            }

                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(isEdit ? 'Jadwal berhasil diperbarui!' : 'Jadwal berhasil ditambahkan!'),
                                backgroundColor: AppColors.primary,
                              ),
                            );
                          },
                          child: Text(
                            isEdit ? 'SIMPAN PERUBAHAN' : 'SIMPAN JADWAL',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildReadOnlyField({required IconData icon, required String text, required bool hasValue}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textHint),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: hasValue ? AppColors.textHeading : AppColors.textHint,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint, IconData icon) {
    return TextField(
      controller: ctrl,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
        prefixIcon: Icon(icon, color: AppColors.textHint, size: 20),
        filled: true, fillColor: AppColors.background,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }

  // ==================== UBAH STATUS JADWAL ====================
  void _tampilUbahStatus(Map<String, dynamic> jadwal) {
    int currentStatus = jadwal['status_jadwal'] ?? 0;
    final alasanCtrl = TextEditingController(text: jadwal['alasan_perubahan'] ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Ubah Status Jadwal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildStatusRadio(0, 'Sesuai Jadwal', const Color(0xFF4CAF50), currentStatus, (val) {
                    setDialogState(() => currentStatus = val!);
                  }),
                  _buildStatusRadio(1, 'Ditunda', AppColors.warning, currentStatus, (val) {
                    setDialogState(() => currentStatus = val!);
                  }),
                  _buildStatusRadio(2, 'Dibatalkan', AppColors.danger, currentStatus, (val) {
                    setDialogState(() => currentStatus = val!);
                  }),
                  if (currentStatus != 0) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: alasanCtrl,
                      maxLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Alasan perubahan...',
                        hintStyle: const TextStyle(fontSize: 13),
                        filled: true, fillColor: AppColors.background,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal', style: TextStyle(color: AppColors.textSubtitle)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  onPressed: () async {
                    Navigator.pop(context);
                    await FirebaseService.updateStatusJadwal(
                      jadwal['id'],
                      statusJadwal: currentStatus,
                      alasanPerubahan: alasanCtrl.text.trim(),
                    );
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Status jadwal diperbarui!'), backgroundColor: AppColors.primary),
                    );
                  },
                  child: const Text('Simpan', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStatusRadio(int value, String label, Color color, int groupValue, ValueChanged<int?> onChanged) {
    return RadioListTile<int>(
      value: value,
      groupValue: groupValue,
      onChanged: onChanged,
      dense: true,
      activeColor: color,
      title: Text(label, style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.bold)),
    );
  }

  // ==================== HAPUS JADWAL ====================
  void _konfirmasiHapusJadwal(String idJadwal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Jadwal?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Jadwal yang dihapus tidak dapat dikembalikan.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseService.hapusJadwal(idJadwal);
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Jadwal dihapus!'), backgroundColor: AppColors.primary),
              );
            },
            child: const Text('Ya, Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ==================== HELPER WARNA STATUS ====================
  Color _warnaStatus(int status) {
    switch (status) {
      case 1: return AppColors.warning;
      case 2: return AppColors.danger;
      default: return const Color(0xFF4CAF50);
    }
  }

  IconData _ikonStatus(int status) {
    switch (status) {
      case 1: return Icons.pause_circle;
      case 2: return Icons.cancel;
      default: return Icons.check_circle;
    }
  }

  String _labelStatus(int status) {
    switch (status) {
      case 1: return 'Ditunda';
      case 2: return 'Dibatalkan';
      default: return 'Sesuai Jadwal';
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
            // Header Kelas + Tambah
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.warningLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.class_, color: AppColors.warning, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      namaKelas,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textHeading),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: AppColors.primary),
                  tooltip: 'Tambah Jadwal',
                  onPressed: () => _tampilFormJadwal(idKelas, namaKelas),
                ),
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
                      'Belum ada jadwal untuk kelas ini.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSubtitle, fontSize: 13),
                    ),
                  );
                }

                // Sort by date
                jadwalList.sort((a, b) => (a['tanggal'] ?? '').compareTo(b['tanggal'] ?? ''));

                return Column(
                  children: jadwalList.map((jadwal) {
                    DateTime tgl;
                    try { tgl = DateTime.parse(jadwal['tanggal']); }
                    catch (_) { tgl = DateTime.now(); }

                    final tglStr = DateFormat('dd MMM yyyy').format(tgl);
                    final isHariIni = DateFormat('yyyy-MM-dd').format(tgl) == DateFormat('yyyy-MM-dd').format(DateTime.now());
                    final int status = jadwal['status_jadwal'] ?? 0;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _warnaStatus(status), width: isHariIni ? 2 : 1),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: _warnaStatus(status).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(_ikonStatus(status), color: _warnaStatus(status), size: 20),
                            ),
                            title: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    jadwal['nama_pemateri'] ?? '-',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textHeading),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _warnaStatus(status).withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    _labelStatus(status),
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _warnaStatus(status)),
                                  ),
                                ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 12, color: AppColors.textSubtitle),
                                    const SizedBox(width: 4),
                                    Text(
                                      isHariIni ? '📌 Hari Ini — $tglStr' : tglStr,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isHariIni ? AppColors.primary : AppColors.textSubtitle,
                                        fontWeight: isHariIni ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.access_time, size: 12, color: AppColors.textSubtitle),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${jadwal['waktu_mulai'] ?? '-'} — ${jadwal['waktu_selesai'] ?? '-'}',
                                      style: const TextStyle(fontSize: 11, color: AppColors.textSubtitle),
                                    ),
                                  ],
                                ),
                                if ((jadwal['materi_pembahasan'] ?? '').isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      '📖 ${jadwal['materi_pembahasan']}',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 11, color: AppColors.textBody),
                                    ),
                                  ),
                                if (status != 0 && (jadwal['alasan_perubahan'] ?? '').isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      '💬 ${jadwal['alasan_perubahan']}',
                                      style: TextStyle(fontSize: 11, color: _warnaStatus(status), fontStyle: FontStyle.italic),
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          // Action buttons
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: const BoxDecoration(
                              border: Border(top: BorderSide(color: AppColors.borderLight)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // Ubah Status
                                TextButton.icon(
                                  onPressed: () => _tampilUbahStatus(jadwal),
                                  icon: const Icon(Icons.swap_horiz, size: 16),
                                  label: const Text('Status', style: TextStyle(fontSize: 12)),
                                  style: TextButton.styleFrom(foregroundColor: AppColors.info),
                                ),
                                // Edit
                                TextButton.icon(
                                  onPressed: () => _tampilFormJadwal(idKelas, namaKelas, jadwalLama: jadwal),
                                  icon: const Icon(Icons.edit, size: 16),
                                  label: const Text('Edit', style: TextStyle(fontSize: 12)),
                                  style: TextButton.styleFrom(foregroundColor: AppColors.warning),
                                ),
                                // Hapus
                                TextButton.icon(
                                  onPressed: () => _konfirmasiHapusJadwal(jadwal['id']),
                                  icon: const Icon(Icons.delete, size: 16),
                                  label: const Text('Hapus', style: TextStyle(fontSize: 12)),
                                  style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                                ),
                              ],
                            ),
                          ),
                        ],
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
