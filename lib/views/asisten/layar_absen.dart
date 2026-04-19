import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../widgets/tombol_utama.dart';
import '../../controllers/asisten_controller.dart';
import '../../models/model_jamaah.dart';
import '../../models/model_jadwal.dart';
import '../../controllers/login_controller.dart';

// layar buat asisten input siapa aja jamaah yang dateng pas kajian
class LayarAbsen extends StatefulWidget {
  final int idKelas;
  const LayarAbsen({super.key, required this.idKelas});

  @override
  State<LayarAbsen> createState() => _LayarAbsenState();
}

class _LayarAbsenState extends State<LayarAbsen> {
  final AsistenController _controller = AsistenController();
  final LoginController _loginController = LoginController();

  List<JadwalModel> _jadwal = []; // barisan jadwal buat kelas ini
  List<JamaahModel> _students = []; // daftar jamaah yang ada di kelas ini
  // map buat nyimpen status tiap jamaah: id_jamaah -> 'Hadir', 'Alpa', dsb
  final Map<int, String> _absenStatus = {};

  JadwalModel? _selectedJadwal; // jadwal mana nih yang lagi diabsenin
  bool _isLoading = true;
  bool _isSaving = false;

  // buat nyaring nama jamaah kalo daftar-nya kepanjangan
  final TextEditingController _cariCtrl = TextEditingController();
  List<JamaahModel> _studentsTampil = [];

  @override
  void initState() {
    super.initState();
    // pas buka layar langsung loading data-datanya
    _loadData();
    // mantau kalo ada yang ngetik di kotak cari
    _cariCtrl.addListener(_filterStudents);
  }

  @override
  void dispose() {
    _cariCtrl.dispose();
    super.dispose();
  }

  // fungsi buat tarik data asisten, jadwal, sama list jamaah sekaligus
  void _loadData() async {
    final user = await _loginController.getCurrentUser();
    if (user != null) {
      final semuaJadwal = await _controller.getMySchedules(user.idUser!);
      // cuma ambil jadwal yang emang buat kelas ini ya
      final jadwalKelas = semuaJadwal.where((j) => j.idKelas == widget.idKelas).toList();
      final students = await _controller.getJamaahForClass(widget.idKelas);

      setState(() {
        _jadwal = jadwalKelas;
        _students = students;
        _studentsTampil = students;
        // seting awal semuanya gue anggep 'Hadir' dulu biar cepet asistennya
        for (var s in students) {
          _absenStatus[s.idJamaah!] = 'Hadir';
        }
        if (_jadwal.isNotEmpty) _selectedJadwal = _jadwal.first;
        _isLoading = false;
      });

      // kalo ada jadwal, coba cek apa udah pernah diabsen sebelumnya
      if (_jadwal.isNotEmpty) {
        _loadExistingAbsen(_jadwal.first.idJadwal!);
      }
    }
  }

  // kalo ternyata udah pernah diinput absennya, gue tampilin lagi datanya
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

  // fungsi pas asisten nyari nama jamaah di kotak pencarian
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

  // fungsi pas asisten pencet tombol simpan semua absen
  void _handleSave() async {
    // pastiin pilih jadwalnya dulu ya
    if (_selectedJadwal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih jadwal terlebih dahulu')),
      );
      return;
    }

    setState(() => _isSaving = true);

    // bungkus data absen semua jamaah jadi satu list buat dikirim ke controller
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
                // bagian pilih jadwal sama kotak cari di atas
                Container(
                  padding: const EdgeInsets.all(16),
                  color: AppColors.background,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pilih Jadwal Pertemuan',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // kalo jadwal belum ada, ingetin asistennya
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
                                    // balikin lagi ke settingan awal (Hadir)
                                    for (var s in _students) {
                                      _absenStatus[s.idJamaah!] = 'Hadir';
                                    }
                                  });
                                  // kalo ganti jadwal, liat apa jadwal ini udah pernah diabsen belom
                                  if (val != null) _loadExistingAbsen(val.idJadwal!);
                                },
                              ),
                            ),
                      const SizedBox(height: 12),
                      // kotak buat asisten cari nama jamaah
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

                // buat nampilin total berapa orang yang hadir
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

                // list daftar jamaah buat diabsen satu-satu
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
                              // buletan inisial jamaah
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
                                s.noHp ?? 'Gak ada nomor HP',
                                style: const TextStyle(fontSize: 12),
                              ),
                              // milih status (hadir, alpa, izin, sakit) pake dropdown kecil
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

                // tombol buat nge-save semua data absen ke database
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

  // fungsi buat nentuin warna buletan sesuai statusnya
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

  // fungsi buat nentuin warna background kotak status
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

  // fungsi buat nentuin warna teks status biar jelas dibaca
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
