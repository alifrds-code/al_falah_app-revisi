import 'package:flutter/material.dart';
import 'package:al_falah_app/controllers/pengumuman_controller.dart';
import 'package:al_falah_app/utils/app_colors.dart';

class FormPengumuman extends StatefulWidget {
  final Map<String, dynamic>? pengumumanLama;

  const FormPengumuman({super.key, this.pengumumanLama});

  @override
  State<FormPengumuman> createState() => _FormPengumumanState();
}

class _FormPengumumanState extends State<FormPengumuman> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _judulController;
  late TextEditingController _isiController;

  bool _isLoading = false;

  bool get isEdit => widget.pengumumanLama != null;

  @override
  void initState() {
    super.initState();
    _judulController = TextEditingController(text: isEdit ? widget.pengumumanLama!['judul'] : '');
    _isiController = TextEditingController(text: isEdit ? widget.pengumumanLama!['isi'] : '');
  }

  @override
  void dispose() {
    _judulController.dispose();
    _isiController.dispose();
    super.dispose();
  }

  void _simpanData() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        if (isEdit) {
          await PengumumanController.updatePengumuman(
            widget.pengumumanLama!['id'],
            judul: _judulController.text.trim(),
            isi: _isiController.text.trim(),
          );
        } else {
          await PengumumanController.tambahPengumuman(
            judul: _judulController.text.trim(),
            isi: _isiController.text.trim(),
          );
        }

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEdit
                  ? 'Pengumuman berhasil diubah!'
                  : 'Pengumuman baru berhasil dibuat!',
            ),
            backgroundColor: AppColors.primary,
          ),
        );

        Navigator.pop(context, true);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Pengumuman' : 'Buat Pengumuman Baru',
          style: const TextStyle(
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
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
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
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E63), // Pink for Pengumuman
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _isLoading ? null : _simpanData,
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'SIMPAN DATA',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
            ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text(
              'INFORMASI PENGUMUMAN',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textSubtitle,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _judulController,
              label: 'Judul Pengumuman',
              icon: Icons.title,
              hint: 'Contoh: Perubahan Jadwal Mengajar',
              validator: (v) => v!.isEmpty ? 'Judul wajib diisi!' : null,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _isiController,
              label: 'Isi Pengumuman',
              icon: Icons.notes,
              hint: 'Ketik pesan lengkapnya di sini...',
              validator: (v) => v!.isEmpty ? 'Isi wajib diisi!' : null,
              maxLines: 8,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textBody,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textHint, fontSize: 14),
            prefixIcon: maxLines == 1
                ? Icon(icon, color: AppColors.textHint, size: 20)
                : null,
            filled: true,
            fillColor: AppColors.background,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE91E63), width: 2), // Pink
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.danger),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.danger, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
