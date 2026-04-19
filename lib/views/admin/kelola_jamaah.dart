import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../widgets/tombol_utama.dart';
import '../../widgets/form_isian.dart';
import '../../widgets/tampilan_kosong.dart';
import '../../controllers/admin_controller.dart';
import '../../models/model_jamaah.dart';
import '../../models/model_kelas.dart';

// Layar kelola biodata jamaah oleh Admin
class KelolaJamaah extends StatefulWidget {
  const KelolaJamaah({super.key});

  @override
  State<KelolaJamaah> createState() => _KelolaJamaahState();
}

class _KelolaJamaahState extends State<KelolaJamaah> {
  final AdminController _controller = AdminController();

  // Daftar jamaah yang ditampilkan
  List<JamaahModel> _jamaah = [];
  // Daftar jamaah asli (untuk filter pencarian)
  List<JamaahModel> _jamaahAsli = [];
  // Daftar kelas untuk dropdown
  List<KelasModel> _kelas = [];
  bool _isLoading = true;

  // Controller form tambah jamaah
  final TextEditingController _namaCtrl = TextEditingController();
  final TextEditingController _telpCtrl = TextEditingController();
  final TextEditingController _alamatCtrl = TextEditingController();
  final TextEditingController _cariCtrl = TextEditingController();

  // Pilihan dropdown
  KelasModel? _selectedKelas;
  String _selectedGender = 'Laki-laki';

  @override
  void initState() {
    super.initState();
    _loadData();
    // Dengarkan perubahan teks pencarian
    _cariCtrl.addListener(_filterJamaah);
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _telpCtrl.dispose();
    _alamatCtrl.dispose();
    _cariCtrl.dispose();
    super.dispose();
  }

  // Ambil data dari database
  void _loadData() async {
    final dataJamaah = await _controller.getJamaah();
    final dataKelas = await _controller.getClasses();
    setState(() {
      _jamaah = dataJamaah;
      _jamaahAsli = dataJamaah;
      _kelas = dataKelas;
      if (dataKelas.isNotEmpty) _selectedKelas = dataKelas.first;
      _isLoading = false;
    });
  }

  // Filter jamaah berdasarkan teks pencarian
  void _filterJamaah() {
    final kata = _cariCtrl.text.toLowerCase();
    setState(() {
      if (kata.isEmpty) {
        _jamaah = _jamaahAsli;
      } else {
        _jamaah = _jamaahAsli.where((j) {
          return j.namaLengkap.toLowerCase().contains(kata) ||
              (j.namaKelas ?? '').toLowerCase().contains(kata);
        }).toList();
      }
    });
  }

  // Simpan jamaah baru ke database
  void _handleAdd() async {
    if (_namaCtrl.text.isEmpty || _alamatCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama dan alamat wajib diisi')),
      );
      return;
    }

    final jamaahBaru = JamaahModel(
      namaLengkap: _namaCtrl.text.trim(),
      jenisKelamin: _selectedGender,
      noHp: _telpCtrl.text.trim().isEmpty ? null : _telpCtrl.text.trim(),
      alamat: _alamatCtrl.text.trim(),
      idKelas: _selectedKelas?.idKelas,
    );

    await _controller.addJamaah(jamaahBaru);
    _namaCtrl.clear();
    _telpCtrl.clear();
    _alamatCtrl.clear();
    _selectedGender = 'Laki-laki';

    if (mounted) {
      Navigator.pop(context);
      _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jamaah berhasil ditambahkan')),
      );
    }
  }

  // Konfirmasi hapus jamaah
  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Jamaah?'),
        content: const Text('Data jamaah ini akan dihapus permanen dari sistem.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              await _controller.deleteJamaah(id);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Kelola Jamaah'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Kotak pencarian
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              controller: _cariCtrl,
              decoration: InputDecoration(
                hintText: 'Cari nama atau kelas...',
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                filled: true,
                fillColor: AppColors.background,
                contentPadding: const EdgeInsets.all(0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Daftar jamaah
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _jamaah.isEmpty
                    ? const TampilanKosong(
                        pesan: 'Belum ada jamaah yang terdaftar',
                        icon: Icons.people_outline_rounded,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _jamaah.length,
                        itemBuilder: (context, index) {
                          return _buildJamaahCard(_jamaah[index]);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddForm(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
      ),
    );
  }

  // Kartu satu jamaah
  Widget _buildJamaahCard(JamaahModel jamaah) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          // Foto profil dengan inisial nama
          CircleAvatar(
            backgroundColor: AppColors.primaryLight,
            radius: 24,
            child: Text(
              jamaah.namaLengkap.isNotEmpty ? jamaah.namaLengkap[0].toUpperCase() : '?',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  jamaah.namaLengkap,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  jamaah.namaKelas ?? 'Tanpa Kelas',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  jamaah.noHp ?? '-',
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
          // Tombol hapus
          IconButton(
            onPressed: () => _confirmDelete(jamaah.idJamaah!),
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.red),
          ),
        ],
      ),
    );
  }

  // Form tambah jamaah baru (muncul dari bawah layar)
  void _showAddForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tambah Jamaah Baru',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // Input nama lengkap
                FormIsian(
                  label: 'Nama Lengkap',
                  hint: 'Ketik nama jamaah',
                  controller: _namaCtrl,
                ),
                const SizedBox(height: 16),

                // Pilih jenis kelamin
                const Text(
                  'Jenis Kelamin',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: DropdownButton<String>(
                    value: _selectedGender,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: ['Laki-laki', 'Perempuan']
                        .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                        .toList(),
                    onChanged: (val) {
                      setModalState(() => _selectedGender = val!);
                      _selectedGender = val!;
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Pilih kelas
                const Text(
                  'Pilih Kelas',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: DropdownButton<KelasModel>(
                    value: _selectedKelas,
                    isExpanded: true,
                    underline: const SizedBox(),
                    hint: const Text('Pilih Kelas'),
                    items: _kelas
                        .map((k) => DropdownMenuItem(
                              value: k,
                              child: Text(k.namaKelas),
                            ))
                        .toList(),
                    onChanged: (val) {
                      setModalState(() => _selectedKelas = val);
                      _selectedKelas = val;
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Input nomor telepon
                FormIsian(
                  label: 'Nomor Telepon (Opsional)',
                  hint: '0812...',
                  controller: _telpCtrl,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),

                // Input alamat
                FormIsian(
                  label: 'Alamat',
                  hint: 'Ketik alamat lengkap',
                  controller: _alamatCtrl,
                  maxLines: 2,
                ),
                const SizedBox(height: 32),

                TombolUtama(text: 'Simpan Data Jamaah', onPressed: _handleAdd),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
