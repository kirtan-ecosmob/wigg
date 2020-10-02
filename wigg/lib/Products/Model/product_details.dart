/// code : 200
/// message : "Data fetched successfully"
/// data : {"id":6,"name":"Test Productt with lat llong","description":"sdf","price":"34.00","product_brand":"abcd","product_model":"efgh","latitude":23.02,"longitude":72.57,"expire_date":"09-25-2020","purchase_date":"09-09-2020","purchase_added_by":"kirtan","purchase_from":"Shop","barcode_file":"","images":["http://95.217.176.189:8084/product/product_image/1/IMG_7E3428B88902-1.jpeg"],"documents":["http://95.217.176.189:8084/product/document/6/be0865ab-33b8-43dc-ac78-746894c73e5bBinder1.pdf"],"document_title":["warranty"]}

class ProductDetails {
  int _code;
  String _message;
  ProductDetailsData _data;

  int get code => _code;
  String get message => _message;
  ProductDetailsData get data => _data;

  ProductDetails({
      int code, 
      String message, 
      ProductDetailsData data}){
    _code = code;
    _message = message;
    _data = data;
}

  ProductDetails.fromJson(dynamic json) {
    _code = json["code"];
    _message = json["message"];
    _data = json["data"] != null ? ProductDetailsData.fromJson(json["data"]) : null;
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

/// id : 6
/// name : "Test Productt with lat llong"
/// description : "sdf"
/// price : "34.00"
/// product_brand : "abcd"
/// product_model : "efgh"
/// latitude : 23.02
/// longitude : 72.57
/// expire_date : "09-25-2020"
/// purchase_date : "09-09-2020"
/// purchase_added_by : "kirtan"
/// purchase_from : "Shop"
/// barcode_file : ""
/// images : ["http://95.217.176.189:8084/product/product_image/1/IMG_7E3428B88902-1.jpeg"]
/// documents : ["http://95.217.176.189:8084/product/document/6/be0865ab-33b8-43dc-ac78-746894c73e5bBinder1.pdf"]
/// document_title : ["warranty"]

class ProductDetailsData {
  int _id;
  String _name;
  String _description;
  String _price;
  String _productBrand;
  String _productModel;
  double _latitude;
  double _longitude;
  String _expireDate;
  String _purchaseDate;
  String _purchaseAddedBy;
  String _purchaseFrom;
  String _barcodeFile;
  List<String> _images;
  List<String> _documents;
  List<String> _documentTitle;

  int _groupId;
  int _categoryId;

  int get id => _id;
  String get name => _name;
  String get description => _description;
  String get price => _price;
  String get productBrand => _productBrand;
  String get productModel => _productModel;
  double get latitude => _latitude;
  double get longitude => _longitude;
  String get expireDate => _expireDate;
  String get purchaseDate => _purchaseDate;
  String get purchaseAddedBy => _purchaseAddedBy;
  String get purchaseFrom => _purchaseFrom;
  String get barcodeFile => _barcodeFile;
  List<String> get images => _images;
  List<String> get documents => _documents;
  List<String> get documentTitle => _documentTitle;

  int get groupId => _groupId;
  int get categoryId => _categoryId;

  ProductDetailsData({
    int id,
    String name,
    String description,
    String price,
    String productBrand,
    String productModel,
    double latitude,
    double longitude,
    String expireDate,
    String purchaseDate,
    String purchaseAddedBy,
    String purchaseFrom,
    String barcodeFile,
    List<String> images,
    List<String> documents,
    List<String> documentTitle,
    int groupId,
    int categoryId,
  }) {
    _id = id;
    _name = name;
    _description = description;
    _price = price;
    _productBrand = productBrand;
    _productModel = productModel;
    _latitude = latitude;
    _longitude = longitude;
    _expireDate = expireDate;
    _purchaseDate = purchaseDate;
    _purchaseAddedBy = purchaseAddedBy;
    _purchaseFrom = purchaseFrom;
    _barcodeFile = barcodeFile;
    _images = images;
    _documents = documents;
    _documentTitle = documentTitle;
    _groupId = groupId;
    _categoryId = categoryId;
}

  ProductDetailsData.fromJson(dynamic json) {
    _id = json["id"];
    _name = json["name"];
    _description = json["description"];
    _price = json["price"];
    _productBrand = json["product_brand"];
    _productModel = json["product_model"];
    _latitude = json["latitude"];
    _longitude = json["longitude"];
    _expireDate = json["expire_date"];
    _purchaseDate = json["purchase_date"];
    _purchaseAddedBy = json["purchase_added_by"];
    _purchaseFrom = json["purchase_from"];
    _barcodeFile = json["barcode_file"];
    _images = json["images"] != null ? json["images"].cast<String>() : [];
    _documents = json["documents"] != null ? json["documents"].cast<String>() : [];
    _documentTitle = json["document_title"] != null ? json["document_title"].cast<String>() : [];

    _groupId = json["group_id"];
    _categoryId = json["category_id"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["id"] = _id;
    map["name"] = _name;
    map["description"] = _description;
    map["price"] = _price;
    map["product_brand"] = _productBrand;
    map["product_model"] = _productModel;
    map["latitude"] = _latitude;
    map["longitude"] = _longitude;
    map["expire_date"] = _expireDate;
    map["purchase_date"] = _purchaseDate;
    map["purchase_added_by"] = _purchaseAddedBy;
    map["purchase_from"] = _purchaseFrom;
    map["barcode_file"] = _barcodeFile;
    map["images"] = _images;
    map["documents"] = _documents;
    map["document_title"] = _documentTitle;

    map["group_id"] = _groupId;
    map["category_id"] = _categoryId;
    return map;
  }

}