// services/dashboard_services.dart
//
// Mengambil ringkasan dashboard dari backend.
// - Nasabah: GET /api/v1/dashboard/summary
// - Admin  : GET /api/v1/dashboard/stats
//
// Mengikuti pola AuthService: cek statusCode dahulu, baru decode &
// cek decoded["success"]. Jika 401, hapus session lokal (token invalid).

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sirkula_banksampah/models/response_data_map.dart';
import 'package:sirkula_banksampah/services/storage_services.dart';
import 'package:sirkula_banksampah/services/url.dart' as url;

class DashboardService {
  final StorageService _storage = StorageService();

  Future<ResponseDataMap> getSummary() => _getMap('${url.baseUrl}/dashboard/summary');

  Future<ResponseDataMap> getStats() => _getMap('${url.baseUrl}/dashboard/stats');

  Future<ResponseDataMap> _getMap(String endpoint) async {
    try {
      final user = await _storage.getUserLogin();
      final uri = Uri.parse(endpoint);
      final response = await http.get(
        uri,
        headers: url.defaultHeaders(token: user.token),
      );

      final decoded = json.decode(response.body);

      if (response.statusCode == 200 && decoded['success'] == true) {
        return ResponseDataMap(
          status: true,
          message: decoded['message']?.toString() ?? 'Berhasil',
          data: decoded['data'] is Map ? decoded['data'] : null,
        );
      }

      if (response.statusCode == 401) {
        // Token expired/invalid -> hapus session, JANGAN hapus App Key
        // (App Key disimpan konstan di url.dart, bukan di session).
        await _storage.clearSession();
      }

      return ResponseDataMap(
        status: false,
        message: decoded['message']?.toString() ?? 'Gagal memuat data',
      );
    } catch (e) {
      return ResponseDataMap(
        status: false,
        message: 'Tidak dapat terhubung ke server. Periksa koneksi Anda.',
      );
    }
  }
}