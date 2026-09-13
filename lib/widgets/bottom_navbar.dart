// widgets/bottom_nav.dart
//
// Bottom navigation bar yang menampilkan menu berbeda sesuai role user
// yang sedang login (NASABAH / ADMIN), mengikuti pola modul
// "Membuat Bottom Navigation Bar".
//
// Pemakaian: taruh di attribute bottomNavigationBar milik Scaffold,
// dengan activePage sesuai urutan menu (0, 1, ...).
//   bottomNavigationBar: BottomNav(0),

import 'package:flutter/material.dart';
import 'package:sirkula_banksampah/services/storage_services.dart';

class BottomNav extends StatefulWidget {
  final int activePage;
  const BottomNav(this.activePage, {super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  final StorageService _storage = StorageService();
  String? role;

  Future<void> _getRole() async {
    final user = await _storage.getUserLogin();
    if (!mounted) return;
    if (user.status) {
      setState(() => role = user.role);
    } else {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false);
    }
  }

  @override
  void initState() {
    super.initState();
    _getRole();
  }

  void _goTo(int index) {
    if (role == 'NASABAH') {
      switch (index) {
        case 0:
          Navigator.pushReplacementNamed(context, '/nasabah/home');
          break;
        case 1:
          Navigator.pushReplacementNamed(context, '/nasabah/profil');
          break;
      }
    } else if (role == 'ADMIN') {
      switch (index) {
        case 0:
          Navigator.pushReplacementNamed(context, '/admin/dashboard');
          break;
        case 1:
          Navigator.pushReplacementNamed(context, '/admin/profil');
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (role == 'NASABAH') {
      return BottomNavigationBar(
        currentIndex: widget.activePage,
        onTap: _goTo,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      );
    }

    if (role == 'ADMIN') {
      return BottomNavigationBar(
        currentIndex: widget.activePage,
        onTap: _goTo,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      );
    }

    // Role belum termuat (masih loading dari SharedPreferences).
    return const SizedBox(height: 0);
  }
}