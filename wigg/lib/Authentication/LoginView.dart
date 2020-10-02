import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

//import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'package:wigg/Authentication/ForgetPassView.dart';
import 'package:wigg/Authentication/LoginViewModel.dart';
import 'package:wigg/Authentication/RegistrationView.dart';
import 'package:wigg/HomeTabController.dart';
import 'package:wigg/Utils/AppColors.dart';
import 'package:wigg/Utils/AppFonts.dart';
import 'package:wigg/Utils/AppImages.dart';
import 'package:wigg/Utils/CommonFunctions.dart';
import 'package:toast/toast.dart';
import 'package:device_info/device_info.dart';
import 'package:wigg/Utils/DeviceHeaders.dart';
import 'package:wigg/Utils/Helper.dart';
import 'package:google_sign_in/google_sign_in.dart';
import "package:http/http.dart" as http;
import 'dart:async';
import 'dart:convert' show json;
import 'package:flutter_login_facebook/flutter_login_facebook.dart';

import 'package:wigg/Utils/OnFailure.dart';
//import 'package:flutter_facebook_login/flutter_facebook_login.dart';

GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: <String>[
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ],
);

class LoginView extends StatefulWidget {
  static String name = '/Login';
  final plugin = FacebookLogin(debug: true);

  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  Map<String, dynamic> _deviceData = <String, dynamic>{};
  GoogleSignInAccount _currentUser;
  String _contactText;
  final fb = FacebookLogin();

//  static final FacebookLogin facebookSignIn = new FacebookLogin();

  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtPassword = TextEditingController();

  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  bool _isPassSequre = true;

  String _sdkVersion;
  FacebookAccessToken _token;
  FacebookUserProfile _profile;

  String _imageUrl = "";

  String _email = "";
  String _name = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _handleGoogleSignOut();
    _FBLogOut();

    // _getFBSdkVersion();
    // _updateFBLoginInfo();

