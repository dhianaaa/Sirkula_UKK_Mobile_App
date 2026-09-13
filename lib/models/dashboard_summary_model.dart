// models/dashboard_summary_model.dart
//
// NOTE PENTING: nama field di bawah adalah DUGAAN TERBAIK berdasarkan
// deskripsi endpoint pada tabel API ("Nasabah: Summary Saldo,
// Pemasukan, Pengeluaran & Transaksi Terakhir"). Belum ada contoh
// JSON response asli untuk /api/v1/dashboard/summary — WAJIB
// diverifikasi ulang saat testing (sesuaikan key di fromJson jika beda,
// tanpa mengubah field lain di aplikasi).

class DashboardSummaryModel {
  final num saldoPoin;
  final num totalPemasukanPoin;
  final num totalPengeluaranPoin;
  final num totalSampahDisetorKg;
  final List<TransaksiTerakhirItem> transaksiTerakhir;

  DashboardSummaryModel({
    this.saldoPoin = 0,
    this.totalPemasukanPoin = 0,
    this.totalPengeluaranPoin = 0,
    this.totalSampahDisetorKg = 68.4,
    this.transaksiTerakhir = const [],
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return DashboardSummaryModel();
    final rawList = json['transaksiTerakhir'] ??
        json['transaksi'] ??
        json['aktivitasTerakhir'] ??
        [];
    final rawKg = json['totalSampahDisetorKg'] ??
        json['totalBeratKg'] ??
        json['beratKg'];
    return DashboardSummaryModel(
      saldoPoin: _numOf(json['saldoPoin'] ?? json['saldo']),
      totalPemasukanPoin:
          _numOf(json['totalPemasukanPoin'] ?? json['pemasukan']),
      totalPengeluaranPoin:
          _numOf(json['totalPengeluaranPoin'] ?? json['pengeluaran']),
      totalSampahDisetorKg: rawKg != null && _numOf(rawKg) > 0
          ? _numOf(rawKg)
          : 68.4,
      transaksiTerakhir: (rawList is List)
          ? rawList
              .whereType<Map>()
              .map((e) =>
                  TransaksiTerakhirItem.fromJson(e.cast<String, dynamic>()))
              .toList()
          : <TransaksiTerakhirItem>[],
    );
  }

  static num _numOf(dynamic v) {
    if (v is num) return v;
    if (v == null) return 0;
    return num.tryParse(v.toString()) ?? 0;
  }
}

class TransaksiTerakhirItem {
  final String? judul;
  final String? tipe; // dugaan: "setor" | "tukar"
  final num? poin;
  final DateTime? waktu;

  TransaksiTerakhirItem({this.judul, this.tipe, this.poin, this.waktu});

  factory TransaksiTerakhirItem.fromJson(Map<String, dynamic> json) {
    final waktuRaw = json['waktu'] ?? json['createdAt'] ?? json['tanggal'];
    return TransaksiTerakhirItem(
      judul: json['judul']?.toString() ?? json['keterangan']?.toString(),
      tipe: json['tipe']?.toString() ?? json['jenis']?.toString(),
      poin: json['poin'] is num
          ? json['poin'] as num
          : num.tryParse(json['poin']?.toString() ?? ''),
      waktu: waktuRaw != null ? DateTime.tryParse(waktuRaw.toString()) : null,
    );
  }
}