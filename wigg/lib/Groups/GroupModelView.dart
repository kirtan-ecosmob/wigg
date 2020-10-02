

import 'dart:convert';

import 'package:wigg/Groups/Model/group_model.dart';
import 'package:wigg/Utils/DeviceHeaders.dart';
import 'package:wigg/Utils/OnFailure.dart';
import 'package:wigg/Utils/ResponseStatus.dart';
import 'package:wigg/Utils/WebAPi.dart';
import 'package:http/http.dart' as http;

class GroupModelView {
  GroupModelView._privateConstructor();

  static final GroupModelView _singleton = GroupModelView
      ._privateConstructor();

  static GroupModelView get instance => _singleton;


  Future<GroupModel> getGroupList() async {
    final url = WebApi.groupList;
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
      return GroupModel.fromJson(json.decode(response.body));
    } else {
      final res = ResponseStatus.fromJson(json.decode(response.body));
      throw OnFailure(res.code, res.message);
    }
  }

  Future<ResponseStatus> addEditGroup({String addressName, String type, String address, bool isEdit, GroupData group}) async {
    final url = isEdit ? WebApi.editGroup : WebApi.addGroup;
    var params = {"name": addressName, "type": type, "address": address};
    if (isEdit){
      params["group_id"] = group.id.toString();
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

  Future<ResponseStatus> deleteGroup(String groupId) async {
    final url = WebApi.deleteGroup + "/$groupId";
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