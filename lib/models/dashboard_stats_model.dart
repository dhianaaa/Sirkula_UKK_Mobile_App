// models/dashboard_stats_model.dart
//
// NOTE PENTING: nama field adalah DUGAAN TERBAIK berdasarkan deskripsi
// endpoint ("Admin: Statistik Umum - Total Nasabah, Saldo, Sampah,
// Transaksi"). Belum ada contoh JSON response asli untuk
// /api/v1/dashboard/stats — WAJIB diverifikasi ulang saat testing.

class DashboardStatsModel {
  final int totalNasabah;
  final num totalSaldoPoin;
  final num totalSampahKg;
  final int totalTransaksi;

  DashboardStatsModel({
    this.totalNasabah = 0,
    this.totalSaldoPoin = 0,
    this.totalSampahKg = 0,
    this.totalTransaksi = 0,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return DashboardStatsModel();
    return DashboardStatsModel(
      totalNasabah: _intOf(json['totalNasabah'] ?? json['jumlahNasabah']),
      totalSaldoPoin:
          _numOf(json['totalSaldoPoin'] ?? json['totalSaldo'] ?? json['saldo']),
      totalSampahKg: _numOf(
          json['totalSampahKg'] ?? json['totalTonase'] ?? json['totalSampah']),
      totalTransaksi:
          _intOf(json['totalTransaksi'] ?? json['jumlahTransaksi']),
    );
  }

  static int _intOf(dynamic v) {
    if (v is num) return v.toInt();
    if (v == null) return 0;
    return int.tryParse(v.toString()) ?? 0;
  }

  static num _numOf(dynamic v) {
    if (v is num) return v;
    if (v == null) return 0;
    return num.tryParse(v.toString()) ?? 0;
  }
}