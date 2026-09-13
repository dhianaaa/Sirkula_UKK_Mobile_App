// views/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:sirkula_banksampah/config/app_theme.dart';
import 'package:sirkula_banksampah/controllers/auth_controllers.dart';
import 'package:sirkula_banksampah/utils/validators.dart';
import 'package:sirkula_banksampah/widgets/alert.dart';
import 'package:sirkula_banksampah/widgets/app_button.dart';
import 'package:sirkula_banksampah/widgets/app_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authController = AuthController();
  final _alert = AlertMessage();

  final TextEditingController _username = TextEditingController();
  final TextEditingController _password = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final result = await _authController.login(
      username: _username.text.trim(),
      password: _password.text,
    );

    if (!mounted) return;

    if (result.status == true) {
      _alert.showAlert(context, result.message, true);

      final role = result.data?['role'];
      final targetRoute = role == 'ADMIN' ? '/admin/dashboard' : '/nasabah/home';

      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        Navigator.pushNamedAndRemoveUntil(
          context,
          targetRoute,
          (route) => false,
        );
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
                const SizedBox(height: 28),
                const Text(
                  "Selamat Datang Kembali",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Masuk untuk melanjutkan setoran sampah dan saldo poin.",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 28),
                AppTextField(
                  label: "Username",
                  hint: "Masukkan username",
                  controller: _username,
                  prefixIcon: Icons.person_outline,
                  validator: Validators.username,
                ),
                AppTextField(
                  label: "Password",
                  hint: "Masukkan password",
                  controller: _password,
                  prefixIcon: Icons.lock_outline,
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
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      _alert.showAlert(
                        context,
                        "Fitur lupa password belum tersedia di API",
                        false,
                      );
                    },
                    child: const Text(
                      "Lupa Password?",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: AppColors.primary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                AnimatedBuilder(
                  animation: _authController,
                  builder: (context, _) {
                    return AppButton(
                      label: "Masuk",
                      isLoading: _authController.isLoading,
                      onPressed: _submitLogin,
                    );
                  },
                ),
                const SizedBox(height: 24),
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pushNamed(context, '/register'),
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                        children: [
                          TextSpan(text: "Belum punya akun? "),
                          TextSpan(
                            text: "Daftar",
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}