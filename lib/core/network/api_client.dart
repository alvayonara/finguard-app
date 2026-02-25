import 'package:alice/alice.dart';
import 'package:dio/dio.dart';
import 'package:finguard/core/storage/local_storage.dart';
import 'dart:async';

class ApiClient {
  static const _retryHeader = 'X-RETRY';
  static const _refreshPath = '/v1/users/refresh';
  static const String baseUrl = String.fromEnvironment('BASE_URL', defaultValue: 'http://localhost:8080');

  final Dio dio;
  final LocalStorage localStorage;
  final Alice alice;
  Future<void>? _refreshInFlight;
  String? _cachedAccessToken;
  String? _cachedUserUid;

  ApiClient(this.localStorage, {required this.alice})
    : dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      ) {
    unawaited(_loadCachedSession());
    dio.interceptors.add(alice.getDioInterceptor());

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          options.headers.remove(_retryHeader);

          final accessToken =
              _cachedAccessToken ?? await localStorage.getAccessToken();
          if (accessToken != null && accessToken.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }

          final userUid = _cachedUserUid ?? await localStorage.getUserUid();
          if (userUid != null) {
            options.headers['X-User-Uid'] = userUid;
          }

          return handler.next(options);
        },
        onError: (error, handler) async {
          final requestOptions = error.requestOptions;
          final currentRefreshToken = await localStorage.getRefreshToken();
          final hasRefresh =
              currentRefreshToken != null && currentRefreshToken.isNotEmpty;
          final shouldTryRefresh =
              error.response?.statusCode == 401 &&
              requestOptions.headers[_retryHeader] != true &&
              !_isRefreshRequest(requestOptions) &&
              hasRefresh;

          if (!shouldTryRefresh) {
            return handler.next(error);
          }

          try {
            await _refreshAccessToken();

            final newToken =
                _cachedAccessToken ?? await localStorage.getAccessToken();
            if (newToken == null || newToken.isEmpty) {
              return handler.next(error);
            }

            final retryHeaders = Map<String, dynamic>.from(
              requestOptions.headers,
            );
            retryHeaders['Authorization'] = 'Bearer $newToken';
            retryHeaders[_retryHeader] = true;

            final cachedUserUid =
                _cachedUserUid ?? await localStorage.getUserUid();
            if (cachedUserUid != null && cachedUserUid.isNotEmpty) {
              retryHeaders['X-User-Uid'] = cachedUserUid;
            }

            final retriedResponse = await dio.fetch(
              requestOptions.copyWith(headers: retryHeaders),
            );
            return handler.resolve(retriedResponse);
          } catch (e) {
            try {
              await localStorage.clearAuthSession();
            } catch (_) {}
            return handler.next(error);
          }
        },
      ),
    );
  }

  Future<void> _loadCachedSession() async {
    try {
      _cachedAccessToken = await localStorage.getAccessToken();
      _cachedUserUid = await localStorage.getUserUid();
    } catch (_) {}
  }

  Future<void> refreshCachedSessionFromStorage() async {
    _cachedAccessToken = await localStorage.getAccessToken();
    _cachedUserUid = await localStorage.getUserUid();
  }

  bool _isRefreshRequest(RequestOptions requestOptions) {
    return requestOptions.path == _refreshPath ||
        requestOptions.path.endsWith(_refreshPath);
  }

  Future<void> _refreshAccessToken() async {
    if (_refreshInFlight != null) {
      return _refreshInFlight;
    }

    final completer = Completer<void>();
    _refreshInFlight = completer.future;

    try {
      final currentRefreshToken = await localStorage.getRefreshToken();
      if (currentRefreshToken == null || currentRefreshToken.isEmpty) {
        throw DioException(
          requestOptions: RequestOptions(path: _refreshPath),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: _refreshPath),
            statusCode: 401,
            data: {'message': 'Missing refresh token'},
          ),
        );
      }

      final refreshDio = Dio(
        BaseOptions(
          baseUrl: dio.options.baseUrl,
          connectTimeout: dio.options.connectTimeout,
          receiveTimeout: dio.options.receiveTimeout,
        ),
      );

      final refreshResponse = await refreshDio.post(
        _refreshPath,
        data: {'refreshToken': currentRefreshToken},
      );

      final json = refreshResponse.data as Map<String, dynamic>;
      final nextAccessToken = json['accessToken'] as String?;
      final nextRefreshToken = json['refreshToken'] as String?;
      final nextUserUid = json['userUid'] as String?;

      if (nextAccessToken == null ||
          nextAccessToken.isEmpty ||
          nextRefreshToken == null ||
          nextRefreshToken.isEmpty ||
          nextUserUid == null ||
          nextUserUid.isEmpty) {
        throw DioException(
          requestOptions: RequestOptions(path: _refreshPath),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: _refreshPath),
            statusCode: 500,
            data: {'message': 'Invalid refresh response payload'},
          ),
        );
      }

      await localStorage.saveAuthSession(
        userUid: nextUserUid,
        accessToken: nextAccessToken,
        refreshToken: nextRefreshToken,
      );

      _cachedAccessToken = nextAccessToken;
      _cachedUserUid = nextUserUid;

      completer.complete();
    } catch (error) {
      await localStorage.clearAuthSession();
      _cachedAccessToken = null;
      _cachedUserUid = null;
      completer.completeError(error);
      return;
    } finally {
      _refreshInFlight = null;
    }
  }
}
