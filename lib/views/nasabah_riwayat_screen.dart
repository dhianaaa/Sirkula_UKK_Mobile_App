// views/nasabah_riwayat_screen.dart
//
// Halaman Riwayat Transaksi Nasabah SIRKULA
// Terhubung langsung ke:
// - GET /api/v1/setor-sampah/my-setor
// - GET /api/v1/penukaran-poin/my-penukaran

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sirkula_banksampah/config/app_theme.dart';
import 'package:sirkula_banksampah/services/dashboard_service.dart';
import 'package:sirkula_banksampah/widgets/bottom_navbar.dart';

class NasabahRiwayatScreen extends StatefulWidget {
  const NasabahRiwayatScreen({super.key});

  @override
  State<NasabahRiwayatScreen> createState() => _NasabahRiwayatScreenState();
}

class _NasabahRiwayatScreenState extends State<NasabahRiwayatScreen>
    with SingleTickerProviderStateMixin {
  final DashboardService _dashboardService = DashboardService();

  late TabController _tabController;
  List<Map<String, dynamic>> _mySetorList = [];
  List<Map<String, dynamic>> _myPenukaranList = [];
  bool _isLoading = true;

  final NumberFormat _currencyFormat = NumberFormat('#,###', 'id_ID');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadRiwayat();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRiwayat() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        _dashboardService.getMySetor(),
        _dashboardService.getMyPenukaran(),
      ]);

      if (!mounted) return;
      setState(() {
        _mySetorList = results[0];
        _myPenukaranList = results[1];
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> _getAllTransactions() {
    final List<Map<String, dynamic>> all = [];

    for (final s in _mySetorList) {
      all.add({
        'type': 'setor',
        'rawDate': s['tanggalSetor'] ?? s['createdAt'] ?? '',
        'title': 'Setor Sampah',
        'subtitle': s['kodeSetor'] ?? 'Penyetoran Sampah',
        'points': '+${_currencyFormat.format(s['totalPoin'] ?? 0)} Poin',
        'isPlus': true,
        'status': (s['status'] ?? 'selesai').toString(),
        'weight': '${s['beratKg'] ?? s['totalBeratKg'] ?? 0} kg',
        'data': s,
      });
    }

    for (final p in _myPenukaranList) {
      final hadiah = p['hadiah'] is Map ? p['hadiah']['namaHadiah'] : 'Hadiah';
      all.add({
        'type': 'tukar',
        'rawDate': p['tanggalPenukaran'] ?? p['createdAt'] ?? '',
        'title': 'Tukar: $hadiah',
        'subtitle': p['kodePenukaran'] ?? 'Penukaran Hadiah',
        'points': '-${_currencyFormat.format(p['poinTerpakai'] ?? 0)} Poin',
        'isPlus': false,
        'status': (p['status'] ?? 'diproses').toString(),
        'data': p,
      });
    }

    all.sort((a, b) {
      final dateA = DateTime.tryParse(a['rawDate']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final dateB = DateTime.tryParse(b['rawDate']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0);
      return dateB.compareTo(dateA);
    });

    return all;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F8F4),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          "Riwayat Transaksi",
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF0F5A36),
          unselectedLabelColor: const Color(0xFF6B7280),
          indicatorColor: const Color(0xFF0F5A36),
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          tabs: const [
            Tab(text: "Semua"),
            Tab(text: "Setor Sampah"),
            Tab(text: "Tukar Poin"),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF0F5A36)),
            )
          : RefreshIndicator(
              onRefresh: _loadRiwayat,
              color: const Color(0xFF0F5A36),
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildSemuaTab(),
                  _buildSetorTab(),
                  _buildTukarTab(),
                ],
              ),
            ),
      bottomNavigationBar: const BottomNav(1, role: 'NASABAH'),
    );
  }

  Widget _buildSemuaTab() {
    final all = _getAllTransactions();
    if (all.isEmpty) {
      return _buildEmptyState("Belum ada riwayat transaksi");
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      itemCount: all.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = all[index];
        final isSetor = item['type'] == 'setor';
        return _buildTransactionCard(
          icon: isSetor ? Icons.recycling_rounded : Icons.card_giftcard_rounded,
          iconBg: isSetor ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7),
          iconColor: isSetor ? const Color(0xFF15803D) : const Color(0xFFD97706),
          title: item['title'] as String,
          subtitle: "${_formatDate(item['rawDate'] as String)} • ${item['subtitle']}",
          amount: item['points'] as String,
          isPlus: item['isPlus'] as bool,
          status: _capitalize(item['status'] as String),
        );
      },
    );
  }

  Widget _buildSetorTab() {
    if (_mySetorList.isEmpty) {
      return _buildEmptyState("Belum ada riwayat penyetoran sampah");
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      itemCount: _mySetorList.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final s = _mySetorList[index];
        final kode = s['kodeSetor'] ?? 'Setor Sampah';
        final poin = s['totalPoin'] ?? 0;
        final berat = s['beratKg'] ?? s['totalBeratKg'] ?? 0;
        final rawDate = s['tanggalSetor'] ?? s['createdAt'] ?? '';
        final status = (s['status'] ?? 'selesai').toString();

        return _buildTransactionCard(
          icon: Icons.recycling_rounded,
          iconBg: const Color(0xFFDCFCE7),
          iconColor: const Color(0xFF15803D),
          title: "Setor Sampah • $berat kg",
          subtitle: "${_formatDate(rawDate)} • $kode",
          amount: "+${_currencyFormat.format(poin)} Poin",
          isPlus: true,
          status: _capitalize(status),
        );
      },
    );
  }

  Widget _buildTukarTab() {
    if (_myPenukaranList.isEmpty) {
      return _buildEmptyState("Belum ada riwayat penukaran hadiah");
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      itemCount: _myPenukaranList.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final p = _myPenukaranList[index];
        final kode = p['kodePenukaran'] ?? '-';
        final poin = p['poinTerpakai'] ?? 0;
        final status = (p['status'] ?? 'diproses').toString();
        final rawDate = p['tanggalPenukaran'] ?? p['createdAt'] ?? '';
        final hadiah =
            p['hadiah'] is Map ? p['hadiah']['namaHadiah'] : 'Hadiah';

        return _buildTransactionCard(
          icon: Icons.card_giftcard_rounded,
          iconBg: const Color(0xFFFEF3C7),
          iconColor: const Color(0xFFD97706),
          title: "Tukar $hadiah",
          subtitle: "${_formatDate(rawDate)} • $kode",
          amount: "-${_currencyFormat.format(poin)} Poin",
          isPlus: false,
          status: _capitalize(status),
        );
      },
    );
  }

  Widget _buildTransactionCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String amount,
    required bool isPlus,
    required String status,
  }) {
    final isDone = status.toLowerCase() == 'selesai';
    final isWaiting =
        status.toLowerCase() == 'menunggu' || status.toLowerCase() == 'diproses';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
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
                  color: isPlus ? const Color(0xFF15803D) : const Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isWaiting
                      ? const Color(0xFFFEF3C7)
                      : (isDone
                          ? const Color(0xFFDCFCE7)
                          : const Color(0xFFFEE2E2)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isWaiting
                        ? const Color(0xFFD97706)
                        : (isDone
                            ? const Color(0xFF15803D)
                            : const Color(0xFFDC2626)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String isoString) {
    if (isoString.isEmpty) return '-';
    try {
      final date = DateTime.parse(isoString).toLocal();
      return DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(date);
    } catch (_) {
      return isoString;
    }
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1);
  }
}
