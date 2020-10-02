import 'dart:async';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wigg/Dashboard/DashboardView.dart';
import 'package:wigg/Authentication/ForgetPassView.dart';
import 'package:wigg/Authentication/LoginView.dart';
import 'package:wigg/Authentication/RegistrationView.dart';
import 'package:wigg/Groups/GroupListView.dart';
import 'package:wigg/HomeTabController.dart';
import 'package:wigg/Products/ProductsListView.dart';
import 'package:wigg/SubUsers/AddSubUser.dart';
import 'package:wigg/SubUsers/UsersModelView.dart';
import 'package:wigg/UserProfile/EditMyProfileView.dart';
import 'package:wigg/Utils/AppFonts.dart';
import 'package:wigg/Utils/AppImages.dart';
import 'package:wigg/Utils/DeviceHeaders.dart';
import 'package:wigg/Utils/Preference.dart';
import 'package:wigg/intro/introView.dart';

import 'dart:io';
import 'package:device_info/device_info.dart';
import 'package:flutter/services.dart';

import 'SubUsers/UserListView.dart';
import 'Utils/AppStrings.dart';
import 'Utils/CommonFunctions.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   // Set default home.
//   Widget _defaultHome = new IntroView();
//
//   // Get result of the login function.
//   Map<String, dynamic> deviceData;
//   DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
//
//   PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
//     DeviceHeaders.instance.appVersion = packageInfo.version;
//   });
//
//   try {
//     if (Platform.isAndroid) {
//       AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
//       DeviceHeaders.instance.platform = "ANDROID";
//       DeviceHeaders.instance.osVersion = androidInfo.version.release;
//       DeviceHeaders.instance.device = androidInfo.model;
//     } else if (Platform.isIOS) {
//       IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
//       DeviceHeaders.instance.platform = iosInfo.systemName;
//       DeviceHeaders.instance.osVersion = iosInfo.systemVersion;
//       DeviceHeaders.instance.device = iosInfo.model;
//     }
//   } on PlatformException {
//     deviceData = <String, dynamic>{
//       'Error:': 'Failed to get platform version.'
//     };
//   }
//
//   //Default View
//
//   try{
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     bool _result = prefs.getBool(AppStrings.isLogin) ?? false;
//     String userId = prefs.getInt(AppStrings.userId).toString();
//     String authToken = prefs.getString(AppStrings.authToken);
//
//     DeviceHeaders.instance.isLogin = _result;
//     DeviceHeaders.instance.userId = userId;
//     DeviceHeaders.instance.authToken = authToken;
//
//     if (_result){
//       _defaultHome = new HomeTabBarController();
//     }
//
//   } catch (e){
//     SharedPreferences.setMockInitialValues({});
//     print(e);
//   }
//
//   // isUserLogin().then(
//   //       (value) {
//   //         DeviceHeaders.instance.isLogin = value;
//   //         if (value){
//   //           _defaultHome = new HomeTabBarController();
//   //           getUserId().then((value) {DeviceHeaders.instance.userId = value.toString();});
//   //           getAuthToken().then((value) {DeviceHeaders.instance.authToken = value;});
//   //         }else{
//   //
//   //         }
//   //   },
//   // );
//
//
//   // Run app!
//   runApp(MaterialApp(
//     theme: ThemeData(fontFamily: AppFonts.beVietnam),
//     home: _defaultHome,
//     debugShowCheckedModeBanner: false,
//     routes: <String, WidgetBuilder>{
//       // Set routes for using the Navigator.
//       LoginView.name: (BuildContext context) => LoginView(),
//       ForgetPassView.name: (BuildContext context) => ForgetPassView(),
//       RegistrationView.name: (BuildContext context) => RegistrationView(),
//       HomeTabBarController.name: (BuildContext context) => HomeTabBarController(),
//       DashboardView.name: (BuildContext context) => DashboardView(),
//       UserListView.name: (BuildContext context) => UserListView(),
//       GroupListView.name: (BuildContext context) => GroupListView(),
//     },
//   ));
// }

void main() => runApp(SplashScreen());


