// views/nasabah/nasabah_home_screen.dart
//
// Beranda nasabah: sapaan + saldo poin, sesuai data yang tersimpan
// dari session login (lihat UserLoginModel & StorageService).
// Halaman fitur setor sampah/riwayat menyusul fase berikutnya.

import 'package:flutter/material.dart';
import 'package:sirkula_banksampah/config/app_theme.dart';
import 'package:sirkula_banksampah/controllers/auth_controllers.dart';
import 'package:sirkula_banksampah/models/user_login_model.dart';
import 'package:sirkula_banksampah/services/storage_services.dart';
import 'package:sirkula_banksampah/widgets/bottom_navbar.dart';

class NasabahHomeScreen extends StatefulWidget {
  const NasabahHomeScreen({super.key});

  @override
  State<NasabahHomeScreen> createState() => _NasabahHomeScreenState();
}

class _NasabahHomeScreenState extends State<NasabahHomeScreen> {
  final StorageService _storage = StorageService();
  final AuthController _authController = AuthController();
  UserLoginModel? _user;

  Future<void> _loadUser() async {
    final user = await _storage.getUserLogin();
    if (!mounted) return;
    setState(() => _user = user);
  }

  Future<void> _logout() async {
    await _authController.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  void initState() {
    super.initState();
    _loadUser();
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              Container(
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
                    Text(
                      "${_user?.saldoPoin ?? 0} Poin",
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                "Fitur setor sampah & riwayat transaksi akan tersedia\npada fase pengembangan berikutnya.",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNav(0),
    );
  }
}