import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../widgets/tombol_utama.dart';
import '../../widgets/form_isian.dart';
import '../../controllers/admin_controller.dart';
import '../../models/model_user.dart';

class KelolaAsisten extends StatefulWidget {
  const KelolaAsisten({super.key});

  @override
  State<KelolaAsisten> createState() => _KelolaAsistenState();
}

class _KelolaAsistenState extends State<KelolaAsisten> {
  final AdminController _controller = AdminController();
  List<UserModel> _asistens = [];
  bool _isLoading = true;

  final TextEditingController _namaCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final data = await _controller.getAsistens();
    setState(() {
      _asistens = data;
      _isLoading = false;
    });
  }

  void _handleAdd() async {
    if (_namaCtrl.text.isEmpty || _emailCtrl.text.isEmpty || _passCtrl.text.isEmpty) return;

    final newUser = UserModel(
      nama: _namaCtrl.text,
      email: _emailCtrl.text,
      password: _passCtrl.text,
      role: 'asisten',
    );

    await _controller.addAsisten(newUser);
    _namaCtrl.clear();
    _emailCtrl.clear();
    _passCtrl.clear();

    if (mounted) {
      Navigator.pop(context);
      _loadData();
    }
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Akun?'),
        content: const Text('Tindakan ini tidak dapat dibatalkan. Menghapus asisten juga akan menghapus data terkait mereka.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              await _controller.deleteAsisten(id);
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
        title: const Text('Manajemen Asisten'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _asistens.isEmpty
              ? const Center(child: Text('Belum ada asisten yang didaftarkan'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _asistens.length,
                  itemBuilder: (context, index) {
                    final a = _asistens[index];
                    return _buildAsistenCard(a);
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddForm(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildAsistenCard(UserModel user) {
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
          CircleAvatar(
            backgroundColor: AppColors.primaryLight,
            radius: 24,
            child: Text(user.nama[0].toUpperCase(), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.nama, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.text)),
                const SizedBox(height: 2),
                Text(user.email, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _confirmDelete(user.idUser!),
            icon: const Icon(Icons.delete_outline_rounded, color: AppColors.red),
          ),
        ],
      ),
    );
  }

  void _showAddForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tambah Asisten Baru', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              FormIsian(label: 'Nama Lengkap', hint: 'Ketik nama pengelola', controller: _namaCtrl),
              const SizedBox(height: 16),
              FormIsian(label: 'Email Login', hint: 'contoh@alfalah.com', controller: _emailCtrl, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              FormIsian(label: 'Password', hint: 'Minimal 8 karakter', controller: _passCtrl, isPassword: true),
              const SizedBox(height: 32),
              TombolUtama(text: 'Daftarkan Asisten', onPressed: _handleAdd),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
