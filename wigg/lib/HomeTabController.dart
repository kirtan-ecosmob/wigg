// import 'package:cached_network_image/cached_network_image.dart';
import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:badges/badges.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:wigg/AboutUsView.dart';
import 'package:wigg/Category/CategoryListView.dart';
import 'package:wigg/Dashboard/DashboardView.dart';
import 'package:wigg/Groups/GroupListView.dart';
import 'package:wigg/Products/ProductsListView.dart';
import 'package:wigg/SettingView.dart';
import 'package:wigg/SubmitTicket/SubmitTicketView.dart';
import 'package:wigg/UserProfile/EditMyProfileView.dart';
import 'package:wigg/UserProfile/MyProfileView.dart';

import 'Authentication/LoginView.dart';
import 'Authentication/LoginViewModel.dart';
import 'Products/Model/product_model.dart';
import 'Products/ProductDetailView.dart';
import 'SubUsers/UserListView.dart';
import 'Utils/AppColors.dart';
import 'Utils/AppFonts.dart';
import 'Utils/AppImages.dart';
import 'Utils/Preference.dart';
import 'package:wigg/Utils/CommonFunctions.dart';


import 'package:wigg/main.dart';



class HomeTabBarController extends StatefulWidget {
  static String name = '/HomeTab';

   var index;

  HomeTabBarController({this.index = 0});

  @override
  _HomeTabBarControllerState createState() => _HomeTabBarControllerState();
}

// class ListScreenState extends State<ListScreen> implements StateListener {
class _HomeTabBarControllerState extends State<HomeTabBarController> {
  int _currentIndex = 0;
  // String _notificationCount = "";

  // final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  String id;
  static final Map<String, Route<void>> routes = <String, Route<void>>{};
  bool isFromLaunch = false;

  // _HomeTabBarControllerState(){
  //   var stateProvider = new StateProvider();
  //   stateProvider.subscribe(this);
  // }

  // TODO: implement initState
  @override
  void initState() {
    super.initState();
    // var stateProvider = new StateProvider();
    // stateProvider.subscribe(this);
    _firebaseConfig();
    _configureSelectNotificationSubject();
    setState(() {
      _currentIndex = widget.index;
    });



  }


  //TODO:- Firebase notification redirection

