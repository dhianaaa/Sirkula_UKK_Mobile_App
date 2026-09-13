import 'package:flutter_test/flutter_test.dart';
import 'package:sirkula_banksampah/models/dashboard_summary_model.dart';

void main() {
  group('DashboardSummaryModel Real Backend JSON Parsing', () {
    test('Parses official UKK GET /api/v1/dashboard/summary response', () {
      final json = {
        "statusCode": 200,
        "success": true,
        "message": "Summary dashboard nasabah berhasil diambil",
        "data": {
          "saldoPoinSaatIni": 150,
          "totalSampahDisetorKg": 15,
          "totalPoinDidapat": 150,
          "totalPoinDitukar": 75,
          "transaksiTerakhirSetor": {
            "kodeSetor": "STR-202608-1001",
            "tanggal": "2026-08-26T09:35:51.874Z",
            "beratKg": 15,
            "poin": 150,
            "status": "selesai"
          },
          "transaksiTerakhirTukar": {
            "kodePenukaran": "TKR-202608-5001",
            "tanggal": "2026-08-26T09:35:52.333Z",
            "hadiah": "Voucher Pulsa / E-Wallet Rp 25.000",
            "poin": 75,
            "status": "selesai"
          }
        }
      };

      final summary = DashboardSummaryModel.fromJson(
        json['data'] as Map<String, dynamic>,
      );

      expect(summary.saldoPoin, 150);
      expect(summary.totalSampahDisetorKg, 15);
      expect(summary.totalPemasukanPoin, 150);
      expect(summary.totalPengeluaranPoin, 75);
      expect(summary.transaksiTerakhir.length, 2);

      final itemSetor = summary.transaksiTerakhir[0];
      expect(itemSetor.judul, 'Setor Sampah #STR-202608-1001');
      expect(itemSetor.tipe, 'setor');
      expect(itemSetor.poin, 150);
      expect(itemSetor.beratKg, 15);
      expect(itemSetor.status, 'selesai');

      final itemTukar = summary.transaksiTerakhir[1];
      expect(itemTukar.judul, 'Voucher Pulsa / E-Wallet Rp 25.000');
      expect(itemTukar.tipe, 'tukar');
      expect(itemTukar.poin, 75);
      expect(itemTukar.status, 'selesai');
    });

    test('Parses empty state with zero defaults and empty list', () {
      final summary = DashboardSummaryModel.fromJson({});

      expect(summary.saldoPoin, 0);
      expect(summary.totalSampahDisetorKg, 0);
      expect(summary.totalPemasukanPoin, 0);
      expect(summary.totalPengeluaranPoin, 0);
      expect(summary.transaksiTerakhir, isEmpty);
    });
  });
}
