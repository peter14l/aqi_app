/// Raised when a fetch/wrapper operation fails in a controlled way.
class FetchError implements Exception {
  final String message;

  FetchError(this.message);

  @override
  String toString() => 'FetchError: $message';
}
