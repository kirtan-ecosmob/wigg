/// code : 200
/// message : "User logged in successfully"
/// data : {"userId":4,"authToken":"oiLHoCJJS9tF8gk9XCYJUDivHHQXNU","email":"kinjal.pethani@ecosmob.com","name":"kinjal","mobile":"1234567890","role":"","profile_pic":"http://95.217.176.189:8084/profile_image/4.png"}

class LoginModel {
  int _code;
  String _message;
  UserData _data;

  int get code => _code;
  String get message => _message;
  UserData get data => _data;

  LoginModel({
      int code, 
      String message, 
      UserData data}){
    _code = code;
    _message = message;
    _data = data;
}

  LoginModel.fromJson(dynamic json) {
    _code = json["code"];
    _message = json["message"];
    _data = json["data"] != null ? UserData.fromJson(json["data"]) : null;
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

/// userId : 4
/// authToken : "oiLHoCJJS9tF8gk9XCYJUDivHHQXNU"
/// email : "kinjal.pethani@ecosmob.com"
/// name : "kinjal"
/// mobile : "1234567890"
/// role : ""
/// profile_pic : "http://95.217.176.189:8084/profile_image/4.png"

class UserData {
  int _userId;
  String _authToken;
  String _email;
  String _name;
  String _mobile;
  String _role;
  String _profilePic;
  int _warrantyExpireDay;
  bool _isParentUser;

  int get userId => _userId;
  String get authToken => _authToken;
  String get email => _email;
  String get name => _name;
  String get mobile => _mobile;
  String get role => _role;
  String get profilePic => _profilePic;
  int get warrantyExpireDay => _warrantyExpireDay;
  bool get isParentUser => _isParentUser;

  UserData({
      int userId, 
      String authToken, 
      String email, 
      String name, 
      String mobile, 
      String role, 
      String profilePic,
      bool isParentUser,
    int warrantyExpireDay}){
    _userId = userId;
    _authToken = authToken;
    _email = email;
    _name = name;
    _mobile = mobile;
    _role = role;
    _profilePic = profilePic;
    _warrantyExpireDay = warrantyExpireDay;
    _isParentUser = isParentUser;
}

  UserData.fromJson(dynamic json) {
    _userId = json["userId"];
    _authToken = json["authToken"];
    _email = json["email"];
    _name = json["name"];
    _mobile = json["mobile"];
    _role = json["role"];
    _profilePic = json["profile_pic"];
    _warrantyExpireDay = json["warranty_expire_days"];
    _isParentUser  = json["is_parent_user"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["userId"] = _userId;
    map["authToken"] = _authToken;
    map["email"] = _email;
    map["name"] = _name;
    map["mobile"] = _mobile;
    map["role"] = _role;
    map["profile_pic"] = _profilePic;
    map["warranty_expire_days"] = _warrantyExpireDay;
    map["is_parent_user"] = _isParentUser;
    return map;
  }

}