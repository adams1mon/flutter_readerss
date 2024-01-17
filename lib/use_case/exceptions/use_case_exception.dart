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