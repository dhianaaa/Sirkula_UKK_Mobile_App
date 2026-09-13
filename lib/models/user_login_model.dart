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
  final int? id;
  final String? username;
  final String? nama;
  final String? role;
  final int? saldoPoin;

  UserLoginModel({
    required this.status,
    this.token,
    this.id,
    this.username,
    this.nama,
    this.role,
    this.saldoPoin,
  });

  /// Session kosong, dipakai ketika belum pernah login / logout.
  factory UserLoginModel.empty() {
    return UserLoginModel(status: false);
  }

  /// Dipanggil setelah login/register sukses, dari response API:
  /// { "status": true, "data": {...}, "authorisation": {"token": "..."} }
  factory UserLoginModel.fromApiJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final auth = json['authorisation'] as Map<String, dynamic>?;

    return UserLoginModel(
      status: true,
      token: auth != null ? auth['token']?.toString() : json['token']?.toString(),
      id: data['id'] is int ? data['id'] : int.tryParse('${data['id']}'),
      username: data['username']?.toString(),
      nama: (data['namaNasabah'] ?? data['nama'] ?? data['name'])?.toString(),
      role: data['role']?.toString(),
      saldoPoin: data['saldoPoin'] is int
          ? data['saldoPoin']
          : int.tryParse('${data['saldoPoin'] ?? 0}'),
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
    };
  }

  /// Rekonstruksi dari JSON yang tersimpan di SharedPreferences.
  factory UserLoginModel.fromStorageJson(Map<String, dynamic> map) {
    return UserLoginModel(
      status: map['status'] == true,
      token: map['token']?.toString(),
      id: map['id'] is int ? map['id'] : int.tryParse('${map['id']}'),
      username: map['username']?.toString(),
      nama: map['nama']?.toString(),
      role: map['role']?.toString(),
      saldoPoin: map['saldoPoin'] is int
          ? map['saldoPoin']
          : int.tryParse('${map['saldoPoin'] ?? 0}'),
    );
  }
}