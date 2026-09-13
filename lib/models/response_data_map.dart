// models/response_data_map.dart
//
// Model generik untuk menampung hasil response API yang berupa
// satu object (Map). Dipakai oleh AuthService (login & register).

class ResponseDataMap {
  bool status;
  String message;
  Map? data;

  ResponseDataMap({
    required this.status,
    required this.message,
    this.data,
  });
}