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

import 'Model/users_model.dart';



class UsersModelView{
  UsersModelView._privateConstructor();

  static final UsersModelView _singleton = UsersModelView._privateConstructor();

  static UsersModelView get instance => _singleton;

  var userRole = "";
  bool isParent = false;


  Future<UsersModel> getSubUserList() async {
    final url = WebApi.userList;
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
      return UsersModel.fromJson(json.decode(response.body));
    } else {
      final res = ResponseStatus.fromJson(json.decode(response.body));
      throw OnFailure(res.code, res.message);
    }
  }

  Future<ResponseStatus> deleteSubUser(String subuserId) async {
    final url = WebApi.userDelete + "/$subuserId";
    // var params = {"token": AppStrings.appToken, "email": email, "password": password, "device_token" : "123456789"};
    print("Url : $url");
    // print("Params : $params");
    // final http.Response response = await http.get(
    //   url,
    //   headers: DeviceHeaders.instance.getHeaders(),
    //   // body: jsonEncode(params),
    // );

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


  Future<ResponseStatus> addEditSubUser({Map<dynamic, dynamic> para, bool isEdit, SubUsersData user}) async {
    final url = isEdit ? WebApi.editUser : WebApi.addUser;
    var params = para;
    if (isEdit){
      params["sub_user_id"] = user.id.toString();
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


  Future<UsersDetails> getSubUserDetails(String userId) async {
    final url = WebApi.userDetails + "/$userId";
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
      return UsersDetails.fromJson(json.decode(response.body));
    } else {
      final res = ResponseStatus.fromJson(json.decode(response.body));
      throw OnFailure(res.code, res.message);
    }
  }

}