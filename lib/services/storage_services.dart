// services/storage_service.dart
//
// Menangani penyimpanan session (token, role, data user) ke
// SharedPreferences, agar user tidak perlu login ulang setiap buka app.
// Disimpan sebagai satu JSON string agar tidak banyak key terpisah.

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sirkula_banksampah/models/user_login_model.dart';

class StorageService {
  static const String _kSessionKey = 'sirkula_session';

  /// Simpan session setelah login/register berhasil.
  Future<void> saveUserLogin(UserLoginModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSessionKey, json.encode(user.toStorageJson()));
  }

  /// Ambil data user yang sedang login.
  /// Mengembalikan UserLoginModel.empty() (status=false) jika belum
  /// pernah login / session tidak ada.
  Future<UserLoginModel> getUserLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kSessionKey);
    if (raw == null) {
      return UserLoginModel.empty();
    }
    try {
      final map = json.decode(raw) as Map<String, dynamic>;
      return UserLoginModel.fromStorageJson(map);
    } catch (_) {
      return UserLoginModel.empty();
    }
  }

  /// Hapus session (dipakai saat logout atau token invalid/expired).
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kSessionKey);
  }
}