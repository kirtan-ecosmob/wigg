import 'package:flutter/material.dart';
import 'package:wigg/HomeTabController.dart';
import 'package:wigg/Utils/AppColors.dart';
import 'package:wigg/Utils/AppImages.dart';
import 'package:wigg/Utils/CommonFunctions.dart';
import 'package:wigg/Utils/Helper.dart';
import 'package:toast/toast.dart';
import 'package:wigg/Utils/OnFailure.dart';
import 'LoginViewModel.dart';

class RegistrationView extends StatefulWidget {
  static String name = '/Registration';

  @override
  _RegistrationViewState createState() => _RegistrationViewState();
}

class _RegistrationViewState extends State<RegistrationView> {
  TextEditingController txtName = TextEditingController();
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtPassword = TextEditingController();
  TextEditingController txtConfirmPass = TextEditingController();
  TextEditingController txtMobile = TextEditingController();

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  final FocusNode _confirmPsswordFocus = FocusNode();
  final FocusNode _mobileFocus = FocusNode();

  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  bool _isPassSecure = true;
  bool _isConfirmPassSecure = true;


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // txtName.text = "kirtan";
    // txtEmail.text = "kirtan.parakhiya@ecosmob.com";
    // txtPassword.text = "Kirtan@123";
    // txtConfirmPass.text = "Kirtan@123";

  }

//  Widget customTextfield(String placeholder, TextEditingController controller,
//      TextInputType keyboardType,
//      BuildContext context,FocusNode focus,
//      {isLastTextfield = false, isSecure = false,void Function(String) onSubmitted}) {
//    return Container(
//      height: 40,
//      padding: EdgeInsets.only(left: 20, right: 20),
//      child: TextField(
//        focusNode: focus,
//        cursorColor: AppColors.appBlueColour,
//        keyboardType: keyboardType,
//        textInputAction:
//        isLastTextfield ? TextInputAction.done : TextInputAction.next,
//        onSubmitted: onSubmitted,
////            (_) => isLastTextfield
////            ? FocusScope.of(context).unfocus()
////            : FocusScope.of(context).nextFocus(),
//        obscureText: isSecure,
//        decoration: InputDecoration(
//          hintText: placeholder,
//          focusedBorder: UnderlineInputBorder(
//              borderSide: BorderSide(color: AppColors.appBlueColour)),
//        ),
//      ),
//    );
//  }

  // TODO: Other Func

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
    if (txtName.text.trim().isEmpty) {
      Toast.show('Please enter name', context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      return false;
    }else if (txtEmail.text.trim().isEmpty) {
      Toast.show('Please enter email', context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      return false;
    }else if (txtEmail.text.trim().validateEmail() == false){
      Toast.show('Please enter valid email', context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      return false;
    }else if (txtPassword.text.trim().length < 6){
      Toast.show('Password must be 6 to 20 characters long', context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      return false;
    }else if (isPasswordCompliant(txtPassword.text.trim()) == false){
      Toast.show('Please should contain a minimum of 1 Capital alphabet, 1 number and 1 symbol', context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      return false;
    } else if (txtPassword.text.trim() != txtConfirmPass.text.trim()) {
      Toast.show('Password and confirm password not match', context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      return false;
    }
  }


  registerAPI(BuildContext context) {
    Dialogs.showLoadingDialog(context, _keyLoader);
    LoginViewModel.instance.registerUser(txtName.text.trim(), txtEmail.text.trim(), txtPassword.text.trim(), txtMobile.text.trim()).then((response) {
      Navigator.of(_keyLoader.currentContext,rootNavigator: true).pop();
      if (response.code == 200){
        // if (response.data.userId == ""){
        //   Toast.show(response.message, context,
        //       duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        // }else{
        //   CommonFunction.saveToPref(response.data);
        //   Navigator.of(context).pushNamedAndRemoveUntil(
        //       HomeTabBarController.name, (Route route) => false);
        // }

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
      },);
  }


  @override
  Widget build(BuildContext context) {
    final regText = Text(
      "Registration",
      style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          decoration: TextDecoration.none),
    );

    _fieldFocusChange(
        BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
      currentFocus.unfocus();
      FocusScope.of(context).requestFocus(nextFocus);
    }


    final passField = Stack(
      children: [
        CommonFunction.focusCustomTextField("* Password", txtPassword,
            TextInputType.text, context, _passwordFocus, isSecure: _isPassSecure, maxLength: 20,
            onSubmitted: (value) {
              _fieldFocusChange(context, _passwordFocus, _confirmPsswordFocus);
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
                      _isPassSecure = !_isPassSecure;
                    });
                    // loadAssets();
                  }),
            ))
      ],
    );

    final confirmPassField = Stack(
      children: [
        CommonFunction.focusCustomTextField("* Confirm Password", txtConfirmPass,
            TextInputType.text, context, _confirmPsswordFocus,
            isSecure: _isConfirmPassSecure, onSubmitted: (value) {
              _fieldFocusChange(context, _confirmPsswordFocus, _mobileFocus);
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
                      _isConfirmPassSecure = !_isConfirmPassSecure;
                    });
                    // loadAssets();
                  }),
            ))
      ],
    );

    final allTextFields = Container(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: 20),
            CommonFunction.focusCustomTextField(
                "* Name", txtName, TextInputType.text, context, _nameFocus,
                onSubmitted: (value) {
                  _fieldFocusChange(context, _nameFocus, _emailFocus);
                }),
            SizedBox(height: 8),
            CommonFunction.focusCustomTextField(
                "* Email",
                txtEmail,
                TextInputType.emailAddress,
                context,
                _emailFocus, onSubmitted: (value) {
              _fieldFocusChange(context, _emailFocus, _passwordFocus);
            }),
            SizedBox(height: 8),
            passField,
            SizedBox(height: 8),
            confirmPassField,
            SizedBox(height: 8),
            CommonFunction.focusCustomTextField("Mobile Number", txtMobile,
                TextInputType.text, context, _mobileFocus,
                isLastTextfield: _isPassSecure, maxLength: 16, onSubmitted: (value) {
                  _mobileFocus.unfocus();
                }),
            SizedBox(height: 8),
          ],
        ),
      ),
    );

    final dataColumn = Column(
      children: [
        SizedBox(height: 20),
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
            child: regText,
          ),
        ),
        allTextFields,
        SizedBox(height: 20,)
      ],
    );

    final dataList = ListView(
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
            child: regText,
          ),
        ),
        allTextFields
      ],
    );

    final middleContainer = Center(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        width: MediaQuery.of(context).size.width * 0.85,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(40)),
        child: dataColumn,
//        child: SingleChildScrollView(
//          child: dataColumn,
//        ),
      ),
      heightFactor: 1.2,
    );

    final bottomButtons = Container(
      width: MediaQuery.of(context).size.width,
      child: new Row(
        mainAxisAlignment: (MainAxisAlignment.spaceBetween),
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: new Container(
              padding: EdgeInsets.only(left: 20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Have an account?",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Sign in",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          color: AppColors.appYellowColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    )
                  ]),
            ),
          ),
          new Container(
            child: YellowThemeButton(
              btnName: "Register",
              onPressed: () {
                if (_isValidate(context) == null) {
                  registerAPI(context);
                }
              },
            ),
          ),
        ],
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
          child: bottomButtons,
        ),
      ],
    );

    return Scaffold(
//      resizeToAvoidBottomInset: false,
      resizeToAvoidBottomPadding: true,
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
