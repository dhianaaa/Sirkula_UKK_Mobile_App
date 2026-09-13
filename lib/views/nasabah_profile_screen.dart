// views/nasabah/nasabah_profile_screen.dart
//
// Halaman profil nasabah: menampilkan data akun dari session & tombol
// keluar (logout).

import 'package:flutter/material.dart';
import 'package:sirkula_banksampah/config/app_theme.dart';
import 'package:sirkula_banksampah/controllers/auth_controllers.dart';
import 'package:sirkula_banksampah/models/user_login_model.dart';
import 'package:sirkula_banksampah/services/storage_services.dart';
import 'package:sirkula_banksampah/widgets/app_button.dart';
import 'package:sirkula_banksampah/widgets/bottom_navbar.dart';

class NasabahProfileScreen extends StatefulWidget {
  const NasabahProfileScreen({super.key});

  @override
  State<NasabahProfileScreen> createState() => _NasabahProfileScreenState();
}

class _NasabahProfileScreenState extends State<NasabahProfileScreen> {
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
    Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
  }

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Widget _infoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Profil Saya")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.primaryLight,
                child: Icon(
                  Icons.person,
                  size: 36,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoTile("Nama Lengkap", _user?.nama ?? '-'),
                    const Divider(),
                    _infoTile("Username", _user?.username ?? '-'),
                    const Divider(),
                    _infoTile("Saldo Poin", "${_user?.saldoPoin ?? 0}"),
                  ],
                ),
              ),
              const Spacer(),
              AppButton(
                label: "Keluar",
                color: AppColors.error,
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Konfirmasi Keluar"),
                        content: const Text(
                          "Apakah kamu yakin ingin keluar dari akun?",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, false);
                            },
                            child: const Text("Batal"),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, true);
                            },
                            child: const Text("Keluar"),
                          ),
                        ],
                      );
                    },
                  );

                  if (confirm != true) return;

                  await _logout();
                }, 
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNav(4, role: 'NASABAH'),
    );
  }
}
