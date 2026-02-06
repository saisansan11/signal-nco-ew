// Client-side Rate Limiter for Signal NCO EW
// Token bucket algorithm to prevent API abuse

class RateLimiter {
  static final RateLimiter _instance = RateLimiter._();
  static RateLimiter get instance => _instance;

  RateLimiter._();

  final Map<String, _TokenBucket> _buckets = {};

  // Default rate limits per operation type
  static const Map<String, _RateConfig> _defaultLimits = {
    'firestore_read': _RateConfig(maxTokens: 30, refillPerSecond: 0.5),
    'firestore_write': _RateConfig(maxTokens: 10, refillPerSecond: 0.17),
    'auth_attempt': _RateConfig(maxTokens: 5, refillPerSecond: 0.033),
    'classroom_join': _RateConfig(maxTokens: 5, refillPerSecond: 0.083),
    'quiz_submit': _RateConfig(maxTokens: 10, refillPerSecond: 0.17),
  };

  /// Check if an operation is allowed
  bool canPerform(String operationKey) {
    final bucket = _getOrCreateBucket(operationKey);
    return bucket.hasTokens;
  }

  /// Record an operation (consume a token)
  /// Returns true if the operation was allowed, false if rate limited
  bool tryPerform(String operationKey) {
    final bucket = _getOrCreateBucket(operationKey);
    return bucket.tryConsume();
  }

  /// Get remaining tokens for an operation
  int remainingTokens(String operationKey) {
    final bucket = _getOrCreateBucket(operationKey);
    bucket.refill();
    return bucket.tokens.floor();
  }

  /// Get time until next token is available
  Duration? timeUntilAvailable(String operationKey) {
    final bucket = _getOrCreateBucket(operationKey);
    if (bucket.hasTokens) return Duration.zero;

    final config = _defaultLimits[operationKey] ?? _defaultLimits['firestore_read']!;
    final secondsUntilToken = (1.0 - bucket.tokens) / config.refillPerSecond;
    return Duration(milliseconds: (secondsUntilToken * 1000).ceil());
  }

  /// Reset all rate limits (e.g., on logout)
  void reset() {
    _buckets.clear();
  }

  /// Reset a specific operation's rate limit
  void resetOperation(String operationKey) {
    _buckets.remove(operationKey);
  }

  _TokenBucket _getOrCreateBucket(String key) {
    if (!_buckets.containsKey(key)) {
      final config = _defaultLimits[key] ?? _defaultLimits['firestore_read']!;
      _buckets[key] = _TokenBucket(
        maxTokens: config.maxTokens.toDouble(),
        refillPerSecond: config.refillPerSecond,
      );
    }
    return _buckets[key]!;
  }
}

class _RateConfig {
  final int maxTokens;
  final double refillPerSecond;

  const _RateConfig({
    required this.maxTokens,
    required this.refillPerSecond,
  });
}

class _TokenBucket {
  final double maxTokens;
  final double refillPerSecond;
  double tokens;
  DateTime lastRefill;

  _TokenBucket({
    required this.maxTokens,
    required this.refillPerSecond,
  })  : tokens = maxTokens,
        lastRefill = DateTime.now();

  bool get hasTokens {
    refill();
    return tokens >= 1.0;
  }

  bool tryConsume() {
    refill();
    if (tokens >= 1.0) {
      tokens -= 1.0;
      return true;
    }
    return false;
  }

  void refill() {
    final now = DateTime.now();
    final elapsed = now.difference(lastRefill).inMilliseconds / 1000.0;
    tokens = (tokens + elapsed * refillPerSecond).clamp(0.0, maxTokens);
    lastRefill = now;
  }
}
