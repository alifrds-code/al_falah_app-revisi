import 'package:flutter/material.dart';
import 'package:al_falah_app/controllers/jamaah_controller.dart';
import 'package:al_falah_app/controllers/kelas_controller.dart';
import 'package:al_falah_app/controllers/admin_controller.dart';
import 'package:al_falah_app/models/model_user.dart';
import 'package:al_falah_app/utils/app_colors.dart';

class DetailKelas extends StatefulWidget {
  final Map<String, dynamic> kelas;

  const DetailKelas({Key? key, required this.kelas}) : super(key: key);

  @override
  State<DetailKelas> createState() => _DetailKelasState();
}

class _DetailKelasState extends State<DetailKelas> {
  late Map<String, dynamic> _dataKelas;

  @override
  void initState() {
    super.initState();
    _dataKelas = Map<String, dynamic>.from(widget.kelas);
  }

  Future<List<Map<String, dynamic>>> _loadJamaahKelas() async {
    return await JamaahController.getJamaahBerdasarkanKelas(
      _dataKelas['id_kelas'],
    );
  }

  void _tampilDetailAsisten(BuildContext context, int idAsisten) async {
    final listAsisten = await AdminController.getSemuaAsisten();
    final UserModel? asistenLengkap = listAsisten.firstWhere(
      (a) => a.idUser == idAsisten,
      orElse: () => UserModel(
        nama: 'Error',
        email: 'Tidak ditemukan',
        password: '',
        role: 'asisten',
      ),
    );

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  color: AppColors.primary,
                  size: 48,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                asistenLengkap!.nama,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textHeading,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.infoLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'ASISTEN KELAS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.info,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.email_outlined,
                      color: AppColors.textSubtitle,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Email Terdaftar',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSubtitle,
                            ),
                          ),
                          Text(
                            asistenLengkap.email,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textHeading,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Tutup',
                    style: TextStyle(
                      color: AppColors.textSubtitle,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _tampilDetailJamaah(BuildContext context, Map<String, dynamic> jamaah) {
    bool isLaki = jamaah['jenis_kelamin'] == 'Laki-laki';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isLaki ? Colors.blue[50] : Colors.pink[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isLaki ? Icons.face : Icons.face_3,
                  color: isLaki ? Colors.blue : Colors.pink,
                  size: 48,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                jamaah['nama_lengkap'],
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textHeading,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.wc,
                          color: AppColors.textSubtitle,
                          size: 20,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Jenis Kelamin',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSubtitle,
                                ),
                              ),
                              Text(
                                jamaah['jenis_kelamin'],
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textHeading,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24, color: AppColors.borderLight),
                    Row(
                      children: [
                        const Icon(
                          Icons.phone,
                          color: AppColors.textSubtitle,
                          size: 20,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Nomor WhatsApp',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSubtitle,
                                ),
                              ),
                              Text(
                                jamaah['no_hp'] ?? '-',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textHeading,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24, color: AppColors.borderLight),
                    Row(
                      children: [
                        const Icon(
                          Icons.home,
                          color: AppColors.textSubtitle,
                          size: 20,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Alamat',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSubtitle,
                                ),
                              ),
                              Text(
                                jamaah['alamat'],
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textHeading,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Tutup',
                    style: TextStyle(
                      color: AppColors.textSubtitle,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _konfirmasiCopotAsisten() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Copot Asisten?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Yakin mau mencopot ${_dataKelas['nama_asisten']} dari kelas ini?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Batal',
              style: TextStyle(color: AppColors.textSubtitle),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () async {
              Navigator.pop(context);
              await KelasController.copotAsisten(_dataKelas['id_kelas']);
              setState(() {
                _dataKelas['nama_asisten'] = null;
                _dataKelas['id_asisten'] = null;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Asisten berhasil dicopot!'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            child: const Text(
              'Ya, Copot',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _konfirmasiKeluarkanJamaah(Map<String, dynamic> jamaah) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Keluarkan Jamaah?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Yakin mau mengeluarkan ${jamaah['nama_lengkap']} dari kelas ini? (Data jamaah tidak akan dihapus, hanya status kelasnya dicabut)',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Batal',
              style: TextStyle(color: AppColors.textSubtitle),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () async {
              Navigator.pop(context);
              await JamaahController.keluarkanDariKelas(jamaah['id_jamaah']);
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Jamaah dikeluarkan dari kelas!'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            child: const Text(
              'Ya, Keluarkan',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _tampilPopUpPilihJamaah() {
    int? selectedIdJamaah;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const Text(
                    'Pilih Jamaah',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textHeading,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Pilih jamaah yang belum memiliki kelas untuk dimasukkan ke kelas ini.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSubtitle,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // FUTURE.WAIT UNTUK MENARIK 2 DATA
                  // 1. Data Jamaah TANPA KELAS
                  // 2. Total Semua Jamaah di Database
                  FutureBuilder<List<dynamic>>(
                    future: Future.wait([
                      JamaahController.getJamaahTanpaKelas(),
                      JamaahController.getHitungTotalJamaah(),
                    ]),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        );
                      }

                      final listNganggur =
                          snapshot.data![0] as List<Map<String, dynamic>>;
                      final totalJamaah = snapshot.data![1] as int;

                      // KONDISI 1: DATABASE EMANG KOSONG MELOMPONG
                      if (totalJamaah == 0) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.dangerLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Data jamaah masih kosong!\nSilakan tambah data jamaah baru di menu Kelola Jamaah terlebih dahulu.',
                            style: TextStyle(
                              color: AppColors.danger,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }

                      // KONDISI 2: ADA JAMAAH, TAPI SEMUANYA UDAH PUNYA KELAS
                      if (listNganggur.isEmpty) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.dangerLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Semua jamaah saat ini sudah terdaftar di kelas lain.\nSilakan tambah data jamaah baru jika ingin memasukkan ke kelas ini.',
                            style: TextStyle(
                              color: AppColors.danger,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }

                      // KONDISI 3: AMAN, TAMPILKAN DROPDOWN
                      return DropdownButtonFormField<int?>(
                        value: selectedIdJamaah,
                        hint: const Text(
                          'Pilih nama jamaah...',
                          style: TextStyle(
                            color: AppColors.textHint,
                            fontSize: 14,
                          ),
                        ),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(
                            Icons.person_add,
                            color: AppColors.textHint,
                            size: 20,
                          ),
                          filled: true,
                          fillColor: AppColors.background,
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
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text(
                              '-- Batal Pilih --',
                              style: TextStyle(
                                color: AppColors.textSubtitle,
                                fontStyle: FontStyle.italic,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          ...listNganggur.map((j) {
                            return DropdownMenuItem<int?>(
                              value: j['id_jamaah'],
                              child: Text(
                                j['nama_lengkap'],
                                style: const TextStyle(
                                  color: AppColors.textHeading,
                                  fontSize: 14,
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                        onChanged: (val) {
                          setModalState(() {
                            selectedIdJamaah = val;
                          });
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // TOMBOL SUBMIT
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: selectedIdJamaah == null
                          ? null
                          : () async {
                              Navigator.pop(context);
                              await JamaahController.assignKelas(
                                selectedIdJamaah!,
                                _dataKelas['id_kelas'],
                              );
                              setState(() {});
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Mantap! Jamaah berhasil dimasukkan ke kelas.',
                                  ),
                                  backgroundColor: AppColors.primary,
                                ),
                              );
                            },
                      child: const Text(
                        'MASUKKAN KE KELAS',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String namaAsisten =
        _dataKelas['nama_asisten'] ?? "Belum ada asisten kelas";
    bool adaUstadz = _dataKelas['nama_asisten'] != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Detail Kelas',
          style: TextStyle(
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

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text(
          'Pilih Jamaah',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onPressed: _tampilPopUpPilihJamaah,
      ),

      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _loadJamaahKelas(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          if (snapshot.hasError)
            return Center(child: Text('Waduh error: ${snapshot.error}'));

          final daftarJamaah = snapshot.data ?? [];
          final int totalJamaah = daftarJamaah.length;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  border: const Border(
                    bottom: BorderSide(color: AppColors.borderLight),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: AppColors.warningLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.class_,
                        color: AppColors.warning,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _dataKelas['nama_kelas'],
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textHeading,
                      ),
                    ),
                    const SizedBox(height: 20),

                    InkWell(
                      onTap: adaUstadz
                          ? () => _tampilDetailAsisten(
                              context,
                              _dataKelas['id_asisten'],
                            )
                          : null,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderLight),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: adaUstadz
                                    ? AppColors.primaryLight
                                    : AppColors.dangerLight,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.person,
                                color: adaUstadz
                                    ? AppColors.primary
                                    : AppColors.danger,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Asisten Kelas',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSubtitle,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    namaAsisten,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: adaUstadz
                                          ? AppColors.textHeading
                                          : AppColors.danger,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (adaUstadz)
                              IconButton(
                                icon: const Icon(
                                  Icons.remove_circle_outline,
                                  color: AppColors.danger,
                                ),
                                onPressed: _konfirmasiCopotAsisten,
                                tooltip: 'Copot Asisten',
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Daftar Jamaah',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textHeading,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.infoLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Total: $totalJamaah Orang',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.info,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: daftarJamaah.isEmpty
                    ? const Center(
                        child: Text(
                          'Belum ada jamaah di kelas ini.\nKlik tombol di bawah buat milih jamaah.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSubtitle,
                            fontSize: 14,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        itemCount: totalJamaah,
                        itemBuilder: (context, index) {
                          final jamaah = daftarJamaah[index];
                          bool isLaki = jamaah['jenis_kelamin'] == 'Laki-laki';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.borderLight),
                            ),
                            child: ListTile(
                              onTap: () => _tampilDetailJamaah(context, jamaah),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isLaki
                                      ? Colors.blue[50]
                                      : Colors.pink[50],
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isLaki ? Icons.person : Icons.person_3,
                                  color: isLaki ? Colors.blue : Colors.pink,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                jamaah['nama_lengkap'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: AppColors.textHeading,
                                ),
                              ),
                              subtitle: Text(
                                jamaah['no_hp'] ?? '-',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSubtitle,
                                ),
                              ),
                              trailing: IconButton(
                                icon: const Icon(
                                  Icons.do_not_disturb_on_outlined,
                                  color: AppColors.danger,
                                ),
                                onPressed: () =>
                                    _konfirmasiKeluarkanJamaah(jamaah),
                                tooltip: 'Keluarkan dari Kelas',
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
