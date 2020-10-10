// import 'dart:html';

import 'dart:async';
import 'dart:io';

import 'package:badges/badges.dart';
import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:flutter_advanced_networkimage/provider.dart';
import 'package:toast/toast.dart';
import 'package:wigg/Dashboard/DashboardViewModel.dart';
import 'package:wigg/Dashboard/Model/dashboard_model.dart';
import 'package:wigg/Notification/NotificaitonListView.dart';
import 'package:wigg/Utils/AppColors.dart';
import 'package:wigg/Utils/AppImages.dart';
import 'package:wigg/Utils/AppStrings.dart';
import 'package:wigg/Utils/CommonFunctions.dart';
import 'package:wigg/Utils/OnFailure.dart';
import 'package:wigg/Utils/Preference.dart';
import 'package:wigg/Utils/StateProvider.dart';

import '../HomeTabController.dart';
import '../main.dart';
// import 'package:cached_network_image/cached_network_image.dart';

class DashboardView extends StatefulWidget {
  static String name = '/Dashboard';

  @override
  _DashboardViewState createState() => _DashboardViewState();
}

// class _DashboardViewState extends State<DashboardView> {
class _DashboardViewState extends State<DashboardView>  implements StateListener {

  _DashboardViewState(){
    var stateProvider = new StateProvider();
    stateProvider.subscribe(this);
  }


  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  DashboardData dashBoardDetails = DashboardData();
  StateProvider _stateProvider = StateProvider();
  String _profilePic = "";
  String _userFullName = "";
  int _currentIndex = 0;

  String id;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    DartNotificationCenter.subscribe(channel: AppStrings.updateNotificationCount, observer: this.dashBoardDetails, onNotification: (result) {
      _dashboardAPI();
    });

    // if (_keyLoader.currentContext != null){
    //   Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
    // }

