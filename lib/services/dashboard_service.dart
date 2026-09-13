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
    // hitung ringkasan secara mandiri dari data transaksi /setor-sampah/my-setor, /penukaran-poin/my-penukaran, dan user.
    try {
      final user = await _storage.getUserLogin();
      final setors = await getMySetor();
      final penukarans = await getMyPenukaran();

      num totalSampahDisetorKg = 0;
      num totalPemasukanPoin = 0;
      num totalPengeluaranPoin = 0;
      List<Map<String, dynamic>> listTransaksi = [];

      for (var item in setors) {
        final berat = (item['totalBeratKg'] is num) ? item['totalBeratKg'] as num : 0;
        final poin = (item['totalPoin'] is num) ? item['totalPoin'] as num : 0;
        totalSampahDisetorKg += berat;
        totalPemasukanPoin += poin;

        listTransaksi.add({
          'judul': 'Setor Sampah #${item['kodeSetor'] ?? ''}',
          'tipe': 'setor',
          'poin': poin,
          'beratKg': berat,
          'status': item['status']?.toString() ?? 'selesai',
          'waktu': item['tanggal'] ?? item['createdAt'],
        });
      }

      for (var item in penukarans) {
        final poin = (item['poinTerpakai'] is num) ? item['poinTerpakai'] as num : 0;
        totalPengeluaranPoin += poin;

        final hadiah = item['hadiah'] is Map ? item['hadiah']['namaHadiah'] : null;
        listTransaksi.add({
          'judul': hadiah?.toString() ?? 'Tukar Poin #${item['kodePenukaran'] ?? ''}',
          'tipe': 'tukar',
          'poin': poin,
          'status': item['status']?.toString() ?? 'selesai',
          'waktu': item['tanggal'] ?? item['createdAt'],
        });
      }

      // Urutkan transaksi dari yang paling baru
      listTransaksi.sort((a, b) {
        final timeA = a['waktu'] != null ? DateTime.tryParse(a['waktu'].toString()) : null;
        final timeB = b['waktu'] != null ? DateTime.tryParse(b['waktu'].toString()) : null;
        if (timeA == null && timeB == null) return 0;
        if (timeA == null) return 1;
        if (timeB == null) return -1;
        return timeB.compareTo(timeA);
      });

      final saldoAktual = user.saldoPoin ?? (totalPemasukanPoin - totalPengeluaranPoin);

      return ResponseDataMap(
        status: true,
        message: 'Berhasil memuat ringkasan',
        data: {
          'saldoPoin': saldoAktual < 0 ? 0 : saldoAktual,
          'saldoPoinSaatIni': saldoAktual < 0 ? 0 : saldoAktual,
          'totalSampahDisetorKg': totalSampahDisetorKg,
          'totalPemasukanPoin': totalPemasukanPoin,
          'totalPoinDidapat': totalPemasukanPoin,
          'totalPengeluaranPoin': totalPengeluaranPoin,
          'totalPoinDitukar': totalPengeluaranPoin,
          'transaksiTerakhir': listTransaksi.take(5).toList(),
        },
      );
    } catch (_) {
      return result;
    }
  }

  /// Mengambil daftar pengajuan & histori penyetoran sampah nasabah
  /// endpoint: GET /api/v1/setor-sampah/my-setor (?bulan=YYYY-MM)
  Future<List<Map<String, dynamic>>> getMySetor({String? bulan}) async {
    try {
      final user = await _storage.getUserLogin();
      var endpoint = '${url.baseUrl}/setor-sampah/my-setor';
      if (bulan != null && bulan.isNotEmpty) {
        endpoint += '?bulan=$bulan';
      }
      final response = await http.get(
        Uri.parse(endpoint),
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

  /// Mengambil histori penukaran poin nasabah
  /// endpoint: GET /api/v1/penukaran-poin/my-penukaran
  Future<List<Map<String, dynamic>>> getMyPenukaran() async {
    try {
      final user = await _storage.getUserLogin();
      final response = await http.get(
        Uri.parse('${url.baseUrl}/penukaran-poin/my-penukaran'),
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

  /// Mengajukan penyetoran sampah baru (multi-item)
  /// endpoint: POST /api/v1/setor-sampah/pengajuan
  Future<ResponseDataMap> ajukanSetor(Map<String, dynamic> data) async {
    try {
      final user = await _storage.getUserLogin();
      final response = await http.post(
        Uri.parse('${url.baseUrl}/setor-sampah/pengajuan'),
        headers: url.defaultHeaders(token: user.token),
        body: json.encode(data),
      );
      final decoded = json.decode(response.body);
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          decoded['success'] == true) {
        return ResponseDataMap(
          status: true,
          message: decoded['message']?.toString() ?? 'Pengajuan setor berhasil dibuat',
          data: decoded['data'] is Map ? decoded['data'] : null,
        );
      }
      return ResponseDataMap(
        status: false,
        message: decoded['message']?.toString() ?? 'Gagal mengajukan penyetoran',
      );
    } catch (_) {
      return ResponseDataMap(
        status: false,
        message: 'Tidak dapat terhubung ke server.',
      );
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

  /// Mengambil katalog barang / voucher hadiah
  /// endpoint: GET /api/v1/hadiah
  Future<List<Map<String, dynamic>>> getHadiah() async {
    try {
      final user = await _storage.getUserLogin();
      final uri = Uri.parse('${url.baseUrl}/hadiah');
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

  /// Menukar poin dengan hadiah
  /// endpoint: POST /api/v1/penukaran-poin/tukar
  Future<ResponseDataMap> tukarPoin(String hadiahId) async {
    try {
      final user = await _storage.getUserLogin();
      final uri = Uri.parse('${url.baseUrl}/penukaran-poin/tukar');
      final response = await http.post(
        uri,
        headers: url.defaultHeaders(token: user.token),
        body: json.encode({'hadiahId': hadiahId}),
      );
      final decoded = json.decode(response.body);
      if ((response.statusCode == 200 || response.statusCode == 201) &&
          decoded['success'] == true) {
        return ResponseDataMap(
          status: true,
          message: decoded['message']?.toString() ?? 'Penukaran poin berhasil',
          data: decoded['data'] is Map ? decoded['data'] : null,
        );
      }
      return ResponseDataMap(
        status: false,
        message: decoded['message']?.toString() ?? 'Gagal menukar poin',
      );
    } catch (_) {
      return ResponseDataMap(
        status: false,
        message: 'Tidak dapat terhubung ke server.',
      );
    }
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