// views/pilih_role_screen.dart
//
// Layar pemilihan role sebelum mendaftar/masuk, sesuai desain UI yang
// dikirim: dua kartu (Nasabah / Admin) dengan state selected, lalu
// tombol "Lanjutkan" yang mengarahkan ke alur pendaftaran yang sesuai.
//
// Nasabah -> '/register'         (RegisterScreen, sudah ada)
// Admin   -> '/admin/register'   (AdminRegisterScreen, sudah ada)
//
// Untuk user yang SUDAH punya akun (Nasabah maupun Admin), disediakan
// link "Sudah punya akun? Masuk" -> '/login'. Login TIDAK dibedakan per
// role di sini karena endpoint /auth/login bersifat unified — role
// ditentukan backend dari response, lalu login_screen.dart yang
// menentukan redirect ke '/admin/dashboard' atau '/nasabah/home'.
//
// TODO(main.dart): daftarkan kedua route berikut:
//   '/pilih-role'     -> const PilihRoleScreen()
//   '/admin/register' -> const AdminRegisterScreen()

import 'package:flutter/material.dart';
import 'package:sirkula_banksampah/config/app_theme.dart';

enum SirkulaRole { nasabah, admin }

class PilihRoleScreen extends StatefulWidget {
  const PilihRoleScreen({super.key});

  @override
  State<PilihRoleScreen> createState() => _PilihRoleScreenState();
}

class _PilihRoleScreenState extends State<PilihRoleScreen> {
  SirkulaRole _selected = SirkulaRole.nasabah;

  void _lanjutkan() {
    if (_selected == SirkulaRole.nasabah) {
      Navigator.pushNamed(context, '/registernasabah');
    } else {
      Navigator.pushNamed(context, '/registeradmin');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 45),
              _buildLogo(),
              const SizedBox(height: 75),
              const Text(
                "Pilih Role Anda",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 29,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Masuk sebagai nasabah atau admin\nuntuk melanjutkan.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 75),
              _roleCard(
                role: SirkulaRole.nasabah,
                icon: Icons.eco_outlined,
                title: "Nasabah",
                tag: "WARGA",
                description:
                    "Setor sampah, kumpulkan poin, dan tukarkan dengan hadiah.",
              ),
              const SizedBox(height: 14),
              _roleCard(
                role: SirkulaRole.admin,
                icon: Icons.inventory_2_outlined,
                title: "Admin",
                tag: "PETUGAS",
                description:
                    "Kelola nasabah, sampah, hadiah, dan pengajuan setoran.",
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _lanjutkan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Lanjutkan",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              // Center(
              //   child: GestureDetector(
              //     onTap: () => Navigator.pushNamed(context, '/login'),
              //     child: RichText(
              //       text: const TextSpan(
              //         style: TextStyle(
              //           fontFamily: 'Poppins',
              //           fontSize: 13,
              //           color: AppColors.textSecondary,
              //         ),
              //         children: [
              //           TextSpan(text: "Sudah punya akun? "),
              //           TextSpan(
              //             text: "Masuk",
              //             style: TextStyle(
              //               color: AppColors.primary,
              //               fontWeight: FontWeight.w600,
              //             ),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ),
              // ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified_user_outlined,
                      size: 13,
                      color: AppColors.textSecondary.withValues(alpha: 0.8)),
                  const SizedBox(width: 6),
                  const Flexible(
                    child: Text(
                      "Peran dapat disesuaikan kembali lewat pengaturan akun",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // GestureDetector(
              //   onTap: () {
              //     // TODO: belum ada endpoint/kontak dukungan resmi di
              //     // dokumentasi API — tautan ini sementara tidak melakukan
              //     // navigasi apa pun.
              //   },
              //   child: const Text(
              //     "Perlu bantuan memilih akun? Hubungi Admin",
              //     style: TextStyle(
              //       fontFamily: 'Poppins',
              //       fontSize: 12,
              //       fontWeight: FontWeight.w600,
              //       color: AppColors.primary,
              //     ),
              //   ),
              // ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
                  ClipRect(
                    child: SizedBox(
                      width: 110,
                      height: 35,
                      child: Image.asset(
                        'assets/logoatas.png',
                        height: 35,
                        fit: BoxFit.fitHeight,
                        alignment: Alignment.centerLeft,
                      ),
                    ),
                  ),
                ],
    );
  }

  Widget _roleCard({
    required SirkulaRole role,
    required IconData icon,
    required String title,
    required String tag,
    required String description,
  }) {
    final bool selected = _selected == role;

    return GestureDetector(
      onTap: () => setState(() => _selected = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.06)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: selected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          tag,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              selected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: selected ? AppColors.primary : AppColors.border,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}