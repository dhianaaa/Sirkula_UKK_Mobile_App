// services/url.dart
//
// Base URL backend SIRKULA. Sesuaikan dengan environment kamu:
// - Emulator Android mengakses localhost mesin lewat 10.0.2.2
// - Device fisik / browser: ganti dengan IP komputer kamu atau domain
//   backend online.

// Contoh jika backend Laravel dijalankan lokal (php artisan serve)
// dan diakses dari Android Emulator:
final String baseUrl = "https://learn.smktelkom-mlg.sch.id/bank_sampah/api";

// Dipakai untuk mengakses file/gambar (foto profil, dsb) yang disimpan
// di storage backend, tanpa prefix /api.
final String baseUrlTanpaApi = "https://learn.smktelkom-mlg.sch.id/bank_sampah";