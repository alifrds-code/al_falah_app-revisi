import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../widgets/tombol_utama.dart';
import '../../controllers/admin_controller.dart';
import '../../controllers/laporan_controller.dart';
import '../../models/model_kelas.dart';

class LaporanAbsensi extends StatefulWidget {
  const LaporanAbsensi({super.key});

  @override
  State<LaporanAbsensi> createState() => _LaporanAbsensiState();
}

class _LaporanAbsensiState extends State<LaporanAbsensi> {
  final AdminController _adminController = AdminController();
  final LaporanController _laporanController = LaporanController();
  
  List<KelasModel> _classes = [];
  KelasModel? _selectedKelas;
  String _selectedMonth = "2025-04"; // Default
  bool _isLoadingData = true;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final classes = await _adminController.getClasses();
    setState(() {
      _classes = classes;
      if (classes.isNotEmpty) _selectedKelas = classes.first;
      _isLoadingData = false;
    });
  }

  void _handleExport() async {
    if (_selectedKelas == null) return;

    setState(() => _isExporting = true);
    
    final path = await _laporanController.exportAttendanceToCSV(
      _selectedKelas!.idKelas!,
      _selectedKelas!.namaKelas,
      _selectedMonth,
    );

    setState(() => _isExporting = false);

    if (mounted) {
      if (path != null) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Ekspor Berhasil'),
            content: Text('File CSV disimpan di:\n$path'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
            ],
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal mengekspor data atau data kosong')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Laporan Absensi'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pilih Parameter Laporan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  const Text('Data akan dikonversi menjadi file CSV yang dapat dibuka di MS Excel.', style: TextStyle(color: AppColors.muted, fontSize: 13)),
                  const SizedBox(height: 32),
                  
                  // Pick Class
                  const Text('Kelas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                    child: DropdownButton<KelasModel>(
                      value: _selectedKelas,
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: _classes.map((k) => DropdownMenuItem(value: k, child: Text(k.namaKelas))).toList(),
                      onChanged: (val) => setState(() => _selectedKelas = val),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Pick Month (Simplified for MVP)
                  const Text('Bulan (Format: YYYY-MM)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                    child: DropdownButton<String>(
                      value: _selectedMonth,
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: ['2025-01', '2025-02', '2025-03', '2025-04', '2025-05'].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                      onChanged: (val) => setState(() => _selectedMonth = val!),
                    ),
                  ),
                  
                  const Spacer(),
                  if (_isExporting)
                    const Center(child: CircularProgressIndicator())
                  else
                    TombolUtama(
                      text: 'Ekspor ke CSV',
                      onPressed: _handleExport,
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
