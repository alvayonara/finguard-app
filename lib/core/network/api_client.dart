import 'package:alice/alice.dart';
import 'package:dio/dio.dart';
import 'package:finguard_app/core/storage/local_storage.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';

class ApiClient {
  static const _retryHeader = 'X-RETRY';
  static const _refreshPath = '/v1/users/refresh';

  final Dio dio;
  final LocalStorage localStorage;
  final Alice alice;
  Future<void>? _refreshInFlight;
  Future<void>? _reauthInFlight;

  ApiClient(this.localStorage, {required this.alice})
    : dio = Dio(
        BaseOptions(
          baseUrl: "http://localhost:8080",
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      ) {
    dio.interceptors.add(alice.getDioInterceptor());

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          options.headers.remove(_retryHeader);

          final accessToken = await localStorage.getAccessToken();
          if (accessToken != null && accessToken.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }

          final userUid = await localStorage.getUserUid();
          if (userUid != null) {
            options.headers['X-USER-UID'] = userUid;
          }

          return handler.next(options);
        },
        onError: (error, handler) async {
          final requestOptions = error.requestOptions;
          final shouldTryRefresh =
              error.response?.statusCode == 401 &&
              requestOptions.headers[_retryHeader] != true &&
              !_isRefreshRequest(requestOptions);

          if (!shouldTryRefresh) {
            return handler.next(error);
          }

          try {
            await _refreshAccessToken();

            final newToken = await localStorage.getAccessToken();
            if (newToken == null || newToken.isEmpty) {
              return handler.next(error);
            }

            final retryHeaders = Map<String, dynamic>.from(
              requestOptions.headers,
            );
            retryHeaders['Authorization'] = 'Bearer $newToken';
            retryHeaders[_retryHeader] = true;

            final retriedResponse = await dio.fetch(
              requestOptions.copyWith(headers: retryHeaders),
            );
            return handler.resolve(retriedResponse);
          } catch (e) {
            return handler.next(error);
          }
        },
      ),
    );
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
      final userUid = json['userUid'] as String?;

      if (nextAccessToken == null ||
          nextAccessToken.isEmpty ||
          nextRefreshToken == null ||
          nextRefreshToken.isEmpty ||
          userUid == null ||
          userUid.isEmpty) {
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
        userUid: userUid,
        accessToken: nextAccessToken,
        refreshToken: nextRefreshToken,
      );

      completer.complete();
    } catch (error) {
      // Try to recreate anonymous user as fallback
      try {
        await _recreateAnonymousUser();
        completer.complete();
      } catch (reauthError) {
        await localStorage.clearAuthSession();
        completer.completeError(error);
        rethrow;
      }
    } finally {
      _refreshInFlight = null;
    }
  }

  Future<void> _recreateAnonymousUser() async {
    if (_reauthInFlight != null) {
      return _reauthInFlight;
    }

    final completer = Completer<void>();
    _reauthInFlight = completer.future;

    try {
      final currentAnonymousId = await localStorage.getAnonymousId();
      final resolvedAnonymousId =
          (currentAnonymousId != null && currentAnonymousId.isNotEmpty)
          ? currentAnonymousId
          : const Uuid().v4();

      final authDio = Dio(
        BaseOptions(
          baseUrl: dio.options.baseUrl,
          connectTimeout: dio.options.connectTimeout,
          receiveTimeout: dio.options.receiveTimeout,
        ),
      );

      final response = await authDio.post(
        '/v1/users/anonymous',
        data: {'anonymousId': resolvedAnonymousId},
      );

      final json = response.data as Map<String, dynamic>;
      final userUid = json['userUid'] as String;
      final accessToken = json['accessToken'] as String;
      final refreshToken = json['refreshToken'] as String;
      final anonymousId = json['anonymousId'] as String?;

      final finalAnonymousId = anonymousId ?? resolvedAnonymousId;
      await localStorage.saveAnonymous(finalAnonymousId);

      await localStorage.saveAuthSession(
        userUid: userUid,
        accessToken: accessToken,
        refreshToken: refreshToken,
      );

      completer.complete();
    } catch (error) {
      completer.completeError(error);
      rethrow;
    } finally {
      _reauthInFlight = null;
    }
  }
}
