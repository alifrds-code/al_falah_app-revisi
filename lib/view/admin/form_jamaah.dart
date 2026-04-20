import 'package:flutter/material.dart';
import 'package:al_falah_app/controllers/admin_controller.dart';
import 'package:al_falah_app/models/model_jamaah.dart';

// IMPORT GUDANG DESAIN KITA
import 'package:al_falah_app/utils/app_colors.dart';
import 'package:al_falah_app/widgets/form_isian.dart';

class FormJamaah extends StatefulWidget {
  final Map<String, dynamic>? jamaahLama;
  // TAMBAHAN: Buat nangkep ID kelas kalau form dipanggil dari Detail Kelas
  final String? preselectedIdKelas;

  const FormJamaah({Key? key, this.jamaahLama, this.preselectedIdKelas})
    : super(key: key);

  @override
  State<FormJamaah> createState() => _FormJamaahState();
}

class _FormJamaahState extends State<FormJamaah> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _noHpController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();

  bool _isLoading = false;
  bool get isEdit => widget.jamaahLama != null;

  String? _selectedJK;
  String? _selectedIdKelas; // Tipe datanya String? biar bisa null
  List<Map<String, dynamic>> _daftarKelas = [];

  @override
  void initState() {
    super.initState();
    _loadDaftarKelas();

    if (isEdit) {
      _namaController.text = widget.jamaahLama!['nama_lengkap'];
      _noHpController.text = widget.jamaahLama!['no_hp'] ?? '';
      _alamatController.text = widget.jamaahLama!['alamat'];
      _selectedJK = widget.jamaahLama!['jenis_kelamin'];

      if (widget.jamaahLama!['id_kelas'] != null) {
        _selectedIdKelas = widget.jamaahLama!['id_kelas'].toString();
      }
    } else if (widget.preselectedIdKelas != null) {
      // TAMBAHAN: Kalau dari layar Detail Kelas, otomatis pilih kelasnya
      _selectedIdKelas = widget.preselectedIdKelas;
    }
  }

  void _loadDaftarKelas() async {
    final kelas = await AdminController.ambilSemuaKelas();

    // GANTI BAGIAN SETSTATE INI
    if (mounted) {
      setState(() {
        _daftarKelas = kelas;

        // PENTING: Kita cek apakah _selectedIdKelas (dari data jamaah lama)
        // beneran ADA di dalam _daftarKelas yang baru ditarik dari database.
        // Kalau ternyata udah dihapus kelasnya, kita set null aja biar ga error.
        if (_selectedIdKelas != null) {
          bool kelasAda = _daftarKelas.any(
            (k) => k['id'] == _selectedIdKelas,
          );
          if (!kelasAda) {
            _selectedIdKelas = null;
          }
        }
      });
    }
  }

  void _simpanJamaah() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedJK == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pilih Jenis Kelamin terlebih dahulu!'),
            backgroundColor: AppColors.warning,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        JamaahModel dataJamaah = JamaahModel(
          idJamaah: isEdit ? widget.jamaahLama!['id_jamaah'] : null,
          namaLengkap: _namaController.text.trim(),
          jenisKelamin: _selectedJK!,
          noHp: _noHpController.text.trim(),
          alamat: _alamatController.text.trim(),
          idKelas: _selectedIdKelas,
          statusJamaah: 1,
        );

        if (isEdit) {
          await AdminController.updateJamaah(widget.jamaahLama!['id'], dataJamaah);
        } else {
          await AdminController.tambahJamaah(dataJamaah);
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEdit
                  ? 'Data jamaah diupdate!'
                  : 'Jamaah baru berhasil ditambah!',
            ),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.pop(context, true);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Data Jamaah' : 'Tambah Jamaah Baru',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: AppColors.primaryLight,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isEdit ? Icons.edit : Icons.person_add_alt_1,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Biodata Jamaah',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textHeading,
                                ),
                              ),
                              Text(
                                'Isi data diri dan tentukan kelasnya',
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
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Divider(color: AppColors.borderLight, height: 1),
                    ),

                    FormIsian(
                      controller: _namaController,
                      labelText: 'Nama Lengkap',
                      prefixIcon: Icons.person_outline,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Nama tidak boleh kosong'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    // DROPDOWN JENIS KELAMIN
                    DropdownButtonFormField<String>(
                      value: _selectedJK,
                      hint: const Text(
                        'Pilih Jenis Kelamin',
                        style: TextStyle(
                          color: AppColors.textHint,
                          fontSize: 14,
                        ),
                      ),
                      decoration: InputDecoration(
                        labelText: 'Jenis Kelamin',
                        labelStyle: const TextStyle(
                          color: AppColors.textSubtitle,
                        ),
                        prefixIcon: const Icon(
                          Icons.wc,
                          color: AppColors.textHint,
                          size: 20,
                        ),
                        filled: true,
                        fillColor: AppColors.surface,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                      items: ['Laki-laki', 'Perempuan'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: const TextStyle(
                              color: AppColors.textHeading,
                              fontSize: 14,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (newValue) =>
                          setState(() => _selectedJK = newValue),
                    ),
                    const SizedBox(height: 16),

                    FormIsian(
                      controller: _noHpController,
                      labelText: 'Nomor HP / WhatsApp',
                      prefixIcon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),

                    FormIsian(
                      controller: _alamatController,
                      labelText: 'Alamat Domisili',
                      prefixIcon: Icons.home_outlined,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Alamat tidak boleh kosong'
                          : null,
                    ),
                    const SizedBox(height: 16),

                    DropdownButtonFormField<String?>(
                      value:
                          _daftarKelas.any(
                            (k) => k['id'] == _selectedIdKelas,
                          )
                          ? _selectedIdKelas
                          : null,
                      hint: const Text(
                        'Pilih Kelas',
                        style: TextStyle(
                          color: AppColors.textHint,
                          fontSize: 14,
                        ),
                      ),
                      decoration: InputDecoration(
                        labelText: 'Daftarkan ke Kelas',
                        labelStyle: const TextStyle(
                          color: AppColors.textSubtitle,
                        ),
                        prefixIcon: const Icon(
                          Icons.class_outlined,
                          color: AppColors.textHint,
                          size: 20,
                        ),
                        filled: true,
                        fillColor: AppColors.surface,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                      ),
                      items: [
                        // INI OPSI BUAT MENGOSONGKAN KELAS
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text(
                            '-- Belum ada kelas --',
                            style: TextStyle(
                              color: AppColors.textSubtitle,
                              fontStyle: FontStyle.italic,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        // DAFTAR KELAS DARI DATABASE
                        ..._daftarKelas.map((kelas) {
                          return DropdownMenuItem<String?>(
                            value: kelas['id'],
                            child: Text(
                              kelas['nama_kelas'],
                              style: const TextStyle(
                                color: AppColors.textHeading,
                                fontSize: 14,
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                      onChanged: (newValue) =>
                          setState(() => _selectedIdKelas = newValue),
                    ),

                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _isLoading ? null : _simpanJamaah,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 3,
                                ),
                              )
                            : Text(
                                isEdit ? 'UPDATE JAMAAH' : 'SIMPAN JAMAAH',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
