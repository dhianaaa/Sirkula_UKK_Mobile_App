// controllers/auth_controller.dart
//
// Menjembatani View (Login/Register) dengan AuthService.
// Menangani state loading & error sesuai tanggung jawab layer Controller
// (state, loading, error, business logic, memanggil service).

import 'package:flutter/foundation.dart';
import 'package:sirkula_banksampah/models/response_data_map.dart';
import 'package:sirkula_banksampah/services/auth_services.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool isLoading = false;
  String? errorMessage;

  Future<ResponseDataMap> registerNasabah({
    required String username,
    required String password,
    required String namaNasabah,
    required String alamat,
    required String telp,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final result = await _authService.registerNasabah({
      "username": username,
      "password": password,
      "namaNasabah": namaNasabah,
      "alamat": alamat,
      "telp": telp,
    });

    isLoading = false;
    if (result.status == false) {
      errorMessage = result.message;
    }
    notifyListeners();

    return result;
  }

  Future<ResponseDataMap> login({
    required String username,
    required String password,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    final result = await _authService.loginUser({
      "username": username,
      "password": password,
    });

    isLoading = false;
    if (result.status == false) {
      errorMessage = result.message;
    }
    notifyListeners();

    return result;
  }

  Future<void> logout() async {
    await _authService.logout();
  }
}