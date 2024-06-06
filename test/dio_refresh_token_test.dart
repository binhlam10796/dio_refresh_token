import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';

import 'package:dio_refresh_token/token_manager.dart';
import 'package:dio_refresh_token/token_refresh_strategy.dart';
import 'package:dio_refresh_token/token_interceptor.dart';
import 'package:dio_refresh_token/token_error_messages.dart';
import 'package:dio_refresh_token/token_exception.dart';

class MockTokenManager extends Mock implements TokenManager {}

class MockTokenRefreshStrategy extends Mock implements TokenRefreshStrategy {}

class MockDio extends Mock implements Dio {}

void main() {
  group('TokenManagerImpl', () {
    late TokenManagerImpl tokenManager;
    late MockTokenManager mockTokenManager;

    setUp(() {
      tokenManager = TokenManagerImpl();
      mockTokenManager = MockTokenManager();
    });

    test('getAccessToken returns token when successful', () async {
      when(mockTokenManager.getAccessToken())
          .thenAnswer((_) async => 'access_token');

      final token = await tokenManager.getAccessToken();

      expect(token, 'access_token');
      verify(mockTokenManager.getAccessToken()).called(1);
    });

    test('saveAccessToken saves token successfully', () async {
      when(mockTokenManager.saveAccessToken('access_token'))
          .thenAnswer((_) async {});

      await tokenManager.saveAccessToken('access_token');

      verify(mockTokenManager.saveAccessToken('access_token')).called(1);
    });

    test('clearAccessToken clears token successfully', () async {
      when(mockTokenManager.clearAccessToken())
          .thenAnswer((_) async {});

      await tokenManager.clearAccessToken();

      verify(mockTokenManager.clearAccessToken()).called(1);
    });

    test('getRefreshToken returns token when successful', () async {
      when(mockTokenManager.getRefreshToken())
          .thenAnswer((_) async => 'refresh_token');

      final token = await tokenManager.getRefreshToken();

      expect(token, 'refresh_token');
      verify(mockTokenManager.getRefreshToken()).called(1);
    });

    test('saveRefreshToken saves token successfully', () async {
      when(mockTokenManager.saveRefreshToken('refresh_token'))
          .thenAnswer((_) async {});

      await tokenManager.saveRefreshToken('refresh_token');

      verify(mockTokenManager.saveRefreshToken('refresh_token')).called(1);
    });

    test('clearRefreshToken clears token successfully', () async {
      when(mockTokenManager.clearRefreshToken())
          .thenAnswer((_) async {});

      await tokenManager.clearRefreshToken();

      verify(mockTokenManager.clearRefreshToken()).called(1);
    });

    test('clearTokens clears both tokens successfully', () async {
      when(mockTokenManager.clearAccessToken())
          .thenAnswer((_) async {});
      when(mockTokenManager.clearRefreshToken())
          .thenAnswer((_) async {});

      await tokenManager.clearTokens();

      verify(mockTokenManager.clearAccessToken()).called(1);
      verify(mockTokenManager.clearRefreshToken()).called(1);
    });
  });

  group('TokenRefreshStrategyImpl', () {
    late TokenRefreshStrategyImpl strategy;
    late MockDio mockDio;
    late MockTokenManager mockTokenManager;

    setUp(() {
      mockDio = MockDio();
      mockTokenManager = MockTokenManager();
      strategy = TokenRefreshStrategyImpl(
        refreshHandler: (dio, refreshToken) async {
          return Response(
            requestOptions: RequestOptions(path: ''),
            statusCode: 200,
          );
        },
        accessTokenExtractor: (response) => 'new_access_token',
        refreshTokenExtractor: (response) => 'new_refresh_token',
      );
    });

    test('refreshToken returns new access token when successful', () async {
      when(mockTokenManager.getRefreshToken())
          .thenAnswer((_) async => 'refresh_token');
      when(mockTokenManager.saveAccessToken('new_access_token'))
          .thenAnswer((_) async {});
      when(mockTokenManager.saveRefreshToken('new_refresh_token'))
          .thenAnswer((_) async {});

      final newAccessToken = await strategy.refreshToken(mockDio, mockTokenManager);

      expect(newAccessToken, 'new_access_token');
      verify(mockTokenManager.getRefreshToken()).called(1);
      verify(mockTokenManager.saveAccessToken('new_access_token')).called(1);
      verify(mockTokenManager.saveRefreshToken('new_refresh_token')).called(1);
    });

    test('refreshToken throws exception when refresh token is null', () async {
      when(mockTokenManager.getRefreshToken()).thenAnswer((_) async => null);

      expect(
        strategy.refreshToken(mockDio, mockTokenManager),
        throwsA(isA<TokenRefreshException>()),
      );
      verify(mockTokenManager.getRefreshToken()).called(1);
    });

    test('shouldRefreshToken returns true for 401 status code', () {
      final response = Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 401,
      );

      final shouldRefresh = strategy.shouldRefreshToken(response);

      expect(shouldRefresh, true);
    });

    test('shouldRefreshToken returns false for non-401 status code', () {
      final response = Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: 200,
      );

      final shouldRefresh = strategy.shouldRefreshToken(response);

      expect(shouldRefresh, false);
    });

    test('getAuthorizationHeaders returns correct headers', () {
      final headers = strategy.getAuthorizationHeaders('access_token');

      expect(headers, {'Authorization': 'Bearer access_token'});
    });
  });

  group('TokenInterceptor', () {
    late TokenInterceptor interceptor;
    late MockTokenManager mockTokenManager;
    late MockTokenRefreshStrategy mockStrategy;
    late MockDio mockDio;

    setUp(() {
      mockTokenManager = MockTokenManager();
      mockStrategy = MockTokenRefreshStrategy();
      interceptor = TokenInterceptor(
        tokenManager: mockTokenManager,
        tokenRefreshStrategy: mockStrategy,
      );
      mockDio = MockDio();
    });

    Response<dynamic> mockHttpResponse(int statusCode, {dynamic data}) {
      return Response(
        requestOptions: RequestOptions(path: ''),
        statusCode: statusCode,
        data: data,
      );
    }

    test('onRequest adds authorization header when access token is available', () async {
      when(mockTokenManager.getAccessToken())
          .thenAnswer((_) async => 'access_token');
      when(mockStrategy.getAuthorizationHeaders('access_token'))
          .thenReturn({'Authorization': 'Bearer access_token'});

      final options = RequestOptions(path: '');
      final handler = RequestInterceptorHandler();

      await interceptor.onRequest(options, handler);

      expect(options.headers, {'Authorization': 'Bearer access_token'});
      verify(mockTokenManager.getAccessToken()).called(1);
      verify(mockStrategy.getAuthorizationHeaders('access_token')).called(1);
    });

    test('onError refreshes token and retries request when needed', () async {
      when(mockStrategy.shouldRefreshToken(mockHttpResponse(401))).thenReturn(true);
      when(mockStrategy.refreshToken(mockDio, mockTokenManager)).thenAnswer((_) async => 'new_access_token');
      when(mockStrategy.getAuthorizationHeaders('new_access_token'))
          .thenReturn({'Authorization': 'Bearer new_access_token'});

      final err = DioException(
        requestOptions: RequestOptions(path: ''),
        response: mockHttpResponse(401),
      );
      final handler = ErrorInterceptorHandler();

      await interceptor.onError(err, handler);

      verify(mockStrategy.shouldRefreshToken(mockHttpResponse(401))).called(1);
      verify(mockStrategy.refreshToken(mockDio, mockTokenManager)).called(1);
      verify(mockStrategy.getAuthorizationHeaders('new_access_token')).called(1);
    });

    test('onError clears tokens and throws exception when refresh fails', () async {
      when(mockStrategy.shouldRefreshToken(mockHttpResponse(401))).thenReturn(true);
      when(mockStrategy.refreshToken(mockDio, mockTokenManager))
          .thenThrow(TokenRefreshException(TokenErrorMessages.failedToRefreshAccessToken));
      when(mockTokenManager.clearTokens()).thenAnswer((_) async {});

      final err = DioException(
        requestOptions: RequestOptions(path: ''),
        response: mockHttpResponse(401),
      );
      final handler = ErrorInterceptorHandler();

      await interceptor.onError(err, handler);

      verify(mockStrategy.shouldRefreshToken(mockHttpResponse(401))).called(1);
      verify(mockStrategy.refreshToken(mockDio, mockTokenManager)).called(1);
      verify(mockTokenManager.clearTokens()).called(1);
    });
  });
}
