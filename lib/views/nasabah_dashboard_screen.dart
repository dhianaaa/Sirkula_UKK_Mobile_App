// views/nasabah/nasabah_home_screen.dart
//
// Dashboard Nasabah SIRKULA yang terintegrasi penuh dengan backend REST API:
// - Header sapaan riil + lokasi riil + lonceng notifikasi dinamis
// - Hero Card Saldo Poin riil dari server dengan tombol aksi (+ Setor, Tukar, Tarik)
// - Kartu Dampak Lingkungan (CO2 & Pohon) terhitung riil dari total sampah disetor
// - Kartu Penjemputan Dijadwalkan dari pengajuan setor aktif (atau status informatif)
// - Grid Menu Utama (Jemput Sampah, Katalog Harga, Drop Point, Edukasi Pilah)
// - Harga Sampah Hari Ini riil dari GET /api/v1/kategori-sampah
// - Banner Edukasi "Tips Sirkuler: Pilah Bersih, Poin Berlebih!"
// - Aktivitas Terakhir dari histori transaksi riil nasabah
// - Bottom Navigation Bar 5 item dengan tombol daur ulang di tengah

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sirkula_banksampah/config/app_theme.dart';
import 'package:sirkula_banksampah/models/dashboard_summary_model.dart';
import 'package:sirkula_banksampah/models/response_data_map.dart';
import 'package:sirkula_banksampah/models/user_login_model.dart';
import 'package:sirkula_banksampah/services/auth_services.dart';
import 'package:sirkula_banksampah/services/dashboard_service.dart';
import 'package:sirkula_banksampah/services/storage_services.dart';
import 'package:sirkula_banksampah/widgets/bottom_navbar.dart';

class NasabahHomeScreen extends StatefulWidget {
  const NasabahHomeScreen({super.key});

  @override
  State<NasabahHomeScreen> createState() => _NasabahHomeScreenState();
}

class _NasabahHomeScreenState extends State<NasabahHomeScreen> {
  final StorageService _storage = StorageService();
  final DashboardService _dashboardService = DashboardService();
  final AuthService _authService = AuthService();

  UserLoginModel? _user;
  DashboardSummaryModel _summary = DashboardSummaryModel();
  List<Map<String, dynamic>> _kategoriList = [];
  List<Map<String, dynamic>> _mySetorList = [];
  List<Map<String, dynamic>> _myPenukaranList = [];
  bool _isLoading = true;

  final NumberFormat _currencyFormat = NumberFormat('#,###', 'id_ID');

  @override
  void initState() {
    super.initState();
    _refreshAll();
  }

  Future<void> _refreshAll() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      // 1. Muat session user lokal terlebih dahulu
      final localUser = await _storage.getUserLogin();
      if (mounted) setState(() => _user = localUser);

      // Coba refresh profil dari server di background untuk memastikan saldo/alamat teranyar
      _authService.getProfile().then((res) async {
        if (res.status && mounted) {
          final refreshed = await _storage.getUserLogin();
          setState(() => _user = refreshed);
        }
      }).catchError((_) {});

      // 2. Muat data riil dari backend secara paralel
      final results = await Future.wait([
        _dashboardService.getSummary(),
        _dashboardService.getKategoriSampah(),
        _dashboardService.getMySetor(),
        _dashboardService.getMyPenukaran(),
      ]);

      if (!mounted) return;

      final summaryRes = results[0] as ResponseDataMap;
      final katList = results[1] as List<Map<String, dynamic>>;
      final setorList = results[2] as List<Map<String, dynamic>>;
      final penukaranList = results[3] as List<Map<String, dynamic>>;

      DashboardSummaryModel summary = _summary;
      if (summaryRes.status) {
        summary = DashboardSummaryModel.fromJson(
          summaryRes.data?.cast<String, dynamic>(),
        );
      }

      setState(() {
        _summary = summary;
        _kategoriList = katList;
        _mySetorList = setorList;
        _myPenukaranList = penukaranList;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Format tanggal ramah pengguna
  String _formatDateStr(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'Hari ini';
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 60 && diff.inMinutes >= 0) {
        return '${diff.inMinutes == 0 ? 1 : diff.inMinutes} menit lalu';
      } else if (diff.inHours < 24 && diff.inHours >= 0) {
        return '${diff.inHours} jam lalu';
      } else if (diff.inDays == 1) {
        return 'Kemarin, ${DateFormat('HH:mm').format(dt)} WIB';
      } else {
        return '${DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(dt)} WIB';
      }
    } catch (_) {
      return dateStr;
    }
  }

