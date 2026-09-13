// main.dart
//
// Entry point SIRKULA.
// Setiap kali menambah halaman baru (page.dart), tambahkan routes
// di sini sesuai aturan project (poin C.4 pedoman project).

import 'package:flutter/material.dart';
import 'package:sirkula_banksampah/config/app_theme.dart';
import 'package:sirkula_banksampah/views/admin_dashboard_screen.dart';
import 'package:sirkula_banksampah/views/admin_profile_screen.dart';
import 'package:sirkula_banksampah/views/login_admin_screen.dart';
import 'package:sirkula_banksampah/views/login_nasabah_screen.dart';
import 'package:sirkula_banksampah/views/nasabah_dashboard_screen.dart';
import 'package:sirkula_banksampah/views/nasabah_profile_screen.dart';
import 'package:sirkula_banksampah/views/pilih_role_screen.dart';
import 'package:sirkula_banksampah/views/register_admin_screen.dart';
import 'package:sirkula_banksampah/views/register_nasabah_screen.dart';
import 'package:sirkula_banksampah/views/splash_screen.dart';
import 'package:sirkula_banksampah/views/welcome_screen.dart';

void main() {
  runApp(const SirkulaApp());
}

class SirkulaApp extends StatelessWidget {
  const SirkulaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIRKULA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/pilihrole': (context) => const PilihRoleScreen(),
        '/login': (context) => const LoginNasabahScreen(),
        '/loginnasabah': (context) => const LoginNasabahScreen(),
        '/loginadmin': (context) => const LoginAdminScreen(),
        '/register': (context) => const RegisterNasabahScreen(),
        '/registernasabah': (context) => const RegisterNasabahScreen(),
        '/registeradmin': (context) => const RegisterAdminScreen(),

        // Nasabah
        '/nasabah/home': (context) => const NasabahHomeScreen(),
        '/nasabah/profil': (context) => const NasabahProfileScreen(),

        // Admin
        '/admin/dashboard': (context) => const AdminHomeScreen(),
        '/admin/profil': (context) => const AdminProfileScreen(),
      },
    );
  }
}