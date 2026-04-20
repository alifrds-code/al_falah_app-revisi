import 'package:flutter/material.dart';
import 'package:al_falah_app/controllers/login_controller.dart';
import 'package:al_falah_app/extensions/navigator.dart';
import 'package:al_falah_app/view/admin/beranda_admin.dart';
import 'package:al_falah_app/view/asisten/beranda_asisten.dart';

// IMPORT GUDANG DESAIN KITA:
import 'package:al_falah_app/utils/app_colors.dart';
import 'package:al_falah_app/widgets/form_isian.dart';

class LayarLogin extends StatefulWidget {
  const LayarLogin({Key? key}) : super(key: key);

  @override
  State<LayarLogin> createState() => _LayarLoginState();
}

class _LayarLoginState extends State<LayarLogin> {
  // Controller buat nangkep ketikan user
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Variabel buat ngatur UI/UX
  // bool _isObscure = true; // <-- Udah ga dipake di sini, diurus otomatis sama FormIsian!
  bool _isLoading = false;

  // Fungsi saat tombol login ditekan
  void _prosesLogin() async {
    // 1. Validasi kosong
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email dan Password wajib diisi')),
      );
      return;
    }

    // 2. Nyalain animasi loading
    setState(() {
      _isLoading = true;
    });

    try {
      // 3. Panggil otak login
      final user = await LoginController.loginUser(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 4. Pengaman Flutter: Pastikan layar masih ada sebelum ngapa-ngapain
      if (!mounted) return;

      // 5. Cek hasil login
      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Selamat datang, ${user.nama}!'),
            backgroundColor: AppColors.primary, // Ganti pake hijau tema
          ),
        );

        // POLISI LALU LINTAS ROLE
        if (user.role == 'admin') {
          context.pushAndRemoveAll(
            BerandaAdmin(namaUser: user.nama, emailUser: user.email),
          );
        } else if (user.role == 'asisten') {
          // ARAHIN KE HALAMAN ASISTEN SAMBIL BAWA DATANYA
          context.pushAndRemoveAll(
            BerandaAsisten(
              uid: user.uid ?? '',
              namaUser: user.nama,
              emailUser: user.email,
            ),
          );
        }
      } else {
        // Kalau kembaliannya null (salah email/pass)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email atau Password salah. Coba lagi!'),
            backgroundColor: AppColors.danger, // Ganti pake merah tema
          ),
        );
      }
    } catch (e) {
      // 6. TANGKAP ERROR DATABASE DI SINI BIAR KETAHUAN PENYAKITNYA
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error Sistem: $e'),
          backgroundColor: AppColors.danger,
          duration: const Duration(seconds: 5), // Agak lama biar sempet dibaca
        ),
      );
      print("ERROR WAKTU LOGIN: $e");
    } finally {
      // 7. APAPUN YANG TERJADI (Sukses/Error), LOADING WAJIB MATI
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppColors.background, // Pake abu-abu super muda dari tema
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // LOGO APLIKASI
                Image.asset(
                  'assets/images/logoAlFalah.png', // Logo dari folder assets [cite: 1]
                  height: 200,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.mosque,
                    size: 100,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 40),

                const Text(
                  'Silakan masuk ke akun Anda',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: AppColors.textSubtitle),
                ),
                const SizedBox(height: 16), // Jarak diubah dikit biar lega
                // Form Input Email (Pake cetakan widget yang lu buat)
                FormIsian(
                  controller: _emailController,
                  labelText: 'Email',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // Form Input Password (Pake cetakan widget yang lu buat)
                FormIsian(
                  controller: _passwordController,
                  labelText: 'Password',
                  prefixIcon: Icons.lock_outline,
                  isPassword:
                      true, // Otomatis nge-trigger tombol buka/tutup mata
                ),
                const SizedBox(height: 32),

                // Tombol Login
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary, // Hijau Emerald
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation:
                          0, // Dihilangin bayangannya biar modern ala Tailwind
                    ),
                    onPressed: _isLoading ? null : _prosesLogin,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : const Text(
                            'MASUK',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
