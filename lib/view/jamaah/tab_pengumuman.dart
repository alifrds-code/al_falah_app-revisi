import 'package:flutter/material.dart';
import 'package:al_falah_app/controllers/jamaah_controller.dart';
import 'package:al_falah_app/utils/app_colors.dart';
import 'dart:convert';

class TabPengumumanJamaah extends StatefulWidget {
  const TabPengumumanJamaah({super.key});

  @override
  State<TabPengumumanJamaah> createState() => _TabPengumumanJamaahState();
}

class _TabPengumumanJamaahState extends State<TabPengumumanJamaah> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _pengumumanList = [];
  List<Map<String, dynamic>> _acaraList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final pengumuman = await JamaahController.ambilPengumuman();
    final acara = await JamaahController.ambilAcara();

    if (mounted) {
      setState(() {
        _pengumumanList = pengumuman;
        _acaraList = acara;
        _isLoading = false;
      });
    }
  }

  void _bukaDetail(String tipe, Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(10)),
                ),
              ),
              if (tipe == 'pengumuman') ...[
                Text(
                  data['judul'] ?? '-',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textHeading),
                ),
                const SizedBox(height: 8),
                Text(
                  'Diterbitkan: ${data['tanggal_dibuat'] ?? '-'}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSubtitle),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      data['isi'] ?? '',
                      style: const TextStyle(fontSize: 14, color: AppColors.textBody, height: 1.6),
                    ),
                  ),
                ),
              ] else ...[
                // ACARA
                if ((data['url_poster'] ?? '').isNotEmpty)
                  Container(
                    height: 200,
                    margin: const EdgeInsets.only(bottom: 16),
                    width: double.infinity,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: data['url_poster'].startsWith('http')
                          ? Image.network(data['url_poster'], fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.broken_image))
                          : Image.memory(base64Decode(data['url_poster']), fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.broken_image)),
                    ),
                  ),
                Text(
                  data['nama_acara'] ?? '-',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textHeading),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      data['tanggal'] ?? '-',
                      style: const TextStyle(fontSize: 14, color: AppColors.textBody),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: AppColors.warning),
                    const SizedBox(width: 8),
                    Text(
                      data['waktu'] ?? '-',
                      style: const TextStyle(fontSize: 14, color: AppColors.textBody),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: AppColors.danger),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        data['lokasi'] ?? '-',
                        style: const TextStyle(fontSize: 14, color: AppColors.textBody),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Deskripsi Acara',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textHeading),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      data['deskripsi'] ?? '',
                      style: const TextStyle(fontSize: 14, color: AppColors.textBody, height: 1.5),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('TUTUP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          color: AppColors.surface,
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textHint,
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(text: 'Pengumuman'),
              Tab(text: 'Acara / Kegiatan'),
            ],
          ),
        ),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
              : TabBarView(
                  controller: _tabController,
                  children: [
                    // TAB PENGUMUMAN
                    RefreshIndicator(
                      onRefresh: _loadData,
                      child: _pengumumanList.isEmpty
                          ? ListView(
                              children: [
                                SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                                const Icon(Icons.campaign_outlined, size: 60, color: AppColors.border),
                                const SizedBox(height: 16),
                                const Text('Belum ada pengumuman terbaru.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSubtitle))
                              ],
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(20),
                              itemCount: _pengumumanList.length,
                              itemBuilder: (context, index) {
                                final item = _pengumumanList[index];
                                return Card(
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: const BorderSide(color: AppColors.borderLight),
                                  ),
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: InkWell(
                                    onTap: () => _bukaDetail('pengumuman', item),
                                    borderRadius: BorderRadius.circular(16),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(12)),
                                            child: const Icon(Icons.campaign, color: AppColors.primary),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(item['judul'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                                const SizedBox(height: 4),
                                                Text(
                                                  item['isi'] ?? '',
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: const TextStyle(fontSize: 12, color: AppColors.textBody),
                                                ),
                                                const SizedBox(height: 6),
                                                Text(item['tanggal_dibuat'] ?? '-', style: const TextStyle(fontSize: 10, color: AppColors.textSubtitle)),
                                              ],
                                            ),
                                          ),
                                          const Icon(Icons.chevron_right, color: AppColors.border),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),

                    // TAB ACARA
                    RefreshIndicator(
                      onRefresh: _loadData,
                      child: _acaraList.isEmpty
                          ? ListView(
                              children: [
                                SizedBox(height: MediaQuery.of(context).size.height * 0.25),
                                const Icon(Icons.event_available_outlined, size: 60, color: AppColors.border),
                                const SizedBox(height: 16),
                                const Text('Belum ada acara atau kegiatan tayang.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textSubtitle))
                              ],
                            )
                          : GridView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.68,
                              ),
                              itemCount: _acaraList.length,
                              itemBuilder: (context, index) {
                                final item = _acaraList[index];
                                final urlPoster = item['url_poster'] ?? '';

                                return InkWell(
                                  onTap: () => _bukaDetail('acara', item),
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.surface,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: AppColors.borderLight),
                                      boxShadow: [
                                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                            child: urlPoster.isNotEmpty
                                                ? urlPoster.startsWith('http')
                                                    ? Image.network(urlPoster, fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.broken_image))
                                                    : Image.memory(base64Decode(urlPoster), fit: BoxFit.cover, errorBuilder: (_,__,___) => const Icon(Icons.broken_image))
                                                : Container(color: AppColors.warningLight, child: const Icon(Icons.event_available, color: AppColors.warning, size: 40)),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                item['nama_acara'] ?? '-',
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textHeading),
                                              ),
                                              const SizedBox(height: 6),
                                              Row(
                                                children: [
                                                  const Icon(Icons.calendar_today, size: 10, color: AppColors.textSubtitle),
                                                  const SizedBox(width: 4),
                                                  Expanded(
                                                    child: Text(
                                                      item['tanggal'] ?? '-',
                                                      overflow: TextOverflow.ellipsis,
                                                      style: const TextStyle(fontSize: 10, color: AppColors.textSubtitle),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}
