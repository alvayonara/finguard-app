import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static const baseUrl = "http://localhost:8080";

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return jsonDecode(response.body);
  }
}
