// views/admin/admin_register_screen.dart
//
// Registrasi Unit Admin Bank Sampah baru.
// endpoint: POST /api/v1/auth/admin/register
// body: { username, password, namaUnit, namaPengelola, telp }

import 'package:flutter/material.dart';
import 'package:sirkula_banksampah/config/app_theme.dart';
import 'package:sirkula_banksampah/controllers/auth_controllers.dart';
import 'package:sirkula_banksampah/utils/validators.dart';
import 'package:sirkula_banksampah/widgets/alert.dart';
import 'package:sirkula_banksampah/widgets/app_button.dart';
import 'package:sirkula_banksampah/widgets/app_text_field.dart';

class RegisterAdminScreen extends StatefulWidget {
  const RegisterAdminScreen({super.key});

  @override
  State<RegisterAdminScreen> createState() => _RegisterAdminScreenState();
}

class _RegisterAdminScreenState extends State<RegisterAdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authController = AuthController();
  final _alert = AlertMessage();

  final TextEditingController _namaUnit = TextEditingController();
  final TextEditingController _namaPengelola = TextEditingController();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _telp = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _konfirmasiPassword = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureKonfirmasi = true;

  @override
  void dispose() {
    _namaUnit.dispose();
    _namaPengelola.dispose();
    _username.dispose();
    _telp.dispose();
    _password.dispose();
    _konfirmasiPassword.dispose();
    super.dispose();
  }

  Future<void> _submitRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final result = await _authController.registerAdmin(
      username: _username.text.trim(),
      password: _password.text,
      namaUnit: _namaUnit.text.trim(),
      namaPengelola: _namaPengelola.text.trim(),
      telp: _telp.text.trim(),
    );

    if (!mounted) return;

    if (result.status == true) {
      _alert.showAlert(
        context,
        "Registrasi unit berhasil, silakan masuk dengan akun Anda",
        true,
      );
      Future.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/loginadmin');
      });
    } else {
      _alert.showAlert(context, result.message, false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () => Navigator.of(context).maybePop(),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back, size: 18),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Daftar Unit Bank Sampah",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Daftarkan unit bank sampah Anda untuk mulai mengelola "
                  "nasabah, kategori sampah, dan pengajuan setoran.",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                AppTextField(
                  label: "Nama Unit",
                  hint: "Contoh: Bank Sampah Sejahtera",
                  controller: _namaUnit,
                  validator: (v) => Validators.required(v, field: "Nama unit"),
                ),
                AppTextField(
                  label: "Nama Pengelola",
                  hint: "Nama penanggung jawab unit",
                  controller: _namaPengelola,
                  validator: (v) =>
                      Validators.required(v, field: "Nama pengelola"),
                ),
                AppTextField(
                  label: "Username",
                  hint: "Buat nama pengguna",
                  controller: _username,
                  validator: Validators.username,
                ),
                AppTextField(
                  label: "Nomor Telepon",
                  hint: "812xxxxxxxx",
                  controller: _telp,
                  keyboardType: TextInputType.phone,
                  validator: Validators.phone,
                ),
                AppTextField(
                  label: "Password",
                  hint: "Minimal 8 karakter",
                  controller: _password,
                  obscureText: _obscurePassword,
                  validator: Validators.password,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
                AppTextField(
                  label: "Konfirmasi Password",
                  hint: "Ulangi password",
                  controller: _konfirmasiPassword,
                  obscureText: _obscureKonfirmasi,
                  validator: (v) =>
                      Validators.confirmPassword(v, _password.text),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureKonfirmasi
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () {
                      setState(() => _obscureKonfirmasi = !_obscureKonfirmasi);
                    },
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedBuilder(
                  animation: _authController,
                  builder: (context, _) {
                    return AppButton(
                      label: "Daftar Unit",
                      isLoading: _authController.isLoading,
                      onPressed: _submitRegister,
                    );
                  },
                ),
                const SizedBox(height: 20),
                Center(
                  child: GestureDetector(
                    onTap: () =>
                        Navigator.pushReplacementNamed(context, '/loginadmin'),
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                        children: [
                          TextSpan(text: "Sudah punya akun? "),
                          TextSpan(
                            text: "Masuk",
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}