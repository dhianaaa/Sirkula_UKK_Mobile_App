// views/admin/admin_home_screen.dart
//
// Dashboard admin: sapaan singkat. Fitur kelola nasabah/setoran
// menyusul fase pengembangan berikutnya.

import 'package:flutter/material.dart';
import 'package:sirkula_banksampah/config/app_theme.dart';
import 'package:sirkula_banksampah/controllers/auth_controllers.dart';
import 'package:sirkula_banksampah/models/user_login_model.dart';
import 'package:sirkula_banksampah/services/storage_services.dart';
import 'package:sirkula_banksampah/widgets/bottom_navbar.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
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
            Text("SIRKULA Admin",
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
              const SizedBox(height: 28),
              const Text(
                "Fitur kelola nasabah, verifikasi setoran, dan laporan\nakan tersedia pada fase pengembangan berikutnya.",
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