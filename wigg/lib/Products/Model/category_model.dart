/// code : 200
/// message : "Data fetched successfully"
/// data : [{"id":1,"name":"Appliances"},{"id":2,"name":"Lifestyle"},{"id":3,"name":"Electronics"}]

class CategoryModel {
  int _code;
  String _message;
  List<CategoryData> _data;

  int get code => _code;
  String get message => _message;
  List<CategoryData> get catData => _data;

  CategoryModel({
      int code, 
      String message, 
      List<CategoryData> data}){
    _code = code;
    _message = message;
    _data = data;
}

  CategoryModel.fromJson(dynamic json) {
    _code = json["code"];
    _message = json["message"];
    if (json["data"] != null) {
      _data = [];
      json["data"].forEach((v) {
        _data.add(CategoryData.fromJson(v));
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

/// id : 1
/// name : "Appliances"

class CategoryData {
  int _id;
  String _name;
  bool _isSelected = false;

  int get id => _id;
  String get name => _name;
  bool get isSelectd => _isSelected;

  set isSelectd(bool value){
    this._isSelected = value;
  }
  set name(String value){
    this._name = value;
  }

  CategoryData({
      int id, 
      String name,
      bool isSelected}){
    _id = id;
    _name = name;
    _isSelected = isSelected;
}

  CategoryData.fromJson(dynamic json) {
    _id = json["id"];
    _name = json["name"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["id"] = _id;
    map["name"] = _name;
    return map;
  }

}