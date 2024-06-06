/// The TokenErrorMessages class provides a collection of static constant strings
/// representing various error messages related to token operations. These error
/// messages can be used throughout the application to provide consistent and
/// meaningful error feedback.
class TokenErrorMessages {
  /// Error message indicating a failure to retrieve the access token.
  static const String failedToGetAccessToken = 'Failed to get access token';

  /// Error message indicating a failure to save the access token.
  static const String failedToSaveAccessToken = 'Failed to save access token';

  /// Error message indicating a failure to clear the access token.
  static const String failedToClearAccessToken = 'Failed to clear access token';

  /// Error message indicating a failure to retrieve the refresh token.
  static const String failedToGetRefreshToken = 'Failed to get refresh token';

  /// Error message indicating a failure to save the refresh token.
  static const String failedToSaveRefreshToken = 'Failed to save refresh token';

  /// Error message indicating a failure to clear the refresh token.
  static const String failedToClearRefreshToken =
      'Failed to clear refresh token';

  /// Error message indicating that the refresh token is null.
  static const String refreshTokenIsNull = 'Refresh token is null';

  /// Error message indicating a failure to extract the access token.
  static const String failedToExtractAccessToken =
      'Failed to extract access token';

  /// Error message indicating a failure to refresh the access token.
  static const String failedToRefreshAccessToken =
      'Failed to refresh access token';
}
