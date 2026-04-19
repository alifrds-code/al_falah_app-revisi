import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';
import '../../widgets/tombol_utama.dart';
import '../../widgets/form_isian.dart';
import '../../widgets/tampilan_kosong.dart';
import '../../controllers/admin_controller.dart';
import '../../models/model_pengumuman.dart';
import '../../models/model_acara.dart';

// Layar kelola pengumuman dan acara oleh Admin
class KelolaInfo extends StatefulWidget {
  const KelolaInfo({super.key});

  @override
  State<KelolaInfo> createState() => _KelolaInfoState();
}

class _KelolaInfoState extends State<KelolaInfo> with SingleTickerProviderStateMixin {
  final AdminController _controller = AdminController();
  late TabController _tabController;

  List<PengumumanModel> _pengumuman = [];
  List<AcaraModel> _acara = [];
  bool _isLoading = true;

  // Controller form pengumuman
  final TextEditingController _annTitleCtrl = TextEditingController();
  final TextEditingController _annBodyCtrl = TextEditingController();

  // Controller form acara
  final TextEditingController _evtNameCtrl = TextEditingController();
  final TextEditingController _evtDescCtrl = TextEditingController();
  final TextEditingController _evtDateCtrl = TextEditingController();
  final TextEditingController _evtTimeCtrl = TextEditingController();
  final TextEditingController _evtLocCtrl = TextEditingController();
  final TextEditingController _evtSpeakerCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _annTitleCtrl.dispose();
    _annBodyCtrl.dispose();
    _evtNameCtrl.dispose();
    _evtDescCtrl.dispose();
    _evtDateCtrl.dispose();
    _evtTimeCtrl.dispose();
    _evtLocCtrl.dispose();
    _evtSpeakerCtrl.dispose();
    super.dispose();
  }

  void _loadData() async {
    final dataPengumuman = await _controller.getPengumuman();
    final dataAcara = await _controller.getAcara();
    setState(() {
      _pengumuman = dataPengumuman;
      _acara = dataAcara;
      _isLoading = false;
    });
  }

  // Simpan pengumuman baru
  void _handleSaveAnn() async {
    if (_annTitleCtrl.text.isEmpty || _annBodyCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Judul dan isi wajib diisi')),
      );
      return;
    }
    await _controller.postAnnouncement(_annTitleCtrl.text.trim(), _annBodyCtrl.text.trim());
    _annTitleCtrl.clear();
    _annBodyCtrl.clear();
    if (mounted) {
      Navigator.pop(context);
      _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengumuman berhasil diposting')),
      );
    }
  }

  // Hapus pengumuman
  void _confirmDeleteAnn(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Pengumuman?'),
        content: const Text('Pengumuman ini akan dihapus permanen.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              await _controller.deleteAnnouncement(id);
              if (mounted) {
                Navigator.pop(context);
                _loadData();
              }
            },
            child: const Text('Hapus', style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
  }

  // Simpan acara baru
  void _handleSaveEvt() async {
    if (_evtNameCtrl.text.isEmpty || _evtDateCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama acara dan tanggal wajib diisi')),
      );
      return;
    }
    final acara = AcaraModel(
      namaAcara: _evtNameCtrl.text.trim(),
      deskripsi: _evtDescCtrl.text.trim(),
      tanggalAcara: _evtDateCtrl.text.trim(),
      waktu: _evtTimeCtrl.text.trim(),
      lokasi: _evtLocCtrl.text.trim(),
      namaPemateri: _evtSpeakerCtrl.text.trim(),
    );
    await _controller.postEvent(acara);
    _evtNameCtrl.clear();
    _evtDescCtrl.clear();
    _evtDateCtrl.clear();
    _evtTimeCtrl.clear();
    _evtLocCtrl.clear();
    _evtSpeakerCtrl.clear();
    if (mounted) {
      Navigator.pop(context);
      _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kegiatan berhasil diposting')),
      );
    }
  }

  // Hapus acara
  void _confirmDeleteEvt(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Acara?'),
        content: const Text('Data acara ini akan dihapus permanen.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              await _controller.deleteEvent(id);
              if (mounted) {
                Navigator.pop(context);
                _loadData();
              }
            },
            child: const Text('Hapus', style: TextStyle(color: AppColors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Kelola Info & Agenda'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Pengumuman'),
            Tab(text: 'Acara'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // TAB 1: Pengumuman
                _buildPengumumanTab(),
                // TAB 2: Acara
                _buildAcaraTab(),
              ],
            ),
    );
  }

  // Tab daftar pengumuman
  Widget _buildPengumumanTab() {
    return Column(
      children: [
        // Tombol buat pengumuman baru
        Padding(
          padding: const EdgeInsets.all(16),
          child: TombolUtama(
            text: 'Buat Pengumuman Baru',
            onPressed: () => _showAnnForm(context),
          ),
        ),
        // Daftar pengumuman
        Expanded(
          child: _pengumuman.isEmpty
              ? const TampilanKosong(
                  pesan: 'Belum ada pengumuman yang diposting',
                  icon: Icons.campaign_outlined,
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _pengumuman.length,
                  itemBuilder: (context, index) {
                    final p = _pengumuman[index];
                    return _buildPengumumanCard(p);
                  },
                ),
        ),
      ],
    );
  }

  // Kartu satu pengumuman
  Widget _buildPengumumanCard(PengumumanModel p) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  p.judul,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _confirmDeleteAnn(p.idPengumuman!),
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.red, size: 20),
              ),
            ],
          ),
          Text(
            p.isiTeks,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, color: AppColors.muted),
          ),
          const SizedBox(height: 8),
          Text(
            p.tanggalPost.substring(0, 10),
            style: const TextStyle(fontSize: 11, color: AppColors.muted),
          ),
        ],
      ),
    );
  }

  // Tab daftar acara
  Widget _buildAcaraTab() {
    return Column(
      children: [
        // Tombol buat acara baru
        Padding(
          padding: const EdgeInsets.all(16),
          child: TombolUtama(
            text: 'Buat Agenda Baru',
            onPressed: () => _showEvtForm(context),
          ),
        ),
        // Daftar acara
        Expanded(
          child: _acara.isEmpty
              ? const TampilanKosong(
                  pesan: 'Belum ada acara yang dijadwalkan',
                  icon: Icons.event_outlined,
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _acara.length,
                  itemBuilder: (context, index) {
                    final a = _acara[index];
                    return _buildAcaraCard(a);
                  },
                ),
        ),
      ],
    );
  }

  // Kartu satu acara
  Widget _buildAcaraCard(AcaraModel a) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  a.namaAcara,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _confirmDeleteEvt(a.idAcara!),
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.red, size: 20),
              ),
            ],
          ),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.muted),
              const SizedBox(width: 4),
              Text(
                '${a.tanggalAcara} • ${a.waktu}',
                style: const TextStyle(fontSize: 12, color: AppColors.muted),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 14, color: AppColors.muted),
              const SizedBox(width: 4),
              Text(
                a.lokasi,
                style: const TextStyle(fontSize: 12, color: AppColors.muted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Form buat pengumuman baru (muncul dari bawah)
  void _showAnnForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Posting Pengumuman',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              FormIsian(
                label: 'Judul Pengumuman',
                hint: 'Ketik judul pengumuman',
                controller: _annTitleCtrl,
              ),
              const SizedBox(height: 16),
              FormIsian(
                label: 'Isi Pengumuman',
                hint: 'Ketik isi pesan...',
                controller: _annBodyCtrl,
                maxLines: 4,
              ),
              const SizedBox(height: 32),
              TombolUtama(text: 'Posting Sekarang', onPressed: _handleSaveAnn),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // Form buat acara baru (muncul dari bawah)
  void _showEvtForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Buat Agenda Baru',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              FormIsian(
                label: 'Nama Kegiatan',
                hint: 'Wisuda Tahfidz / Tabligh Akbar',
                controller: _evtNameCtrl,
              ),
              const SizedBox(height: 16),
              FormIsian(
                label: 'Deskripsi',
                hint: 'Ketik detail acara...',
                controller: _evtDescCtrl,
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FormIsian(
                      label: 'Tanggal',
                      hint: '2026-04-20',
                      controller: _evtDateCtrl,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FormIsian(
                      label: 'Waktu',
                      hint: '08:00 WIB',
                      controller: _evtTimeCtrl,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FormIsian(
                label: 'Lokasi',
                hint: 'Masjid Al Falah / Aula',
                controller: _evtLocCtrl,
              ),
              const SizedBox(height: 16),
              FormIsian(
                label: 'Pemateri / Pengisi',
                hint: 'Ust. Ahmad...',
                controller: _evtSpeakerCtrl,
              ),
              const SizedBox(height: 32),
              TombolUtama(text: 'Posting Agenda', onPressed: _handleSaveEvt),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
