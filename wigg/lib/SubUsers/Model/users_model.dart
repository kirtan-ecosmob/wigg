/// code : 200
/// message : "Data fetched successfully"
/// UsersData : [{"id":9,"email":"kirtan@gmail.com","name":"kp","relation":"Bro","mobile":"","status":"Active","parent_name":"kirtan"}]

class UsersModel {
  int _code;
  String _message;
  List<SubUsersData> _data;

  int get code => _code;
  String get message => _message;
  List<SubUsersData> get subUserData => _data;

  UsersModel({int code, String message, List<SubUsersData> usersData}) {
    _code = code;
    _message = message;
    _data = usersData;
  }

  UsersModel.fromJson(dynamic json) {
    _code = json["code"];
    _message = json["message"];
    if (json["data"] != null) {
      _data = [];
      json["data"].forEach((v) {
        _data.add(SubUsersData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["code"] = _code;
    map["message"] = _message;
    if (_data != null) {
      map["data"] = _data.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class UsersDetails {
  int _code;
  String _message;
  SubUsersData _data;

  int get code => _code;
  String get message => _message;
  SubUsersData get subUserData => _data;

  UsersDetails({int code, String message, SubUsersData usersData}) {
    _code = code;
    _message = message;
    _data = usersData;
  }

  UsersDetails.fromJson(dynamic json) {
    _code = json["code"];
    _message = json["message"];
    _data = json["data"] != null ? SubUsersData.fromJson(json["data"]) : null;
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

/// id : 9
/// email : "kirtan@gmail.com"
/// name : "kp"
/// relation : "Bro"
/// mobile : ""
/// status : "Active"
/// parent_name : "kirtan"

class SubUsersData {
  int _id;
  String _email;
  String _name;
  String _relation;
  String _mobile;
  String _status;
  String _parentName;
  String _profilePic;
  String _role;
  String _productIds;

  int get id => _id;
  String get email => _email;
  String get name => _name;
  String get relation => _relation;
  String get mobile => _mobile;
  String get status => _status;
  String get parentName => _parentName;
  String get profilePic => _profilePic;
  String get role => _role;
  String get productIds => _productIds;

  SubUsersData(
      {int id,
      String email,
      String name,
      String relation,
      String mobile,
      String status,
      String parentName,
        String profilePic,
        String role,
        String productIds,}) {
    _id = id;
    _email = email;
    _name = name;
    _relation = relation;
    _mobile = mobile;
    _status = status;
    _parentName = parentName;
    _profilePic = profilePic;
    _role = role;
    _productIds = productIds;
  }

  SubUsersData.fromJson(dynamic json) {
    _id = json["id"];
    _email = json["email"];
    _name = json["name"];
    _relation = json["relation"];
    _mobile = json["mobile"];
    _status = json["status"];
    _parentName = json["parent_name"];
    _profilePic = json["profile_pic"];
    _role = json["role"];
    _productIds = json["product_ids"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["id"] = _id;
    map["email"] = _email;
    map["name"] = _name;
    map["relation"] = _relation;
    map["mobile"] = _mobile;
    map["status"] = _status;
    map["parent_name"] = _parentName;
    map["profile_pic"] = _profilePic;
    map["role"] = _role;
    map["product_ids"] = _productIds;
    return map;
  }
}
