// Nyimpen variabel warna utama (Hijau, Merah, dll) biar tinggal panggil
import 'package:flutter/material.dart';

class AppColors {
  // 1. WARNA UTAMA (THEME: EMERALD / HIJAU ISLAMI MODERN)
  static const Color primary = Color(
    0xFF059669,
  ); // emerald-600 (Utama: Header, Tombol)
  static const Color primaryLight = Color(
    0xFFECFDF5,
  ); // emerald-50 (Background icon/badge)
  static const Color primaryDark = Color(
    0xFF047857,
  ); // emerald-700 (Hover/Active state)
  static const Color primaryGradientEnd = Color(
    0xFF065F46,
  ); // emerald-800 (Buat efek gradasi)

  // 2. WARNA BACKGROUND & BORDER (ABU-ABU BERSIH)

  static const Color background = Color(
    0xFFF9FAFB,
  ); // gray-50 (Background layar keseluruhan)
  static const Color surface = Colors.white; // Background untuk Card / Kotak
  static const Color border = Color(
    0xFFE5E7EB,
  ); // gray-200 (Garis pinggir input/kartu)
  static const Color borderLight = Color(
    0xFFF3F4F6,
  ); // gray-100 (Garis pemisah tipis)

  // 3. WARNA TEKS (TYPOGRAPHY)

  static const Color textHeading = Color(
    0xFF111827,
  ); // gray-900 (Judul besar, sangat gelap)
  static const Color textBody = Color(
    0xFF4B5563,
  ); // gray-600 (Teks biasa/paragraf)
  static const Color textSubtitle = Color(
    0xFF6B7280,
  ); // gray-500 (Teks kecil, keterangan)
  static const Color textHint = Color(
    0xFF9CA3AF,
  ); // gray-400 (Teks dalam form yang belum diisi)

  // 4. WARNA STATUS & AKSI LAINNYA

  static const Color danger = Color(
    0xFFF43F5E,
  ); // rose-500 (Tombol hapus, error)
  static const Color dangerLight = Color(
    0xFFFFF1F2,
  ); // rose-50 (Background icon hapus)

  static const Color info = Color(0xFF2563EB); // blue-600 (Informasi/Edit)
  static const Color infoLight = Color(
    0xFFDBEAFE,
  ); // blue-100 (Background icon info)

  static const Color warning = Color(
    0xFFF59E0B,
  ); // amber-500 (Peringatan/Kelas)
  static const Color warningLight = Color(
    0xFFFEF3C7,
  ); // amber-100 (Background icon kelas)
}
