/// The TokenManagerException class represents exceptions that occur within the
/// TokenManager during token management operations.
///
/// This class implements the [Exception] interface and contains a message
/// describing the specific error.
class TokenManagerException implements Exception {
  /// The error message describing the exception.
  final String message;

  /// Creates a [TokenManagerException] with the given error [message].
  TokenManagerException(this.message);

  /// Returns a string representation of the exception.
  @override
  String toString() => 'TokenManagerException: $message';
}

/// The TokenRefreshException class represents exceptions that occur during the
/// token refresh process.
///
/// This class implements the [Exception] interface and contains a message
/// describing the specific error.

class TokenRefreshException implements Exception {
  /// The error message describing the exception.
  final String message;

  /// Creates a [TokenRefreshException] with the given error [message].
  TokenRefreshException(this.message);

  /// Returns a string representation of the exception.
  @override
  String toString() => 'TokenRefreshException: $message';
}
