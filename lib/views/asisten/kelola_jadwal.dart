import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../widgets/label_status.dart';
import '../../widgets/tombol_utama.dart';
import '../../widgets/form_isian.dart';
import '../../widgets/tampilan_kosong.dart';
import '../../controllers/asisten_controller.dart';
import '../../controllers/login_controller.dart';
import '../../models/model_jadwal.dart';

// Layar kelola jadwal pertemuan oleh Asisten
class KelolaJadwal extends StatefulWidget {
  final int idKelas;
  const KelolaJadwal({super.key, required this.idKelas});

  @override
  State<KelolaJadwal> createState() => _KelolaJadwalState();
}

class _KelolaJadwalState extends State<KelolaJadwal> {
  final AsistenController _controller = AsistenController();
  final LoginController _loginController = LoginController();
  List<JadwalModel> _jadwal = [];
  bool _isLoading = true;

  // Controller untuk form tambah/edit jadwal
  final TextEditingController _materiCtrl = TextEditingController();
  final TextEditingController _pemateriCtrl = TextEditingController();
  final TextEditingController _tanggalCtrl = TextEditingController();
  final TextEditingController _mulaiCtrl = TextEditingController();
  final TextEditingController _selesaiCtrl = TextEditingController();
  final TextEditingController _alasanCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _materiCtrl.dispose();
    _pemateriCtrl.dispose();
    _tanggalCtrl.dispose();
    _mulaiCtrl.dispose();
    _selesaiCtrl.dispose();
    _alasanCtrl.dispose();
    super.dispose();
  }

  void _loadData() async {
    final user = await _loginController.getCurrentUser();
    if (user != null) {
      final data = await _controller.getMySchedules(user.idUser!);
      setState(() {
        // Tampilkan hanya jadwal milik kelas ini
        _jadwal = data.where((j) => j.idKelas == widget.idKelas).toList();
        _isLoading = false;
      });
    }
  }

  // Bersihkan semua input form
  void _clearForm() {
    _materiCtrl.clear();
    _pemateriCtrl.clear();
    _tanggalCtrl.clear();
    _mulaiCtrl.clear();
    _selesaiCtrl.clear();
    _alasanCtrl.clear();
  }

  // Simpan jadwal baru
  void _handleSave() async {
    if (_tanggalCtrl.text.isEmpty || _pemateriCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tanggal dan nama pemateri wajib diisi')),
      );
      return;
    }

    final user = await _loginController.getCurrentUser();
    if (user == null) return;

    final jadwalBaru = JadwalModel(
      idKelas: widget.idKelas,
      idUser: user.idUser!,
      materiPembahasan: _materiCtrl.text.trim(),
      namaPemateri: _pemateriCtrl.text.trim(),
      tanggal: _tanggalCtrl.text.trim(),
      waktuMulai: _mulaiCtrl.text.trim(),
      waktuSelesai: _selesaiCtrl.text.trim(),
      statusJadwal: 'Sesuai Jadwal', // Default status baru
    );

    await _controller.createSchedule(jadwalBaru);
    _clearForm();

    if (mounted) {
      Navigator.pop(context);
      _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jadwal berhasil ditambahkan!')),
      );
    }
  }

  // Hapus jadwal setelah konfirmasi
  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Jadwal?'),
        content: const Text('Jadwal ini beserta data absensinya akan terhapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              await _controller.deleteSchedule(id);
              if (mounted) {
                Navigator.pop(context);
                _loadData();
              }
            },
            child: const Text('Hapus', style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
  }

  // Ubah status jadwal (Ditunda atau Dibatalkan)
  void _showChangeStatus(JadwalModel jadwal) {
    _alasanCtrl.clear();
    String statusBaru = 'Ditunda';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Ubah Status Jadwal'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pilih status baru
              RadioListTile<String>(
                title: const Text('Ditunda'),
                value: 'Ditunda',
                groupValue: statusBaru,
                onChanged: (val) => setDialogState(() => statusBaru = val!),
                activeColor: AppColors.yellow,
              ),
              RadioListTile<String>(
                title: const Text('Dibatalkan'),
                value: 'Dibatalkan',
                groupValue: statusBaru,
                onChanged: (val) => setDialogState(() => statusBaru = val!),
                activeColor: AppColors.red,
              ),
              const SizedBox(height: 8),
              // Input alasan
              TextField(
                controller: _alasanCtrl,
                decoration: const InputDecoration(
                  hintText: 'Ketik alasan penundaan/pembatalan...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                await _controller.updateScheduleStatus(
                  jadwal.idJadwal!,
                  statusBaru,
                  _alasanCtrl.text.trim().isEmpty ? null : _alasanCtrl.text.trim(),
                );
                if (mounted) {
                  Navigator.pop(context);
                  _loadData();
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Kelola Jadwal'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _jadwal.isEmpty
              ? const TampilanKosong(
                  pesan: 'Belum ada jadwal.\nTekan + untuk membuat jadwal baru.',
                  icon: Icons.event_note_rounded,
                )
              : RefreshIndicator(
                  onRefresh: () async => _loadData(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _jadwal.length,
                    itemBuilder: (context, index) {
                      final j = _jadwal[index];
                      return _buildJadwalCard(j);
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormJadwal(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Kartu satu jadwal
  Widget _buildJadwalCard(JadwalModel jadwal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tanggal
                    Text(
                      jadwal.tanggal,
                      style: const TextStyle(fontSize: 13, color: AppColors.muted),
                    ),
                    const SizedBox(height: 4),
                    // Pemateri
                    Text(
                      jadwal.namaPemateri,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.text,
                      ),
                    ),
                    // Materi
                    Text(
                      jadwal.materiPembahasan ?? 'Kajian Rutin',
                      style: const TextStyle(fontSize: 13, color: AppColors.muted),
                    ),
                    // Jam
                    Text(
                      '${jadwal.waktuMulai} - ${jadwal.waktuSelesai}',
                      style: const TextStyle(fontSize: 12, color: AppColors.muted),
                    ),
                  ],
                ),
              ),
              LabelStatus(status: jadwal.statusJadwal),
            ],
          ),

          // Tampilkan alasan kalau ada
          if (jadwal.alasanPerubahan != null && jadwal.alasanPerubahan!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.yellowLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Alasan: ${jadwal.alasanPerubahan}',
                style: const TextStyle(fontSize: 12, color: AppColors.yellow),
              ),
            ),
          ],

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 8),

          // Tombol aksi
          Row(
            children: [
              // Ubah status
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showChangeStatus(jadwal),
                  icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                  label: const Text('Ubah Status'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.yellow,
                    side: const BorderSide(color: AppColors.yellow),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Hapus
              OutlinedButton.icon(
                onPressed: () => _confirmDelete(jadwal.idJadwal!),
                icon: const Icon(Icons.delete_outline_rounded, size: 16),
                label: const Text('Hapus'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.red,
                  side: const BorderSide(color: AppColors.red),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Form tambah jadwal baru (muncul dari bawah)
  void _showFormJadwal(BuildContext context) {
    _clearForm();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tambah Jadwal Baru',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              FormIsian(
                label: 'Materi Pembahasan',
                hint: 'Contoh: Tafsir Surah Al-Fatihah',
                controller: _materiCtrl,
              ),
              const SizedBox(height: 16),
              FormIsian(
                label: 'Nama Pemateri',
                hint: 'Contoh: Ust. Ahmad',
                controller: _pemateriCtrl,
              ),
              const SizedBox(height: 16),
              FormIsian(
                label: 'Tanggal',
                hint: 'Contoh: 2026-04-20',
                controller: _tanggalCtrl,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FormIsian(
                      label: 'Jam Mulai',
                      hint: '08:00',
                      controller: _mulaiCtrl,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FormIsian(
                      label: 'Jam Selesai',
                      hint: '10:00',
                      controller: _selesaiCtrl,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              TombolUtama(text: 'Simpan Jadwal', onPressed: _handleSave),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
