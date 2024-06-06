/// The dio_refresh_token library provides the necessary components for handling
/// token-based authentication with automatic token refresh functionality.
///
/// This library exports the following components:
/// - `token_manager.dart`: Defines the TokenManager interface and its implementation for managing tokens.
/// - `token_refresh_strategy.dart`: Contains strategies for refreshing tokens.
/// - `token_interceptor.dart`: Provides the interceptor for handling token refresh during HTTP requests.

library dio_refresh_token;

// Export the TokenManager interface and its implementation.
// TokenManager: An abstract class defining the methods for managing tokens.
// TokenManagerImpl: A concrete implementation of the TokenManager interface.
export 'token_manager.dart';

// Export the token refresh strategy.
// TokenRefreshStrategy: An abstract class defining the method for refreshing tokens.
// TokenRefreshStrategyImpl: A concrete implementation of the TokenRefreshStrategy interface.
export 'token_refresh_strategy.dart';

// Export the token interceptor.
// TokenInterceptor: An interceptor that handles token refresh logic during HTTP requests.
export 'token_interceptor.dart';
