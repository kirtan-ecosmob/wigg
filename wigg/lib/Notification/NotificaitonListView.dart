import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'package:wigg/Notification/Model/notification_model.dart';
import 'package:wigg/Notification/NotificationModelView.dart';
import 'package:wigg/Products/Model/product_details.dart';
import 'package:wigg/Products/Model/product_model.dart';
import 'package:wigg/Products/ProductDetailView.dart';
import 'package:wigg/Utils/AppColors.dart';
import 'package:wigg/Utils/AppStrings.dart';
import 'package:wigg/Utils/CommonFunctions.dart';
import 'package:wigg/Utils/OnFailure.dart';

class NotificationListView extends StatefulWidget {
  @override
  _NotificationListViewState createState() => _NotificationListViewState();
}

class _NotificationListViewState extends State<NotificationListView> {
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  List<NotificationData> notificationList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    postInit(() {
      _getNotificationList();
    });
  }


  // TODO: API calling

  _getNotificationList(){
    Dialogs.showLoadingDialog(context, _keyLoader);
    NotificationModelView.instance.getNotificationList().then(
          (response) {
        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
        if (response.code == 200) {
          setState(() {
            notificationList = response.notificationData;
          });
        } else {
          Toast.show(response.message, context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        }
      },
      onError: (e) {
        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
        if (e is OnFailure) {
          final res = e;
          Toast.show(res.message, context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
          CommonFunction.redirectToLogin(context, e);
        }
      },
    );
  }
  
  _readNotification(String notificationId){
    NotificationModelView.instance.readNotification(notificationId).then(
          (response) {
        // Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
        if (response.code == 200) {
          // _getNotificationList();
        } else {
          Toast.show(response.message, context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        }
      },
      onError: (e) {
        // Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
        if (e is OnFailure) {
          final res = e;
          Toast.show(res.message, context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
          CommonFunction.redirectToLogin(context, e);
        }
      },
    );
  }


  // TODO:Custom Functions



  @override
  Widget build(BuildContext context) {



    Widget _notificationDataContainer(int index) {
      return new Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: Container(
          padding: EdgeInsets.only(left: 20, right: 20),
          // height: 70,
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
              color: Color(0xff00001A).withOpacity(0.3),
              //Colors.grey.withOpacity(0.5),
              spreadRadius: 0,
              blurRadius: 3,
              offset: Offset(0, 3),
            ),
          ], color: Colors.white, borderRadius: BorderRadius.circular(14)),
          child: Column(
            children: [
              // SizedBox(height: 10,),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    width: MediaQuery.of(context).size.width - 80,
                    child: Text(
                      notificationList[index].notificationText,
                      overflow: TextOverflow.ellipsis,
                      // maxLines: 3,
                      style:
                      TextStyle(fontSize: 18, fontWeight: notificationList[index].readStatus == "Y" ? FontWeight.normal : FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    Widget _notificationListView() {
      return new Container(
        // height: MediaQuery.of(context).size.height - 320,
        width: MediaQuery.of(context).size.width,
        // color: Colors.pinkAccent,
        child: ListView.builder(
            shrinkWrap: false,
            itemCount: notificationList.length,
            itemBuilder: (ctx, index) {
              return GestureDetector(
                onTap: () {
                  print(notificationList[index].notificationId);
                  if (notificationList[index].readStatus == "N"){
                    setState(() {
                      notificationList[index].readStatus = "Y";
                    });
                    DartNotificationCenter.post(channel: AppStrings.updateNotificationCount);
                    _readNotification(notificationList[index].notificationId.toString());
                  }

                  if (notificationList[index].notificationType == "purchase" || notificationList[index].notificationType == "warranty"){
                    Product tempProduct = Product(id: notificationList[index].typeId);
                    // Product tempProduct = Product(id: 10);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ProductDetailView(selectedProduct: tempProduct,)),
                    );
                  }

                },
                child: _notificationDataContainer(index),
              );
            }),
      );
    }


    final title = Container(
      // padding: EdgeInsets.only(top: 0, left: 20, right: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text("List of Notifications", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
      ),
    );

    final mainContainer = Container(
      // height: 100,
      // width: MediaQuery.of(context).size.width,
      // color: Colors.pink,
      // height: MediaQuery.of(context).size.height - 90,
      padding: EdgeInsets.only(top: 50, left: 20, right: 20),
      // color: Colors.black,
      child: Column(
        // mainAxisSize: MainAxisSize.min,
        children: [
          title,
          SizedBox(height: 10,),
          Expanded(
            child: _notificationListView(),
          ),
        ],
      ),
    );


    return Scaffold(
      backgroundColor: AppColors.appBottleGreenColor,
      appBar: AppBar(
        title: Text("Notifications", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: AppColors.appBottleGreenColor,
        shadowColor: Colors.transparent,
      ),
      body: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40), topRight: Radius.circular(40))),
        child: mainContainer,
      ),
    );
  }
}
