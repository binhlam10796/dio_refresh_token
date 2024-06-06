import 'package:dio/dio.dart';

import 'token_error_messages.dart';
import 'token_exception.dart';
import 'token_manager.dart';
import 'token_refresh_strategy.dart';

/// The TokenInterceptor class is an implementation of the Dio [Interceptor]
/// that handles adding authorization headers to requests and refreshing tokens
/// when necessary.
class TokenInterceptor extends Interceptor {
  /// The TokenManager instance used to manage access and refresh tokens.
  final TokenManager tokenManager;

  /// The TokenRefreshStrategy instance used to define the strategy for
  /// refreshing tokens.
  final TokenRefreshStrategy tokenRefreshStrategy;

  /// Creates a [TokenInterceptor] with the given [tokenManager] and
  /// [tokenRefreshStrategy].
  TokenInterceptor({
    required this.tokenManager,
    required this.tokenRefreshStrategy,
  });

  /// Intercepts outgoing requests to add the authorization headers.
  ///
  /// Retrieves the access token from the [tokenManager] and uses the
  /// [tokenRefreshStrategy] to get the authorization headers. Adds these
  /// headers to the request options.
  ///
  /// If an error occurs while retrieving the access token, rejects the request
  /// with a [TokenManagerException].
  @override
  Future onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      final accessToken = await tokenManager.getAccessToken();
      if (accessToken != null) {
        final headers =
            tokenRefreshStrategy.getAuthorizationHeaders(accessToken);
        options.headers.addAll(headers);
      }
      return handler.next(options);
    } catch (e) {
      return handler.reject(DioException(
        requestOptions: options,
        error: TokenManagerException(TokenErrorMessages.failedToGetAccessToken),
      ));
    }
  }

  /// Intercepts errors to handle token refresh if necessary.
  ///
  /// If the error indicates that the token should be refreshed, uses the
  /// [tokenRefreshStrategy] to refresh the token. If successful, retries the
  /// original request with the new token. If the refresh fails, clears the
  /// tokens using the [tokenManager] and rejects the request with a
  /// [TokenRefreshException].
  @override
  Future onError(DioException err, ErrorInterceptorHandler handler) async {
    if (tokenRefreshStrategy.shouldRefreshToken(err.response!)) {
      try {
        final newAccessToken =
            await tokenRefreshStrategy.refreshToken(Dio(), tokenManager);
        if (newAccessToken != null) {
          final headers =
              tokenRefreshStrategy.getAuthorizationHeaders(newAccessToken);
          err.requestOptions.headers.addAll(headers);
          final cloneReq = await Dio().request(
            err.requestOptions.path,
            options: Options(
              method: err.requestOptions.method,
              headers: err.requestOptions.headers,
            ),
          );
          return handler.resolve(cloneReq);
        } else {
          return handler.next(err);
        }
      } catch (e) {
        await tokenManager.clearTokens();
        return handler.next(DioException(
          requestOptions: err.requestOptions,
          error: TokenRefreshException(
              TokenErrorMessages.failedToRefreshAccessToken),
        ));
      }
    }
    return handler.next(err);
  }
}
