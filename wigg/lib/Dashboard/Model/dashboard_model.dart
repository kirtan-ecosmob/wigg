/// code : 200
/// message : "Data fetched successfully"
/// data : {"product":0,"groups":0,"user":0,"expire_product":0}

class DashboardModel {
  int _code;
  String _message;
  DashboardData _data;

  int get code => _code;
  String get message => _message;
  DashboardData get data => _data;

  DashboardModel({
      int code, 
      String message, 
      DashboardData data}){
    _code = code;
    _message = message;
    _data = data;
}

  DashboardModel.fromJson(dynamic json) {
    _code = json["code"];
    _message = json["message"];
    _data = json["data"] != null ? DashboardData.fromJson(json["data"]) : null;
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

/// product : 0
/// groups : 0
/// user : 0
/// expire_product : 0

class DashboardData {
  int _product;
  int _groups;
  int _user;
  int _expireProduct;
  int _notification;

  int get product => _product;
  int get groups => _groups;
  int get user => _user;
  int get expireProduct => _expireProduct;
  int get notification => _notification;

  DashboardData({
    int product,
    int groups,
    int user,
    int expireProduct,
    int notification}){
    _product = product;
    _groups = groups;
    _user = user;
    _expireProduct = expireProduct;
    _notification = notification;
  }

  DashboardData.fromJson(dynamic json) {
    _product = json["product"];
    _groups = json["groups"];
    _user = json["user"];
    _expireProduct = json["expire_product"];
    _notification = json["notification"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["product"] = _product;
    map["groups"] = _groups;
    map["user"] = _user;
    map["expire_product"] = _expireProduct;
    map["notification"] = _notification;
    return map;
  }

}