  /// Membangun daftar notifikasi dinamis berbasis status riil penyetoran & penukaran nasabah
  List<Map<String, dynamic>> _getRealNotifications() {
    final List<Map<String, dynamic>> notifs = [];

    // Notifikasi dari transaksi setoran sampah
    for (var s in _mySetorList) {
      final status = s['status']?.toString() ?? '';
      final kode = s['kodeSetor'] ?? '';
      final berat = s['totalBeratKg'] ?? 0;
      final poin = s['totalPoin'] ?? 0;
      final tgl = s['tanggal']?.toString() ?? s['createdAt']?.toString();
      final formattedTime = _formatDateStr(tgl);

      if (status == 'menunggu_konfirmasi') {
        notifs.add({
          'icon': Icons.schedule_rounded,
          'color': const Color(0xFFD97706),
          'bg': const Color(0xFFFEF3C7),
          'title': 'Pengajuan Setor Dalam Antrean',
          'desc':
              'Setoran #$kode ($berat Kg) telah tercatat dan menunggu konfirmasi petugas.',
          'time': formattedTime,
        });
      } else if (status == 'diverifikasi') {
        notifs.add({
          'icon': Icons.local_shipping_outlined,
          'color': const Color(0xFF0284C7),
          'bg': const Color(0xFFE0F2FE),
          'title': 'Penjemputan / Penimbangan Berlangsung',
          'desc':
              'Petugas sedang memverifikasi & menimbang setoran sampah #$kode.',
          'time': formattedTime,
        });
      } else if (status == 'selesai') {
        notifs.add({
          'icon': Icons.savings_outlined,
          'color': const Color(0xFF15803D),
          'bg': const Color(0xFFDCFCE7),
          'title': 'Poin Berhasil Ditambahkan',
          'desc':
              'Setoran #$kode selesai. +$poin Poin berhasil ditambahkan ke saldo Anda.',
          'time': formattedTime,
        });
      }
    }

    // Notifikasi dari transaksi penukaran hadiah
    for (var p in _myPenukaranList) {
      final kode = p['kodePenukaran'] ?? '';
      final poin = p['poinTerpakai'] ?? 0;
      final hadiah = p['hadiah'] is Map ? p['hadiah']['namaHadiah'] : 'Hadiah';
      final tgl = p['tanggal']?.toString() ?? p['createdAt']?.toString();
      final formattedTime = _formatDateStr(tgl);

      notifs.add({
        'icon': Icons.card_giftcard_rounded,
        'color': const Color(0xFF7C3AED),
        'bg': const Color(0xFFF3E8FF),
        'title': 'Penukaran Poin Berhasil',
        'desc':
            'Penukaran voucher/hadiah "$hadiah" (-$poin Poin) dengan kode #$kode.',
        'time': formattedTime,
      });
    }

    return notifs;
  }

