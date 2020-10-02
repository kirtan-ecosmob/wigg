import 'package:meta/meta.dart';

class ResponseStatus {
  String message;
  int code;

  void setMessage(String message) {
    this.message = message;
  }

  void setCode(int code) {
    this.code = code;
  }

  /// A [Unit] stores its name and conversion factor.
  ///
  /// An example would be 'Meter' and '1.0'.
  ResponseStatus(
      {@required this.code, @required this.message});

  /// Creates a [Unit] from a JSON object.
  factory ResponseStatus.fromJson(Map jsonMap) {
    return ResponseStatus(
        code: jsonMap['code'],
        message: jsonMap['message'],);
  }
}
