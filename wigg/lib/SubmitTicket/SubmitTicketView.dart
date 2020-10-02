import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'package:wigg/Groups/Model/group_model.dart';
import 'package:wigg/Utils/AppColors.dart';
import 'package:wigg/Utils/CommonFunctions.dart';
import 'package:wigg/Utils/DeviceHeaders.dart';
import 'package:wigg/Utils/OnFailure.dart';
import 'package:wigg/Utils/ResponseStatus.dart';
import 'package:wigg/Utils/WebAPi.dart';
import 'package:http/http.dart' as http;

class SubmitTicketView extends StatefulWidget {
  static String name = '/SubmitTicket';
  @override
  _SubmitTicketViewState createState() => _SubmitTicketViewState();
}

class _SubmitTicketViewState extends State<SubmitTicketView> {
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  TextEditingController txtSubject = TextEditingController();
  TextEditingController txtDesc = TextEditingController();

  // TODO: implement initState
  @override
  void initState() {
    super.initState();

  }


  // TODO: API calling

  // Future<ResponseStatus> submitTicket() async {
  //   final url = WebApi.submitTicket;
  //   var params = {"subject": txtSubject.text.trim(), "description": txtDesc.text.trim()};
  //
  //   print("Url : $url");
  //   print("Params : $params");
  //
  //   final http.Response response = await http.post(
  //     url,
  //     headers: DeviceHeaders.instance.getHeaders(),
  //     body: jsonEncode(params),
  //   );
  //
  //   print("Status Code : ${response.statusCode}");
  //   print("Response : ${response.body}");
  //   if (response.statusCode == 200 || response.statusCode == 401) {
  //     return ResponseStatus.fromJson(json.decode(response.body));
  //   } else {
  //     final res = ResponseStatus.fromJson(json.decode(response.body));
  //     throw OnFailure(res.code, res.message);
  //   }
  // }

  _submitTicket() async {
    Dialogs.showLoadingDialog(context, _keyLoader);
    final url = WebApi.submitTicket;
    var params = {"subject": txtSubject.text.trim(), "description": txtDesc.text.trim()};

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

      Navigator.of(context).pop();
      Toast.show(res.message, context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);

    } else {
    final res = ResponseStatus.fromJson(json.decode(response.body));
    Toast.show(res.message, context,
        duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    // throw OnFailure(res.code, res.message);
    }
  }


  // TODO: Custon Functions

  bool _isValidate(BuildContext context) {
    if (txtSubject.text.trim().isEmpty) {
      Toast.show('Please enter subject', context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      return false;
    } else if (txtDesc.text.trim().isEmpty) {
      Toast.show('Please enter description', context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      return false;
    }
  }



  @override
  Widget build(BuildContext context) {


    Widget allTextField(){
      return SingleChildScrollView(
        // physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            CommonFunction.customTextfield("Subject of Complain", txtSubject, TextInputType.text, context),
            // addressTypeDropDown(),
            // SizedBox(height: 15,),
            CommonFunction.customTextfield("Description", txtDesc, TextInputType.text, context, isLastTextfield: true),
          ],
        ),
      );
    }


    Widget stackView() {
      return Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height - 227,
            // color: Colors.blue,
          ),
          Container(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: allTextField(),
          ),
          new Positioned(
            right: 0,
            bottom: 40,
            child: Container(
              child: YellowThemeButton(
                btnName: "Submit",
                onPressed: () {
                  if (_isValidate(context) == null){
                    _submitTicket();
                  }
                },
              ),
            ),
          )
        ],
      );
    }

    final title = Container(
      padding: EdgeInsets.only(top: 50, left: 20, right: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit.", style: TextStyle(fontSize: 16),),
      ),
    );



    final mainContainer = Container(
      child: Column(
        children: [
          title,
          SizedBox(height: 30,),
          stackView(),
          // Expanded(// wrap in Expanded
          //   child: Container(
          //     padding: EdgeInsets.only(bottom: 20),
          //     // child: dataContainer(),
          //   ),
          // ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.appBottleGreenColor,
      appBar: AppBar(
        title: Text("Submit Ticket",
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
                  topLeft: Radius.circular(40), topRight: Radius.circular(40))),
          child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: mainContainer,
          ),
        ),
      ),
    );
  }
}
