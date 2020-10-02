import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyhub/easyHub.dart';
import 'package:flutter_easyhub/flutter_easy_hub.dart';
import 'package:wigg/Authentication/LoginView.dart';
import 'package:wigg/Dashboard/Model/dashboard_model.dart';
import 'package:wigg/Utils/DeviceHeaders.dart';
import 'package:wigg/Utils/OnFailure.dart';
import 'package:wigg/Utils/ResponseStatus.dart';
import 'package:wigg/Utils/WebAPi.dart';
import 'package:http/http.dart' as http;

class DashboardViewModel {
  DashboardViewModel._privateConstructor();

  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  static final DashboardViewModel _singleton =
      DashboardViewModel._privateConstructor();

  static DashboardViewModel get instance => _singleton;

  get email => null;

  Future<DashboardModel> getDashboardData() async {
    // EasyHub.instance.indicatorType =
    //     EasyHubIndicatorType.circularProgressEasy;
    // EasyHub.instance
    //   ..animationForegroundColor =
    //   new AlwaysStoppedAnimation(Colors.lightBlue)
    //   ..animationBackgroundColor = Colors.white;
    //
    // EasyHub.showHub();

    final url = WebApi.dashboard;
    // var params = {"token": AppStrings.appToken, "email": email, "password": password, "device_token" : "123456789"};
    print("Url : $url");
    // print("Params : $params");

    final http.Response response = await http.get(
      url,
      headers: DeviceHeaders.instance.getHeaders(),
    );

    print("Status Code : ${response.statusCode}");
    print("Response : ${response.body}");
    // Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
    // EasyHub.dismiss();
    if (response.statusCode == 200) {
      return DashboardModel.fromJson(json.decode(response.body));
    } else {
      final res = ResponseStatus.fromJson(json.decode(response.body));
      throw OnFailure(res.code, res.message);
    }
  }
}