    postInit(() {
      _getNameAndImg();
      _dashboardAPI();
    });
  }


  //TODO:- Firebase notification redirection

  Future <void> _showNotification({String title, String body, String payload}) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
        '0', 'Wigg', 'your channel description',
        importance: Importance.max,
        priority: Priority.high);
    const NotificationDetails platformChannelSpecifics =
    NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, title, body, platformChannelSpecifics,
        payload: payload);
  }

  // TODO: API calling and functions

  _getNameAndImg() {
    getProfileImage().then(
          (value) {
        setState(() {
          this._profilePic = value;
        });
      },
    );
    getFullname().then((value) {
      setState(() {
        this._userFullName = value;
      });
    });
  }

  _dashboardAPI() {
    Dialogs.showLoadingDialog(context, _keyLoader);
    DashboardViewModel.instance.getDashboardData().then((response) {
      Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
      if (response.code == 200) {
        setState(() {
          this.dashBoardDetails = response.data;
          // Timer(Duration(seconds: 1), (){setState(() {_stateProvider.notify(ObserverState.VALUE_CHANGED, this.dashBoardDetails.notification.toString());});});
        });
      } else {
        Toast.show(response.message, context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      }
    }, onError: (e) {
      Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
      if (e is OnFailure) {
        final res = e;
        Toast.show(res.message, context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        CommonFunction.redirectToLogin(context, e);
      }
    });
  }

  Widget buildCustomContainer(String imgName, String apiData, String title){
      return Container(
        padding: EdgeInsets.all(20),
        // height: 200,
        width: (MediaQuery.of(context).size.width/2) - 30,
        decoration: BoxDecoration(
            color: AppColors.appLightBottleGreenColor, borderRadius: BorderRadius.circular(30)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                height: 30,
                width: 30,
                child: CommonFunction.setImage(imgName, BoxFit.cover),
              ),
            ),

            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                child: Text(apiData == "null" ? "0" : apiData, style: TextStyle(fontSize: 50, color: Colors.white),),
              ),
            ),
            Text(title, style: TextStyle(fontSize: 18, color: Colors.white),),
          ],
        ),
      );
  }


  Widget _shoppingCartBadge() {
    return Badge(
      position: BadgePosition.topRight(top: 0, right: 3),
      animationDuration: Duration(milliseconds: 300),
      animationType: BadgeAnimationType.slide,
      badgeContent: Text(
        this.dashBoardDetails.notification != null ? this.dashBoardDetails.notification.toString() : "0",
        style: TextStyle(color: Colors.white),
      ),
      child: IconButton(icon: Image.asset(AppImages.ic_notificationbell), onPressed: () {
        print("notification");
        Navigator.push(context, MaterialPageRoute(builder: (context) => NotificationListView()));
      }),
    );
  }

  Text _tabBarText(String text, int index){
    if (index == _currentIndex){
      return new Text('$text\n•', textAlign: TextAlign.center,style: TextStyle(height: 1),);
    }else{
      return new Text('$text');
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget _sizedContainer(Widget child) {
      return SizedBox(
        width: 300.0,
        height: 150.0,
        child: Center(child: child),
      );
    }

    final userProfilePlaceHolder = CircleAvatar(
      backgroundColor: Colors.transparent,
      backgroundImage: AssetImage(AppImages.user_placeholder),
      radius: 30,
    );

    // final userImage = CachedNetworkImage(
    //   imageUrl: _profilePic,
    //   // placeholder: (context, url) => CircularProgressIndicator(),
    //   // errorWidget: (context, url, error) => Icon(Icons.error),
    //   placeholder: (context, url) => CircleAvatar(
    //     backgroundColor: Colors.amber,
    //     backgroundImage: AssetImage(AppImages.profile, package: 'wigg'),
    //     radius: 30,
    //   ),
    //   imageBuilder: (context, image) =>
    //       CircleAvatar(
    //         backgroundImage: image,
    //         radius: 30,
    //       ),
    // );

    final userImage = Container(
      height: 60,
      width: 60,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Image.network(
          _profilePic,
          fit: BoxFit.cover,
        ),
      ),
    );


    // final userImage = Container(
    //   height: 60,
    //   width: 60,
    //   child: ClipRRect(
    //     borderRadius: BorderRadius.circular(30),
    //     child: // using image provider
    //     Image(
    //       image: AdvancedNetworkImage(
    //         _profilePic,
    //         // header: header,
    //         useDiskCache: false,
    //         cacheRule: CacheRule(maxAge: const Duration(days: 7)),
    //       ),
    //       fit: BoxFit.cover,
    //     )
    //   ),
    // );


    final userDetailsContainer = Container(
      padding: EdgeInsets.only(left: 20, right: 20),
      height: 60,
      width: MediaQuery
          .of(context)
          .size
          .width,
      child: Row(
        mainAxisAlignment: (MainAxisAlignment.spaceBetween),
        children: [
          _profilePic != "" ? userImage : userProfilePlaceHolder,
          // _profilePic != "" ? CommonFunction.roundUseImage(_profilePic, 30) : Container(),
          Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    'Welcome',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                    textAlign: TextAlign.end,
                  ),
                  Text(_userFullName,
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                      textAlign: TextAlign.end),
                ],
              )),
        ],
      ),
      // color: Colors.black,
    );

    final dataContainer = Container(
        height: MediaQuery.of(context).size.height * 0.6,
      // width: MediaQuery.of(context).size.width - 40,
        // color: Colors.orange,
      child: SingleChildScrollView(
        child: Container(
          // width: MediaQuery.of(context).size.width - 80,
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  buildCustomContainer(AppImages.yourProducts, this.dashBoardDetails.product.toString(), '''Your\nProducts'''),
                  SizedBox(width: 20,),
                  buildCustomContainer(AppImages.warrentyExpire, this.dashBoardDetails.expireProduct.toString(), '''Warranty\nExpires'''),
                ],
              ),
              SizedBox(height: 25,),
              Row(
                children: [
                  buildCustomContainer(AppImages.userGroups, this.dashBoardDetails.groups.toString(), '''No. of\nGroups'''),
                  SizedBox(width: 20,),
                  buildCustomContainer(AppImages.subUser, this.dashBoardDetails.user.toString(), '''No. of\nSub Users'''),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    // final List<Widget> _grids = [
    //   buildCustomContainer(AppImages.yourProducts, this.dashBoardDetails.product.toString(), '''Your\nProducts'''),
    //   buildCustomContainer(AppImages.warrentyExpire, this.dashBoardDetails.expireProduct.toString(), '''Warranty\nExpires'''),
    //   buildCustomContainer(AppImages.userGroups, this.dashBoardDetails.groups.toString(), '''No. of\nGroups'''),
    //   buildCustomContainer(AppImages.subUser, this.dashBoardDetails.user.toString(), '''No. of\nSub Users'''),
    // ];
    //
    // final gridData = GridView.count(
    //
    //   crossAxisSpacing: 10,
    //   mainAxisSpacing: 10,
    //   crossAxisCount: 2,
    //   children: [
    //     buildCustomContainer(AppImages.yourProducts, this.dashBoardDetails.product.toString(), '''Your\nProducts'''),
    //     buildCustomContainer(AppImages.warrentyExpire, this.dashBoardDetails.expireProduct.toString(), '''Warranty\nExpires'''),
    //     buildCustomContainer(AppImages.userGroups, this.dashBoardDetails.groups.toString(), '''No. of\nGroups'''),
    //     buildCustomContainer(AppImages.subUser, this.dashBoardDetails.user.toString(), '''No. of\nSub Users'''),
    //   ],
    // );
    //
    //
    // final temp = GridView.count(
    //   crossAxisCount: 2 ,
    //   children: List.generate(50,(index){
    //     return Container(
    //       child: Card(
    //         color: Colors.blue,
    //       ),
    //     );
    //   }),
    // );

    final mainContainer = Column(
      children: [
        userDetailsContainer,
        SizedBox(height: 20,),
        dataContainer,
        // temp,
      ],

    );


    void onTabTapped(int index) {
      setState(() {
        _currentIndex = index;
      });
    }

    BottomNavigationBar _bottomTab() {
      return BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        unselectedItemColor: Colors.grey,
        //AppColors.textGreyColour,
        selectedItemColor: AppColors.appBottleGreenColor,
        currentIndex: _currentIndex,
        onTap: onTabTapped,
        // this will be set when a new tab is tapped
        items: [
          BottomNavigationBarItem(
            icon: new Icon(Icons.home),
            title: new Text('Dashboard'),
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage(AppImages.products),
              size: 15,
              color: _currentIndex == 1
                  ? AppColors.appBottleGreenColor
                  : Colors.grey,
            ),
            title: new Text('Products'),
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage(AppImages.groups),
              size: 15,
              color: _currentIndex == 2
                  ? AppColors.appBottleGreenColor
                  : Colors.grey,
            ),
            title: new Text('Groups'),
          ),
          BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage(AppImages.users),
                size: 15,
                color: _currentIndex == 3
                    ? AppColors.appBottleGreenColor
                    : Colors.grey,
              ),
              title: Text('Users')),
          BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage(AppImages.profile),
                size: 15,
                color: _currentIndex == 4
                    ? AppColors.appBottleGreenColor
                    : Colors.grey,
              ),
              title: Text('Profile')
          ),
              // title: Text( _currentIndex == 4 ? '''Profile\n•''' : 'Profile', textAlign: TextAlign.center,)),
        ],
      );
    }


    return Scaffold(
      appBar: AppBar(
        // title: Text("", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: AppColors.appBottleGreenColor,
        shadowColor: Colors.transparent,
        actions: [
          _shoppingCartBadge(),
        ],
        leading: CommonFunction.sideMenuBuilder(),
      ),
      endDrawer:  Builder(
        builder: (BuildContext context) {
          return IconButton(
            icon: Icon(Icons.home),
            onPressed: () {
              // Navigator.of(context).pushNamedAndRemoveUntil(
              //     HomeController.name, (Route route) => false);
            },
          );
        },
      ),
      drawer: navigationDrawer(),
      backgroundColor: Colors.transparent,
      body: mainContainer,
    );

    // return Scaffold(
    //   backgroundColor: AppColors.appBottleGreenColor,
    //   appBar: AppBar(
    //     centerTitle: true,
    //     title: Text(""),
    //     backgroundColor: AppColors.appBottleGreenColor,
    //     shadowColor: Colors.transparent,
    //     leading: Builder(
    //       builder: (BuildContext context) {
    //         return IconButton(
    //           icon: Image.asset(
    //             AppImages.side_menu,
    //           ),
    //           onPressed: () {
    //             Scaffold.of(context).openDrawer();
    //           },
    //           tooltip: MaterialLocalizations
    //               .of(context)
    //               .openAppDrawerTooltip,
    //         );
    //       },
    //     ),
    //   ),
    //   drawer: navigationDrawer(),
    //   body: mainContainer,
    //   bottomNavigationBar: _bottomTab(),
    // );
  }

  @override
  void onStateChanged(ObserverState state, String value) {
    // TODO: implement onStateChanged
    if (state == ObserverState.VALUE_CHANGED) {
      if (this.mounted) {
        setState(() {
          _getNameAndImg();
        });
      }
    }
  }
}