  void _showNotificationsDialog() {
    final notifs = _getRealNotifications();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Notifikasi",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (notifs.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 9, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "${notifs.length} Terbaru",
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (notifs.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.notifications_none_rounded,
                            size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 10),
                        const Text(
                          "Belum Ada Notifikasi Baru",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4B5563),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Aktivitas penyetoran sampah dan penukaran poin Anda akan muncul di sini.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: notifs.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final n = notifs[index];
                      return _buildNotificationItem(
                        icon: n['icon'] as IconData,
                        color: n['color'] as Color,
                        bg: n['bg'] as Color,
                        title: n['title'] as String,
                        desc: n['desc'] as String,
                        time: n['time'] as String,
                      );
                    },
                  ),
                ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationItem({
    required IconData icon,
    required Color color,
    required Color bg,
    required String title,
    required String desc,
    required String time,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11.5,
                  color: AppColors.textSecondary,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showActionNotice(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: Color(0xFF4B5563),
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F5A36),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// Modal detail transaksi setoran
  void _showSetorDetailDialog(Map<String, dynamic> item) {
    final kode = item['kodeSetor'] ?? '-';
    final tgl = _formatDateStr(item['tanggal']?.toString());
    final status = item['status']?.toString() ?? 'selesai';
    final berat = item['totalBeratKg'] ?? 0;
    final poin = item['totalPoin'] ?? 0;
    final catatan = item['catatan']?.toString() ?? '-';
    final details = item['detailSetors'] as List?;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Detail Setor #$kode",
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: status == 'selesai'
                          ? const Color(0xFFDCFCE7)
                          : const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: status == 'selesai'
                            ? const Color(0xFF15803D)
                            : const Color(0xFFD97706),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildDetailRow("Waktu Pengajuan", tgl),
              _buildDetailRow("Total Berat Riil", "$berat Kg"),
              _buildDetailRow("Poin Diperoleh", "+$poin Poin"),
              _buildDetailRow("Catatan Nasabah", catatan),
              if (details != null && details.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text(
                  "Rincian Jenis Sampah:",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 6),
                ...details.map((d) {
                  final nama = d['kategoriSampah']?['namaKategori'] ??
                      'Sampah Terpilah';
                  final b = d['beratKg'] ?? 0;
                  final p = d['subtotalPoin'] ?? 0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("• $nama ($b Kg)",
                            style: const TextStyle(fontSize: 12.5)),
                        Text("+$p Poin",
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF15803D),
                            )),
                      ],
                    ),
                  );
                }),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F5A36),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Tutup",
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12.5,
                  color: Color(0xFF6B7280))),
          Text(value,
              style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827))),
        ],
      ),
    );
  }

  /// Dialog alur pengajuan penyetoran sampah riil ke backend
  void _showFormPengajuanSetorDialog() {
    if (_kategoriList.isEmpty) {
      _showActionNotice(
        "Kategori Belum Tersedia",
        "Kategori sampah belum dapat dimuat dari server. Silakan coba kembali nanti.",
      );
      return;
    }

    String selectedKategoriId = _kategoriList.first['id']?.toString() ?? '';
    final beratController = TextEditingController(text: "2.0");
    final catatanController =
        TextEditingController(text: "Sampah sudah dipilah rapi");
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      "Ajukan Penyetoran Sampah",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Pilih kategori sampah dan masukkan estimasi berat untuk penjemputan oleh kurir.",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Dropdown Kategori
                    DropdownButtonFormField<String>(
                      initialValue: selectedKategoriId,
                      decoration: InputDecoration(
                        labelText: "Pilih Kategori Sampah",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                      ),
                      items: _kategoriList.map((k) {
                        final nama = k['namaKategori']?.toString() ?? '';
                        final harga = k['hargaPerKg'] ?? 0;
                        return DropdownMenuItem<String>(
                          value: k['id']?.toString(),
                          child: Text(
                            "$nama (Rp $harga/kg)",
                            style: const TextStyle(fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() => selectedKategoriId = val);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    // Input Berat
                    TextField(
                      controller: beratController,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      decoration: InputDecoration(
                        labelText: "Estimasi Berat (Kg)",
                        suffixText: "Kg",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Input Catatan
                    TextField(
                      controller: catatanController,
                      decoration: InputDecoration(
                        labelText: "Catatan Tambahan (opsional)",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F5A36),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                final berat =
                                    double.tryParse(beratController.text) ??
                                        1.0;
                                setModalState(() => isSubmitting = true);

                                final payload = {
                                  "tanggal": DateTime.now().toIso8601String(),
                                  "catatan": catatanController.text.trim(),
                                  "items": [
                                    {
                                      "kategoriSampahId": selectedKategoriId,
                                      "beratKg": berat,
                                    }
                                  ]
                                };

                                final res = await _dashboardService
                                    .ajukanSetor(payload);
                                if (!context.mounted) return;
                                Navigator.pop(context);

                                if (res.status) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      backgroundColor: Color(0xFF15803D),
                                      content: Text(
                                          "Pengajuan penyetoran sampah berhasil dibuat!"),
                                    ),
                                  );
                                  _refreshAll();
                                } else {
                                  _showActionNotice("Gagal", res.message);
                                }
                              },
                        child: isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              )
                            : const Text(
                                "Kirim Pengajuan Penjemputan",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F8F4),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshAll,
          color: const Color(0xFF0F5A36),
          child: ListView(
            key: const Key('nasabah_main_scroll'),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            children: [
              if (_isLoading)
                const LinearProgressIndicator(
                  minHeight: 2.5,
                  color: Color(0xFF15803D),
                  backgroundColor: Colors.transparent,
                ),
              _buildHeader(),
              const SizedBox(height: 16),
              _buildHeroSaldoCard(),
              const SizedBox(height: 14),
              _buildEcoImpactCard(),
              const SizedBox(height: 14),
              _buildPickupStatusCard(),
              const SizedBox(height: 20),
              _buildQuickMenuGrid(),
              const SizedBox(height: 24),
              _buildHargaSampahSection(),
              const SizedBox(height: 20),
              _buildTipsBanner(),
              const SizedBox(height: 24),
              _buildAktivitasTerakhirSection(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNav(0, role: 'NASABAH'),
    );
  }

  /// 1. Header: Sapaan Nama Riil + Lokasi Riil + Tombol Notifikasi Dinamis
  Widget _buildHeader() {
    final nama = _user?.nama ?? _user?.username ?? 'Nasabah';
    final alamat = (_user?.alamat != null && _user!.alamat!.trim().isNotEmpty)
        ? _user!.alamat!
        : 'Alamat belum diatur';

    final notifs = _getRealNotifications();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Halo, $nama 👋",
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 21,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 13,
                    color: Color(0xFF15803D),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      alamat,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: Color(0xFF6B7280),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: _showNotificationsDialog,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: Color(0xFFE2F3E7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_none_rounded,
                  color: Color(0xFF166534),
                  size: 22,
                ),
              ),
              if (notifs.isNotEmpty)
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      notifs.length.toString(),
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// 2. Hero Card: Total Saldo Poin Riil dari Backend & Tombol Aksi
  Widget _buildHeroSaldoCard() {
    // Gunakan nilai riil dari ringkasan atau profil user, tanpa nilai dummy
    num saldo = 0;
    if (_summary.saldoPoin > 0) {
      saldo = _summary.saldoPoin;
    } else if (_user?.saldoPoin != null && _user!.saldoPoin! > 0) {
      saldo = _user!.saldoPoin!;
    }

    final formattedSaldo = _currencyFormat.format(saldo);

    final num totalKgVal = _summary.totalSampahDisetorKg;
    final totalKgStr = (totalKgVal % 1 == 0)
        ? totalKgVal.toInt().toString()
        : totalKgVal.toStringAsFixed(1).replaceAll('.', ',');

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0F5A36),
            Color(0xFF167B48),
            Color(0xFF0F5232),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F5A36).withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Watermark aksen lingkaran
          Positioned(
            right: -30,
            bottom: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.06),
                  width: 30,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Baris Atas: Label & Badge Disetor Riil
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.recycling_rounded,
                              color: Colors.white70, size: 14),
                          SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              "TOTAL SALDO POIN",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.8,
                                color: Colors.white70,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          const Text(
                            "Disetor ",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 10,
                              color: Colors.white70,
                            ),
                          ),
                          const Icon(Icons.recycling,
                              color: Colors.white, size: 12),
                          const SizedBox(width: 3),
                          Text(
                            "$totalKgStr Kg",
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Nilai Saldo Utama Riil
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      formattedSaldo,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      "Poin",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF86EFAC),
                      ),
                    ),
                  ],
                ),
                Text(
                  "Setara Rp $formattedSaldo",
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 18),
                // Tombol Aksi: + Setor, Tukar, Tarik
                Row(
                  children: [
                    Expanded(
                      child: _buildHeroActionButton(
                        icon: Icons.add_circle_outline_rounded,
                        label: "Setor",
                        isPrimary: true,
                        onTap: _showFormPengajuanSetorDialog,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildHeroActionButton(
                        icon: Icons.card_giftcard_outlined,
                        label: "Tukar",
                        isPrimary: false,
                        onTap: () {
                          Navigator.pushNamed(context, '/nasabah/tukar');
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildHeroActionButton(
                        icon: Icons.account_balance_wallet_outlined,
                        label: "Tarik",
                        isPrimary: false,
                        onTap: () => _showActionNotice(
                          "Pencairan Saldo Poin",
                          "Saldo poin Anda dapat dicairkan langsung menjadi uang tunai atau ditransfer melalui rekening saat penimbangan di unit Bank Sampah terdekat.",
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroActionButton({
    required IconData icon,
    required String label,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.5),
        decoration: BoxDecoration(
          color: isPrimary ? Colors.white : Colors.white.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15,
              color: isPrimary ? const Color(0xFF0F5A36) : Colors.white,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: isPrimary ? const Color(0xFF0F5A36) : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 3. Kartu Dampak Lingkungan (Terkalkulasi Riil dari Total Kg Disetor)
  Widget _buildEcoImpactCard() {
    final totalKgVal = _summary.totalSampahDisetorKg;
    final co2Value = totalKgVal * 1.8;
    final co2Str = (co2Value % 1 == 0)
        ? "${co2Value.toInt()} kg CO₂"
        : "${co2Value.toStringAsFixed(1).replaceAll('.', ',')} kg CO₂";

    final pohonValue = (totalKgVal / 4.0).floor();
    final pohonStr = "$pohonValue Pohon";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5EDE7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD1F4DE),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      "CO₂",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF15803D),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        co2Str,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Text(
                        "Berhasil Dicegah",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10.5,
                          color: Color(0xFF6B7280),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 32,
            width: 1,
            color: Colors.grey.shade200,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD1F4DE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.forest_rounded,
                    color: Color(0xFF15803D),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pohonStr,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Text(
                        "Diselamatkan",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10.5,
                          color: Color(0xFF6B7280),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 4. Kartu Penjemputan Dijadwalkan (Data Riil Pengajuan Setor Aktif)
  Widget _buildPickupStatusCard() {
    // Cari apakah ada transaksi setor yang sedang menunggu konfirmasi atau diverifikasi
    final activeList = _mySetorList.where((s) {
      final st = s['status']?.toString();
      return st == 'menunggu_konfirmasi' || st == 'diverifikasi';
    }).toList();

    final hasActive = activeList.isNotEmpty;
    final activeItem = hasActive ? activeList.first : null;

    // Jika ada penjemputan aktif
    if (hasActive && activeItem != null) {
      final kode = activeItem['kodeSetor'] ?? '';
      final tgl = _formatDateStr(activeItem['tanggal']?.toString());
      final isVerif = activeItem['status'] == 'diverifikasi';
      final labelStatus =
          isVerif ? "Sedang Diverifikasi" : "Penjemputan Dijadwalkan";
      final berat = activeItem['totalBeratKg'] ?? 0;

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5EDE7)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Garis aksen oranye vertikal di tepi kiri
                Container(
                  width: 4.5,
                  color: const Color(0xFFD97706),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 9, vertical: 3.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF3C7),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.circle,
                                        size: 7, color: Color(0xFFD97706)),
                                    const SizedBox(width: 5),
                                    Flexible(
                                      child: Text(
                                        labelStatus,
                                        style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFFD97706),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "ID #$kode",
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFB45309),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.access_time_rounded,
                                size: 17, color: Color(0xFF0F5A36)),
                            const SizedBox(width: 7),
                            Flexible(
                              child: Text(
                                tgl,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF111827),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFF3F4F6),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                        Icons.local_shipping_outlined,
                                        size: 14,
                                        color: Color(0xFF4B5563)),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      "Estimasi $berat Kg sampah",
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 12,
                                        color: Color(0xFF4B5563),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => _showSetorDetailDialog(activeItem),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  "Detail",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF15803D),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Jika tidak ada penjemputan aktif tapi pernah ada setoran selesai
    final hasHistory = _mySetorList.isNotEmpty;
    if (hasHistory) {
      final latest = _mySetorList.first;
      final kode = latest['kodeSetor'] ?? '';
      final tgl = _formatDateStr(latest['tanggal']?.toString());
      final berat = latest['totalBeratKg'] ?? 0;

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5EDE7)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 4.5, color: const Color(0xFF15803D)),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 9, vertical: 3.5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(Icons.check_circle,
                                      size: 12, color: Color(0xFF15803D)),
                                  SizedBox(width: 5),
                                  Text(
                                    "Setoran Terakhir Selesai",
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF15803D),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              "ID #$kode",
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF15803D),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Penyetoran $berat Kg sampah selesai diverifikasi ($tgl).",
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: Color(0xFF4B5563),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Siap setor kembali?",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF111827),
                              ),
                            ),
                            GestureDetector(
                              onTap: _showFormPengajuanSetorDialog,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F5A36),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  "Ajukan Setor",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // State jika akun nasabah baru (belum pernah ada penjemputan)
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5EDE7)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4.5, color: const Color(0xFF15803D)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2F3E7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.recycling_rounded,
                                size: 12, color: Color(0xFF15803D)),
                            SizedBox(width: 5),
                            Text(
                              "Layanan Bank Sampah Aktif",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF15803D),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Belum Ada Jadwal Penjemputan",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        "Pilah sampah daur ulang Anda dan jadwalkan penjemputan sekarang.",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 11.5,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: _showFormPengajuanSetorDialog,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F5A36),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              "+ Jadwalkan",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 5. Quick Menu 4 Kolom: Jemput Sampah, Katalog Harga, Drop Point, Edukasi Pilah
  Widget _buildQuickMenuGrid() {
    final menus = [
      (
        "Jemput\nSampah",
        Icons.electric_moped_outlined,
        const Color(0xFF15803D),
        const Color(0xFFDCFCE7),
        _showFormPengajuanSetorDialog
      ),
      (
        "Katalog\nHarga",
        Icons.receipt_long_outlined,
        const Color(0xFF0284C7),
        const Color(0xFFE0F2FE),
        () {
          if (_kategoriList.isEmpty) {
            _showActionNotice("Katalog Harga",
                "Katalog harga sedang dimuat dari server Bank Sampah.");
            return;
          }
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
            builder: (context) => Container(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7),
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Katalog Harga Sampah Hari Ini",
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: _kategoriList.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, idx) {
                        final item = _kategoriList[idx];
                        final nama = item['namaKategori'] ?? 'Sampah';
                        final harga = _currencyFormat
                            .format(item['hargaPerKg'] ?? 0);
                        final poin = item['poinPerKg'] ?? 0;
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(nama,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text("Poin: $poin poin/kg"),
                          trailing: Text("Rp $harga /kg",
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF15803D))),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      ),
      (
        "Drop\nPoint",
        Icons.location_on_outlined,
        const Color(0xFFD97706),
        const Color(0xFFFEF3C7),
        () => _showActionNotice(
              "Pos & Drop Point Bank Sampah",
              "Pos Penyetoran Terdekat:\n• Bank Sampah Unit Asri Jaya (Buka: Senin - Sabtu 08:00 - 16:00)\n• Pos RT 03/05 RW Bersih\n\nAnda dapat mengantarkan sampah secara mandiri atau menggunakan kurir jemput.",
            )
      ),
      (
        "Edukasi\nPilah",
        Icons.school_outlined,
        const Color(0xFF7C3AED),
        const Color(0xFFF3E8FF),
        () => _showActionNotice(
              "Panduan Pemilahan Sampah",
              "1. Plastik: Cuci dan keringkan botol PET, lepaskan segel tutup.\n2. Kardus/Kertas: Lipat rapi dan hindari terkena minyak atau air.\n3. Logam/Kaleng: Bersihkan sisa minuman agar tidak berkarat.\n4. Kaca: Pastikan tidak pecah dan dikemas dalam wadah aman.",
            )
      ),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: menus.map((m) {
        return Expanded(
          child: GestureDetector(
            onTap: m.$5,
            child: Column(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5EDE7)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: m.$4,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(m.$2, color: m.$3, size: 19),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  m.$1,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1F2937),
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  /// 6. Harga Sampah Hari Ini (Riil dari GET /api/v1/kategori-sampah)
  Widget _buildHargaSampahSection() {
    IconData getIconForJenis(String? jenis) {
      switch (jenis?.toLowerCase()) {
        case 'plastik':
          return Icons.delete_outline_rounded;
        case 'kertas':
          return Icons.inventory_2_outlined;
        case 'logam':
          return Icons.view_in_ar_rounded;
        case 'kaca':
          return Icons.wine_bar_rounded;
        case 'minyak':
          return Icons.water_drop_outlined;
        default:
          return Icons.recycling_rounded;
      }
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: const [
                  Flexible(
                    child: Text(
                      "Harga Sampah Hari Ini",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.circle, size: 8, color: Color(0xFF15803D)),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _showActionNotice(
                "Katalog Sampah",
                "Seluruh daftar harga kategori sampah bersumber langsung dari database unit bank sampah.",
              ),
              child: const Text(
                "Lihat Semua >",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF15803D),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_kategoriList.isEmpty && _isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                    color: Color(0xFF15803D), strokeWidth: 2),
              ),
            ),
          )
        else if (_kategoriList.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5EDE7)),
            ),
            child: const Center(
              child: Text(
                "Katalog harga sampah sedang diperbarui oleh Bank Sampah",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
            ),
          )
        else
          SizedBox(
            height: 125,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _kategoriList.length,
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final item = _kategoriList[index];
                final nama = item['namaKategori']?.toString() ?? 'Sampah';
                final harga =
                    _currencyFormat.format(item['hargaPerKg'] ?? 0);
                final jenis = item['jenis']?.toString();
                final poin = item['poinPerKg'] ?? 0;
                final unit = (jenis == 'minyak') ? 'per liter' : 'per kilogram';

                return Container(
                  width: 140,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5EDE7)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF3F8F4),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              getIconForJenis(jenis),
                              size: 14,
                              color: const Color(0xFF15803D),
                            ),
                          ),
                          Flexible(
                            child: Text(
                              "$poin Poin/kg",
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF15803D),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nama,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF111827),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Rp $harga",
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F5A36),
                            ),
                          ),
                          Text(
                            unit,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 9.5,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  /// 7. Banner Edukasi "Tips Sirkuler"
  Widget _buildTipsBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5EDE7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              'assets/pemilahan.png',
              width: 72,
              height: 72,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 72,
                height: 72,
                color: const Color(0xFFE2F3E7),
                child: const Icon(
                  Icons.recycling_rounded,
                  color: Color(0xFF15803D),
                  size: 32,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "Tips Sirkuler",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF15803D),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  "Pilah Bersih, Poin Berlebih!",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  "Keringkan wadah botol PET untuk hindari pemotongan bobot kotor.",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10.5,
                    color: Color(0xFF6B7280),
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 8. Aktivitas Terakhir (Riil dari Histori Transaksi Nasabah)
  Widget _buildAktivitasTerakhirSection() {
    final list = _summary.transaksiTerakhir;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(
              child: Text(
                "Aktivitas Terakhir",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF111827),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/nasabah/riwayat');
              },
              child: const Text(
                "Lihat Riwayat",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF15803D),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (list.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5EDE7)),
            ),
            child: Column(
              children: [
                Icon(Icons.receipt_long_outlined,
                    size: 40, color: Colors.grey.shade400),
                const SizedBox(height: 10),
                const Text(
                  "Belum Ada Transaksi",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Riwayat setoran sampah dan penukaran poin Anda akan tercatat secara otomatis di sini.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11.5,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F5A36),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: _showFormPengajuanSetorDialog,
                  icon: const Icon(Icons.add, size: 16, color: Colors.white),
                  label: const Text("Mulai Setor Sampah",
                      style: TextStyle(color: Colors.white, fontSize: 12.5)),
                ),
              ],
            ),
          )
        else
          Column(
            children: list.map((item) {
              final isSetor = item.tipe == 'setor';
              final icon = isSetor
                  ? Icons.recycling_rounded
                  : Icons.card_giftcard_rounded;
              final iconColor = isSetor
                  ? const Color(0xFF15803D)
                  : const Color(0xFFD97706);
              final iconBg = isSetor
                  ? const Color(0xFFDCFCE7)
                  : const Color(0xFFFEF3C7);

              final title = item.judul ?? (isSetor ? "Setor Sampah" : "Tukar Poin");
              final timeStr = _formatDateStr(item.waktu?.toIso8601String());
              final subtitle = (isSetor && item.beratKg != null && item.beratKg! > 0)
                  ? "$timeStr • ${item.beratKg} Kg"
                  : timeStr;

              final poinStr = _currencyFormat.format(item.poin ?? 0);
              final amount = isSetor ? "+$poinStr Poin" : "-$poinStr Poin";
              final status = item.status == 'menunggu_konfirmasi'
                  ? 'Menunggu'
                  : 'Selesai';

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildTransactionCard(
                  icon: icon,
                  iconColor: iconColor,
                  iconBg: iconBg,
                  title: title,
                  subtitle: subtitle,
                  amount: amount,
                  isPlus: isSetor,
                  status: status,
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildTransactionCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required String amount,
    required bool isPlus,
    required String status,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5EDE7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: Color(0xFF6B7280),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: isPlus
                      ? const Color(0xFF15803D)
                      : const Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 3),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: status == 'Menunggu'
                      ? const Color(0xFFFEF3C7)
                      : const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: status == 'Menunggu'
                        ? const Color(0xFFD97706)
                        : const Color(0xFF15803D),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
