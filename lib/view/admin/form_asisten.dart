import 'package:flutter/material.dart';
import 'package:al_falah_app/controllers/admin_controller.dart';
import 'package:al_falah_app/models/model_user.dart';
import 'package:al_falah_app/utils/app_colors.dart';
import 'package:al_falah_app/widgets/form_isian.dart';

class FormAsisten extends StatefulWidget {
  // KANTONG DATA: Buat nangkep data asisten lama kalau tombol edit dipencet.
  // Pake tanda tanya (?) karena kalau nambah asisten baru, isinya pasti kosong (null).
  final UserModel? asistenLama;

  const FormAsisten({Key? key, this.asistenLama}) : super(key: key);

  @override
  State<FormAsisten> createState() => _FormAsistenState();
}

class _FormAsistenState extends State<FormAsisten> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;

  // VARIABEL SAKTI: Ngecek apakah ini lagi mode Edit atau bukan
  bool get isEdit => widget.asistenLama != null;

  @override
  void initState() {
    super.initState();
    // Kalau ini mode Edit, otomatis isi kotak teks dengan data lama!
    if (isEdit) {
      _namaController.text = widget.asistenLama!.nama;
      _emailController.text = widget.asistenLama!.email;
      // Note: Kotak password sengaja dibiarin kosong demi keamanan.
    }
  }

  void _simpanAsisten() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        if (isEdit) {
          // ==========================================
          // MODE EDIT: UPDATE DATA
          // ==========================================

          // LOGIKA PASSWORD:
          // Kalau admin gak ngetik password baru (kosong), pake password lama dari database.
          // Kalau admin ngetik sesuatu, berarti passwordnya diganti!
          String passwordFinal = _passwordController.text.trim().isEmpty
              ? widget.asistenLama!.password
              : _passwordController.text.trim();

          UserModel asistenUpdate = UserModel(
            idUser:
                widget.asistenLama!.idUser, // ID wajib ada buat patokan UPDATE
            nama: _namaController.text.trim(),
            email: _emailController.text.trim(),
            password: passwordFinal,
            role: 'asisten', // Tetep asisten
          );

          await AdminController.updateAsisten(asistenUpdate);
        } else {
          // ==========================================
          // MODE TAMBAH BARU (CREATE)
          // ==========================================
          UserModel asistenBaru = UserModel(
            nama: _namaController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            role: 'asisten',
          );

          await AdminController.tambahAsisten(asistenBaru);
        }

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            // Pesan suksesnya nyesuain mode
            content: Text(
              isEdit
                  ? 'Mantap! Data asisten berhasil diupdate.'
                  : 'Mantap! Akun Asisten baru berhasil dibuat.',
            ),
            backgroundColor: AppColors.primary,
          ),
        );

        Navigator.pop(context, true);
      } catch (e) {
        if (!mounted) return;

        // KITA CEGAT ERROR DARI SQLITE DI SINI
        String pesanError = e.toString();

        // Kalau error-nya gara-gara email udah ada di database (UNIQUE constraint)
        if (pesanError.contains('UNIQUE constraint failed')) {
          pesanError =
              'Gagal: Email tersebut sudah terdaftar! Silakan gunakan email lain.';
        } else {
          // Kalau error lain, tampilin aslinya
          pesanError = 'Terjadi kesalahan sistem: $e';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(pesanError),
            backgroundColor: AppColors.danger, // Merah
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
        // Judul atasnya berubah otomatis!
        title: Text(
          isEdit ? 'Edit Akun Asisten' : 'Buat Akun Asisten',
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
                            isEdit ? Icons.edit : Icons.person_add,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isEdit
                                    ? 'Update Data Asisten'
                                    : 'Data Diri Asisten',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textHeading,
                                ),
                              ),
                              const Text(
                                'Akun ini akan dipakai asisten untuk login',
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
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Nama tidak boleh kosong!';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    FormIsian(
                      controller: _emailController,
                      labelText: 'Email Aktif',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Email tidak boleh kosong!';
                        if (!value.contains('@'))
                          return 'Format email tidak valid!';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    FormIsian(
                      controller: _passwordController,
                      // Label passwordnya menyesuaikan mode Edit/Baru
                      labelText: isEdit
                          ? 'Password Baru (Kosongkan jika tdk diganti)'
                          : 'Buat Password',
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                      validator: (value) {
                        // Kalau nambah baru, password WAJIB isi.
                        if (!isEdit && (value == null || value.isEmpty)) {
                          return 'Password tidak boleh kosong!';
                        }
                        // Kalau diisi (baik mode edit/baru), minimal 6 karakter
                        if (value != null &&
                            value.isNotEmpty &&
                            value.length < 6) {
                          return 'Password minimal 6 karakter!';
                        }
                        return null;
                      },
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
                        onPressed: _isLoading ? null : _simpanAsisten,
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
                                // Teks tombol nyesuain
                                isEdit ? 'UPDATE DATA' : 'SIMPAN AKUN',
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