  _firebaseConfig() {
    firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");

        if (Platform.isAndroid) {
          id = message['data']['id'];
          _showNotification(
              title: message['notification']['title'],
              body: message['notification']['body'],
              payload: message['data']['type']);
        } else if (Platform.isIOS) {
          id = message['id'];
          _showNotification(
              title: message['aps']['alert']['title'],
              body: message['aps']['alert']['body'],
              payload: message['type']);
        }
      },
      onLaunch: (Map<String, dynamic> message) async {
        log("onLaunch: $message");
        // _navigateToItemDetail(message['type']);
        isFromLaunch = true;

        if (Platform.isAndroid) {
          id = message['data']['id'];
          selectNotificationSubject.add(message['data']['type']);
        } else if (Platform.isIOS) {
          id = message['id'];
          selectNotificationSubject.add(message['type']);
        }

      },
      onResume: (Map<String, dynamic> message) async {
        log("onResume: $message");
        if (Platform.isAndroid) {
          id = message['data']['id'];
          selectNotificationSubject.add(message['data']['type']);
        } else if (Platform.isIOS) {
          id = message['id'];
          selectNotificationSubject.add(message['type']);
        }
        // _navigateToItemDetail(message['type']);
      },
      onBackgroundMessage: myBackgroundMessageHandler,

    );
  }

  // void _navigateToItemDetail(String payload) {
  //   print(payload);
  //   if ((payload == "purchase" || payload == "warranty") && id != null){
  //     print('payload $payload id $id');
  //     Product tempProduct = Product(id: int.parse(id));
  //
  //     Navigator.push(
  //       context,
  //       MaterialPageRoute(builder: (context) => ProductDetailView(selectedProduct: tempProduct,)),
  //     );
  //   }
  // }

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


  final List<Widget> _children = [
    DashboardView(),
    ProductListView(),
    GroupListView(),
    UserListView(),
    MyProfileView(),
  ];

  Text _tabBarText(String text, int index){
    if (index == _currentIndex){
      return new Text('$text\n•', textAlign: TextAlign.center,style: TextStyle(height: 1),);
    }else{
      return new Text('$text');
    }
  }


  Future<void> _configureSelectNotificationSubject() async {
    selectNotificationSubject.stream.listen((String payload) async {

      if ((payload.toLowerCase() == "purchase" || payload.toLowerCase() == "warranty" || payload.toLowerCase() == "product" ) && id != null){
        print('payload $payload id $id');
        Product tempProduct = Product(id: int.parse(id));

        routes.putIfAbsent(
          DashboardView.name,
              () =>
              MaterialPageRoute<void>(
                settings: RouteSettings(name: DashboardView.name),
                builder: (BuildContext context) => DashboardView(),
              ),
        );

        // Navigator.popUntil(context, (Route<dynamic> route) {
        //   Navigator.push(
        //     context,
        //     MaterialPageRoute(builder: (context) => ProductDetailView(selectedProduct: tempProduct, isFromNotification: true,)),
        //   );
        //   return true;
        // });

        if (isFromLaunch){
          Timer(Duration(seconds: 2), (){
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProductDetailView(selectedProduct: tempProduct, isFromNotification: true,)),
            );
          });
          isFromLaunch = false;
        }else{
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProductDetailView(selectedProduct: tempProduct, isFromNotification: true,)),
          );
        }



        // await Navigator.push(
        //   context,
        //   MaterialPageRoute<void>(
        //       builder: (BuildContext context) => ProductDetailView(selectedProduct: tempProduct, isFromNotification: true,)),
        // );
      }
    });
  }

  @override
  void dispose() {
    selectNotificationSubject.close();
    super.dispose();
  }

  //---//

  @override
  Widget build(BuildContext context) {
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
            title: _tabBarText("Dashboard", 0)//new Text('Dashboard\n•', textAlign: TextAlign.center,style: TextStyle(height: 1),),
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage(AppImages.products),
              size: 15,
              color: _currentIndex == 1
                  ? AppColors.appBottleGreenColor
                  : Colors.grey,
            ),
            title: _tabBarText('Products', 1)//new Text('Products'),
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(
              AssetImage(AppImages.groups),
              size: 15,
              color: _currentIndex == 2
                  ? AppColors.appBottleGreenColor
                  : Colors.grey,
            ),
            title: _tabBarText('Groups', 2)//new Text('Groups'),
          ),
          BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage(AppImages.users),
                size: 15,
                color: _currentIndex == 3
                    ? AppColors.appBottleGreenColor
                    : Colors.grey,
              ),
              title: _tabBarText('Users', 3)),
          BottomNavigationBarItem(
              icon: ImageIcon(
                AssetImage(AppImages.profile),
                size: 15,
                color: _currentIndex == 4
                    ? AppColors.appBottleGreenColor
                    : Colors.grey,
              ),
              title: _tabBarText('Profile', 4)),
          // title: Text( _currentIndex == 4 ? '''Profile\n•''' : 'Profile', textAlign: TextAlign.center,)),
        ],
      );
    }

    return Scaffold(
      backgroundColor: AppColors.appBottleGreenColor,
      drawer: navigationDrawer(),
      body: _children[_currentIndex],
      bottomNavigationBar: _bottomTab(),
    );
  }

  // @override
  // void onStateChanged(ObserverState state, String value) {
  //   // TODO: implement onStateChanged
  //   if (state == ObserverState.VALUE_CHANGED) {
  //     setState(() {
  //       _currentIndex = int.parse(value);
  //     });
  //   }
  // }
}

//TODO:- Drawer

class navigationDrawer extends StatefulWidget {
  
  @override
  _navigationDrawerState createState() => _navigationDrawerState();
}

