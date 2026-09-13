// widgets/bottom_navbar.dart
//
// Bottom navigation bar yang menampilkan menu sesuai role user
// yang sedang login (NASABAH / ADMIN), mengikuti desain referensi Sirkula:
// - Nasabah: 5 items (Beranda, Riwayat, Tombol Lingkar Hijau Setor, Tukar, Profil)
// - Admin  : Dashboard, Profil

import 'package:flutter/material.dart';
import 'package:sirkula_banksampah/config/app_theme.dart';
import 'package:sirkula_banksampah/services/storage_services.dart';

class BottomNav extends StatefulWidget {
  final int activePage;
  final String? role;
  const BottomNav(this.activePage, {super.key, this.role});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  final StorageService _storage = StorageService();
  String? role;

  Future<void> _getRole() async {
    if (widget.role != null && widget.role!.isNotEmpty) {
      if (mounted) setState(() => role = widget.role);
      return;
    }
    final user = await _storage.getUserLogin();
    if (!mounted) return;
    if (user.status && user.role != null) {
      setState(() => role = user.role);
    } else {
      setState(() => role = role ?? 'NASABAH');
    }
  }

  @override
  void initState() {
    super.initState();
    role = widget.role;
    _getRole();
  }

  void _showSetorSampahModal() {
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
              const Text(
                "Pilih Metode Setor Sampah",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Dapatkan poin daur ulang dari sampah anorganikmu.",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 18),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.local_shipping_outlined,
                    color: Color(0xFF15803D),
                  ),
                ),
                title: const Text(
                  "Jemput Sampah ke Lokasi",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                subtitle: const Text(
                  "Kurir Sirkula akan menjemput sampah di rumahmu.",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Layanan Jemput Sampah berhasil dipilih. Kurir akan datang sesuai jadwal.",
                      ),
                    ),
                  );
                },
              ),
              const Divider(height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.location_on_outlined,
                    color: Color(0xFF0369A1),
                  ),
                ),
                title: const Text(
                  "Antar ke Drop Point Terdekat",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                subtitle: const Text(
                  "Bawa sampah langsung ke Bank Sampah unit terdekat.",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Lokasi Drop Point terdekat: Bank Sampah Asri Jaya (500m).",
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentRole = (role ?? widget.role ?? 'NASABAH').toUpperCase();

    if (currentRole == 'ADMIN') {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard,
                  label: 'Dashboard',
                  isActive: widget.activePage == 0,
                  onTap: () {
                    if (widget.activePage != 0) {
                      Navigator.pushReplacementNamed(
                          context, '/admin/dashboard');
                    }
                  },
                ),
                _buildNavItem(
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: 'Profil',
                  isActive: widget.activePage == 1,
                  onTap: () {
                    if (widget.activePage != 1) {
                      Navigator.pushReplacementNamed(context, '/admin/profil');
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Role NASABAH: 5 menu persis sesuai referensi gambar
    final isProfilActive = widget.activePage == 1 || widget.activePage == 4;
    final isBerandaActive = widget.activePage == 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 68,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: _buildNavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: 'Beranda',
                  isActive: isBerandaActive,
                  onTap: () {
                    if (!isBerandaActive) {
                      Navigator.pushReplacementNamed(context, '/nasabah/home');
                    }
                  },
                ),
              ),
              Expanded(
                child: _buildNavItem(
                  icon: Icons.receipt_long_outlined,
                  activeIcon: Icons.receipt_long_rounded,
                  label: 'Riwayat',
                  isActive: false,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Riwayat transaksi dapat dilihat pada bagian Aktivitas Terakhir.",
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Floating Center Action Button (Setor Sampah)
              GestureDetector(
                onTap: _showSetorSampahModal,
                child: Container(
                  width: 50,
                  height: 50,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F5A36),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F5A36).withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.recycling_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _buildNavItem(
                  icon: Icons.card_giftcard_outlined,
                  activeIcon: Icons.card_giftcard_rounded,
                  label: 'Tukar',
                  isActive: false,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Fitur Penukaran Hadiah dapat diakses melalui menu Hadiah.",
                        ),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: _buildNavItem(
                  icon: Icons.person_outline_rounded,
                  activeIcon: Icons.person_rounded,
                  label: 'Profil',
                  isActive: isProfilActive,
                  onTap: () {
                    if (!isProfilActive) {
                      Navigator.pushReplacementNamed(context, '/nasabah/profil');
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    const activeColor = Color(0xFF0F5A36);
    const inactiveColor = Color(0xFF6B7280);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? activeColor : inactiveColor,
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}