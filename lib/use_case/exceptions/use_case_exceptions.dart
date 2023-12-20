class UseCaseException implements Exception {
  final dynamic message;
  final String exceptionName = "UseCaseException";

  UseCaseException([this.message]);

  @override
  String toString() {
    Object? message = this.message;
    if (message == null) return exceptionName;
    return "$exceptionName: $message";
  }
}

class FeedLoadException extends UseCaseException {
  FeedLoadException([super.message]);

  @override
  String get exceptionName => "FeedLoadException";
}

class FeedToggleException extends UseCaseException {
  FeedToggleException([super.message]);

  @override
  String get exceptionName => "FeedToggleException";
}

class FeedBookmarkException extends UseCaseException {
  FeedBookmarkException([super.message]);

  @override
  String get exceptionName => "FeedBookmarkException";
}