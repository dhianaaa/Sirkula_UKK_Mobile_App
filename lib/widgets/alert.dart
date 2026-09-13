// widgets/alert_message.dart
//
// Menampilkan snackbar sukses (hijau) atau gagal (merah) di atas layar
// manapun. Dipanggil dari controller/view: AlertMessage().showAlert(
// context, message, status).

import 'package:flutter/material.dart';
import 'package:sirkula_banksampah/config/app_theme.dart';

class AlertMessage {
  void showAlert(BuildContext context, String message, bool status) {
    final Color fillColor =
        status ? AppColors.primaryLight.withOpacity(0.35) : Colors.red[100]!;
    final Color borderColor = status ? AppColors.success : AppColors.error;
    final IconData icon =
        status ? Icons.check_circle_outline : Icons.error_outline;

    final snackBar = SnackBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
      content: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: fillColor,
          border: Border.all(color: borderColor, width: 1.4),
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
              color: Color(0x19000000),
              spreadRadius: 1,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: borderColor, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12.5,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
              child: const Text(
                "X",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }
}