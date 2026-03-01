import 'package:dio/dio.dart';

String extractDioMessage(DioException e, {String fallback = 'Request failed'}) {
  final data = e.response?.data;
  if (data is Map<String, dynamic>) {
    final message = data['message']?.toString();
    if (message != null && message.isNotEmpty) return message;
    final error = data['error']?.toString();
    if (error != null && error.isNotEmpty) return error;
  }
  return e.message ?? fallback;
}
