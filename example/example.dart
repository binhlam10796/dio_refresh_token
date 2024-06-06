import 'package:dio/dio.dart';
import 'package:dio_refresh_token/dio_refresh_token.dart';

void main() async {
  // Create and configure Dio instance
  final dio = Dio();

  // Create TokenManager instance
  final tokenManager = TokenManagerImpl();

  // Define TokenRefreshStrategy implementation
  final tokenRefreshStrategy = TokenRefreshStrategyImpl(
    refreshHandler: (dio, refreshToken) async {
      // Simulate a network request to refresh the token
      return Response(
        requestOptions: RequestOptions(path: '/refresh'),
        statusCode: 200,
        data: {'access_token': 'newAccessToken', 'refresh_token': 'newRefreshToken'},
      );
    },
    accessTokenExtractor: (response) => response.data['access_token'],
    refreshTokenExtractor: (response) => response.data['refresh_token'],
  );

  // Add TokenInterceptor to Dio instance
  dio.interceptors.add(TokenInterceptor(
    tokenManager: tokenManager,
    tokenRefreshStrategy: tokenRefreshStrategy,
  ));

  // Save initial tokens (for demonstration purposes)
  await tokenManager.saveAccessToken('initial_access_token');
  await tokenManager.saveRefreshToken('initial_refresh_token');

  // Perform a network request
  try {
    final response = await dio.get('https://api.example.com/data');
    print('Response data: ${response.data}');
  } catch (e) {
    print('Request failed: $e');
  }

  // Access and refresh tokens
  final accessToken = await tokenManager.getAccessToken();
  final refreshToken = await tokenManager.getRefreshToken();
  print('Access Token: $accessToken');
  print('Refresh Token: $refreshToken');

  // Clear tokens
  await tokenManager.clearTokens();
}
