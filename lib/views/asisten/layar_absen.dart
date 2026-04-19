import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../widgets/tombol_utama.dart';
import '../../controllers/asisten_controller.dart';
import '../../models/model_jamaah.dart';
import '../../models/model_jadwal.dart';
import '../../controllers/login_controller.dart';

// Layar input absensi jamaah untuk jadwal tertentu
class LayarAbsen extends StatefulWidget {
  final int idKelas;
  const LayarAbsen({super.key, required this.idKelas});

  @override
  State<LayarAbsen> createState() => _LayarAbsenState();
}

class _LayarAbsenState extends State<LayarAbsen> {
  final AsistenController _controller = AsistenController();
  final LoginController _loginController = LoginController();

  List<JadwalModel> _jadwal = []; // Daftar jadwal kelas ini
  List<JamaahModel> _students = []; // Daftar jamaah kelas ini
  // Map: id_jamaah -> status_hadir ('Hadir', 'Alpa', 'Izin', 'Sakit')
  final Map<int, String> _absenStatus = {};

  JadwalModel? _selectedJadwal; // Jadwal yang sedang dipilih
  bool _isLoading = true;
  bool _isSaving = false;

  // Untuk kotak pencarian nama jamaah
  final TextEditingController _cariCtrl = TextEditingController();
  List<JamaahModel> _studentsTampil = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    _cariCtrl.addListener(_filterStudents);
  }

  @override
  void dispose() {
    _cariCtrl.dispose();
    super.dispose();
  }

  void _loadData() async {
    final user = await _loginController.getCurrentUser();
    if (user != null) {
      final semuaJadwal = await _controller.getMySchedules(user.idUser!);
      // Filter hanya jadwal milik kelas ini
      final jadwalKelas = semuaJadwal.where((j) => j.idKelas == widget.idKelas).toList();
      final students = await _controller.getJamaahForClass(widget.idKelas);

      setState(() {
        _jadwal = jadwalKelas;
        _students = students;
        _studentsTampil = students;
        // Default semua jamaah: Hadir
        for (var s in students) {
          _absenStatus[s.idJamaah!] = 'Hadir';
        }
        if (_jadwal.isNotEmpty) _selectedJadwal = _jadwal.first;
        _isLoading = false;
      });

      // Kalau ada jadwal terpilih, coba load absensi yang sudah ada
      if (_jadwal.isNotEmpty) {
        _loadExistingAbsen(_jadwal.first.idJadwal!);
      }
    }
  }

  // Load absensi yang sudah pernah disimpan sebelumnya
  void _loadExistingAbsen(int idJadwal) async {
    final records = await _controller.getAttendanceRecords(idJadwal);
    if (records.isNotEmpty) {
      setState(() {
        for (var r in records) {
          _absenStatus[r['id_jamaah'] as int] = r['status_hadir'] as String;
        }
      });
    }
  }

  // Filter tampilan jamaah berdasarkan pencarian nama
  void _filterStudents() {
    final kata = _cariCtrl.text.toLowerCase();
    setState(() {
      if (kata.isEmpty) {
        _studentsTampil = _students;
      } else {
        _studentsTampil = _students
            .where((s) => s.namaLengkap.toLowerCase().contains(kata))
            .toList();
      }
    });
  }

  // Simpan semua absensi ke database
  void _handleSave() async {
    if (_selectedJadwal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih jadwal terlebih dahulu')),
      );
      return;
    }

    setState(() => _isSaving = true);

    // Buat batch data dari semua jamaah
    final List<Map<String, dynamic>> batch = _students.map((s) {
      return {
        'id_jamaah': s.idJamaah,
        'status_hadir': _absenStatus[s.idJamaah] ?? 'Hadir',
      };
    }).toList();

    await _controller.saveAttendance(_selectedJadwal!.idJadwal!, batch);

    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Absensi berhasil disimpan!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Input Absensi'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Header: pilih jadwal dan cari nama
                Container(
                  padding: const EdgeInsets.all(16),
                  color: AppColors.background,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Dropdown pilih jadwal
                      const Text(
                        'Pilih Jadwal Pertemuan',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _jadwal.isEmpty
                          ? const Text(
                              'Belum ada jadwal. Buat jadwal dulu di menu Kelola Jadwal.',
                              style: TextStyle(color: AppColors.red, fontSize: 12),
                            )
                          : Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: DropdownButton<JadwalModel>(
                                value: _selectedJadwal,
                                isExpanded: true,
                                underline: const SizedBox(),
                                hint: const Text('Pilih Jadwal'),
                                items: _jadwal.map((j) {
                                  return DropdownMenuItem(
                                    value: j,
                                    child: Text(
                                      '${j.tanggal} - ${j.materiPembahasan ?? "Kajian Rutin"}',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  setState(() {
                                    _selectedJadwal = val;
                                    // Reset status ke default Hadir
                                    for (var s in _students) {
                                      _absenStatus[s.idJamaah!] = 'Hadir';
                                    }
                                  });
                                  // Load absensi yang sudah ada untuk jadwal baru
                                  if (val != null) _loadExistingAbsen(val.idJadwal!);
                                },
                              ),
                            ),
                      const SizedBox(height: 12),
                      // Kotak pencarian nama
                      TextField(
                        controller: _cariCtrl,
                        decoration: InputDecoration(
                          hintText: 'Cari nama jamaah...',
                          prefixIcon: const Icon(Icons.search, color: AppColors.primary, size: 20),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.all(0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: AppColors.border),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Counter jamaah hadir
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: AppColors.primaryLight,
                  child: Row(
                    children: [
                      Text(
                        '${_absenStatus.values.where((s) => s == 'Hadir').length} dari ${_students.length} jamaah hadir',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Daftar nama jamaah + status absen
                Expanded(
                  child: _students.isEmpty
                      ? const Center(
                          child: Text(
                            'Belum ada jamaah di kelas ini.\nTambahkan jamaah di menu Kelola Jamaah.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.muted),
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: _studentsTampil.length,
                          separatorBuilder: (context, index) =>
                              const Divider(height: 1, indent: 70),
                          itemBuilder: (context, index) {
                            final s = _studentsTampil[index];
                            final statusSaat = _absenStatus[s.idJamaah] ?? 'Hadir';

                            return ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _getAvatarColor(statusSaat),
                                child: Text(
                                  s.namaLengkap.isNotEmpty ? s.namaLengkap[0].toUpperCase() : '?',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                s.namaLengkap,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                s.noHp ?? 'Tidak ada nomor HP',
                                style: const TextStyle(fontSize: 12),
                              ),
                              // Dropdown pilih status hadir
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  color: _getStatusBgColor(statusSaat),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: DropdownButton<String>(
                                  value: statusSaat,
                                  underline: const SizedBox(),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: _getStatusTextColor(statusSaat),
                                  ),
                                  items: ['Hadir', 'Alpa', 'Izin', 'Sakit']
                                      .map((status) => DropdownMenuItem(
                                            value: status,
                                            child: Text(status),
                                          ))
                                      .toList(),
                                  onChanged: (val) {
                                    setState(() => _absenStatus[s.idJamaah!] = val!);
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                ),

                // Tombol simpan
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TombolUtama(
                    text: 'Simpan Absensi',
                    onPressed: _handleSave,
                    isLoading: _isSaving,
                  ),
                ),
              ],
            ),
    );
  }

  // Warna avatar berdasarkan status
  Color _getAvatarColor(String status) {
    switch (status) {
      case 'Hadir':
        return AppColors.primary;
      case 'Alpa':
        return AppColors.red;
      case 'Izin':
        return AppColors.yellow;
      case 'Sakit':
        return Colors.blue;
      default:
        return AppColors.muted;
    }
  }

  // Warna background dropdown status
  Color _getStatusBgColor(String status) {
    switch (status) {
      case 'Hadir':
        return AppColors.primaryLight;
      case 'Alpa':
        return AppColors.redLight;
      case 'Izin':
        return AppColors.yellowLight;
      case 'Sakit':
        return Colors.blue.shade50;
      default:
        return AppColors.background;
    }
  }

  // Warna teks status
  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'Hadir':
        return AppColors.primary;
      case 'Alpa':
        return AppColors.red;
      case 'Izin':
        return AppColors.yellow;
      case 'Sakit':
        return Colors.blue;
      default:
        return AppColors.text;
    }
  }
}
