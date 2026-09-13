// models/response_data_list.dart
//
// Model generik untuk menampung hasil response API yang berupa
// List (array), misal daftar riwayat setoran / daftar nasabah.

class ResponseDataList {
  bool status;
  String message;
  List? data;

  ResponseDataList({
    required this.status,
    required this.message,
    this.data,
  });
}