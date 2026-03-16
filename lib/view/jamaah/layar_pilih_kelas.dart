// // Lokasi: lib/views/jamaah/layar_pilih_kelas.dart

// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../utils/app_colors.dart';
// import 'beranda_jamaah.dart';

// class LayarPilihKelas extends StatefulWidget {
//   const LayarPilihKelas({Key? key}) : super(key: key);

//   @override
//   State<LayarPilihKelas> createState() => _LayarPilihKelasState();
// }

// class _LayarPilihKelasState extends State<LayarPilihKelas> {
//   /* -------------------------------------------------------------------------
//     PANDUAN DATA UNTUK DEVELOPER:
//     -------------------------------------------------------------------------
//     1. SEKARANG (Fokus UI): 
//        Kita pake data dummy '_daftarKelasDummy' di bawah ini. Ini buat simulasi 
//        tampilan list kelas yang ada di Yayasan Al Falah (sekitar 10 kelas)[cite: 3, 111].
    
//     2. NANTI (Integrasi Database):
//        Pas 'sqflite_helper.dart' udah jadi[cite: 149], data ini harus lu tarik dari 
//        'tb_kelas' pake 'KelasController.getAllKelas()'[cite: 4, 148].
    
//     3. PENYIMPANAN:
//        Pilihan user di sini harus disimpen secara permanen di HP. 
//        Gua saranin pake 'prefs.setStringList' buat nyimpen ID kelas yang dipilih.
//     -------------------------------------------------------------------------
//   */

//   final List<Map<String, dynamic>> _daftarKelasDummy = [
//     {"id": 1, "nama": "MT Samawa", "ustadz": "Ustadz Abdullah"},
//     {"id": 2, "nama": "MT Lansia", "ustadz": "Ustadz Hilman"},
//     {"id": 3, "nama": "Tahsin Dasar", "ustadz": "Ustadz Fauzi"},
//     {"id": 4, "nama": "Fiqih Ibadah", "ustadz": "Ustadz Zaki"},
//     {"id": 5, "nama": "Sirah Nabawiyah", "ustadz": "Ustadz Hanif"},
//   ];

//   // Set buat nampung ID kelas yang dipilih jamaah [cite: 29]
//   final Set<int> _idKelasTerpilih = {};

//   Future<void> _simpanPilihanDanMasukBeranda() async {
//     if (_idKelasTerpilih.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text("Pilih minimal 1 kelas yang Anda ikuti ya."),
//           backgroundColor: Colors.redAccent,
//         ),
//       );
//       return;
//     }

//     /* -------------------------------------------------------------------------
//       LOGIKA SISTEM (DI BALIK LAYAR)[cite: 65]:
//       -------------------------------------------------------------------------
//       1. Tandai 'isFirstTime' jadi false di SharedPreferences[cite: 28, 30].
//       2. Simpan list '_idKelasTerpilih' ke memori lokal.
//       3. Navigasi pushReplacement biar user nggak bisa klik 'Back' ke sini lagi.
//       -------------------------------------------------------------------------
//     */

//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('isFirstTime', false);
//     // Simpan pilihan sebagai List of String (karena SharedPreferences nggak dukung List of Int)
//     await prefs.setStringList(
//       'pilihan_kelas',
//       _idKelasTerpilih.map((id) => id.toString()).toList(),
//     );

//     if (mounted) {
//       Navigator.pushReplacement(
//         context,
//         MaterialPageRoute(builder: (context) => const BerandaJamaah()),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.bgSlate,
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Header: Judul dan Penjelasan [cite: 28]
//             Padding(
//               padding: const EdgeInsets.fromLTRB(24, 40, 24, 20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     "Pilih Kelas Anda",
//                     style: TextStyle(
//                       fontSize: 32,
//                       fontWeight: FontWeight.w800,
//                       color: AppColors.textSlate800,
//                       letterSpacing: -1,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   Text(
//                     "Tandai kelas yang Anda ikuti secara rutin. Beranda Anda nantinya hanya akan menampilkan jadwal dari kelas tersebut[cite: 16].",
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: AppColors.textSlate500,
//                       height: 1.6,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // List Kelas dengan desain Card Modern [cite: 29]
//             Expanded(
//               child: ListView.builder(
//                 padding: const EdgeInsets.symmetric(horizontal: 24),
//                 itemCount: _daftarKelasDummy.length,
//                 itemBuilder: (context, index) {
//                   final kelas = _daftarKelasDummy[index];
//                   final isSelected = _idKelasTerpilih.contains(kelas["id"]);

//                   return Padding(
//                     padding: const EdgeInsets.only(bottom: 12),
//                     child: InkWell(
//                       onTap: () {
//                         setState(() {
//                           if (isSelected) {
//                             _idKelasTerpilih.remove(kelas["id"]);
//                           } else {
//                             _idKelasTerpilih.add(kelas["id"]);
//                           }
//                         });
//                       },
//                       borderRadius: BorderRadius.circular(20),
//                       child: AnimatedContainer(
//                         duration: const Duration(milliseconds: 250),
//                         padding: const EdgeInsets.all(20),
//                         decoration: BoxDecoration(
//                           color: isSelected
//                               ? Colors.white
//                               : Colors.white.withOpacity(0.6),
//                           borderRadius: BorderRadius.circular(20),
//                           border: Border.all(
//                             color: isSelected
//                                 ? AppColors.primaryEmerald
//                                 : Colors.transparent,
//                             width: 2,
//                           ),
//                           boxShadow: isSelected
//                               ? [
//                                   BoxShadow(
//                                     color: AppColors.primaryEmerald.withOpacity(
//                                       0.1,
//                                     ),
//                                     blurRadius: 10,
//                                     offset: const Offset(0, 4),
//                                   ),
//                                 ]
//                               : null,
//                         ),
//                         child: Row(
//                           children: [
//                             // Custom Checkbox Bulat Modern
//                             Container(
//                               width: 24,
//                               height: 24,
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 color: isSelected
//                                     ? AppColors.primaryEmerald
//                                     : Colors.transparent,
//                                 border: Border.all(
//                                   color: isSelected
//                                       ? AppColors.primaryEmerald
//                                       : Colors.grey.shade400,
//                                   width: 2,
//                                 ),
//                               ),
//                               child: isSelected
//                                   ? const Icon(
//                                       Icons.check,
//                                       size: 16,
//                                       color: Colors.white,
//                                     )
//                                   : null,
//                             ),
//                             const SizedBox(width: 16),
//                             Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   kelas["nama"],
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: isSelected
//                                         ? FontWeight.bold
//                                         : FontWeight.w600,
//                                     color: isSelected
//                                         ? AppColors.primaryTeal
//                                         : AppColors.textSlate800,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 2),
//                                 Text(
//                                   kelas["ustadz"],
//                                   style: TextStyle(
//                                     fontSize: 12,
//                                     color: AppColors.textSlate500,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),

//             // Tombol Konfirmasi Permanen [cite: 30]
//             Container(
//               padding: const EdgeInsets.all(24),
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(30),
//                   topRight: Radius.circular(30),
//                 ),
//               ),
//               child: ElevatedButton(
//                 onPressed: _simpanPilihanDanMasukBeranda,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.primaryEmerald,
//                   foregroundColor: Colors.white,
//                   minimumSize: const Size(double.infinity, 60),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   elevation: 0,
//                 ),
//                 child: const Text(
//                   "Mulai Gunakan Aplikasi",
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
