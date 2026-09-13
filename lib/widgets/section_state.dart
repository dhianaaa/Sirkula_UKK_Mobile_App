// widgets/section_state.dart
//
// Reusable loading/error/empty untuk section dashboard (dipakai di
// Nasabah & Admin Home Screen), sesuai aturan #30 (jangan membuat
// widget yang sama berulang kali) dan #31 (setiap halaman API wajib
// punya loading/success/empty/error/retry).

import 'package:flutter/material.dart';
import 'package:sirkula_banksampah/config/app_theme.dart';

class SectionState extends StatelessWidget {
  final Widget child;
  const SectionState._(this.child);

  factory SectionState.loading() {
    return const SectionState._(
      Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
    );
  }

  factory SectionState.error(String message, VoidCallback onRetry) {
    return SectionState._(
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12.5,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text(
                "Coba Lagi",
                style: TextStyle(fontFamily: 'Poppins', fontSize: 12.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  factory SectionState.empty(String message) {
    return SectionState._(
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12.5,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => child;
}