    //Google check if user already login with google then return google data
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      setState(() {
        _currentUser = account;

        _email = _currentUser.email;
        _name = _currentUser.displayName;
        if (_email.trim() != "" && _name.trim() != "") {
          registerAPI(context);
        }

        print(_currentUser.email);
        print('$_currentUser');
      });
      if (_currentUser != null) {
        _handleGetGoogleContact();
      }
    });
    _googleSignIn.signInSilently();

    // txtEmail.text = "kinjal.pethani@ecosmob.com";
    // txtEmail.text = "kirtan.parakhiya@ecosmob.com";
    // txtPassword.text = "Kirtan@123";

    txtEmail.text = "wigg.one@yopmail.com";
    txtPassword.text = "mSSTn9z3q1";
  }

  // TODO: Google Login
  Future<void> _handleGetGoogleContact() async {
    setState(() {
      _contactText = "Loading contact info...";
    });
    final http.Response response = await http.get(
      'https://people.googleapis.com/v1/people/me/connections'
      '?requestMask.includeField=person.names',
      headers: await _currentUser.authHeaders,
    );
    if (response.statusCode != 200) {
      setState(() {
        _contactText = "People API gave a ${response.statusCode} "
            "response. Check logs for details.";
      });
      print('People API ${response.statusCode} response: ${response.body}');
      return;
    }
    final Map<String, dynamic> data = json.decode(response.body);
    final String namedContact = _pickGoogleFirstNamedContact(data);
    setState(() {
      if (namedContact != null) {
        _contactText = "I see you know $namedContact!";
      } else {
        _contactText = "No contacts to display.";
      }
    });
  }

  String _pickGoogleFirstNamedContact(Map<String, dynamic> data) {
    final List<dynamic> connections = data['connections'];
    final Map<String, dynamic> contact = connections?.firstWhere(
      (dynamic contact) => contact['names'] != null,
      orElse: () => null,
    );
    if (contact != null) {
      final Map<String, dynamic> name = contact['names'].firstWhere(
        (dynamic name) => name['displayName'] != null,
        orElse: () => null,
      );
      if (name != null) {
        return name['displayName'];
      }
    }
    return null;
  }

  Future<void> _handleGoogleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }

  Future<void> _handleGoogleSignOut() => _googleSignIn.disconnect();

  // TODO: FB Login

  void _getFBSdkVersion() async {
    final sdkVesion = await widget.plugin.sdkVersion;
    setState(() {
      _sdkVersion = sdkVesion;
    });
  }

  void _FBLogOut() async {
    await widget.plugin.logOut();
    _updateFBLoginInfo();
  }

  void _updateFBLoginInfo() async {
    final plugin = widget.plugin;
    final token = await plugin.accessToken;
    FacebookUserProfile profile;
    String email;
    String imageUrl;

    if (token != null) {
      profile = await plugin.getUserProfile();
      if (token.permissions?.contains(FacebookPermission.email.name) ?? false)
        email = await plugin.getUserEmail();
      imageUrl = await plugin.getProfileImageUrl(width: 100);
    }

    setState(() {
      _token = token;
      _profile = profile;
      _imageUrl = imageUrl;
      _name = profile.name;

      _email = email;
      _name = profile.name;
      if (_email.trim() != "" && _name.trim() != "") {
        registerAPI(context);
      }
    });
  }

  // TODO: Other Func

  registerAPI(BuildContext context) {
    Dialogs.showLoadingDialog(context, _keyLoader);
    LoginViewModel.instance
        .registerUser(_name.trim(), _email.trim(), "", "")
        .then(
      (response) {
        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
        if (response.code == 200 || response.code == 401) {
          // CommonFunction.saveToPref(response.data);
          // Navigator.of(context).pushNamedAndRemoveUntil(
          //     HomeTabBarController.name, (Route route) => false);

          if (response.data.userId == null) {
            Toast.show(response.message, context,
                duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
          } else {
            CommonFunction.saveToPref(response.data);
            Navigator.of(context).pushNamedAndRemoveUntil(
                HomeTabBarController.name, (Route route) => false);
          }
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
        }
      },
    );
  }


  bool isPasswordCompliant(String password, [int minLength = 6]) {
    if (password == null || password.isEmpty) {
      return false;
    }

    bool hasUppercase = password.contains(new RegExp(r'[A-Z]'));
    bool hasDigits = password.contains(new RegExp(r'[0-9]'));
    bool hasLowercase = password.contains(new RegExp(r'[a-z]'));
    bool hasSpecialCharacters = password.contains(new RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    bool hasMinLength = password.length > minLength;

    return hasDigits & hasUppercase & hasLowercase & hasSpecialCharacters & hasMinLength;
  }

  bool _isValidate(BuildContext context) {
    if (txtEmail.text.trim().isEmpty) {
      Toast.show('Please enter email', context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      return false;
    } else if (txtEmail.text.trim().validateEmail() == false) {
      Toast.show('Please enter valid email', context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      return false;
    } else if (txtPassword.text.trim().isEmpty) {
      Toast.show('Please enter password', context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      return false;
    }

    // else if (txtPassword.text.trim().length < 6){
    //   Toast.show('Password must be 6 to 20 characters long', context,
    //       duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
    //   return false;
    // }else if (isPasswordCompliant(txtPassword.text.trim()) == false){
    //   Toast.show('Please should contain a minimum of 1 Capital alphabet, 1 number and 1 symbol', context,
    //       duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    //   return false;
    // }


  }

  loginAPI(BuildContext context) {
    Dialogs.showLoadingDialog(context, _keyLoader);
    LoginViewModel.instance
        .loginUser(txtEmail.text.trim(), txtPassword.text.trim())
        .then(
      (response) {
        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
        if (response.code == 200) {
          // saveToPref(response.data);

          DeviceHeaders.instance.userId = response.data.userId.toString();
          DeviceHeaders.instance.authToken = response.data.authToken;
          DeviceHeaders.instance.isLogin = true;

          CommonFunction.saveToPref(response.data);
          Navigator.of(context).pushNamedAndRemoveUntil(
              HomeTabBarController.name, (Route route) => false);
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
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    _fieldFocusChange(
        BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
      currentFocus.unfocus();
      FocusScope.of(context).requestFocus(nextFocus);
    }

    final logintext = Text(
      "Log in",
      style: TextStyle(
          fontSize: 24,
          fontFamily: AppFonts.beVietnam,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          decoration: TextDecoration.none),
    );

    final btnForget = Align(
      alignment: Alignment.centerRight,
      child: Container(
        height: 30,
        child: FlatButton(
          textColor: AppColors.appBlueColor,
          onPressed: () {
            Navigator.of(context).pushNamed(ForgetPassView.name);
          },
          child: Text("Forgot Password?"),
        ),
      ),
    );

    final btnGoogle = Container(
//      height: 50,
        width: 50,
        child: ConstrainedBox(
            constraints: BoxConstraints.expand(),
            child: FlatButton(
                onPressed: () {
                  _handleGoogleSignIn();
//                  _googleSignIn.disconnect(); //For logout google.
                },
                padding: EdgeInsets.all(0.0),
                child: Image.asset(AppImages.google))));

    final btnFb = Container(
//        height: 50,
        width: 50,
        child: ConstrainedBox(
            constraints: BoxConstraints.expand(),
            child: FlatButton(
                onPressed: () async {
                  await widget.plugin.logIn(permissions: [
                    FacebookPermission.publicProfile,
                    FacebookPermission.email,
                  ]);
                  _updateFBLoginInfo();
                },
                padding: EdgeInsets.all(0.0),
                child: Image.asset(AppImages.fb))));

    final socialMediaView = Container(
      height: 50,
//      width: MediaQuery.of(context).size.width - 40,
//      color: Colors.pink,
      child: Row(
        mainAxisAlignment: (MainAxisAlignment.spaceBetween),
        children: [
          Text(
            "Sign in using",
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(
            width: 10,
          ),
          btnGoogle,
          SizedBox(
            width: 10,
          ),
          btnFb
        ],
      ),
    );

    final dataColumn = Column(
      children: [
        SizedBox(height: 30),
        Container(
          height: 60,
          width: 165,
          child: CommonFunction.setImage(AppImages.logo, BoxFit.fitHeight),
        ),
        SizedBox(height: 30),
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: logintext,
          ),
        ),
        SizedBox(height: 30),
//        customTextfield("Email", txtEmail, TextInputType.emailAddress),
        CommonFunction.focusCustomTextField(
            "Email", txtEmail, TextInputType.emailAddress, context, _emailFocus,
            onSubmitted: (value) {
          // _email = value;
          _fieldFocusChange(context, _emailFocus, _passwordFocus);
        }),
        SizedBox(height: 10),
        Stack(
          children: [
            CommonFunction.focusCustomTextField("Password", txtPassword,
                TextInputType.text, context, _passwordFocus,
                isSecure: _isPassSequre,
                isLastTextfield: true, maxLength: 20, onSubmitted: (value) {
              _passwordFocus.unfocus();
            }),
            Positioned(
                right: 20,
                bottom: 20,
                child: Container(
                  height: 40,
                  width: 40,
                  // color: Colors.black,
                  child: IconButton(
                      icon: Image.asset(AppImages.eye),
                      onPressed: () {
                        setState(() {
                          _isPassSequre = !_isPassSequre;
                        });
                        // loadAssets();
                      }),
                ))
          ],
        ),
        SizedBox(height: 4),
        btnForget,
      ],
    );

    final middleContainer = Center(
      child: Container(
        alignment: AlignmentDirectional(0.0, 0.0),
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height - 250,
            maxWidth: MediaQuery.of(context).size.width - 40,
            minWidth: MediaQuery.of(context).size.width - 40,
            minHeight: MediaQuery.of(context).size.height - 250),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(40)),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Form(
                child: Container(
              padding: EdgeInsets.only(left: 20, right: 20),
              child: dataColumn,
            )),
            new Positioned(
              bottom: 20,
              child: socialMediaView,
            )
          ],
        ),
      ),
    );

    final stackView = new Stack(
//      fit: StackFit.loose,
      children: [
        CommonFunction.setImage(AppImages.app_bg, BoxFit.cover),
        middleContainer,
        new Positioned(
          bottom: 25,
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                new Container(
                  child: ClearButton(
                    btnName: "Don’t Have account?",
                    onPressed: () {
                      Navigator.of(context).pushNamed(RegistrationView.name);
                    },
                  ),
                ),
                new Container(
                  child: YellowThemeButton(
                    btnName: "Log in",
                    onPressed: () {
                      if (_isValidate(context) == null) {
                        loginAPI(context);
                      } else {
                        print("not proper");
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: stackView),
    );
  }
}

////TODO: FB Login Function
//class CustomWebView extends StatefulWidget {
//  final String selectedUrl;
//
//  CustomWebView({this.selectedUrl});
//
//  @override
//  _CustomWebViewState createState() => _CustomWebViewState();
//}
//
//class _CustomWebViewState extends State<CustomWebView> {
//  final flutterWebviewPlugin = new FlutterWebviewPlugin();
//
//  @override
//  void initState() {
//    super.initState();
//
//    flutterWebviewPlugin.onUrlChanged.listen((String url) {
//      if (url.contains("#access_token")) {
//        succeed(url);
//      }
//
//      if (url.contains(
//          "https://www.facebook.com/connect/login_success.html?error=access_denied&error_code=200&error_description=Permissions+error&error_reason=user_denied")) {
//        denied();
//      }
//    });
//  }
//
//  denied() {
//    Navigator.pop(context);
//  }
//
//  succeed(String url) {
//    var params = url.split("access_token=");
//
//    var endparam = params[1].split("&");
//
//    Navigator.pop(context, endparam[0]);
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    return WebviewScaffold(
//        url: widget.selectedUrl,
//        appBar: new AppBar(
//          backgroundColor: Color.fromRGBO(66, 103, 178, 1),
//          title: new Text("Facebook login"),
//        ));
//  }
//}
