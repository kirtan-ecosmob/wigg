/// code : 200
/// message : "Data fetched successfully"
/// data : [{"id":3,"name":"Test Product 123","images":["http://95.217.176.189:8084/product/product_image/3/thumbnail/11302014981538490429.jpg"]},{"id":2,"name":"Test Productt","images":[]}]

class ProductModel {
  int _code;
  String _message;
  List<Product> _product;

  int get code => _code;
  String get message => _message;
  List<Product> get productData => _product;

  ProductModel({
      int code, 
      String message,
      List<Product> data}){
    _code = code;
    _message = message;
    _product = data;
}

  ProductModel.fromJson(dynamic json) {
    _code = json["code"];
    _message = json["message"];
    if (json["data"] != null) {
      _product = [];
      json["data"].forEach((v) {
        _product.add(Product.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["code"] = _code;
    map["message"] = _message;
    if (_product != null) {
      map["data"] = _product.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// id : 3
/// name : "Test Product 123"
/// images : ["http://95.217.176.189:8084/product/product_image/3/thumbnail/11302014981538490429.jpg"]

class Product {
  int _id;
  String _name;
  String _expiryDate;
  String _purchaseDate;
  List<String> _images;
  bool _isSelected = false;

  int get id => _id;
  String get name => _name;
  String get expiryDate => _expiryDate;
  String get purchaseDate => _purchaseDate;
  List<String> get images => _images;
  bool get isSelected => _isSelected;

  set isSelected(bool value){
    this._isSelected = value;
  }

  Product({
      int id, 
      String name,
    String expiryDate,
    String purchaseDate,
      List<String> images,
    bool isSelected}){
    _id = id;
    _name = name;
    _expiryDate = expiryDate;
    _purchaseDate = purchaseDate;
    _images = images;
    _isSelected = isSelected;
}

  Product.fromJson(dynamic json) {
    _id = json["id"];
    _name = json["name"];
    _expiryDate = json["expiry_date"];
    _purchaseDate = json["purchase_date"];
    _images = json["images"] != null ? json["images"].cast<String>() : [];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["id"] = _id;
    map["name"] = _name;
    map["expiry_date"] = _expiryDate;
    map["purchase_date"] = _purchaseDate;
    map["images"] = _images;
    return map;
  }

}