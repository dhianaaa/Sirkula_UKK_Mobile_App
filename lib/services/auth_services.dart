// services/auth_service.dart
//
// Mengakses endpoint autentikasi backend (register nasabah & login).
// Mengikuti pola dari modul "Register User" & "Membuat Halaman Login":
// - POST dengan body Map
// - Cek statusCode 200 dahulu, baru decode & cek data["status"]
// - Simpan token & profil ke StorageService jika login sukses.

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sirkula_banksampah/models/response_data_map.dart';
import 'package:sirkula_banksampah/models/user_login_model.dart';
import 'package:sirkula_banksampah/services/storage_services.dart';
import 'package:sirkula_banksampah/services/url.dart' as url;

class AuthService {
  final StorageService _storage = StorageService();

  /// Registrasi akun nasabah baru.
  /// endpoint: POST {baseUrl}/auth/register
  Future<ResponseDataMap> registerNasabah(Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('${url.baseUrl}/v1/maker/login');
      final response = await http.post(
        uri,
        body: data.map((key, value) => MapEntry(key, value.toString())),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final decoded = json.decode(response.body);

        if (decoded['status'] == true) {
          return ResponseDataMap(
            status: true,
            message: decoded['message']?.toString() ??
                'Registrasi berhasil, silakan masuk',
            data: decoded['data'],
          );
        } else {
          return ResponseDataMap(
            status: false,
            message: _extractMessage(decoded['message']),
          );
        }
      }

      return ResponseDataMap(
        status: false,
        message: 'Gagal registrasi, kode error ${response.statusCode}',
      );
    } catch (e) {
      return ResponseDataMap(
        status: false,
        message: 'Tidak dapat terhubung ke server. Periksa koneksi Anda.',
      );
    }
  }

  /// Login user (nasabah / admin).
  /// endpoint: POST {baseUrl}/auth/login
  Future<ResponseDataMap> loginUser(Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('${url.baseUrl}/auth/login');
      final response = await http.post(
        uri,
        body: data.map((key, value) => MapEntry(key, value.toString())),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        if (decoded['status'] == true) {
          final userLogin = UserLoginModel.fromApiJson(decoded);
          await _storage.saveUserLogin(userLogin);

          return ResponseDataMap(
            status: true,
            message: decoded['message']?.toString() ?? 'Berhasil masuk',
            data: decoded['data'],
          );
        } else {
          return ResponseDataMap(
            status: false,
            message: _extractMessage(decoded['message']) ??
                'Username atau password salah',
          );
        }
      }

      return ResponseDataMap(
        status: false,
        message: 'Gagal masuk, kode error ${response.statusCode}',
      );
    } catch (e) {
      return ResponseDataMap(
        status: false,
        message: 'Tidak dapat terhubung ke server. Periksa koneksi Anda.',
      );
    }
  }

  /// Logout: hapus session lokal. Endpoint logout ke server bersifat
  /// best-effort (tidak memblokir logout jika gagal/timeout).
  Future<void> logout() async {
    try {
      final user = await _storage.getUserLogin();
      if (user.status && user.token != null) {
        final uri = Uri.parse('${url.baseUrl}/auth/logout');
        await http.post(
          uri,
          headers: {'Authorization': 'Bearer ${user.token}'},
        );
      }
    } catch (_) {
      // Abaikan error jaringan saat logout, tetap hapus session lokal.
    } finally {
      await _storage.clearSession();
    }
  }

  /// Pesan error dari Laravel bisa berupa String atau Map of List
  /// (validation errors: {"field": ["pesan"]}). Ratakan jadi satu String.
  String _extractMessage(dynamic message) {
    if (message == null) return 'Terjadi kesalahan';
    if (message is String) return message;
    if (message is Map) {
      final buffer = StringBuffer();
      for (final key in message.keys) {
        final value = message[key];
        if (value is List && value.isNotEmpty) {
          buffer.writeln(value.first.toString());
        } else {
          buffer.writeln(value.toString());
        }
      }
      return buffer.toString().trim();
    }
    return message.toString();
  }
}