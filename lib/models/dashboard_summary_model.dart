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
    this.totalSampahDisetorKg = 0,
    this.transaksiTerakhir = const [],
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return DashboardSummaryModel();

    final rawKg = json['totalSampahDisetorKg'] ??
        json['totalBeratKg'] ??
        json['beratKg'] ??
        0;

    final List<TransaksiTerakhirItem> list = [];

    // Cek apakah ada list transaksi
    final rawList = json['transaksiTerakhir'] ??
        json['transaksi'] ??
        json['aktivitasTerakhir'];

    if (rawList is List) {
      for (final e in rawList) {
        if (e is Map<String, dynamic>) {
          list.add(TransaksiTerakhirItem.fromJson(e));
        } else if (e is Map) {
          list.add(TransaksiTerakhirItem.fromJson(e.cast<String, dynamic>()));
        }
      }
    } else {
      // Cek format spesifik resmi UKK: transaksiTerakhirSetor & transaksiTerakhirTukar
      final rawSetor = json['transaksiTerakhirSetor'];
      if (rawSetor is Map) {
        list.add(TransaksiTerakhirItem(
          judul: 'Setor Sampah #${rawSetor['kodeSetor'] ?? ''}',
          tipe: 'setor',
          poin: _numOf(rawSetor['poin']),
          beratKg: _numOf(rawSetor['beratKg']),
          status: rawSetor['status']?.toString() ?? 'selesai',
          waktu: rawSetor['tanggal'] != null
              ? DateTime.tryParse(rawSetor['tanggal'].toString())
              : null,
        ));
      }

      final rawTukar = json['transaksiTerakhirTukar'];
      if (rawTukar is Map) {
        list.add(TransaksiTerakhirItem(
          judul: rawTukar['hadiah']?.toString() ??
              'Tukar Poin #${rawTukar['kodePenukaran'] ?? ''}',
          tipe: 'tukar',
          poin: _numOf(rawTukar['poin']),
          status: rawTukar['status']?.toString() ?? 'selesai',
          waktu: rawTukar['tanggal'] != null
              ? DateTime.tryParse(rawTukar['tanggal'].toString())
              : null,
        ));
      }
    }

    return DashboardSummaryModel(
      saldoPoin: _numOf(
          json['saldoPoinSaatIni'] ?? json['saldoPoin'] ?? json['saldo']),
      totalPemasukanPoin: _numOf(
          json['totalPoinDidapat'] ?? json['totalPemasukanPoin'] ?? json['pemasukan']),
      totalPengeluaranPoin: _numOf(
          json['totalPoinDitukar'] ?? json['totalPengeluaranPoin'] ?? json['pengeluaran']),
      totalSampahDisetorKg: _numOf(rawKg),
      transaksiTerakhir: list,
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
  final String? tipe; // "setor" | "tukar"
  final num? poin;
  final num? beratKg;
  final String? status;
  final DateTime? waktu;

  TransaksiTerakhirItem({
    this.judul,
    this.tipe,
    this.poin,
    this.beratKg,
    this.status,
    this.waktu,
  });

  factory TransaksiTerakhirItem.fromJson(Map<String, dynamic> json) {
    final waktuRaw = json['waktu'] ?? json['createdAt'] ?? json['tanggal'];
    return TransaksiTerakhirItem(
      judul: json['judul']?.toString() ?? json['keterangan']?.toString(),
      tipe: json['tipe']?.toString() ?? json['jenis']?.toString(),
      poin: json['poin'] is num
          ? json['poin'] as num
          : num.tryParse(json['poin']?.toString() ?? ''),
      beratKg: json['beratKg'] is num
          ? json['beratKg'] as num
          : num.tryParse(json['beratKg']?.toString() ?? ''),
      status: json['status']?.toString(),
      waktu: waktuRaw != null ? DateTime.tryParse(waktuRaw.toString()) : null,
    );
  }
}