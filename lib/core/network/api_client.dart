import 'package:dio/dio.dart';
import 'package:finguard_app/core/storage/local_storage.dart';

class ApiClient {
  final Dio dio;
  final LocalStorage localStorage;

  ApiClient(this.localStorage)
    : dio = Dio(
        BaseOptions(
          baseUrl: "http://localhost:8080",
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      ) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final userUid = await localStorage.getUserUid();
          if (userUid != null) {
            options.headers['X-USER-UID'] = userUid;
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          print("API ERROR: ${error.response?.data}");
          return handler.next(error);
        },
      ),
    );
  }
}
