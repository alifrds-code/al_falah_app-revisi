import 'package:flutter/material.dart';
import 'package:al_falah_app/controllers/kelas_controller.dart';
import 'package:al_falah_app/controllers/admin_controller.dart'; // Buat narik data ustadz
import 'package:al_falah_app/models/model_kelas.dart';
import 'package:al_falah_app/models/model_user.dart'; // Buat model ustadz

// IMPORT GUDANG DESAIN KITA
import 'package:al_falah_app/utils/app_colors.dart';
import 'package:al_falah_app/widgets/form_isian.dart';

class FormKelas extends StatefulWidget {
  // KANTONG DATA: Buat nangkep data kelas lama kalau dari tombol Edit
  final Map<String, dynamic>? kelasLama;

  const FormKelas({Key? key, this.kelasLama}) : super(key: key);

  @override
  State<FormKelas> createState() => _FormKelasState();
}

class _FormKelasState extends State<FormKelas> {
  // 1. Kunci Rahasia Form (Buat fitur validasi ala Play Store)
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaKelasController = TextEditingController();

  bool _isLoading = false;

  // VARIABEL SAKTI: Ngecek apakah ini lagi mode Edit atau bukan
  bool get isEdit => widget.kelasLama != null;

  // Penampung daftar ustadz buat dropdown
  List<UserModel> _daftarAsisten = [];
  int? _selectedIdAsisten; // Nyimpen ID ustadz yang dipilih

  @override
  void initState() {
    super.initState();
    // Kalau mode Edit, otomatis isi nama kelasnya
    if (isEdit) {
      _namaKelasController.text = widget.kelasLama!['nama_kelas'];
    }
    // Langsung narik daftar ustadz pas halaman dibuka
    _loadDaftarAsisten();
  }

  // Fungsi narik data asisten buat menu Dropdown
  void _loadDaftarAsisten() async {
    final asisten = await AdminController.getSemuaAsisten();
    setState(() {
      _daftarAsisten = asisten;
      // Kalau lagi mode edit dan kelas ini udah punya ustadz, langsung pilih ustadznya
      if (isEdit && widget.kelasLama!['id_asisten'] != null) {
        _selectedIdAsisten = widget.kelasLama!['id_asisten'];
      }
    });
  }

  void _simpanKelas() async {
    // 2. Cek apakah formnya udah diisi dengan bener?
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        if (isEdit) {
          // ==========================================
          // MODE EDIT: UPDATE KELAS & ASSIGN USTADZ
          // ==========================================
          // Bikin model datanya
          // Sesuaikan parameter ini dengan kodingan model_kelas.dart lu ya
          KelasModel kelasUpdate = KelasModel(
            idKelas: widget.kelasLama!['id_kelas'], // ID Wajib ada buat edit
            namaKelas: _namaKelasController.text.trim(),
            idAsisten:
                _selectedIdAsisten, // ID Ustadz yang dipilih dari dropdown
          );

          // Lempar ke controller buat diupdate ke SQLite
          // (Pastikan lu udah bikin fungsi updateKelas di KelasController ya Bro!)
          await KelasController.updateKelas(kelasUpdate);
        } else {
          // ==========================================
          // MODE TAMBAH BARU (CUMA NAMA KELAS)
          // ==========================================
          KelasModel kelasBaru = KelasModel(
            namaKelas: _namaKelasController.text.trim(),
            // idAsisten dikosongin dulu sesuai rencana lu
          );

          // Lempar ke controller buat disimpen ke SQLite
          await KelasController.tambahKelas(kelasBaru);
        }

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEdit
                  ? 'Mantap! Kelas berhasil diupdate.'
                  : 'Mantap! Kelas baru berhasil dibuat.',
            ),
            backgroundColor: AppColors.primary, // Emerald
          ),
        );

        // 3. Tutup halaman form dan balik ke halaman sebelumnya
        Navigator.pop(context, true);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e'),
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
      backgroundColor:
          AppColors.background, // Background abu-abu muda biar cardnya keliatan
      appBar: AppBar(
        title: Text(
          isEdit ? 'Update Master Kelas' : 'Buat Master Kelas',
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
          key: _formKey, // Pasang kunci form di sini
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // PANEL FORM (Biar gak keliatan melompong / kosong di layar putih)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface, // Kotak putih
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
                    // Header Form
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: AppColors.primaryLight,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isEdit ? Icons.edit : Icons.class_outlined,
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
                                    ? 'Detail Kelas & Asisten'
                                    : 'Informasi Kelas',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textHeading,
                                ),
                              ),
                              Text(
                                isEdit
                                    ? 'Pilih Asisten yang akan melola kelass ini'
                                    : 'Masukkan nama kelas yang akan dibuat',
                                style: const TextStyle(
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

                    // Kotak Input Pake Cetakan FormIsian
                    FormIsian(
                      controller: _namaKelasController,
                      labelText: 'Nama Kelas (Contoh: MT Samawa)',
                      prefixIcon: Icons.edit_note,
                      // Ini pesan error merah yang muncul otomatis kalau kosong
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama kelas tidak boleh kosong!';
                        }
                        return null;
                      },
                    ),

                    // ==========================================
                    // DROPDOWN MUNCUL KHUSUS MODE EDIT AJA!
                    // ==========================================
                    if (isEdit) ...[
                      const SizedBox(height: 16),
                      // Ubah tipe datanya jadi int? (pake tanda tanya)
                      DropdownButtonFormField<int?>(
                        value: _selectedIdAsisten,
                        hint: const Text(
                          'Pilih Ustadz / Asisten',
                          style: TextStyle(
                            color: AppColors.textHint,
                            fontSize: 14,
                          ),
                        ),
                        decoration: InputDecoration(
                          labelText: 'Ustadz Pengajar',
                          labelStyle: const TextStyle(
                            color: AppColors.textSubtitle,
                          ),
                          prefixIcon: const Icon(
                            Icons.person,
                            color: AppColors.textHint,
                            size: 20,
                          ),
                          filled: true,
                          fillColor: AppColors.surface,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                        ),
                        // KITA TAMBAHIN OPSI KOSONG DI PALING ATAS
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text(
                              '-- Kosongkan Asisten --',
                              style: TextStyle(
                                color: AppColors.danger,
                                fontStyle: FontStyle.italic,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          // Baru dilanjut sama daftar asisten dari database
                          ..._daftarAsisten.map((asisten) {
                            return DropdownMenuItem<int?>(
                              value: asisten.idUser,
                              child: Text(
                                asisten.nama,
                                style: const TextStyle(
                                  color: AppColors.textHeading,
                                  fontSize: 14,
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedIdAsisten = value;
                          });
                        },
                      ),
                    ],

                    const SizedBox(height: 32),

                    // Tombol Simpan
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
                        onPressed: _isLoading ? null : _simpanKelas,
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
                                isEdit ? 'UPDATE KELAS' : 'SIMPAN KELAS',
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

              // Sedikit Info Tambahan di luar kotak
              if (!isEdit)
                const Padding(
                  padding: EdgeInsets.only(top: 24, left: 8, right: 8),
                  child: Text(
                    'Catatan: Setelah kelas dibuat, Anda dapat menugaskan Ustadz/Asisten ke kelas ini melalui menu Edit.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textHint,
                      height: 1.5,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
