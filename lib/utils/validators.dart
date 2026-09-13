// utils/validators.dart
//
// Kumpulan validator untuk TextFormField, dipakai di seluruh form
// (login, register, dll) agar aturan validasi konsisten & tidak
// ditulis ulang di setiap screen.

class Validators {
  Validators._();

  static String? required(String? value, {String field = "Field ini"}) {
    if (value == null || value.trim().isEmpty) {
      return '$field harus diisi';
    }
    return null;
  }

  static String? username(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username harus diisi';
    }
    if (value.trim().length < 4) {
      return 'Username minimal 4 karakter';
    }
    if (value.contains(' ')) {
      return 'Username tidak boleh mengandung spasi';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password harus diisi';
    }
    if (value.length < 6) {
      return 'Password minimal 6 karakter';
    }
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if (value == null || value.isEmpty) {
      return 'Konfirmasi password harus diisi';
    }
    if (value != original) {
      return 'Konfirmasi password tidak sama';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Nomor telepon harus diisi';
    }
    final digitsOnly = RegExp(r'^[0-9]+$');
    if (!digitsOnly.hasMatch(value.trim())) {
      return 'Nomor telepon hanya boleh berisi angka';
    }
    if (value.trim().length < 8 || value.trim().length > 13) {
      return 'Nomor telepon tidak valid';
    }
    return null;
  }
}