class OnFailure implements Exception {
  final message;
  final int code;

  OnFailure([this.code, this.message]);

  String toString() {
    if (message == null) return "Exception";
    return "$code: $message";
  }
}
