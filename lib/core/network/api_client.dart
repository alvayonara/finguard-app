import 'package:dio/dio.dart';

class ApiClient {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: "http://localhost:8080",
      connectTimeout: const Duration(seconds: 5),
    ),
  );
}
