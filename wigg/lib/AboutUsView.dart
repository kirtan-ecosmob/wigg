// import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:wigg/Utils/WebAPi.dart';
import 'package:http/http.dart' as http;
import 'package:wigg/Utils/CommonFunctions.dart';

import 'Utils/AppColors.dart';
import 'Utils/DeviceHeaders.dart';
import 'Utils/OnFailure.dart';

class AboutUsView extends StatefulWidget {
  @override
  _AboutUsViewState createState() => _AboutUsViewState();
}

class _AboutUsViewState extends State<AboutUsView> {
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  String htmlString = "";


  // TODO: implement initState
  @override
  void initState() {
    super.initState();
    postInit(() {
      getAboutUs();
    });
  }


  // TODO: API calling

  getAboutUs() async {
    Dialogs.showLoadingDialog(context, _keyLoader);
    final url = WebApi.aboutUs;
    print("Url : $url");
    final http.Response response = await http.get(
      url,
      headers: DeviceHeaders.instance.getHeaders(),
      // body: jsonEncode(params),
    );

    print("Status Code : ${response.statusCode}");
    print("Response : ${response.body}");
    Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
    if (response.statusCode == 200) {
      setState(() {
        htmlString = response.body;
      });
    } else {

    }

  }



  @override
  Widget build(BuildContext context) {






    return Scaffold(
      backgroundColor: AppColors.appBottleGreenColor,
      appBar: AppBar(
        title: Text("About Us",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: AppColors.appBottleGreenColor,
        shadowColor: Colors.transparent,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          height: MediaQuery.of(context).size.height - 100,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40))),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Html(
                    data: this.htmlString,
                  ),
                ],
              ),
            ),
        ),
      ),
    );

  }
}
