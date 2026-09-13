// views/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:sirkula_banksampah/config/app_theme.dart';
import 'package:sirkula_banksampah/services/storage_services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final StorageService _storage = StorageService();

  Future<void> _checkSession() async {
    // Memberikan waktu agar splash terlihat.
    await Future.delayed(const Duration(seconds: 6));

    final user = await _storage.getUserLogin();

    if (!mounted) return;

    if (user.status) {
      final target =
          user.role == 'ADMIN' ? '/admin/dashboard' : '/nasabah/home';

      Navigator.pushNamedAndRemoveUntil(
        context,
        target,
        (route) => false,
      );
    } else {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/welcome',
        (route) => false,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Image.asset(
          'assets/sirkula.png',
          width: 220,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}