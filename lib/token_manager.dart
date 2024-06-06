import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'token_error_messages.dart';
import 'token_exception.dart';

/// The TokenManager interface defines the contract for managing access and
/// refresh tokens. It includes methods for retrieving, saving, and clearing
/// both types of tokens.
abstract class TokenManager {
  /// Retrieves the access token.
  ///
  /// Returns the access token as a [String], or null if it doesn't exist.
  Future<String?> getAccessToken();

  /// Saves the access token.
  ///
  /// Takes the access token as a [String] and saves it.
  Future<void> saveAccessToken(String token);

  /// Clears the access token.
  Future<void> clearAccessToken();

  /// Retrieves the refresh token.
  ///
  /// Returns the refresh token as a [String], or null if it doesn't exist.
  Future<String?> getRefreshToken();

  /// Saves the refresh token.
  ///
  /// Takes the refresh token as a [String] and saves it.
  Future<void> saveRefreshToken(String token);

  /// Clears the refresh token.
  Future<void> clearRefreshToken();

  /// Clears both access and refresh tokens.
  Future<void> clearTokens() async {
    await clearAccessToken();
    await clearRefreshToken();
  }
}

/// The TokenManagerImpl class provides a concrete implementation of the
/// [TokenManager] interface, using [FlutterSecureStorage] to securely manage
/// access and refresh tokens.
class TokenManagerImpl implements TokenManager {
  final _storage = const FlutterSecureStorage();

  /// Retrieves the access token from secure storage.
  ///
  /// Throws a [TokenManagerException] if an error occurs during retrieval.
  @override
  Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: 'access_token');
    } catch (e) {
      throw TokenManagerException(TokenErrorMessages.failedToGetAccessToken);
    }
  }

  /// Saves the access token to secure storage.
  ///
  /// Throws a [TokenManagerException] if an error occurs during saving.
  @override
  Future<void> saveAccessToken(String token) async {
    try {
      await _storage.write(key: 'access_token', value: token);
    } catch (e) {
      throw TokenManagerException(TokenErrorMessages.failedToSaveAccessToken);
    }
  }

  /// Clears the access token from secure storage.
  ///
  /// Throws a [TokenManagerException] if an error occurs during clearing.
  @override
  Future<void> clearAccessToken() async {
    try {
      await _storage.delete(key: 'access_token');
    } catch (e) {
      throw TokenManagerException(TokenErrorMessages.failedToClearAccessToken);
    }
  }

  /// Retrieves the refresh token from secure storage.
  ///
  /// Throws a [TokenManagerException] if an error occurs during retrieval.
  @override
  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: 'refresh_token');
    } catch (e) {
      throw TokenManagerException(TokenErrorMessages.failedToGetRefreshToken);
    }
  }

  /// Saves the refresh token to secure storage.
  ///
  /// Throws a [TokenManagerException] if an error occurs during saving.
  @override
  Future<void> saveRefreshToken(String token) async {
    try {
      await _storage.write(key: 'refresh_token', value: token);
    } catch (e) {
      throw TokenManagerException(TokenErrorMessages.failedToSaveRefreshToken);
    }
  }

  /// Clears the refresh token from secure storage.
  ///
  /// Throws a [TokenManagerException] if an error occurs during clearing.
  @override
  Future<void> clearRefreshToken() async {
    try {
      await _storage.delete(key: 'refresh_token');
    } catch (e) {
      throw TokenManagerException(TokenErrorMessages.failedToClearRefreshToken);
    }
  }

  /// Clears both the access and refresh tokens from secure storage.
  @override
  Future<void> clearTokens() async {
    await clearAccessToken();
    await clearRefreshToken();
  }
}
