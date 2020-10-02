

import 'dart:convert';
import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:wigg/Groups/Model/group_model.dart';
import 'package:wigg/Products/Model/category_model.dart';
import 'package:wigg/Products/Model/product_model.dart';
import 'package:wigg/Utils/AppStrings.dart';
import 'package:wigg/Utils/DeviceHeaders.dart';
import 'package:wigg/Utils/OnFailure.dart';
import 'package:wigg/Utils/ResponseStatus.dart';
import 'package:wigg/Utils/WebAPi.dart';
import 'package:http/http.dart' as http;

import 'Model/product_details.dart';

class ProductModelView {
  ProductModelView._privateConstructor();

  static final ProductModelView _singleton = ProductModelView._privateConstructor();

  static ProductModelView get instance => _singleton;


  Future<ProductModel> getProductList({String amount = "", String purchaseDate = "", String expirySoon = "", String categoryId = "", String addressId = "", String title = ""}) async {
    final url = WebApi.productList;
    var params = {"amount": amount, "purchase_date": purchaseDate, "expiry_soon": expirySoon, "category_id" : categoryId, "address_id" : addressId, "title" : title};
    print("Url : $url");
    print("Params : $params");
    final http.Response response = await http.post(
      url,
      headers: DeviceHeaders.instance.getHeaders(),
      body: jsonEncode(params),
    );

    print("Status Code : ${response.statusCode}");
    print("Response : ${response.body}");
    if (response.statusCode == 200) {
      return ProductModel.fromJson(json.decode(response.body));
    } else {
      final res = ResponseStatus.fromJson(json.decode(response.body));
      throw OnFailure(res.code, res.message);
    }
  }


  Future<ResponseStatus> deleteProduct(String productId) async {
    final url = WebApi.productDelete + "/$productId";
    // var params = {"token": AppStrings.appToken, "email": email, "password": password, "device_token" : "123456789"};
    print("Url : $url");
    // print("Params : $params");

    final http.Response response = await http.delete(
      url,
      headers: DeviceHeaders.instance.getHeaders(),
    );

    print("Status Code : ${response.statusCode}");
    print("Response : ${response.body}");
    if (response.statusCode == 200) {
      return ResponseStatus.fromJson(json.decode(response.body));
    } else {
      final res = ResponseStatus.fromJson(json.decode(response.body));
      throw OnFailure(res.code, res.message);
    }
  }

  Future<ProductDetails> getProductDetails(String productId) async {
    final url = WebApi.productDetails + "/$productId";
    // var params = {"token": AppStrings.appToken, "email": email, "password": password, "device_token" : "123456789"};
    print("Url : $url");
    // print("Params : $params");
    final http.Response response = await http.get(
      url,
      headers: DeviceHeaders.instance.getHeaders(),
      // body: jsonEncode(params),
    );

    print("Status Code : ${response.statusCode}");
    print("Response : ${response.body}");
    if (response.statusCode == 200) {
      return ProductDetails.fromJson(json.decode(response.body));
    } else {
      final res = ResponseStatus.fromJson(json.decode(response.body));
      throw OnFailure(res.code, res.message);
    }
  }

  //TODO:- Add Product

  Future<File> testCompressAndGetFile(File file, String targetPath) async {
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path, targetPath,
      quality: 50,
      // rotate: 180,
    );

    print(file.lengthSync());
    print(result.lengthSync());

