
import 'dart:convert';

import 'package:wigg/Notification/Model/notification_model.dart';
import 'package:wigg/Utils/DeviceHeaders.dart';
import 'package:wigg/Utils/OnFailure.dart';
import 'package:wigg/Utils/ResponseStatus.dart';
import 'package:wigg/Utils/WebAPi.dart';
import 'package:http/http.dart' as http;

class NotificationModelView{
  NotificationModelView._privateConstructor();

  static final NotificationModelView _singleton = NotificationModelView._privateConstructor();
  static NotificationModelView get instance => _singleton;



  Future<NotificationModel> getNotificationList() async {
    final url = WebApi.notificationList;
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
      return NotificationModel.fromJson(json.decode(response.body));
    } else {
      final res = ResponseStatus.fromJson(json.decode(response.body));
      throw OnFailure(res.code, res.message);
    }
  }

  Future<ResponseStatus> readNotification(String notificationId) async {
    final url = WebApi.readNotification;
    var params = {"notification_id": notificationId};
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

}