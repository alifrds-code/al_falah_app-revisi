import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../widgets/tombol_utama.dart';
import '../../widgets/form_isian.dart';
import '../../controllers/login_controller.dart';
import '../asisten/beranda_asisten.dart';
import '../admin/beranda_admin.dart';

// layar buat login pengurus yayasan
class LayarLogin extends StatefulWidget {
  const LayarLogin({super.key});

  @override
  State<LayarLogin> createState() => _LayarLoginState();
}

class _LayarLoginState extends State<LayarLogin> {
  final LoginController _controller = LoginController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  // fungsi pas tombol login dipencet, gue cek dulu email pass-nya
  void _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // kalo kosong ya gak usah diproses lah ya
    if (email.isEmpty || password.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final user = await _controller.login(email, password);
      if (user != null) {
        if (mounted) {
          // kalo admin arahin ke dashboard admin, kalo asisten ya ke punya asisten
          if (user.role == 'admin') {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const BerandaAdmin()),
              (route) => false,
            );
          } else {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const BerandaAsisten()),
              (route) => false,
            );
          }
        }
      } else {
        // kalo gak ketemu datanya, munculin pesan error aja
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Email atau password salah')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // kalo user lupa password, kasih tau suruh hubungi admin pusat
  void _showForgotPassword() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lupa Password?'),
        content: const Text(
          'Silakan hubungi Admin Yayasan untuk melakukan reset kata sandi Anda.',
          style: TextStyle(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // bagian kepala yang ada warna hijaunya
            Container(
              height: 300,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // buletan logo AF itu
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        'AF',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Login Pengurus',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Masuk untuk mengelola data yayasan',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // bagian kotak inputan (form)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  FormIsian(
                    label: 'Email',
                    hint: 'Masukkan email Anda',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 20),
                  FormIsian(
                    label: 'Password',
                    hint: 'Masukkan password Anda',
                    controller: _passwordController,
                    isPassword: true,
                    prefixIcon: Icons.lock_outline,
                  ),
                  const SizedBox(height: 12),
                  // tombol lupa password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _showForgotPassword,
                      child: const Text(
                        'Lupa Password?',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // kalo lagi loading munculin muter-muter, kalo enggak munculin tombolnya
                  if (_isLoading)
                    const CircularProgressIndicator()
                  else
                    TombolUtama(
                      text: 'Masuk Sekarang',
                      onPressed: _handleLogin,
                    ),
                  const SizedBox(height: 40),
                  // tombol buat balik ke halaman depan jamaah
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Kembali ke Beranda Jamaah',
                      style: TextStyle(
                        color: AppColors.muted,
                        fontWeight: FontWeight.w500,
                      ),
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
}
