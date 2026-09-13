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
  /// endpoint: POST {baseUrl}/auth/nasabah/register
  Future<ResponseDataMap> registerNasabah(Map<String, dynamic> data) async {
    try {
      final uri = Uri.parse('${url.baseUrl}/auth/nasabah/register');
      final response = await http.post(
        uri,
        headers: url.defaultHeaders(),
        body: json.encode(data),
      );

      final decoded = json.decode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          decoded['success'] == true) {
        return ResponseDataMap(
          status: true,
          message: decoded['message']?.toString() ??
              'Registrasi berhasil, silakan masuk',
          data: decoded['data'] is Map ? decoded['data'] : null,
        );
      } else {
        return ResponseDataMap(
          status: false,
          message: _extractMessage(decoded['message'] ?? decoded['errors']),
        );
      }
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
        headers: url.defaultHeaders(),
        body: json.encode(data),
      );

      final decoded = json.decode(response.body);

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          decoded['success'] == true) {
        final userLogin = UserLoginModel.fromApiJson(decoded);
        await _storage.saveUserLogin(userLogin);

        return ResponseDataMap(
          status: true,
          message: decoded['message']?.toString() ?? 'Berhasil masuk',
          data: decoded['data'] is Map ? decoded['data'] : null,
        );
      } else {
        return ResponseDataMap(
          status: false,
          message: _extractMessage(decoded['message'] ?? decoded['errors']),
        );
      }
    } catch (e) {
      return ResponseDataMap(
        status: false,
        message: 'Tidak dapat terhubung ke server. Periksa koneksi Anda.',
      );
    }
  }

  /// Logout: hapus session lokal.
  Future<void> logout() async {
    try {
      final user = await _storage.getUserLogin();
      if (user.status && user.token != null) {
        final uri = Uri.parse('${url.baseUrl}/auth/logout');
        await http.post(
          uri,
          headers: url.defaultHeaders(token: user.token),
        );
      }
    } catch (_) {
      // Abaikan error jaringan saat logout, tetap hapus session lokal.
    } finally {
      await _storage.clearSession();
    }
  }

  /// Pesan error dari backend bisa berupa String, List, atau Map.
  String _extractMessage(dynamic message) {
    if (message == null) return 'Terjadi kesalahan pada server';
    if (message is String) return message;
    if (message is List) {
      if (message.isEmpty) return 'Terjadi kesalahan pada server';
      return message.map((e) => e.toString()).join('\n');
    }
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