class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();


  @override
  void initState() {
    super.initState();

    _firebaseConfig();
    initFlutterLocalNotification();
  }


  //TODO: Functions

  _firebaseConfig(){
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        showNotification(
            title: message['notification']['title'],
            body: message['notification']['body'],
            payload: message['data']['type']);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        // _navigateToItemDetail(message);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        // _navigateToItemDetail(message);
      },
      onBackgroundMessage: myBackgroundMessageHandler,
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(
            sound: true, badge: true, alert: true, provisional: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
    _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      print("Push Messaging token: $token");
      log(token);
      DeviceHeaders.instance.deviceToken = token;
      print("Token: ${DeviceHeaders.instance.deviceToken}");

      // setState(() {
      //   _homeScreenText = "Push Messaging token: $token";
      // });
      // print(_homeScreenText);
    });
  }

  void initFlutterLocalNotification() {
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var android = new AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOS = new IOSInitializationSettings(
        defaultPresentAlert: true,
        defaultPresentBadge: true,
        defaultPresentSound: true,
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true);
    var initSetttings = new InitializationSettings(android, iOS);
    flutterLocalNotificationsPlugin.initialize(initSetttings,
        onSelectNotification: onSelectNotification);
  }

  Future onSelectNotification(String payload) {
    _navigateToItemDetail(payload);
  }

  void _navigateToDetail(Map<String, dynamic> message) {
//    final Item item = _itemForMessage(message);
//    // Clear away dialogs
//    Navigator.popUntil(context, (Route<dynamic> route) => route is PageRoute);
//    if (!item.route.isCurrent) {
//      Navigator.push(context, item.route);
//    }
  }

  void _navigateToItemDetail(String payload) {
    print(payload);
  }

  showNotification({String title, String body, String payload}) async {
    var android = new AndroidNotificationDetails(
        '1', 'Wigg', 'CHANNEL DESCRIPTION',
        priority: Priority.High, importance: Importance.Max);
    var iOS = new IOSNotificationDetails();
    var platform = new NotificationDetails(android, iOS);
    await flutterLocalNotificationsPlugin.show(0, title, body, platform,
        payload: payload);
  }



  @override
  Widget build(BuildContext context) {

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return MaterialApp(
      theme: ThemeData(fontFamily: AppFonts.beVietnam),
      home: GetStartedController(),
      debugShowCheckedModeBanner: false,
      routes: <String, WidgetBuilder>{
        // Set routes for using the Navigator.
        LoginView.name: (BuildContext context) => LoginView(),
        ForgetPassView.name: (BuildContext context) => ForgetPassView(),
        RegistrationView.name: (BuildContext context) => RegistrationView(),
        HomeTabBarController.name: (BuildContext context) =>
            HomeTabBarController(),
        DashboardView.name: (BuildContext context) => DashboardView(),
        UserListView.name: (BuildContext context) => UserListView(),
        GroupListView.name: (BuildContext context) => GroupListView(),
        AddSubUserView.name: (BuildContext context) => AddSubUserView(),
        EditMyProfileView.name: (BuildContext context) => EditMyProfileView(),
        ProductListView.name: (BuildContext context) => ProductListView(),

      },
    );
  }
}



//TODO:- Get started Controller

class GetStartedController extends StatefulWidget {
  @override
  _GetStartedControllerState createState() => _GetStartedControllerState();
}

class _GetStartedControllerState extends State<GetStartedController> {
  Widget _defaultHome = new IntroView();

  // Get result of the login function.
  Map<String, dynamic> deviceData;
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getPreferences();
    _initPreferencesData();


    Timer(Duration(seconds: 3),
            ()=>Navigator.pushReplacement(context,
            MaterialPageRoute(builder:
                (context) =>
                _defaultHome
            )
        )
    );

  }

  _initPreferencesData() async {
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      DeviceHeaders.instance.appVersion = packageInfo.version;
    });

    try {
      if (Platform.isAndroid) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        DeviceHeaders.instance.platform = "ANDROID";
        DeviceHeaders.instance.osVersion = androidInfo.version.release;
        DeviceHeaders.instance.device = androidInfo.model;
      } else if (Platform.isIOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        DeviceHeaders.instance.platform = iosInfo.systemName;
        DeviceHeaders.instance.osVersion = iosInfo.systemVersion;
        DeviceHeaders.instance.device = iosInfo.model;
      }
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }
  }


  _getPreferences() async {

    try{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool _result = prefs.getBool(AppStrings.isLogin) ?? false;
      String userId = prefs.getInt(AppStrings.userId).toString();
      String authToken = prefs.getString(AppStrings.authToken);



      DeviceHeaders.instance.isLogin = _result;
      DeviceHeaders.instance.userId = userId;
      DeviceHeaders.instance.authToken = authToken;

      setState(() {
        if (_result){
          UsersModelView.instance.userRole = prefs.getString(AppStrings.role);
          _defaultHome = new HomeTabBarController();
        }
      });

    } catch (e){
      // ignore: invalid_use_of_visible_for_testing_member
      SharedPreferences.setMockInitialValues({});
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Stack(
      children: [
        Container(
          decoration: new BoxDecoration(
              image: new DecorationImage(image: new AssetImage(AppImages.app_bg), fit: BoxFit.cover)
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: Container(
            height: 60,
            width: 165,
            child: CommonFunction.setImage(AppImages.logo, BoxFit.fitHeight),
          ),
        ),
      ],
    );

    // return MaterialApp(
    //   theme: ThemeData(fontFamily: AppFonts.beVietnam),
    //   home: _defaultHome,
    //   debugShowCheckedModeBanner: false,
    //   routes: <String, WidgetBuilder>{
    //     // Set routes for using the Navigator.
    //     LoginView.name: (BuildContext context) => LoginView(),
    //     ForgetPassView.name: (BuildContext context) => ForgetPassView(),
    //     RegistrationView.name: (BuildContext context) => RegistrationView(),
    //     HomeTabBarController.name: (BuildContext context) =>
    //         HomeTabBarController(),
    //     DashboardView.name: (BuildContext context) => DashboardView(),
    //     UserListView.name: (BuildContext context) => UserListView(),
    //     GroupListView.name: (BuildContext context) => GroupListView(),
    //   },
    // );
  }
}


Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) {
  if (message.containsKey('data')) {
    // Handle data message
    final dynamic data = message['data'];
    log("NOTIFICATION:::$data");
  }

  if (message.containsKey('notification')) {
    // Handle notification message
    final dynamic notification = message['notification'];
    log("NOTIFICATION:::$notification");
  }

  return Future<dynamic>.value(message);
  // Or do other work.
}