    return result;
  }

  Future<Directory> getTemporaryDirectory() async {
    return Directory.systemTemp;
  }

  Future<ResponseStatus> addEditProduct({
    String productName,
    String desc,
    String price,
    GroupData group,
    CategoryData category,
    String latitude,
    String longitude,
    String warrantyDate,
    String purchaseDate,
    String purchaseFrom,
    String productBrand,
    String productModel,
    List<File> productImages,
    List<File> productDocs,
    List<String> docTitles,
    File barcodeFile,
    bool isEdit,
    Product product,
    bool isChangesInImages,
    bool isChangesInDoc,
    bool isChangesInBarcode,
  }) async {
    final url = isEdit ? WebApi.editProduct :  WebApi.addProduct;
    // var params = {"profile_pic": base64Image};
    print("Url : $url");
    // print("Params : $params");

    final imageUploadRequest = http.MultipartRequest('POST', Uri.parse(url));

    // final file = await http.MultipartFile.fromPath('profile_pic', image.path);
    // imageUploadRequest.files.add(file);

    if (isChangesInImages){ // && productImages.length > 0
      productImages.forEach((element) async {
        print("FILE SIZE BEFORE: " + element.lengthSync().toString());
        final dir = await getTemporaryDirectory();
        final targetPath = dir.absolute.path + "/temp.jpg";
        print('TargetPath : $targetPath');

        testCompressAndGetFile(element, targetPath).then((value) async {
          print("FILE SIZE AFTER: " + value.lengthSync().toString());
          final imgFile = await http.MultipartFile.fromPath('product_image[]', element.path);
          imageUploadRequest.files.add(imgFile);
        });
      });
    }


    if (isChangesInDoc){ // && productDocs.length > 0
      imageUploadRequest.fields['fileTitles'] = docTitles.join(",");
      productDocs.forEach((element) async {
        final docFile = await http.MultipartFile.fromPath('documents[]', element.path);
        imageUploadRequest.files.add(docFile);
      });
    }

    if (isChangesInBarcode){ // && barcodeFile != null
      final bFile = await http.MultipartFile.fromPath('barcode_file', barcodeFile.path);
      imageUploadRequest.files.add(bFile);
    }

    imageUploadRequest.fields['product_name'] = productName;
    imageUploadRequest.fields['description'] = desc;
    imageUploadRequest.fields['price'] = price;
    imageUploadRequest.fields['group_id'] = group.id.toString();
    imageUploadRequest.fields['category_id'] = category.id.toString();
    imageUploadRequest.fields['latitude'] = latitude;
    imageUploadRequest.fields['longitude'] = longitude;
    imageUploadRequest.fields['warranty_date'] = warrantyDate;
    imageUploadRequest.fields['purchase_date'] = purchaseDate;
    imageUploadRequest.fields['purchase_from'] = purchaseFrom;
    imageUploadRequest.fields['product_brand'] = productBrand;
    imageUploadRequest.fields['product_model'] = productModel;

    if (isEdit){
      imageUploadRequest.fields['product_id'] = product.id.toString();
    }


    imageUploadRequest.headers.addAll(
      DeviceHeaders.instance.getHeaders(),
    );
    print("Params: ${imageUploadRequest.fields}");

    final streamResponse = await imageUploadRequest.send();
    final response = await http.Response.fromStream(streamResponse);


    
    print("Status Code : ${response.statusCode}");
    print("Multipart Uploading : ${response.body}");
    if (response.statusCode == 200) {
      return ResponseStatus.fromJson(json.decode(response.body));
    } else {
      final res = ResponseStatus.fromJson(json.decode(response.body));
      throw OnFailure(res.code, res.message);
    }
  }

//TODO:- Category

  Future<CategoryModel> getCategoryList() async {
    final url = WebApi.categoryList;
    // var params = {"token": AppStrings.appToken, "email": email, "password": password, "device_token" : "123456789"};
    print("Url : $url");
    // print("Params : $params");
    final http.Response response = await http.get(
      url,
      headers: DeviceHeaders.instance.getHeaders(),
      // body: jsonEncode(params),
    );

    print("Status Code : ${response.statusCode}");
    print("Response : ${response.body}");
    if (response.statusCode == 200) {
      return CategoryModel.fromJson(json.decode(response.body));
    } else {
      final res = ResponseStatus.fromJson(json.decode(response.body));
      throw OnFailure(res.code, res.message);
    }
  }


  Future<ResponseStatus> addEditCategory({String categoryName, bool isEdit, CategoryData category}) async {
    final url = isEdit ? WebApi.editCategory : WebApi.addCategory;
    var params = {"name": categoryName};
    if (isEdit){
      params["category_id"] = category.id.toString();
    }
    print("Url : $url");
    print("Params : $params");

    final http.Response response = await http.post(
      url,
      headers: DeviceHeaders.instance.getHeaders(),
      body: jsonEncode(params),
    );

    print("Status Code : ${response.statusCode}");
    print("Response : ${response.body}");
    if (response.statusCode == 200 || response.statusCode == 401) {
      return ResponseStatus.fromJson(json.decode(response.body));
    } else {
      final res = ResponseStatus.fromJson(json.decode(response.body));
      throw OnFailure(res.code, res.message);
    }
  }

  Future<ResponseStatus> deleteCategory(String categoryId) async {
    final url = WebApi.deleteCategory + "/$categoryId";
    // var params = {"token": AppStrings.appToken, "email": email, "password": password, "device_token" : "123456789"};
    print("Url : $url");
    // print("Params : $params");

    final http.Response response = await http.delete(
      url,
      headers: DeviceHeaders.instance.getHeaders(),
    );

    print("Status Code : ${response.statusCode}");
    print("Response : ${response.body}");
    if (response.statusCode == 200) {
      return ResponseStatus.fromJson(json.decode(response.body));
    } else {
      final res = ResponseStatus.fromJson(json.decode(response.body));
      throw OnFailure(res.code, res.message);
    }
  }




}