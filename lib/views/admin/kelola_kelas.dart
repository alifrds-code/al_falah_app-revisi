import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../widgets/tombol_utama.dart';
import '../../widgets/form_isian.dart';
import '../../controllers/admin_controller.dart';
import '../../models/model_kelas.dart';

// layar buat admin ngatur-ngatur daftar kelas yang ada
class KelolaKelas extends StatefulWidget {
  const KelolaKelas({super.key});

  @override
  State<KelolaKelas> createState() => _KelolaKelasState();
}

class _KelolaKelasState extends State<KelolaKelas> {
  final AdminController _controller = AdminController();
  List<KelasModel> _classes = [];
  bool _isLoading = true;

  // controller buat kotak ngetik nama kelas
  final TextEditingController _nameCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // pas pertama masuk langsung tarik datanya
    _loadData();
  }

  // fungsi buat minta list kelas dari database
  void _loadData() async {
    final data = await _controller.getClasses();
    setState(() {
      _classes = data;
      _isLoading = false;
    });
  }

  // fungsi buat simpen data, bisa buat nambah baru atau edit yang lama
  void _handleSave({int? id}) async {
    // jangan sampe kosong namanya, nanti bingung
    if (_nameCtrl.text.isEmpty) return;

    if (id == null) {
      // kalo id-nya gak ada, berarti nambah baru
      await _controller.addClass(_nameCtrl.text);
    } else {
      // kalo ada ya berarti cuma mau ganti nama
      await _controller.updateClass(id, _nameCtrl.text);
    }

    _nameCtrl.clear();
    if (mounted) {
      Navigator.pop(context); // tutup form popup-nya
      _loadData(); // update lagi list yang tampil
    }
  }

  // buat mastiin admin beneran mau hapus kelasnya
  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Kelas?'),
        content: const Text('Ati-ati ya, kalo kelas dihapus, data jamaah sama jadwalnya juga ikut ilang semua.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              await _controller.deleteClass(id);
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
        title: const Text('Manajemen Kelas'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _classes.isEmpty
              ? const Center(child: Text('Belum ada kelas yang dibuat'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _classes.length,
                  itemBuilder: (context, index) {
                    final k = _classes[index];
                    return _buildKelasCard(k);
                  },
                ),
      // tombol plus buat nambah kelas baru
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // desain tiap kotak kelasnya
  Widget _buildKelasCard(KelasModel kelas) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [
          // ikon sekolah kecil di samping
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.school_rounded, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 14),
          // nama kelasnya di tengah
          Expanded(
            child: Text(
              kelas.namaKelas,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.text),
            ),
          ),
          // tombol buat edit (ganti nama)
          IconButton(
            onPressed: () {
              _nameCtrl.text = kelas.namaKelas;
              _showForm(context, id: kelas.idKelas);
            },
            icon: const Icon(Icons.edit_outlined, color: AppColors.muted),
          ),
          // tombol buat hapus
          IconButton(
            onPressed: () => _confirmDelete(kelas.idKelas!),
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.red),
          ),
        ],
      ),
    );
  }

  // popup buat input data kelas baru atau ganti nama
  void _showForm(BuildContext context, {int? id}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(id == null ? 'Tambah Kelas Baru' : 'Ubah Nama Kelas', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            FormIsian(label: 'Nama Kelas', hint: 'Contoh: MT Samawa', controller: _nameCtrl),
            const SizedBox(height: 32),
            TombolUtama(text: 'Simpan Kelas', onPressed: () => _handleSave(id: id)),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
