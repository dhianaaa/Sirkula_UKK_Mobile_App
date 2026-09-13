// models/user_login_model.dart
//
// Menyimpan data user yang sedang login (token, role, profil singkat).
// Dipakai oleh StorageService untuk serialize/deserialize ke
// SharedPreferences (lihat toStorageJson / fromStorageJson).
//
// role bernilai 'ADMIN' atau 'NASABAH' (dipakai login_screen.dart untuk
// menentukan targetRoute setelah login).

class UserLoginModel {
  final bool status;
  final String? token;
  final String? id;
  final String? username;
  final String? nama;
  final String? role;
  final int? saldoPoin;
  final String? alamat;

  UserLoginModel({
    required this.status,
    this.token,
    this.id,
    this.username,
    this.nama,
    this.role,
    this.saldoPoin,
    this.alamat,
  });

  /// Session kosong, dipakai ketika belum pernah login / logout.
  factory UserLoginModel.empty() {
    return UserLoginModel(status: false);
  }

  /// Dipanggil setelah login/register sukses, dari response API
  factory UserLoginModel.fromApiJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final nasabah = data['nasabah'] as Map<String, dynamic>?;
    final admin = data['adminBank'] as Map<String, dynamic>?;

    final role = data['role']?.toString();
    final token = data['token']?.toString() ??
        json['token']?.toString() ??
        (json['authorisation'] as Map<String, dynamic>?)?['token']?.toString();
    final id = data['id']?.toString();
    final username = data['username']?.toString();

    String? nama;
    int? saldoPoin;

    if (role == 'NASABAH' && nasabah != null) {
      nama = nasabah['namaNasabah']?.toString();
      final rawSaldo = nasabah['saldoPoin'];
      if (rawSaldo is num) {
        saldoPoin = rawSaldo.toInt();
      } else if (rawSaldo != null) {
        saldoPoin = int.tryParse(rawSaldo.toString()) ??
            double.tryParse(rawSaldo.toString())?.toInt();
      }
    } else if (role == 'ADMIN' && admin != null) {
      nama = admin['namaPengelola']?.toString() ?? admin['namaUnit']?.toString();
    } else {
      nama = (data['namaNasabah'] ?? data['nama'] ?? data['name'])?.toString();
      final rawSaldo = data['saldoPoin'];
      if (rawSaldo is num) {
        saldoPoin = rawSaldo.toInt();
      } else if (rawSaldo != null) {
        saldoPoin = int.tryParse(rawSaldo.toString()) ??
            double.tryParse(rawSaldo.toString())?.toInt();
      }
    }

    final alamat = nasabah?['alamat']?.toString() ??
        admin?['alamat']?.toString() ??
        data['alamat']?.toString();

    return UserLoginModel(
      status: true,
      token: token,
      id: id,
      username: username,
      nama: nama,
      role: role,
      saldoPoin: saldoPoin,
      alamat: alamat,
    );
  }

  /// Serialize ke JSON string untuk disimpan di SharedPreferences.
  Map<String, dynamic> toStorageJson() {
    return {
      'status': status,
      'token': token,
      'id': id,
      'username': username,
      'nama': nama,
      'role': role,
      'saldoPoin': saldoPoin,
      'alamat': alamat,
    };
  }

  /// Rekonstruksi dari JSON yang tersimpan di SharedPreferences.
  factory UserLoginModel.fromStorageJson(Map<String, dynamic> map) {
    int? parsedSaldo;
    final rawSaldo = map['saldoPoin'];
    if (rawSaldo is num) {
      parsedSaldo = rawSaldo.toInt();
    } else if (rawSaldo != null) {
      parsedSaldo = int.tryParse(rawSaldo.toString()) ??
          double.tryParse(rawSaldo.toString())?.toInt();
    }

    final token = map['token']?.toString();
    final isValidSession =
        map['status'] == true && token != null && token.isNotEmpty;

    return UserLoginModel(
      status: isValidSession,
      token: token,
      id: map['id']?.toString(),
      username: map['username']?.toString(),
      nama: map['nama']?.toString(),
      role: map['role']?.toString(),
      saldoPoin: parsedSaldo,
      alamat: map['alamat']?.toString(),
    );
  }
}