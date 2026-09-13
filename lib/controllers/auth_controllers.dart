// controllers/auth_controllers.dart
//
// Menjembatani UI (Login/Register/AdminRegister screen) dengan
// AuthService. extends ChangeNotifier agar `isLoading` bisa dipantau
// langsung lewat AnimatedBuilder(animation: authController, ...) di
// tombol submit, tanpa perlu Provider.

import 'package:flutter/foundation.dart';
import 'package:sirkula_banksampah/models/response_data_map.dart';
import 'package:sirkula_banksampah/services/auth_services.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool isLoading = false;

  void _setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  /// Login nasabah maupun admin — role ditentukan backend dari response,
  /// BUKAN dari input user.
  Future<ResponseDataMap> login({
    required String username,
    required String password,
  }) async {
    _setLoading(true);
    final result = await _authService.loginUser({
      'username': username,
      'password': password,
    });
    _setLoading(false);
    return result;
  }

  Future<ResponseDataMap> registerNasabah({
    required String username,
    required String password,
    required String namaNasabah,
    required String alamat,
    required String telp,
  }) async {
    _setLoading(true);
    final result = await _authService.registerNasabah({
      'username': username,
      'password': password,
      'namaNasabah': namaNasabah,
      'alamat': alamat,
      'telp': telp,
    });
    _setLoading(false);
    return result;
  }

  Future<ResponseDataMap> registerAdmin({
    required String username,
    required String password,
    required String namaUnit,
    required String namaPengelola,
    required String telp,
  }) async {
    _setLoading(true);
    final result = await _authService.registerAdmin({
      'username': username,
      'password': password,
      'namaUnit': namaUnit,
      'namaPengelola': namaPengelola,
      'telp': telp,
    });
    _setLoading(false);
    return result;
  }

  Future<void> logout() async {
    await _authService.logout();
  }
}