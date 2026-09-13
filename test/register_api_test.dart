import 'package:flutter_test/flutter_test.dart';
import 'package:sirkula_banksampah/services/auth_services.dart';

void main() {
  test('AuthService - registerNasabah duplicate validation test', () async {
    final authService = AuthService();
    
    // Gunakan user yang sudah terdaftar (test_check) untuk memverifikasi respon validasi dari backend
    final result = await authService.registerNasabah({
      "username": "test_check",
      "password": "password123",
      "namaNasabah": "Test User",
      "alamat": "Jl Test No. 1",
      "telp": "081234567890",
    });

    // Harus berhasil terhubung ke server dan mendapatkan respon status=false karena username duplikat
    expect(result.status, false);
    expect(result.message.contains('sudah digunakan'), true);
  });
}
