// views/nasabah/nasabah_home_screen.dart
//
// Dashboard Nasabah: sapaan + ringkasan saldo/pemasukan/pengeluaran
// poin dari GET /api/v1/dashboard/summary, dan daftar transaksi
// terakhir. Fitur Setor Sampah/Riwayat/Hadiah penuh menyusul fase
// pengembangan berikutnya (belum ada screen-nya).

import 'package:flutter/material.dart';
import 'package:sirkula_banksampah/config/app_theme.dart';
import 'package:sirkula_banksampah/controllers/auth_controllers.dart';
import 'package:sirkula_banksampah/models/dashboard_summary_model.dart';
import 'package:sirkula_banksampah/models/user_login_model.dart';
import 'package:sirkula_banksampah/services/dashboard_service.dart';
import 'package:sirkula_banksampah/services/storage_services.dart';
import 'package:sirkula_banksampah/widgets/bottom_navbar.dart';
import 'package:sirkula_banksampah/widgets/section_state.dart';

class NasabahHomeScreen extends StatefulWidget {
  const NasabahHomeScreen({super.key});

  @override
  State<NasabahHomeScreen> createState() => _NasabahHomeScreenState();
}

enum _LoadState { loading, success, empty, error }

class _NasabahHomeScreenState extends State<NasabahHomeScreen> {
  final StorageService _storage = StorageService();
  final AuthController _authController = AuthController();
  final DashboardService _dashboardService = DashboardService();

  UserLoginModel? _user;
  DashboardSummaryModel _summary = DashboardSummaryModel();
  _LoadState _state = _LoadState.loading;
  String _errorMessage = '';

  Future<void> _loadUser() async {
    final user = await _storage.getUserLogin();
    if (!mounted) return;
    setState(() => _user = user);
  }

  Future<void> _loadSummary() async {
    setState(() => _state = _LoadState.loading);
    final result = await _dashboardService.getSummary();
    if (!mounted) return;

    if (result.status) {
      final summary = DashboardSummaryModel.fromJson(
        result.data?.cast<String, dynamic>(),
      );
      setState(() {
        _summary = summary;
        _state = summary.transaksiTerakhir.isEmpty &&
                summary.saldoPoin == 0 &&
                summary.totalPemasukanPoin == 0 &&
                summary.totalPengeluaranPoin == 0
            ? _LoadState.empty
            : _LoadState.success;
      });
    } else {
      setState(() {
        _errorMessage = result.message;
        _state = _LoadState.error;
      });
    }
  }

  Future<void> _logout() async {
    await _authController.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  Future<void> _refreshAll() async {
    await Future.wait([_loadUser(), _loadSummary()]);
  }

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadSummary();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: const [
            Icon(Icons.recycling, color: AppColors.primary, size: 18),
            SizedBox(width: 6),
            Text("SIRKULA",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppColors.primaryDark,
                )),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: AppColors.textSecondary),
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshAll,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            children: [
              Text(
                "Halo, ${_user?.nama ?? '...'} 👋",
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Yuk setorkan sampahmu hari ini.",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              _buildSaldoCard(),
              const SizedBox(height: 14),
              _buildMiniStatsRow(),
              const SizedBox(height: 22),
              _buildQuickMenu(),
              const SizedBox(height: 22),
              const Text(
                "Transaksi Terakhir",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              _buildTransaksiSection(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNav(0),
    );
  }

  Widget _buildSaldoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Saldo Poin Anda",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12.5,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 6),
          _state == _LoadState.loading
              ? const SizedBox(
                  height: 26,
                  width: 26,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.4,
                  ),
                )
              : Text(
                  "${_summary.saldoPoin} Poin",
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildMiniStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _miniStatCard(
            label: "Pemasukan Poin",
            value: "+${_summary.totalPemasukanPoin}",
            icon: Icons.arrow_downward_rounded,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _miniStatCard(
            label: "Pengeluaran Poin",
            value: "-${_summary.totalPengeluaranPoin}",
            icon: Icons.arrow_upward_rounded,
            color: AppColors.error,
          ),
        ),
      ],
    );
  }

  Widget _miniStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickMenu() {
    final menu = [
      ("Setor Sampah", Icons.delete_outline_rounded),
      ("Riwayat", Icons.history_rounded),
      ("Hadiah", Icons.card_giftcard_rounded),
      ("Katalog Harga", Icons.receipt_long_outlined),
    ];

    return Row(
      children: menu
          .map(
            (m) => Expanded(
              child: GestureDetector(
                onTap: () {
                  // TODO(fase berikutnya): screen fitur ini belum dibuat.
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          "Fitur ini akan tersedia pada fase pengembangan berikutnya."),
                    ),
                  );
                },
                child: Column(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(m.$2, color: AppColors.primary),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      m.$1,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontFamily: 'Poppins', fontSize: 10.5),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildTransaksiSection() {
    switch (_state) {
      case _LoadState.loading:
        return SectionState.loading();
      case _LoadState.error:
        return SectionState.error(_errorMessage, _loadSummary);
      case _LoadState.empty:
        return SectionState.empty(
            "Belum ada transaksi. Yuk mulai setor sampah pertamamu!");
      case _LoadState.success:
        if (_summary.transaksiTerakhir.isEmpty) {
          return SectionState.empty("Belum ada transaksi.");
        }
        return Column(
          children: _summary.transaksiTerakhir.map((t) {
            final isTukar = t.tipe == 'tukar';
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.primaryLight.withValues(alpha: 0.25),
                    child: Icon(
                      isTukar ? Icons.card_giftcard : Icons.recycling,
                      color: AppColors.primaryDark,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      t.judul ?? '-',
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Text(
                    "${isTukar ? '-' : '+'}${t.poin ?? 0}",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
                      color: isTukar ? AppColors.error : AppColors.primary,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        );
    }
  }
}