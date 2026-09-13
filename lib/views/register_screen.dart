// views/auth/register_screen.dart

import 'package:flutter/material.dart';
import 'package:sirkula_banksampah/config/app_theme.dart';
import 'package:sirkula_banksampah/controllers/auth_controllers.dart';
import 'package:sirkula_banksampah/utils/validators.dart';
import 'package:sirkula_banksampah/widgets/alert.dart';
import 'package:sirkula_banksampah/widgets/app_button.dart';
import 'package:sirkula_banksampah/widgets/app_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authController = AuthController();
  final _alert = AlertMessage();

  final TextEditingController _namaLengkap = TextEditingController();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _telp = TextEditingController();
  final TextEditingController _alamat = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _konfirmasiPassword = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureKonfirmasi = true;

  @override
  void dispose() {
    _namaLengkap.dispose();
    _username.dispose();
    _telp.dispose();
    _alamat.dispose();
    _password.dispose();
    _konfirmasiPassword.dispose();
    super.dispose();
  }

  Future<void> _submitRegister() async {
    if (!_formKey.currentState!.validate()) return;

    // Nomor telepon digabung dengan kode negara +62 sesuai tampilan UI.
    final telpFinal = "+62${_telp.text.trim()}";

    final result = await _authController.registerNasabah(
      username: _username.text.trim(),
      password: _password.text,
      namaNasabah: _namaLengkap.text.trim(),
      alamat: _alamat.text.trim(),
      telp: telpFinal,
    );

    if (!mounted) return;

    if (result.status == true) {
      _alert.showAlert(
        context,
        "Registrasi berhasil, silakan masuk dengan akun Anda",
        true,
      );
      Future.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/login');
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    Row(
                        children: [
    ClipRect(
      child: SizedBox(
        width: 87,
        height: 28,
        child: Image.asset(
          'assets/logoatas.png',
          height: 28,
          fit: BoxFit.fitHeight,
          alignment: Alignment.centerLeft,
        ),
      ),
    ),
  ]
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  "Buat Akun SIRKULA",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Daftar untuk mulai menyetor sampah dan mengumpulkan poin.",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                AppTextField(
                  label: "Nama Lengkap",
                  hint: "Masukkan nama sesuai KTP",
                  controller: _namaLengkap,
                  validator: (v) => Validators.required(v, field: "Nama lengkap"),
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
                  prefixText: "+62  ",
                  keyboardType: TextInputType.phone,
                  validator: Validators.phone,
                ),
                AppTextField(
                  label: "Alamat",
                  hint: "Jl. Contoh No. 12, RT/RW...",
                  controller: _alamat,
                  maxLines: 2,
                  validator: (v) => Validators.required(v, field: "Alamat"),
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
                      label: "Daftar",
                      isLoading: _authController.isLoading,
                      onPressed: _submitRegister,
                    );
                  },
                ),
                const SizedBox(height: 20),
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pushReplacementNamed(context, '/login'),
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