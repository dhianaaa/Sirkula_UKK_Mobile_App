// services/url.dart
//
// Base URL backend SIRKULA. Sesuaikan dengan environment kamu:
// - Emulator Android mengakses localhost mesin lewat 10.0.2.2
// - Device fisik / browser: ganti dengan IP komputer kamu atau domain
//   backend online.

// Contoh jika backend Laravel dijalankan lokal (php artisan serve)
// dan diakses dari Android Emulator:
// Base URL backend SIRKULA resmi (UKK 2026/2027)
final String baseUrl = "https://learn.smktelkom-mlg.sch.id/bank_sampah/api/v1";

// Base URL tanpa /api untuk keperluan asset/gambar storage backend jika ada
final String baseUrlTanpaApi = "https://learn.smktelkom-mlg.sch.id/bank_sampah";

// App Key unik milik siswa (App Maker)
const String appKey = "76eb039b-a62b-48e0-994a-2bbd6543b318";

/// Helper untuk menyusun headers standar ke API backend
Map<String, String> defaultHeaders({String? token}) {
  final headers = <String, String>{
    'Content-Type': 'application/json',
    'x-app-key': appKey,
  };
  if (token != null && token.isNotEmpty) {
    headers['Authorization'] = 'Bearer $token';
  }
  return headers;
}