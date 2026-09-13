// views/nasabah/nasabah_home_screen.dart
//
// Dashboard Nasabah SIRKULA yang didesain persis sesuai referensi:
// - Header sapaan personal + lokasi + lonceng notifikasi (badge 2)
// - Hero Card Saldo Poin hijau tua dengan tombol aksi (+ Setor, Tukar, Tarik)
// - Kartu Dampak Lingkungan (CO2 Dicegah & Pohon Diselamatkan)
// - Kartu Penjemputan Dijadwalkan (Kurir Sirkula & tombol Lacak)
// - Grid Menu Utama (Jemput Sampah, Katalog Harga, Drop Point, Edukasi Pilah)
// - Harga Sampah Hari Ini (Plastik PET, Kardus Bekas, Minyak Jelantah, Kaleng)
// - Banner Edukasi "Tips Sirkuler: Pilah Bersih, Poin Berlebih!"
// - Aktivitas Terakhir (Setor Sampah Anorganik & Tukar Pulsa)
// - Bottom Navigation Bar kustom dengan tombol aksi melingkar di tengah

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sirkula_banksampah/config/app_theme.dart';
import 'package:sirkula_banksampah/models/dashboard_summary_model.dart';
import 'package:sirkula_banksampah/models/user_login_model.dart';
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

  UserLoginModel? _user;
  DashboardSummaryModel _summary = DashboardSummaryModel();
  List<Map<String, dynamic>> _kategoriList = [];
  bool _isLoading = true;

  final NumberFormat _currencyFormat = NumberFormat('#,###', 'id_ID');

  Future<void> _loadUser() async {
    final user = await _storage.getUserLogin();
    if (!mounted) return;
    setState(() => _user = user);
  }

  Future<void> _loadSummary() async {
    final result = await _dashboardService.getSummary();
    if (!mounted) return;

    if (result.status) {
      final summary = DashboardSummaryModel.fromJson(
        result.data?.cast<String, dynamic>(),
      );
      setState(() => _summary = summary);
    }
  }

  Future<void> _loadKategori() async {
    final categories = await _dashboardService.getKategoriSampah();
    if (!mounted) return;
    if (categories.isNotEmpty) {
      setState(() => _kategoriList = categories);
    }
  }

  Future<void> _refreshAll() async {
    setState(() => _isLoading = true);
    await Future.wait([_loadUser(), _loadSummary(), _loadKategori()]);
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    _refreshAll();
  }

  void _showNotificationsDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
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
                  const Text(
                    "Notifikasi",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "2 Baru",
                      style: TextStyle(
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
              _buildNotificationItem(
                icon: Icons.local_shipping_outlined,
                color: const Color(0xFF15803D),
                bg: const Color(0xFFDCFCE7),
                title: "Kurir Dijadwalkan",
                desc:
                    "Kurir Budi Santoso akan menjemput sampah hari ini pukul 14:00 WIB.",
                time: "10 menit lalu",
              ),
              const SizedBox(height: 12),
              _buildNotificationItem(
                icon: Icons.savings_outlined,
                color: const Color(0xFF0284C7),
                bg: const Color(0xFFE0F2FE),
                title: "Poin Berhasil Ditambahkan",
                desc:
                    "Setoran sampah anorganik 4,2 Kg berhasil diverifikasi (+12.400 Poin).",
                time: "Kemarin",
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
        title: Text(title, style: const TextStyle(fontFamily: 'Poppins')),
        content: Text(message, style: const TextStyle(fontFamily: 'Poppins')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Tutup"),
          ),
        ],
      ),
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

  /// 1. Header: Sapaan Nama + Lokasi + Tombol Notifikasi (Badge 2)
  Widget _buildHeader() {
    final nama = _user?.nama ?? 'Siti Nurhaliza';
    final alamat = _user?.alamat ?? 'Kebayoran Baru, Jaksel';

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
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    "2",
                    style: TextStyle(
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

  /// 2. Hero Card: Total Saldo Poin Hijau Tua dengan Watermark & Tombol Aksi
  Widget _buildHeroSaldoCard() {
    // Tampilkan saldo dari session/summary, jika masih 0 pada mockup pakai nilai representatif 24.850
    final num saldo = (_summary.saldoPoin > 0)
        ? _summary.saldoPoin
        : (_user?.saldoPoin != null && _user!.saldoPoin! > 0)
            ? _user!.saldoPoin!
            : 24850;

    final formattedSaldo = _currencyFormat.format(saldo);
    final totalKg = _summary.totalSampahDisetorKg > 0
        ? _summary.totalSampahDisetorKg.toString().replaceAll('.', ',')
        : "68,4";

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
                // Baris Atas: Label & Badge Disetor
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
                            "$totalKg Kg",
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
                // Nilai Saldo Utama
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
                        onTap: () => _showActionNotice(
                          "Setor Sampah",
                          "Fitur pengajuan setoran sampah siap digunakan. Pilih metode penjemputan atau drop point terdekat.",
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildHeroActionButton(
                        icon: Icons.card_giftcard_outlined,
                        label: "Tukar",
                        isPrimary: false,
                        onTap: () => _showActionNotice(
                          "Tukar Poin",
                          "Tukarkan saldo poin Anda dengan berbagai voucher, sembako, atau pulsa di menu Hadiah.",
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildHeroActionButton(
                        icon: Icons.account_balance_wallet_outlined,
                        label: "Tarik",
                        isPrimary: false,
                        onTap: () => _showActionNotice(
                          "Tarik Saldo",
                          "Penarikan saldo poin menjadi uang tunai/e-wallet dapat dicairkan melalui Unit Bank Sampah.",
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

  /// 3. Kartu Dampak Lingkungan (120 kg CO2 & 18 Pohon)
  Widget _buildEcoImpactCard() {
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
                    children: const [
                      Text(
                        "120 kg CO₂",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                      Text(
                        "Berhasil Dicegah",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10.5,
                          color: Color(0xFF6B7280),
                        ),
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
                    children: const [
                      Text(
                        "18 Pohon",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                      Text(
                        "Diselamatkan",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 10.5,
                          color: Color(0xFF6B7280),
                        ),
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

  /// 4. Kartu Penjemputan Dijadwalkan (Aksen oranye + Kurir Sirkula + Tombol Lacak)
  Widget _buildPickupStatusCard() {
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
                      // Header chip status & ID
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
                                children: const [
                                  Icon(Icons.circle,
                                      size: 7, color: Color(0xFFD97706)),
                                  SizedBox(width: 5),
                                  Flexible(
                                    child: Text(
                                      "Penjemputan Dijadwalkan",
                                      style: TextStyle(
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
                          const Text(
                            "ID #SK-8821",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFB45309),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Jam Penjemputan
                      Row(
                        children: const [
                          Icon(Icons.access_time_rounded,
                              size: 17, color: Color(0xFF0F5A36)),
                          SizedBox(width: 7),
                          Flexible(
                            child: Text(
                              "Hari ini, 14:00 – 16:00 WIB",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
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
                      // Kurir dan Tombol Lacak
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
                                    size: 15,
                                    color: Color(0xFF4B5563),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Expanded(
                                  child: Text(
                                    "Budi Santoso (Kurir Sirkula)",
                                    style: TextStyle(
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
                            onTap: () => _showActionNotice(
                              "Lacak Kurir",
                              "Kurir Budi Santoso sedang dalam perjalanan menuju lokasi Anda (Estimasi 25 menit).",
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                "Lacak",
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

  /// 5. Quick Menu 4 Kolom: Jemput Sampah, Katalog Harga, Drop Point, Edukasi Pilah
  Widget _buildQuickMenuGrid() {
    final menus = [
      (
        "Jemput\nSampah",
        Icons.electric_moped_outlined,
        const Color(0xFF15803D),
        const Color(0xFFDCFCE7),
        () => _showActionNotice("Jemput Sampah",
            "Buat permintaan penjemputan sampah langsung dari alamat Anda.")
      ),
      (
        "Katalog\nHarga",
        Icons.receipt_long_outlined,
        const Color(0xFF0284C7),
        const Color(0xFFE0F2FE),
        () => _showActionNotice("Katalog Harga",
            "Daftar harga dan poin per kilogram untuk semua jenis sampah daur ulang.")
      ),
      (
        "Drop\nPoint",
        Icons.location_on_outlined,
        const Color(0xFFD97706),
        const Color(0xFFFEF3C7),
        () => _showActionNotice("Drop Point",
            "Temukan lokasi bank sampah unit dan pos penyetoran terdekat di sekitar Anda.")
      ),
      (
        "Edukasi\nPilah",
        Icons.school_outlined,
        const Color(0xFF7C3AED),
        const Color(0xFFF3E8FF),
        () => _showActionNotice("Edukasi Pilah",
            "Panduan praktis cara memilah dan membersihkan sampah agar bernilai tinggi.")
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

  /// 6. Harga Sampah Hari Ini (Horizontal Scrollable Cards)
  Widget _buildHargaSampahSection() {
    final defaultCards = [
      {
        'title': 'Plastik PET',
        'price': 'Rp 3.500',
        'unit': 'per kilogram',
        'badge': '📈 +5%',
        'isPositive': true,
        'icon': Icons.delete_outline_rounded,
      },
      {
        'title': 'Kardus Bekas',
        'price': 'Rp 2.200',
        'unit': 'per kilogram',
        'badge': 'Stabil',
        'isPositive': false,
        'icon': Icons.inventory_2_outlined,
      },
      {
        'title': 'Minyak Jelantah',
        'price': 'Rp 7.000',
        'unit': 'per liter',
        'badge': 'Stabil',
        'isPositive': false,
        'icon': Icons.water_drop_outlined,
      },
      {
        'title': 'Kaleng Logam',
        'price': 'Rp 12.000',
        'unit': 'per kilogram',
        'badge': '📈 +8%',
        'isPositive': true,
        'icon': Icons.recycling,
      },
    ];

    final cards = _kategoriList.isNotEmpty
        ? _kategoriList.map((k) {
            final nama = k['namaKategori']?.toString() ?? 'Sampah';
            final harga = k['hargaPerKg'] ?? 0;
            final isTrend = (harga is num && harga >= 3000);
            return {
              'title': nama,
              'price': 'Rp ${_currencyFormat.format(harga)}',
              'unit': 'per kilogram',
              'badge': isTrend ? '📈 +5%' : 'Stabil',
              'isPositive': isTrend,
              'icon': Icons.recycling,
            };
          }).toList()
        : defaultCards;

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
              onTap: () => _showActionNotice("Katalog Lengkap",
                  "Menampilkan seluruh daftar harga sampah daur ulang hari ini."),
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
        SizedBox(
          height: 125,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: cards.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = cards[index];
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
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            item['icon'] as IconData,
                            size: 16,
                            color: const Color(0xFF15803D),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: (item['isPositive'] as bool)
                                ? const Color(0xFFDCFCE7)
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item['badge'] as String,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 9.5,
                              fontWeight: FontWeight.w600,
                              color: (item['isPositive'] as bool)
                                  ? const Color(0xFF15803D)
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'] as String,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item['price'] as String,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF15803D),
                          ),
                        ),
                        Text(
                          item['unit'] as String,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10,
                            color: Color(0xFF6B7280),
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

  /// 7. Banner Edukasi "Tips Sirkuler: Pilah Bersih, Poin Berlebih!"
  Widget _buildTipsBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
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
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/pemilahan.png',
              width: 70,
              height: 70,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                width: 70,
                height: 70,
                color: const Color(0xFFDCFCE7),
                child: const Icon(Icons.eco, color: Color(0xFF15803D)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(10),
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
                  "Keringkan wadah botol PET untuk hindari penolakan saat penimbangan.",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
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

  /// 8. Aktivitas Terakhir (Setor Sampah Anorganik & Tukar Pulsa Telkomsel)
  Widget _buildAktivitasTerakhirSection() {
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
              onTap: () => _showActionNotice(
                "Riwayat Transaksi",
                "Riwayat lengkap setoran sampah dan penukaran poin Anda.",
              ),
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
        // Item 1: Setor Sampah Anorganik (+12.400 Poin)
        _buildTransactionCard(
          icon: Icons.recycling_rounded,
          iconColor: const Color(0xFF15803D),
          iconBg: const Color(0xFFDCFCE7),
          title: "Setor Sampah Anorganik",
          subtitle: "Kemarin, 11:20 WIB • 4,2 Kg",
          amount: "+12.400 Poin",
          isPlus: true,
          status: "Selesai",
        ),
        const SizedBox(height: 10),
        // Item 2: Tukar Pulsa Telkomsel (-10.500 Poin)
        _buildTransactionCard(
          icon: Icons.card_giftcard_rounded,
          iconColor: const Color(0xFFD97706),
          iconBg: const Color(0xFFFEF3C7),
          title: "Tukar Pulsa Telkomsel",
          subtitle: "22 Okt 2023 • Rp 10.000",
          amount: "-10.500 Poin",
          isPlus: false,
          status: "Berhasil",
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
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
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
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 9.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF15803D),
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