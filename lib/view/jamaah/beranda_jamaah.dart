// import 'package:flutter/material.dart';
// import 'package:al_falah_app/utils/app_colors.dart';

// class BerandaJamaah extends StatelessWidget {
//   const BerandaJamaah({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.bgSlate,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         title: const Text(
//           "Ta'lim Al Falah",
//           style: TextStyle(
//             color: AppColors.textSlate800,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(
//               Icons.settings_outlined,
//               color: AppColors.textSlate500,
//             ),
//             onPressed: () {
//               // Ke Pengaturan Kelas
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.login, color: AppColors.textSlate500),
//             onPressed: () {
//               // Ikon tersembunyi ke form Login Pengurus
//             },
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Banner Acara / Highlight
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 gradient: const LinearGradient(
//                   colors: [AppColors.primaryEmerald, AppColors.primaryTeal],
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                 ),
//                 borderRadius: BorderRadius.circular(24),
//                 boxShadow: [
//                   BoxShadow(
//                     color: AppColors.primaryEmerald.withOpacity(0.3),
//                     blurRadius: 15,
//                     offset: const Offset(0, 8),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 10,
//                       vertical: 5,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withOpacity(0.2),
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     child: const Text(
//                       "✨ Acara Terdekat",
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 12,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   const Text(
//                     "Tabligh Akbar Menyambut Ramadhan",
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//                   const Text(
//                     "Ahad, 15 Mar 2026 • Masjid Al Falah",
//                     style: TextStyle(color: Colors.white70, fontSize: 14),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 32),
//             const Text(
//               "Jadwal Kelas Anda",
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: AppColors.textSlate800,
//               ),
//             ),
//             const SizedBox(height: 16),

//             // List 3 Jadwal Terdekat
//             _buildKartuJadwal(
//               "MT Samawa",
//               "Fiqih Ibadah",
//               "16:00 - Selesai",
//               "Sesuai Jadwal",
//               AppColors.statusSesuai,
//             ),
//             const SizedBox(height: 12),
//             _buildKartuJadwal(
//               "MT Samawa",
//               "Tahsin",
//               "16:00 - Selesai",
//               "Ditunda",
//               AppColors.statusDitunda,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildKartuJadwal(
//     String kelas,
//     String materi,
//     String waktu,
//     String status,
//     Color statusColor,
//   ) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: Colors.grey.shade100),
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: AppColors.bgSlate,
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: const Icon(Icons.menu_book, color: AppColors.primaryEmerald),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   materi,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                     color: AppColors.textSlate800,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   "$kelas • $waktu",
//                   style: const TextStyle(
//                     fontSize: 12,
//                     color: AppColors.textSlate500,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//             decoration: BoxDecoration(
//               color: statusColor.withOpacity(0.1),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Text(
//               status,
//               style: TextStyle(
//                 color: statusColor,
//                 fontSize: 10,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
