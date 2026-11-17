import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  static const baseUrl = 'https://share.tryapps.store/mock/teach';

  static const token = String.fromEnvironment('MOCK_API_TOKEN');

  Map<String, String> get headers {
    if (token.isEmpty) {
      throw Exception('Chưa cấu hình MOCK_API_TOKEN');
    }

    return {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;

      return jsonDecode(utf8.decode(response.bodyBytes));
    }

    switch (response.statusCode) {
      case 400:
        throw Exception('Dữ liệu yêu cầu không hợp lệ');
      case 401:
        throw Exception('Token xác thực không hợp lệ');
      case 403:
        throw Exception('Không có quyền truy cập');
      case 404:
        throw Exception('Không tìm thấy dữ liệu');
      case 500:
        throw Exception('Lỗi máy chủ');
      default:
        throw Exception('HTTP Error: ${response.statusCode}');
    }
  }

  Future<dynamic> get(String endpoint) async {
    final response = await http
        .get(Uri.parse('$baseUrl$endpoint'), headers: headers)
        .timeout(const Duration(seconds: 15));

    return _handleResponse(response);
  }

  Future<dynamic> patch(String endpoint, Map<String, dynamic> data) async {
    final response = await http
        .patch(
          Uri.parse('$baseUrl$endpoint'),
          headers: headers,
          body: jsonEncode(data),
        )
        .timeout(const Duration(seconds: 15));

    return _handleResponse(response);
  }

  Future<void> delete(String endpoint) async {
    final response = await http
        .delete(Uri.parse('$baseUrl$endpoint'), headers: headers)
        .timeout(const Duration(seconds: 15));

    _handleResponse(response);
  }
}
