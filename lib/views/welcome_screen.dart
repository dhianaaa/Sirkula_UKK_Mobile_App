// views/welcome_screen.dart

import 'package:flutter/material.dart';

import 'package:sirkula_banksampah/config/app_theme.dart';
import 'package:sirkula_banksampah/widgets/app_button.dart';

const String _kIllustrationAsset = 'assets/pemilahan.png';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Row(
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
              ),
              const Spacer(),
              Container(
                width: double.infinity,
                height: 260,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(
                  _kIllustrationAsset,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        size: 48,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 28),
              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  children: [
                    TextSpan(text: 'Ubah Sampah Jadi '),
                    TextSpan(
                      text: 'Berkah',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Setorkan sampah, dapatkan poin, dan\n'
                'ikut menjaga lingkungan.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
              const Spacer(),
              AppButton(
                label: 'Mulai Sekarang',
                onPressed: () {
                  // Diarahkan ke Pilih Role dulu (Nasabah/Admin),
                  // karena masing-masing punya endpoint register berbeda.
                  Navigator.pushNamed(context, '/pilihrole');
                },
              ),
              const SizedBox(height: 14),
              // GestureDetector(
              //   onTap: () {
              //     Navigator.pushNamed(context, '/login');
              //   },
              //   child: RichText(
              //     text: const TextSpan(
              //       style: TextStyle(
              //         fontFamily: 'Poppins',
              //         fontSize: 13,
              //         color: AppColors.textSecondary,
              //       ),
              //       children: [
              //         TextSpan(text: 'Sudah punya akun? '),
              //         TextSpan(
              //           text: 'Masuk',
              //           style: TextStyle(
              //             color: AppColors.primary,
              //             fontWeight: FontWeight.w600,
              //           ),
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}