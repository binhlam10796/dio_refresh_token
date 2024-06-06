
# Dio Token Manager and Refresher

A Flutter package for managing and refreshing tokens using Dio. Includes token storage, automatic header injection, and customizable refresh strategies.

## Features

- Manage access and refresh tokens securely.
- Automatically add authorization headers to requests.
- Customizable token refresh strategies.
- Easy integration with Dio interceptors.

## Installation

Add dio_refresh_token to your pubspec.yaml:

```yaml
dependencies:
  dio_refresh_token: ^0.0.1
```

Install the package:

```sh
flutter pub get
```

## Usage

### Adding the Interceptor

To use the `TokenInterceptor`, you need to add it to your Dio instance. Here's an example of how to do this:

1. Import the necessary packages:

```dart
import 'package:dio/dio.dart';
import 'package:dio_refresh_token/dio_refresh_token.dart';
```

2. Create and configure your Dio instance:

```dart
final dio = Dio();
```

3. Create an instance of `TokenManager`:

```dart
final tokenManager = TokenManagerImpl();
```

4. Define your token refresh logic by creating an instance of `TokenRefreshStrategyImpl`:

```dart
final tokenRefreshStrategy = TokenRefreshStrategyImpl(
  refreshHandler: (dio, refreshToken) async {
    // Implement your refresh token logic here
    return Response(
      requestOptions: RequestOptions(path: ''),
      statusCode: 200,
      data: {'access_token': 'newAccessToken', 'refresh_token': 'newRefreshToken'},
    );
  },
  accessTokenExtractor: (response) => response.data['access_token'],
  refreshTokenExtractor: (response) => response.data['refresh_token'],
);
```

#### Parameters:

- **refreshHandler**: A function that takes a `Dio` instance and a refresh token as parameters. This function should implement the logic to request a new access token using the refresh token. It should return a `Response` containing the new tokens.
  
  Example:
  
  ```dart
  (dio, refreshToken) async {
    // Request new tokens
    return Response(
      requestOptions: RequestOptions(path: ''),
      statusCode: 200,
      data: {'access_token': 'newAccessToken', 'refresh_token': 'newRefreshToken'},
    );
  }
  ```

- **accessTokenExtractor**: A function that takes a `Response` as a parameter and extracts the new access token from the response.

  Example:
  
  ```dart
  (response) => response.data['access_token']
  ```

- **refreshTokenExtractor**: A function that takes a `Response` as a parameter and extracts the new refresh token from the response.

  Example:
  
  ```dart
  (response) => response.data['refresh_token']
  ```

5. Add the `TokenInterceptor` to your Dio instance:

```dart
dio.interceptors.add(TokenInterceptor(
  tokenManager: tokenManager,
  tokenRefreshStrategy: tokenRefreshStrategy,
));
```

6. Now you can use Dio as usual:

```dart
final response = await dio.get('https://api.example.com/data');
print(response.data);
```

### Using TokenManager

The `TokenManager` class provides methods to manage tokens. Here's how to use it:

```dart
import 'package:dio_refresh_token/dio_refresh_token.dart';

void main() async {
  final tokenManager = TokenManagerImpl();

  // Save tokens
  await tokenManager.saveAccessToken('your_access_token');
  await tokenManager.saveRefreshToken('your_refresh_token');

  // Get tokens
  final accessToken = await tokenManager.getAccessToken();
  final refreshToken = await tokenManager.getRefreshToken();

  // Clear tokens
  await tokenManager.clearAccessToken();
  await tokenManager.clearRefreshToken();
}
```

## Contributions

Contributions are welcome! If you encounter any issues or have suggestions for improvements, please feel free to submit a pull request or create an issue on the GitHub repository.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
