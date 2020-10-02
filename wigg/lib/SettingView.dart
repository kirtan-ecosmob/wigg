import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toast/toast.dart';
import 'package:wigg/Utils/CommonFunctions.dart';

import 'Utils/AppColors.dart';
import 'Utils/AppStrings.dart';
import 'Utils/DeviceHeaders.dart';
import 'Utils/OnFailure.dart';
import 'Utils/Preference.dart';
import 'Utils/ResponseStatus.dart';
import 'Utils/WebAPi.dart';
import 'package:http/http.dart' as http;

class SettingView extends StatefulWidget {
  @override
  _SettingViewState createState() => _SettingViewState();
}

class _SettingViewState extends State<SettingView> {
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  TextEditingController txtDays = TextEditingController();
  String days = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getWarrantyExpireDays().then((value) {
      setState(() {
        this.days = value.toString();
        txtDays.text = this.days;
      });
    });

  }

  // TODO: API calling

  _updateSetting() async {
    Dialogs.showLoadingDialog(context, _keyLoader);
    final url = WebApi.setNotification;
    var params = {"expire_day": txtDays.text.trim()};
    print("Url : $url");
    print("Params : $params");

    final http.Response response = await http.post(
      url,
      headers: DeviceHeaders.instance.getHeaders(),
      body: jsonEncode(params),
    );

    print("Status Code : ${response.statusCode}");
    print("Response : ${response.body}");
    Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
    if (response.statusCode == 200) {
      final res = ResponseStatus.fromJson(json.decode(response.body));

      SharedPreferences pref = await SharedPreferences.getInstance();
      pref.setInt(AppStrings.warrantyExpireDays, int.parse(txtDays.text.trim()));
      
      Toast.show(res.message, context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    } else {
      final res = ResponseStatus.fromJson(json.decode(response.body));
      Toast.show(res.message, context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
  }


  // TODO: Custom Functions

  bool _isValidate(BuildContext context) {
    if (txtDays.text.trim().isEmpty) {
      Toast.show('Please enter days', context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {






    Widget mainTitle(String title) {
      return Container(
        // color: Colors.pink,
        // padding: EdgeInsets.only(top: 0, left: 20, right: 20),
        // width: 100,
        width: MediaQuery.of(context).size.width - 150,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }


    Widget stackView() {
      return Stack(
        children: [
          Container(
            // height: MediaQuery.of(context).size.height - 202,
            // color: Colors.blue,
          ),
          Container(
            // padding: EdgeInsets.only(left: 20, right: 20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    mainTitle("Warranty Expires in (Days)"),
                    Container(
                      padding: EdgeInsets.only(top: 20),
                      width: 100,
                      // height: 55,
                      // color: Colors.amber,
                      child: CommonFunction.customTextfield("Days", txtDays, TextInputType.text, context, maxLength: 3, isLastTextfield: true),
                    ),
                  ],
                ),
              ],
            ),
          ),
          new Positioned(
            right: 0,
            bottom: 30,
            child: Container(
              child: YellowThemeButton(
                btnName: "Update",
                onPressed: () {
                  print("update");
                  FocusScope.of(context).unfocus();
                  if (_isValidate(context) == null){
                    _updateSetting();
                  }
                },
              ),
            ),
          )
        ],
      );
    }

    final mainContainer = Container(
      // color: Colors.pink,
      // height: MediaQuery.of(context).size.height - 100,
      padding: EdgeInsets.only(top: 50, left: 20),
      child: stackView(),
      // child: Column(
      //   children: [
      //     Row(
      //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //       children: [
      //         mainTitle("Warranty Expires in (Days)"),
      //         Container(
      //           padding: EdgeInsets.only(top: 20),
      //           width: 100,
      //           // height: 55,
      //           // color: Colors.amber,
      //           child: CommonFunction.customTextfield("Days", txtDays, TextInputType.text, context, maxLength: 3),
      //         ),
      //       ],
      //     ),
      //   ],
      // ),
    );

    return Scaffold(
      backgroundColor: AppColors.appBottleGreenColor,
      appBar: AppBar(
        title: Text("Settings",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: AppColors.appBottleGreenColor,
        shadowColor: Colors.transparent,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40))),
            child: mainContainer),
      ),
    );
  }
}