class _navigationDrawerState extends State<navigationDrawer> {
  String _profilePic = "";
  String _userFullName = "";
  String _mobileNumber = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    postInit(() {
      _getNameAndImg();
    });
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
    getMobileNumber().then((value) {
      setState(() {
        this._mobileNumber = value;
      });
    });
  }

  Widget createDrawerBodyItem(
      {String icon, String text, GestureTapCallback onTap}) {
    return ListTile(
      title: Row(
        children: <Widget>[
          Image.asset(icon, width: 20 ,),
          Padding(
            padding: EdgeInsets.only(left: 8.0),
            child: Text(text, style: TextStyle(fontSize: 16, color: Color(0xff4A4D4D), fontWeight: FontWeight.normal),),
          )
        ],
      ),
      onTap: onTap,
    );
  }

  showAlertDialog(BuildContext context, String title, String message) {
    // set up the button
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.of(context).pop();
        _logoutAPI(context);
      },
    );

    Widget cancelButton = FlatButton(
      child: Text("CANCEL"),
      onPressed: () {Navigator.of(context).pop();},
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        cancelButton,
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {


    final userProfilePlaceHolder = CircleAvatar(
      backgroundColor: Colors.transparent,
      backgroundImage: AssetImage(AppImages.user_placeholder),
      radius: 30,
    );

    // final userImage = CachedNetworkImage(
    //   imageUrl: _profilePic,
    //   // placeholder: (context, url) => CircularProgressIndicator(),
    //   // placeholder: (context, url) => CircleAvatar(
    //   //   backgroundColor: Colors.transparent,
    //   //   backgroundImage: AssetImage(AppImages.profile, package: 'wigg'),
    //   //   radius: 30,
    //   // ),
    //   imageBuilder: (context, image) => CircleAvatar(
    //     backgroundImage: image,
    //     radius: 30,
    //   ),
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


    Widget createDrawerHeader() {
      return DrawerHeader(
        // margin: EdgeInsets.all(0),
        // padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
        // decoration: BoxDecoration(
        //     image: DecorationImage(
        //         fit: BoxFit.fill, image: AssetImage(AppImages.app_bg))),
        child: Row(
          children: [
            _profilePic != "" ? userImage : userProfilePlaceHolder,
            SizedBox(
              width: 10,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 160,
                  child: Text(_userFullName,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.appBottleGreenColor),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,),
                ),
                Text(
                  _mobileNumber,
                  style: TextStyle(fontSize: 14, color: AppColors.appGrayColor),
                ),
                GestureDetector(
                  onTap: () {
                    print("edit profile");
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => EditMyProfileView()),
                    );

                    // Navigator.of(context).push(new MaterialPageRoute(builder: (_)=>new EditMyProfileView()),)
                    //     .then((val) {
                    //       if (val == true){
                    //
                    //       }
                    // });
                  },
                  child: Text(
                    "Edit Profile",
                    style: TextStyle(
                        fontSize: 14,
                        color: Color(0xffB9B9B9),
                        decoration: TextDecoration.underline),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    final sideMenuList = ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        createDrawerHeader(),
        createDrawerBodyItem(icon: AppImages.ic_Dot, text: 'Categories',
        onTap: (){
          Navigator.of(context).pop();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CategoryListView()),
          );
        }),
        createDrawerBodyItem(icon: AppImages.ic_Dot, text: 'Sub Users',
        onTap: (){
          Navigator.of(context).pop();
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => HomeTabBarController(index: 3,),
              ),
                  (Route route) => false);
        }),
        createDrawerBodyItem(icon: AppImages.ic_Dot, text: 'Purchases',
        onTap: (){
          Navigator.of(context).pop();
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => HomeTabBarController(index: 1,),
              ),
                  (Route route) => false);
        }),
        createDrawerBodyItem(icon: AppImages.ic_Dot, text: 'Submit Ticket',
        onTap: (){
          print("Submit ticket");
          Navigator.of(context).pop();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SubmitTicketView()),
          );
        }),
        createDrawerBodyItem(icon: AppImages.ic_Dot, text: 'My Group/Address',
        onTap: () {
          Navigator.of(context).pop();
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => HomeTabBarController(index: 2,),
              ),
                  (Route route) => false);
        }),
        createDrawerBodyItem(icon: AppImages.ic_Dot, text: 'About us',
            onTap: (){
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AboutUsView(getPageFor: "about", title: 'About us',)),
              );
            }),
        createDrawerBodyItem(icon: AppImages.ic_Dot, text: 'Privacy Policy',
        onTap: (){
          Navigator.of(context).pop();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AboutUsView(getPageFor: "privacy_policy", title: 'Privacy Policy',)),
          );
        }),
        createDrawerBodyItem(icon: AppImages.ic_Dot, text: 'Setting',
            onTap: (){
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingView()),
              );
            }),
        createDrawerBodyItem(icon: AppImages.ic_Dot, text: 'Contact Us',
            onTap: (){
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AboutUsView(getPageFor: "contact", title: "Contact Us",)),
              );
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(builder: (context) => ContactUsView()),
              // );
            }),
        SizedBox(height: 30,),
      ],
    );

    final btnLogout = Container(
      height: 80,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.only(bottom: 30),
      child: RaisedButton(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(AppImages.ic_Dot_white, width: 20,),
            SizedBox(width: 12,),
            Text(
              "Log Out",
              style: TextStyle(
                  fontSize: 20,
                  fontFamily: AppFonts.beVietnam,
                  fontWeight: FontWeight.bold), textAlign: TextAlign.center,
            ),
          ],
        ),
        color: AppColors.appYellowColor,
        onPressed: () {
          // Navigator.of(context).pop();
          // _logoutAPI(context);

          // showAlertDialog(context, "Logout", "Are you sure you want to logout?");

          CommonFunction.showAlertDialog(
              context, "Logout", "Are you sure you want to logout?", (isOk) {
            if (isOk) {
              _logoutAPI(context);
            }
          });
        },
        textColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40), bottomLeft: Radius.circular(40))),
      ),
    );

    final columnView = new Column(
      children: [
        Expanded(flex: 7, child: sideMenuList),
        Expanded(flex: 1, child: btnLogout),
      ],
    );

    return Container(
      width: MediaQuery.of(context).size.width * 0.70,
      child: Drawer(
        child: columnView,
      ),
    );
  }

  _logoutAPI(BuildContext context) {
    LoginViewModel.instance.logoutUser().then(
      (response) async {
        logout().then((value) => Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => LoginView(),
            ),
            (Route route) => false));
      },
    );
  }
}
