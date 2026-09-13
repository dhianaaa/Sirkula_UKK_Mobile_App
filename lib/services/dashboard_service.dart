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

  Future<ResponseDataMap> getSummary() async {
    final result = await _getMap('${url.baseUrl}/dashboard/summary');
    if (result.status) return result;

    // Fallback: Jika endpoint backend /dashboard/summary menghasilkan 401 karena kendala middleware backend,
    // hitung ringkasan secara mandiri dari data transaksi /setor-sampah/my-setor dan saldo user.
    try {
      final user = await _storage.getUserLogin();
      final setorResp = await http.get(
        Uri.parse('${url.baseUrl}/setor-sampah/my-setor'),
        headers: url.defaultHeaders(token: user.token),
      );

      num totalSampahDisetorKg = 0;
      num totalPemasukanPoin = 0;
      List<dynamic> listTransaksi = [];

      if (setorResp.statusCode == 200) {
        final decodedSetor = json.decode(setorResp.body);
        if (decodedSetor['data'] is List) {
          final items = decodedSetor['data'] as List;
          for (var item in items) {
            totalSampahDisetorKg +=
                (item['totalBeratKg'] is num) ? item['totalBeratKg'] : 0;
            totalPemasukanPoin +=
                (item['totalPoin'] is num) ? item['totalPoin'] : 0;
          }
          listTransaksi = items.take(5).map((e) => {
                'judul': 'Setor Sampah #${e['kodeSetor'] ?? ''}',
                'tipe': 'setor',
                'poin': e['totalPoin'] ?? 0,
                'waktu': e['tanggal'],
              }).toList();
        }
      }

      return ResponseDataMap(
        status: true,
        message: 'Berhasil memuat ringkasan',
        data: {
          'saldoPoin': user.saldoPoin ?? totalPemasukanPoin,
          'saldoPoinSaatIni': user.saldoPoin ?? totalPemasukanPoin,
          'totalSampahDisetorKg': totalSampahDisetorKg,
          'totalPemasukanPoin': totalPemasukanPoin,
          'totalPoinDidapat': totalPemasukanPoin,
          'totalPengeluaranPoin': 0,
          'transaksiTerakhir': listTransaksi,
        },
      );
    } catch (_) {
      return result;
    }
  }

  Future<ResponseDataMap> getStats() =>
      _getMap('${url.baseUrl}/dashboard/stats');

  Future<List<Map<String, dynamic>>> getKategoriSampah() async {
    try {
      final user = await _storage.getUserLogin();
      final uri = Uri.parse('${url.baseUrl}/kategori-sampah');
      final response = await http.get(
        uri,
        headers: url.defaultHeaders(token: user.token),
      );
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded['data'] is List) {
          return List<Map<String, dynamic>>.from(decoded['data']);
        }
      }
    } catch (_) {}
    return [];
  }

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