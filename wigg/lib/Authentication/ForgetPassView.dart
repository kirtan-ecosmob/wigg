import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'package:wigg/Utils/AppColors.dart';
import 'package:wigg/Utils/AppImages.dart';
import 'package:wigg/Utils/CommonFunctions.dart';
import 'package:wigg/Utils/Helper.dart';
import 'package:wigg/Utils/OnFailure.dart';

import 'LoginViewModel.dart';

class ForgetPassView extends StatefulWidget {
  static String name = '/Forget';

  @override
  _ForgetPassViewState createState() => _ForgetPassViewState();
}

class _ForgetPassViewState extends State<ForgetPassView> {
  bool isShowCodeAndPass = false;
  String btnName = "Send Link";
  bool _isPassSequre = true;

  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtCode = TextEditingController();
  TextEditingController txtPass = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // txtEmail.text = "kirtan.parakhiya@ecosmob.com";
  }

  //TODO:- Functions

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
    }

    if (isShowCodeAndPass) {
      if (txtCode.text.trim().isEmpty) {
        Toast.show('Please enter code', context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
        return false;
      } else if (txtPass.text.trim().length < 6){
        Toast.show('Password must be 6 to 20 characters long', context,
            duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
        return false;
      } else if (isPasswordCompliant(txtPass.text.trim()) == false){
        Toast.show('Please should contain a minimum of 1 Capital alphabet, 1 number and 1 symbol', context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        return false;
      }
    }
  }

  forgetAPI(BuildContext context) {
    Dialogs.showLoadingDialog(context, _keyLoader);
    LoginViewModel.instance.forgetPassword(txtEmail.text.trim()).then(
      (response) {
        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
        if (response.code == 200 || response.code == 401) {
          if (response.data.code != null) {
            Toast.show(response.data.code, context,
                duration: Toast.LENGTH_LONG, gravity: Toast.TOP);
            setState(() {
              isShowCodeAndPass = true;
              btnName = "Reset";
            });
          }
          Toast.show(response.message, context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
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

  verifyCodeAPI(BuildContext context) {
    Dialogs.showLoadingDialog(context, _keyLoader);
    LoginViewModel.instance
        .verifyCode(
            txtEmail.text.trim(), txtPass.text.trim(), txtCode.text.trim())
        .then(
      (response) {
        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
        if (response.code == 200) {
          Toast.show(response.message, context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
          Navigator.pop(context);
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
    final forgetPassext = Text(
      "Forget your Password",
      style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          decoration: TextDecoration.none),
    );

    final codetextField = Container(
      // height: 40,
      padding: EdgeInsets.only(left: 20, right: 20),
      child: CommonFunction.customTextfield(
          "Code", txtCode, TextInputType.number, context),
    );

    final passTextField = Container(
      // height: 40,
      padding: EdgeInsets.only(left: 20, right: 20),
      child: Stack(
        children: [
          CommonFunction.customTextfield(
              "Password", txtPass, TextInputType.text, context,
              isLastTextfield: true, isSecure: _isPassSequre),
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
    );

    final alltextFields = Container(
      // padding: EdgeInsets.only(left: 20, right: 20),
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(children: [
          Container(
            height: 60,
            padding: EdgeInsets.only(left: 20, right: 20),
            child: CommonFunction.customTextfield(
                "Email", txtEmail, TextInputType.emailAddress, context,
                isLastTextfield: true, onChanged: (value) {
              setState(() {
                isShowCodeAndPass = false;
              });
            }),
          ),
          SizedBox(height: 20),
          isShowCodeAndPass ? codetextField : Container(),
          SizedBox(height: 20),
          isShowCodeAndPass ? passTextField : Container(),
        ]),
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
            child: forgetPassext,
          ),
        ),
        SizedBox(height: 30),
        alltextFields,
      ],
    );

    final middleContainer = Center(
      heightFactor: 1.2,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        width: MediaQuery.of(context).size.width * 0.85,
        alignment: AlignmentDirectional(0.0, 0.0),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(40)),
        child: Stack(
          alignment: Alignment.center,
          children: [
            dataColumn,
          ],
        ),
      ),
    );

    final stackView = new Stack(
//      fit: StackFit.loose,
      children: [
        Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: CommonFunction.setImage(AppImages.app_bg, BoxFit.fitWidth)),
        middleContainer,
        new Positioned(
          bottom: 25,
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: new Row(
              mainAxisAlignment: (MainAxisAlignment.spaceBetween),
              children: [
                new Container(
                  child: ClearButton(
                    btnName: "Back to Sign in?",
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                new Container(
                  child: YellowThemeButton(
                    btnName: btnName,
                    onPressed: () {
                      if (_isValidate(context) == null) {
                        if (isShowCodeAndPass) {
                          verifyCodeAPI(context);
                        } else {
                          forgetAPI(context);
                        }
                        // setState(() {
                        //   isShowCodeAndPass = true;
                        // });
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
        onTap: (){FocusScope.of(context).unfocus();},
        child: SingleChildScrollView(
          physics: ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [stackView],
          ),
        ),
      ),
    );
  }
}
