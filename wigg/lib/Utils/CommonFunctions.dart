import 'dart:ffi';

// import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wigg/Authentication/LoginView.dart';
import 'package:wigg/Authentication/Model/login_model.dart';
import 'package:wigg/SubUsers/UsersModelView.dart';
import 'package:wigg/Utils/AppColors.dart';
import 'package:wigg/Utils/AppFonts.dart';
import 'package:wigg/Utils/Helper.dart';

import 'AppImages.dart';
import 'AppStrings.dart';
import 'DeviceHeaders.dart';
import 'OnFailure.dart';
import 'Preference.dart';

class YellowThemeButton extends StatelessWidget {
  final String btnName;
  final GestureTapCallback onPressed;

  YellowThemeButton({@required this.onPressed, this.btnName});

  @override
  Widget build(BuildContext context) {
    return new Container(
      height: 65,
      width: 160,
      child: RaisedButton(
        child: Text(
          btnName,
          style: TextStyle(
              fontSize: 20,
              fontFamily: AppFonts.beVietnam,
              fontWeight: FontWeight.bold),
        ),
        color: AppColors.appYellowColor,
        onPressed: onPressed,
        textColor: Colors.white,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(32.5),
                bottomLeft: Radius.circular(32.5))),
      ),
    );
  }
}

class ClearButton extends StatelessWidget {
  final String btnName;
  final GestureTapCallback onPressed;

  ClearButton({@required this.onPressed, this.btnName});

  @override
  Widget build(BuildContext context) {
    return new Container(
        height: 65,
//        width: 100,
        child: FlatButton(
          onPressed: onPressed,
          child: Text(btnName,
              style: TextStyle(fontSize: 16, fontFamily: AppFonts.beVietnam)),
          textColor: Colors.white,
        ));
  }
}

class CommonFunction {
  static Container setImage(String name, BoxFit fit) {
    return new Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(name),
          fit: fit,
        ),
      ),
    );
  }

  static Widget customTextfield(
      String placeholder,
      TextEditingController controller,
      TextInputType keyboardType,
      BuildContext context,
      {isLastTextfield = false,
      maxLength = 40,
      isSecure = false,
      textColor = AppColors.appBlueColor,
      void Function(String) onChanged}) {
    return Container(
      height: 55,
      // color: Colors.blue,
      padding: EdgeInsets.only(left: 20, right: 20),
      child: TextFormField(
        maxLength: maxLength,
        style: TextStyle(color: textColor),
        controller: controller,
//        autovalidate: true,
//        validator: (input) => keyboardType == TextInputType.emailAddress ? input.validateEmail() ? null : "Check your email" : null,
        cursorColor: textColor,
        keyboardType: keyboardType,
        textInputAction:
            isLastTextfield ? TextInputAction.done : TextInputAction.next,
        onFieldSubmitted: (_) => isLastTextfield
            ? FocusScope.of(context).unfocus()
            : FocusScope.of(context).nextFocus(),
        onChanged: onChanged,
        obscureText: isSecure,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 6),
          isDense: true,
          hintText: placeholder,
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.appBlueColor)),
        ),
      ),
    );
  }

  static Widget focusCustomTextField(
      String placeholder,
      TextEditingController controller,
      TextInputType keyboardType,
      BuildContext context,
      FocusNode focus,
      {isLastTextfield = false,
      isSecure = false,
      maxLength = 40,
      textColor = AppColors.appBlueColor,
      void Function(String) onSubmitted,
      void Function(String) onChanged}) {
    return Container(
      // color: Colors.pink,
      height: 55,
      padding: EdgeInsets.only(left: 20, right: 20),
      child: TextField(
        maxLines: 1,
        maxLength: maxLength,
        style: TextStyle(color: textColor),
        controller: controller,
        focusNode: focus,
        cursorColor: textColor,
        keyboardType: keyboardType,
        textInputAction:
            isLastTextfield ? TextInputAction.done : TextInputAction.next,
        onSubmitted: onSubmitted,
        onChanged: onChanged,
//            (_) => isLastTextfield
//            ? FocusScope.of(context).unfocus()
//            : FocusScope.of(context).nextFocus(),
        obscureText: isSecure,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 6),
          isDense: true,
          hintText: placeholder,
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.appBlueColor)),
        ),
      ),
    );
  }

  static saveToPref(UserData data) async {

    UsersModelView.instance.userRole = data.role;

    SharedPreferences pref = await SharedPreferences.getInstance();

    pref.setInt(AppStrings.userId, data.userId);
    pref.setString(AppStrings.authToken, data.authToken);
    pref.setString(AppStrings.email, data.email);
    pref.setString(AppStrings.name, data.name);
    pref.setString(AppStrings.mobile, data.mobile);
    pref.setString(AppStrings.role, data.role);
    pref.setString(AppStrings.profile_pic, data.profilePic);
    pref.setBool(AppStrings.isParentUser, data.isParentUser);
    pref.setInt(AppStrings.warrantyExpireDays, data.warrantyExpireDay);
    pref.setBool(AppStrings.isLogin, true);

    UsersModelView.instance.userRole = data.role;
    UsersModelView.instance.isParent = data.isParentUser;

    DeviceHeaders.instance.userId = data.userId.toString();
    DeviceHeaders.instance.authToken = data.authToken;
    DeviceHeaders.instance.isLogin = true;
  }

  static redirectToLogin(BuildContext context, OnFailure e) async {
    if (e.code == 403) {
      logout().then((value) => Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => LoginView(),
          ),
          (Route route) => false));
    }
  }

  static String remainYearsMonthDayFromDate(String date, String format){
    final date1 = new DateFormat(format).parse(date);
    final date2 = DateTime.now();

    int year = date1.difference(date2).inDays ~/ 365;
    int month = (date1.difference(date2).inDays % 365) ~/ 30;
    int days = date1.difference(date2).inDays;


    if (date1.isBefore(date2)){
      return "Warranty expired";
    }else {
      if (year > 0){
        return "Warranty expires in ${year} year ${month} months";
        // if (month == 0){
        //   return "Warranty expires in ${year} year";
        // }else{
        //   return "Warranty expires in ${year} year ${month} months";
        // }
      }else if (month > 0){
        return "Warranty expires in ${month} months";
      }else if (days > 0){
        return "Warranty expires in ${days} days";
      }else{
        return "Warranty expired";
      }
    }
  }

