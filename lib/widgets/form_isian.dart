// WIDGET CETAKAN FORM INPUT (Daur Ulang)
// Desain modern ala Tailwind (Rounded-xl, Focus Emerald)
import 'package:flutter/material.dart';
import 'package:al_falah_app/utils/app_colors.dart'; // Palet warna kita

class FormIsian extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData prefixIcon;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const FormIsian({
    Key? key,
    required this.controller,
    required this.labelText,
    required this.prefixIcon,
    this.isPassword = false, // Default-nya bukan password
    this.keyboardType = TextInputType.text,
    this.validator,
  }) : super(key: key);

  @override
  State<FormIsian> createState() => _FormIsianState();
}

class _FormIsianState extends State<FormIsian> {
  // Variabel buat ngatur buka-tutup mata password
  bool _isObscure = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword ? _isObscure : false,
      keyboardType: widget.keyboardType,
      style: const TextStyle(
        fontSize: 14, // Teks input ukuran normal (text-sm)
        color: AppColors.textHeading,
      ),
      decoration: InputDecoration(
        labelText: widget.labelText,
        labelStyle: const TextStyle(color: AppColors.textSubtitle), // gray-500
        // Ikon di kiri
        prefixIcon: Icon(
          widget.prefixIcon,
          color: AppColors.textHint,
          size: 20,
        ),

        // Ikon Mata di kanan (MUNCUL KALAU isPassword = true AJA)
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _isObscure ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.textHint,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _isObscure = !_isObscure; // Ganti status sembunyi/tampil
                  });
                },
              )
            : null,

        filled: true,
        fillColor: AppColors.surface, // Background putih
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),

        // 1. Kondisi Normal (Garis abu-abu)
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),

        // 2. Kondisi Lagi Diketik (Garis Emerald terang & tebal)
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),

        // 3. Kondisi Error/Kosong (Garis Merah Rose)
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.danger),
        ),

        // 4. Kondisi Error tapi lagi diketik
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.danger, width: 2),
        ),
      ),
      validator: widget.validator, // Sambungin ke kunci rahasia form
    );
  }
}
