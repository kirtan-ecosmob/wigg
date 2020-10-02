/// code : 200
/// message : "Please check your email for verification code"
/// data : {"code":"712426"}

class ForgetPassModel {
  int _code;
  String _message;
  Data _data;

  int get code => _code;
  String get message => _message;
  Data get data => _data;

  ForgetPassModel({
      int code, 
      String message, 
      Data data}){
    _code = code;
    _message = message;
    _data = data;
}

  ForgetPassModel.fromJson(dynamic json) {
    _code = json["code"];
    _message = json["message"];
    _data = json["data"] != null ? Data.fromJson(json["data"]) : null;
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["code"] = _code;
    map["message"] = _message;
    if (_data != null) {
      map["data"] = _data.toJson();
    }
    return map;
  }

}

/// code : "712426"

class Data {
  String _code;

  String get code => _code;

  Data({
      String code}){
    _code = code;
}

  Data.fromJson(dynamic json) {
    _code = json["code"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["code"] = _code;
    return map;
  }

}