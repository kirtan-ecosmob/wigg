import 'dart:convert';
// import 'dart:html';
import 'dart:typed_data';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:wigg/Authentication/Model/forget_pass_model.dart';
import 'package:wigg/Utils/AppStrings.dart';
import 'package:wigg/Utils/CommonFunctions.dart';
import 'package:wigg/Utils/DeviceHeaders.dart';
import 'package:wigg/Utils/OnFailure.dart';
import 'package:wigg/Utils/ResponseStatus.dart';
import 'package:wigg/Utils/WebAPi.dart';
import 'Model/login_model.dart';

class LoginViewModel {
  LoginViewModel._privateConstructor();

  static final LoginViewModel _singleton = LoginViewModel._privateConstructor();

  static LoginViewModel get instance => _singleton;

  Future<LoginModel> loginUser(String email, String password) async {
    final url = WebApi.login;
    var params = {"token": AppStrings.appToken, "email": email, "password": password, "device_token" : "${DeviceHeaders.instance.deviceToken}"};
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
      return LoginModel.fromJson(json.decode(response.body));
    } else {
      final res = ResponseStatus.fromJson(json.decode(response.body));
      throw OnFailure(res.code, res.message);
    }
  }

  Future<ForgetPassModel> forgetPassword(String email) async {
    final url = WebApi.sendCode;
    var params = {"token": AppStrings.appToken, "email": email};
    print("Url : $url");
    print("Url : $params");
    final http.Response response = await http.post(
      url,
      headers: DeviceHeaders.instance.getHeaders(),
      body: jsonEncode(params),
    );

    print("Status Code : ${response.statusCode}");
    print("Response : ${response.body}");
    if (response.statusCode == 200 || response.statusCode == 401) {
      return ForgetPassModel.fromJson(json.decode(response.body));
    } else {
      final res = ResponseStatus.fromJson(json.decode(response.body));
      throw OnFailure(res.code, res.message);
    }
  }

  Future<ResponseStatus> verifyCode(String email, String password, String code) async {
    final url = WebApi.verifyCode;
    var params = {"token": AppStrings.appToken, "email": email, "verification_code" : code, "password" : password};
    print("Url : $url");
    print("Url : $params");
    final http.Response response = await http.post(
      url,
      headers: DeviceHeaders.instance.getHeaders(),
      body: jsonEncode(params),
    );

    print("Status Code : ${response.statusCode}");
    print("Response : ${response.body}");
    if (response.statusCode == 200 ) {
      return ResponseStatus.fromJson(json.decode(response.body));
    } else {
      final res = ResponseStatus.fromJson(json.decode(response.body));
      throw OnFailure(res.code, res.message);
    }
  }

  Future<LoginModel> registerUser(String name, String email, String password, String mobile) async {
    final url = WebApi.register;
    var params = {"token": AppStrings.appToken, "email": email, "password": password, "device_token" : "${DeviceHeaders.instance.deviceToken}", "name": name, "mobile": mobile};
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
      return LoginModel.fromJson(json.decode(response.body));
    } else {
      final res = ResponseStatus.fromJson(json.decode(response.body));
      throw OnFailure(res.code, res.message);
    }
  }

  Future<ResponseStatus> logoutUser() async {
    final url = WebApi.logout;
    // var params = {"token": AppStrings.appToken, "email": email, "password": password, "device_token" : "123456789", "name": name, "mobile": mobile};
    print("Url : $url");
    // print("Params : $params");
    final http.Response response = await http.post(
      url,
      headers: DeviceHeaders.instance.getHeaders(),
      // body: jsonEncode(params),
    );

    print("Status Code : ${response.statusCode}");
    print("Response : ${response.body}");
    return ResponseStatus.fromJson(json.decode(response.body));
    // if (response.statusCode == 200 ) {
    //   return ResponseStatus.fromJson(json.decode(response.body));
    // } else {
    //   final res = ResponseStatus.fromJson(json.decode(response.body));
    //   throw OnFailure(res.code, res.message);
    // }
  }


  //TODO: Profile

  Future<LoginModel> getUserProfile() async {
    final url = WebApi.getProfile;
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
      CommonFunction.saveToPref(LoginModel.fromJson(json.decode(response.body)).data);
      return LoginModel.fromJson(json.decode(response.body));
    } else {
      final res = ResponseStatus.fromJson(json.decode(response.body));
      throw OnFailure(res.code, res.message);
    }
  }


  Future<LoginModel> updateProfilePic(File image) async{

    // ByteData byteData = await imgAsset.getByteData(quality: 50);
    // List<int> imageData = await byteData.buffer.asUint8List();
    // String base64Image = base64Encode(imageData);

    final url = WebApi.updateProfile;
    // var params = {"profile_pic": base64Image};
    print("Url : $url");
    // print("Params : $params");

    // final http.Response response = await http.post(
    //   url,
    //   headers: DeviceHeaders.instance.getHeaders(),
    //   body: jsonEncode(params),
    // );

    final imageUploadRequest = http.MultipartRequest('POST', Uri.parse(url));

    final file = await http.MultipartFile.fromPath('profile_pic', image.path);
    imageUploadRequest.files.add(file);

    imageUploadRequest.headers.addAll(
      DeviceHeaders.instance.getHeaders(),
    );

    final streamResponse = await imageUploadRequest.send();
    final response = await http.Response.fromStream(streamResponse);

    print("Status Code : ${response.statusCode}");
    print("Multipart Uploading : ${response.body}");
    if (response.statusCode == 200) {
      return LoginModel.fromJson(json.decode(response.body));
    } else {
      final res = ResponseStatus.fromJson(json.decode(response.body));
      throw OnFailure(res.code, res.message);
    }
  }

  Future<LoginModel> updateUserDate(String name, String email, String mobile) async{
    final url = WebApi.updateProfile;
    var params = {"email": email, "mobile": mobile, "name": name};
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
      return LoginModel.fromJson(json.decode(response.body));
    } else {
      final res = ResponseStatus.fromJson(json.decode(response.body));
      throw OnFailure(res.code, res.message);
    }
  }

}