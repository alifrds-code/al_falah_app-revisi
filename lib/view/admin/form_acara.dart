import 'package:flutter/material.dart';
import 'package:al_falah_app/controllers/admin_controller.dart';
import 'package:al_falah_app/utils/app_colors.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';

class FormAcara extends StatefulWidget {
  final Map<String, dynamic>? acaraLama;

  const FormAcara({super.key, this.acaraLama});

  @override
  State<FormAcara> createState() => _FormAcaraState();
}

class _FormAcaraState extends State<FormAcara> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _namaController;
  late TextEditingController _lokasiController;
  late TextEditingController _deskripsiController;
  late TextEditingController _urlPosterController;

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();
  String? _base64Image;

  bool get isEdit => widget.acaraLama != null;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: isEdit ? widget.acaraLama!['nama_acara'] : '');
    _lokasiController = TextEditingController(text: isEdit ? widget.acaraLama!['lokasi'] : '');
    _deskripsiController = TextEditingController(text: isEdit ? widget.acaraLama!['deskripsi'] : '');
    
    // We repurpose url_poster to hold the base64 string or original URL
    String initialImage = isEdit ? (widget.acaraLama!['url_poster'] ?? '') : '';
    _urlPosterController = TextEditingController(text: initialImage);
    if(initialImage.isNotEmpty) {
      _base64Image = initialImage;
    }

    if (isEdit) {
      try {
        _selectedDate = DateTime.parse(widget.acaraLama!['tanggal']);
        final jamStr = widget.acaraLama!['jam'] as String;
        final jamParts = jamStr.split(':');
        _selectedTime = TimeOfDay(hour: int.parse(jamParts[0]), minute: int.parse(jamParts[1]));
      } catch (e) {
        // Fallback or ignore
      }
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _lokasiController.dispose();
    _deskripsiController.dispose();
    _urlPosterController.dispose();
    super.dispose();
  }

  void _simpanData() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null || _selectedTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sabar Bro! Tanggal dan jam acara harus diisi.'),
            backgroundColor: AppColors.danger,
          ),
        );
        return;
      }

      setState(() => _isLoading = true);

      String fJam = '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';

      try {
        if (isEdit) {
          await AdminController.updateAcara(
            widget.acaraLama!['id'],
            namaAcara: _namaController.text.trim(),
            tanggal: _selectedDate!,
            jam: fJam,
            lokasi: _lokasiController.text.trim(),
            deskripsi: _deskripsiController.text.trim(),
            urlPoster: _urlPosterController.text.trim(),
          );
        } else {
          await AdminController.tambahAcara(
            namaAcara: _namaController.text.trim(),
            tanggal: _selectedDate!,
            jam: fJam,
            lokasi: _lokasiController.text.trim(),
            deskripsi: _deskripsiController.text.trim(),
            urlPoster: _urlPosterController.text.trim(),
          );
        }

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEdit
                  ? 'Mantap! Acara berhasil diedit.'
                  : 'Mantap! Acara baru berhasil dibuat.',
            ),
            backgroundColor: AppColors.primary,
          ),
        );

        Navigator.pop(context, true);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan sistem: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pilihDariGaleri() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 40, // Compress to save firestore space
        maxWidth: 800,
      );
      if (image != null) {
        final bytes = await File(image.path).readAsBytes();
        final base64Str = base64Encode(bytes);
        setState(() {
          _base64Image = base64Str;
          _urlPosterController.text = base64Str;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal ambil gambar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Acara' : 'Buat Acara Baru',
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
                backgroundColor: const Color(0xFF9C27B0), // Purple!
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
            // INFORMASI UMUM
            const Text(
              'INFORMASI UTAMA',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textSubtitle,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildTextField(
              controller: _namaController,
              label: 'Nama Acara/Event',
              icon: Icons.event,
              hint: 'Contoh: Kajian Akhir Pekan',
              validator: (v) => v!.isEmpty ? 'Wajib diisi Bro!' : null,
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildSelectorCard(
                    title: 'Tanggal',
                    value: _selectedDate == null ? 'Pilih Tanggal' : DateFormat('dd MMM yyyy').format(_selectedDate!),
                    icon: Icons.calendar_today,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => _selectedDate = picked);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSelectorCard(
                    title: 'Jam',
                    value: _selectedTime == null ? 'Pilih Jam' : _selectedTime!.format(context),
                    icon: Icons.access_time,
                    onTap: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: _selectedTime ?? TimeOfDay.now(),
                      );
                      if (picked != null) {
                        setState(() => _selectedTime = picked);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _lokasiController,
              label: 'Lokasi Acara',
              icon: Icons.location_on,
              hint: 'Contoh: Aula Masjid Al-Falah',
              validator: (v) => v!.isEmpty ? 'Wajib diisi Bro!' : null,
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _deskripsiController,
              label: 'Deskripsi Acara',
              icon: Icons.description,
              hint: 'Ceritakan detail acaranya...',
              validator: (v) => v!.isEmpty ? 'Wajib diisi Bro!' : null,
              maxLines: 4,
            ),
            const SizedBox(height: 32),

            // MEDIA SECTION
            const Text(
              'MEDIA & POSTER (GALERI)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textSubtitle,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            
            InkWell(
              onTap: _pilihDariGaleri,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.photo_library, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text(
                      'PILIH FOTO DARI GALERI',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            if (_base64Image != null && _base64Image!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _base64Image!.startsWith('http')
                    ? Image.network(
                        _base64Image!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Image.memory(
                        base64Decode(_base64Image!),
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                           return const Center(child: Text("Bukan format base64 yang valid"));
                        },
                      ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectorCard({
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.background,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF9C27B0), size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 11, color: AppColors.textSubtitle),
                  ),
                  const SizedBox(height: 2),
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
    Function(String)? onChanged,
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
          onChanged: onChanged,
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
              borderSide: const BorderSide(color: Color(0xFF9C27B0), width: 2),
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
