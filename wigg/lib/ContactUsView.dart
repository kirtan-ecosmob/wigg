import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'Utils/AppColors.dart';

class ContactUsView extends StatefulWidget {
  @override
  _ContactUsViewState createState() => _ContactUsViewState();
}

class _ContactUsViewState extends State<ContactUsView> {
  @override
  Widget build(BuildContext context) {




    final mainTitle = Container(
      // padding: EdgeInsets.only(top: 0, left: 20, right: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text("Office Details", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
      ),
    );

    Widget subtitle(String title){
      return Container(
        // padding: EdgeInsets.only(top: 0, left: 20, right: 20),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
        ),
      );
    }

    Widget details(String detail){
      return Container(
        // padding: EdgeInsets.only(top: 0, left: 20, right: 20),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(detail, style: TextStyle(fontSize: 14, color: AppColors.appLightGrayColor),),
        ),
      );
    }

    Widget callOn(String number){
      return GestureDetector(
        onTap: () async {
          print(number);
          String url = 'tel://$number';
          if (await canLaunch(url) != null) {
          await launch(url);
          } else {
          throw 'Could not launch $url';
          }
        },
        child: Container(
          // padding: EdgeInsets.only(top: 0, left: 20, right: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(number, style: TextStyle(fontSize: 14, color: AppColors.appLightGrayColor),),
          ),
        ),
      );
    }

    final mainContainer = Container(
      // color: Colors.pink,
      height: MediaQuery.of(context).size.height - 100,
      padding: EdgeInsets.only(top: 50, left: 20, right: 20),
      // color: Colors.black,
      child: SingleChildScrollView(
        // physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          // mainAxisSize: MainAxisSize.min,
          children: [
            mainTitle,
            SizedBox(height: 20,),
            subtitle("Head Office"),
            SizedBox(height: 8,),
            details("A - 5236, Lorem ipsum dolor smit, Street Name Area Name, City name State Name - 000 000"),
            SizedBox(height: 10,),
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Call on", style: TextStyle(fontSize: 14),),
            ),
            SizedBox(height: 8,),
            Row(
              children: [
                callOn("97486 74895"),
                SizedBox(width: 8,),
                Text("|", style: TextStyle(fontSize: 14, color: AppColors.appLightGrayColor),),
                SizedBox(width: 8,),
                callOn("12344 55677"),
              ],
            ),
            SizedBox(height: 30,),
            subtitle("Area Name Office"),
            SizedBox(height: 8,),
            details("A - 5236, Lorem ipsum dolor smit, Street Name Area Name, City name State Name - 000 000"),
            SizedBox(height: 10,),
            Align(
              alignment: Alignment.centerLeft,
              child: Text("Call on", style: TextStyle(fontSize: 14),),
            ),
            SizedBox(height: 8,),
            Row(
              children: [
                callOn("97486 74895"),
                SizedBox(width: 8,),
                Text("|", style: TextStyle(fontSize: 14, color: AppColors.appLightGrayColor),),
                SizedBox(width: 8,),
                callOn("12344 55677"),
              ],
            ),
          ],
        ),
      )
    );


    return Scaffold(
      backgroundColor: AppColors.appBottleGreenColor,
      appBar: AppBar(
        title: Text("Contact Us",
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
          child: mainContainer
        ),
      ),
    );

  }
}
