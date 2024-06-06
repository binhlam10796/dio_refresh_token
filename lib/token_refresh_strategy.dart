import 'package:dio/dio.dart';

import 'token_error_messages.dart';
import 'token_exception.dart';
import 'token_manager.dart';

/// A function type for handling token refresh.
///
/// Takes a [Dio] instance and a refresh token [String] as parameters, and
/// returns a [Future] that resolves to a [Response].
typedef TokenRefreshHandler = Future<Response> Function(
    Dio dio, String refreshToken);

/// A function type for extracting a token from a [Response].
///
/// Takes a [Response] as a parameter and returns the token as a [String?].
typedef TokenExtractor = String? Function(Response response);

/// The TokenRefreshStrategy interface defines the contract for handling the
/// token refresh process. It includes methods for refreshing the token,
/// determining if a token should be refreshed, and getting authorization headers.
abstract class TokenRefreshStrategy {
  /// Refreshes the token using the provided [Dio] instance and [TokenManager].
  ///
  /// Returns the new access token as a [String], or null if the refresh fails.
  Future<String?> refreshToken(Dio dio, TokenManager tokenManager);

  /// Determines if the token should be refreshed based on the given [Response].
  ///
  /// Returns true if the token should be refreshed, false otherwise.
  bool shouldRefreshToken(Response response);

  /// Gets the authorization headers using the provided access token.
  ///
  /// Returns a map of headers.
  Map<String, String> getAuthorizationHeaders(String accessToken);
}

/// The TokenRefreshStrategyImpl class provides a concrete implementation of the
/// [TokenRefreshStrategy] interface, defining the strategy for refreshing tokens.
class TokenRefreshStrategyImpl implements TokenRefreshStrategy {
  /// The handler function used to perform the token refresh.
  final TokenRefreshHandler refreshHandler;

  /// The function used to extract the access token from the response.
  final TokenExtractor accessTokenExtractor;

  /// The function used to extract the refresh token from the response.
  final TokenExtractor refreshTokenExtractor;

  /// The list of status codes indicating a successful token refresh.
  final List<int> successCodes;

  /// The list of status codes indicating the need to refresh the token.
  final List<int> refreshCodes;

  /// The template for the authorization headers.
  final Map<String, String> authTemplate;

  /// The number of retry attempts for refreshing the token.
  final int retries;

  /// Creates a [TokenRefreshStrategyImpl] with the given parameters.
  ///
  /// - [refreshHandler]: The handler function used to perform the token refresh.
  /// - [accessTokenExtractor]: The function used to extract the access token from the response.
  /// - [refreshTokenExtractor]: The function used to extract the refresh token from the response.
  /// - [successCodes]: The list of status codes indicating a successful token refresh. Default is [200].
  /// - [refreshCodes]: The list of status codes indicating the need to refresh the token. Default is [401].
  /// - [authTemplate]: The template for the authorization headers. Default is {'Authorization': 'Bearer '}.
  /// - [retries]: The number of retry attempts for refreshing the token. Default is 1.
  TokenRefreshStrategyImpl({
    required this.refreshHandler,
    required this.accessTokenExtractor,
    required this.refreshTokenExtractor,
    this.successCodes = const [200],
    this.refreshCodes = const [401],
    this.authTemplate = const {'Authorization': 'Bearer '},
    this.retries = 1,
  });

  /// Refreshes the token using the provided [Dio] instance and [TokenManager].
  ///
  /// Attempts to refresh the token up to [retries] times. If successful,
  /// saves the new access and refresh tokens using the [TokenManager] and
  /// returns the new access token. Throws a [TokenRefreshException] if an error
  /// occurs during the refresh process.
  @override
  Future<String?> refreshToken(Dio dio, TokenManager tokenManager) async {
    final refreshToken = await tokenManager.getRefreshToken();
    if (refreshToken == null) {
      throw TokenRefreshException(TokenErrorMessages.refreshTokenIsNull);
    }

    for (int attempt = 0; attempt < retries; attempt++) {
      try {
        final response = await refreshHandler(dio, refreshToken);

        if (successCodes.contains(response.statusCode)) {
          final accessToken = accessTokenExtractor(response);
          final newRefreshToken = refreshTokenExtractor(response);
          if (accessToken != null) {
            await tokenManager.saveAccessToken(accessToken);
            if (newRefreshToken != null) {
              await tokenManager.saveRefreshToken(newRefreshToken);
            }
            return accessToken;
          } else {
            throw TokenRefreshException(
                TokenErrorMessages.failedToExtractAccessToken);
          }
        } else {
          throw TokenRefreshException(
              TokenErrorMessages.failedToRefreshAccessToken);
        }
      } catch (e) {
        if (attempt == retries - 1) {
          rethrow;
        }
      }
    }
    return null;
  }

  /// Determines if the token should be refreshed based on the given [Response].
  ///
  /// Returns true if the response status code is in [refreshCodes], false otherwise.
  @override
  bool shouldRefreshToken(Response response) {
    return refreshCodes.contains(response.statusCode);
  }

  /// Gets the authorization headers using the provided access token.
  ///
  /// Returns a map of headers with the access token included.
  @override
  Map<String, String> getAuthorizationHeaders(String accessToken) {
    return authTemplate.map((key, value) => MapEntry(key, value + accessToken));
  }
}