// static roundUseImage(String imgUrl, double radius){
//   if (imgUrl == ""){
//     CircleAvatar(
//       backgroundColor: Colors.transparent,
//       backgroundImage: AssetImage(AppImages.profile),
//       radius: 30,
//     );
//   }else{
//     CachedNetworkImage(
//       imageUrl: imgUrl,
//       // errorWidget: (context, url, error) => Icon(Icons.error),
//       // errorWidget: (context, url, error) => Icon(Icons.error),
//       // placeholder: (context, url) => CircularProgressIndicator(),
//       // placeholder: (context, url) => CircleAvatar(
//       //   backgroundColor: Colors.amber,
//       //   radius: _radius,
//       // ),
//       imageBuilder: (context, image) => CircleAvatar(
//         backgroundImage: image,
//         radius: radius,
//       ),
//     );
//   }
// }

  static Widget sideMenuBuilder() {
    return Builder(
      builder: (BuildContext context) {
        return IconButton(
          icon: Image.asset(
            AppImages.side_menu,
          ),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
          tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
        );
      },
    );
  }

  static showAlertDialog(BuildContext context, String title, String message, Function(bool) onPressed) {
    // set up the button
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {
        onPressed(true);
        Navigator.of(context).pop();
      },
    );

    Widget cancelButton = FlatButton(
      child: Text("CANCEL"),
      onPressed: () {onPressed(false);Navigator.of(context).pop();},
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



}

class Dialogs {
  static Future<void> showLoadingDialog(
      BuildContext context, GlobalKey key) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return new WillPopScope(
              onWillPop: () async => false,
              child: SimpleDialog(
                elevation: 0,
                  key: key,
                  backgroundColor: Colors.transparent,
                  children: <Widget>[
                    Center(
                      child: Column(children: [
                        CircularProgressIndicator(
                          backgroundColor: Colors.white,
                          valueColor: new AlwaysStoppedAnimation<Color>(AppColors.appBottleGreenColor),
                        ),
                        // SizedBox(height: 10,),
                        // Text("Please Wait....",style: TextStyle(color: Colors.blueAccent),)
                      ]),
                    )
                  ]),
          );
        });
  }
}

extension StateExtension<T extends StatefulWidget> on State<T> {
  Stream waitForStateLoading() async* {
    while (!mounted) {
      yield false;
    }
    yield true;
  }

  Future<void> postInit(VoidCallback action) async {
    await for (var isLoaded in waitForStateLoading()) {}
    action();
  }
}
