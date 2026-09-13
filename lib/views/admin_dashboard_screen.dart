// views/admin/admin_home_screen.dart
//
// Dashboard Admin: sapaan singkat + statistik umum dari
// GET /api/v1/dashboard/stats (Total Nasabah, Saldo, Sampah, Transaksi).
// Fitur kelola nasabah/setoran/kategori/hadiah menyusul fase
// pengembangan berikutnya (belum ada screen-nya).

import 'package:flutter/material.dart';
import 'package:sirkula_banksampah/config/app_theme.dart';
import 'package:sirkula_banksampah/models/dashboard_stats_model.dart';
import 'package:sirkula_banksampah/models/user_login_model.dart';
import 'package:sirkula_banksampah/services/dashboard_service.dart';
import 'package:sirkula_banksampah/services/storage_services.dart';
import 'package:sirkula_banksampah/widgets/bottom_navbar.dart';
import 'package:sirkula_banksampah/widgets/section_state.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

enum _LoadState { loading, success, error }

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final StorageService _storage = StorageService();
  final DashboardService _dashboardService = DashboardService();

  UserLoginModel? _user;
  DashboardStatsModel _stats = DashboardStatsModel();
  _LoadState _state = _LoadState.loading;
  String _errorMessage = '';

  Future<void> _loadUser() async {
    final user = await _storage.getUserLogin();
    if (!mounted) return;
    setState(() => _user = user);
  }

  Future<void> _loadStats() async {
    setState(() => _state = _LoadState.loading);
    final result = await _dashboardService.getStats();
    if (!mounted) return;

    if (result.status) {
      setState(() {
        _stats = DashboardStatsModel.fromJson(
          result.data?.cast<String, dynamic>(),
        );
        _state = _LoadState.success;
      });
    } else {
      setState(() {
        _errorMessage = result.message;
        _state = _LoadState.error;
      });
    }
  }

  Future<void> _refreshAll() async {
    await Future.wait([_loadUser(), _loadStats()]);
  }

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadStats();
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
            Text("SIRKULA Admin",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppColors.primaryDark,
                )),
          ],
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshAll,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            children: [
              Text(
                "Selamat datang, ${_user?.nama ?? 'Admin'} 👋",
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Kelola data nasabah dan setoran sampah di sini.",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 22),
              _buildStatsSection(),
              const SizedBox(height: 24),
              const Text(
                "Menu Kelola",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              _buildQuickMenu(),
              const SizedBox(height: 8),
              const Text(
                "Fitur kelola nasabah, verifikasi setoran, kategori "
                "sampah, dan hadiah akan tersedia pada fase pengembangan "
                "berikutnya.",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNav(0, role: 'ADMIN'),
    );
  }

  Widget _buildStatsSection() {
    if (_state == _LoadState.loading) {
      return SectionState.loading();
    }
    if (_state == _LoadState.error) {
      return SectionState.error(_errorMessage, _loadStats);
    }

    final items = [
      ("Total Nasabah", "${_stats.totalNasabah}", Icons.groups_rounded),
      ("Total Saldo Poin", "${_stats.totalSaldoPoin}", Icons.savings_rounded),
      ("Total Sampah (Kg)", "${_stats.totalSampahKg}", Icons.recycling),
      (
        "Total Transaksi",
        "${_stats.totalTransaksi}",
        Icons.receipt_long_rounded
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.5,
      children: items.map((i) => _statCard(i.$1, i.$2, i.$3)).toList(),
    );
  }

  Widget _statCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10.5,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickMenu() {
    final menu = [
      ("Kelola Nasabah", Icons.people_alt_outlined),
      ("Verifikasi Setoran", Icons.fact_check_outlined),
      ("Kategori Sampah", Icons.recycling_outlined),
      ("Kelola Hadiah", Icons.card_giftcard_outlined),
    ];

    return Row(
      children: menu
          .map(
            (m) => Expanded(
              child: GestureDetector(
                onTap: () {
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
                          fontFamily: 'Poppins', fontSize: 10),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}