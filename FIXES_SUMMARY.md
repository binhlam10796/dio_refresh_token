# Dio Refresh Token - Issues Fixed

This document summarizes the issues that were identified and fixed in the dio_refresh_token Flutter package.

## Issues Addressed

### Issue #2: URL Construction Problem
**Problem**: When cloning request in TokenInterceptor, the created URL contains only path not full URL.

**Root Cause**: The original code was using only `err.requestOptions.path` which contains just the path portion (e.g., `/all-movies`) instead of the full URL (`https://api.movies.com/all-movies`).

**Solution**: 
- Implemented proper URL construction logic that combines `baseUrl + path` when baseUrl exists
- Falls back to using path only when baseUrl is empty
- This handles both scenarios: when the full URL is in the path, and when it's split between baseUrl and path

```dart
// Old code (broken)
final cloneReq = await Dio().request(
  err.requestOptions.path, // Only path - missing baseUrl!
  // ...
);

// New code (fixed)
final fullUrl = err.requestOptions.baseUrl.isNotEmpty 
    ? err.requestOptions.baseUrl + err.requestOptions.path
    : err.requestOptions.path;
    
final cloneReq = await dioInstance.request(
  fullUrl, // Proper full URL
  // ...
);
```

### Issue #3: Null Reference Exception
**Problem**: The code was calling `err.response!` without checking if response is null, causing unhandled exceptions when network connectivity issues occur.

**Root Cause**: The line `if (tokenRefreshStrategy.shouldRefreshToken(err.response!))` assumes response is never null, but it can be null in cases like network timeouts or connection errors.

**Solution**:
- Added null safety check: `if (err.response != null && tokenRefreshStrategy.shouldRefreshToken(err.response!))`
- This prevents null reference exceptions and gracefully handles network connectivity issues

```dart
// Old code (broken)
if (tokenRefreshStrategy.shouldRefreshToken(err.response!)) {
  // Can throw null reference exception!
}

// New code (fixed)
if (err.response != null && tokenRefreshStrategy.shouldRefreshToken(err.response!)) {
  // Safe from null reference exceptions
}
```

### Issue #1: Incomplete Request Retry Mechanism
**Problem**: When retrieving a new access token, the retry request was not preserving all the original request data.

**Root Cause**: The original retry request only copied method and headers, missing important data like request body, query parameters, and other options.

**Solution**:
- Enhanced the retry mechanism to preserve all original request data
- Added support for passing the same Dio instance to maintain configuration
- Comprehensive request cloning with all options preserved

```dart
// Old code (incomplete)
final cloneReq = await Dio().request(
  err.requestOptions.path,
  options: Options(
    method: err.requestOptions.method,
    headers: err.requestOptions.headers,
  ),
);

// New code (complete)
final cloneReq = await dioInstance.request(
  fullUrl,
  data: err.requestOptions.data,                    // Request body
  queryParameters: err.requestOptions.queryParameters, // Query params
  options: Options(
    method: err.requestOptions.method,
    headers: err.requestOptions.headers,
    responseType: err.requestOptions.responseType,
    contentType: err.requestOptions.contentType,
    validateStatus: err.requestOptions.validateStatus,
    receiveTimeout: err.requestOptions.receiveTimeout,
    sendTimeout: err.requestOptions.sendTimeout,
    extra: err.requestOptions.extra,
  ),
);
```

## Additional Improvements

### Optional Dio Instance Parameter
Added an optional `dio` parameter to the TokenInterceptor constructor to allow using the same Dio instance that has the proper configuration, instead of creating a new one for each retry.

```dart
TokenInterceptor({
  required this.tokenManager,
  required this.tokenRefreshStrategy,
  this.dio, // Optional: maintains configuration consistency
});
```

### Comprehensive Test Coverage
Added new tests to cover:
- Null response handling
- URL construction with baseUrl
- URL construction with empty baseUrl
- All edge cases for the fixes

## Impact

These fixes ensure that:
1. **Retry requests use correct URLs** - fixing the URL construction issue
2. **No null reference exceptions** - making the package more robust
3. **Complete request preservation** - ensuring retry requests work exactly like original requests
4. **Better configuration consistency** - by optionally using the same Dio instance

The changes are minimal and surgical, focusing only on the specific issues without breaking existing functionality.