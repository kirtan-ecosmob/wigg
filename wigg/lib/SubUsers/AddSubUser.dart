import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_picker/Picker.dart';
import 'package:toast/toast.dart';
import 'package:wigg/Authentication/Model/login_model.dart';
import 'package:wigg/Utils/AppColors.dart';
import 'package:wigg/Utils/AppImages.dart';
import 'package:wigg/Utils/AppStrings.dart';
import 'package:wigg/Utils/CommonFunctions.dart';
import 'package:wigg/Utils/Helper.dart';
import 'package:wigg/Utils/OnFailure.dart';

import '../HomeTabController.dart';
import 'Model/users_model.dart';
import 'ProductListForUserView.dart';
import 'UsersModelView.dart';

// enum E_Permissions { ViewOnly, FullAccess, ViewAndEdit, ShareOnly }

class AddSubUserView extends StatefulWidget {
  static String name = '/Addsubuser';

  bool isEditSubUser;
  SubUsersData selectedSubUserData;

  AddSubUserView({this.isEditSubUser = false, this.selectedSubUserData});


  @override
  _AddSubUserViewState createState() => _AddSubUserViewState();
}

class _AddSubUserViewState extends State<AddSubUserView> {
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  TextEditingController txtName = TextEditingController();
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtMobile = TextEditingController();

  TextEditingController txtRelation = TextEditingController();

  SubUsersData userDetails;

  var params = {};

  static const permissions = [
    AppStrings.viewOnly,
    AppStrings.fullAccess,
    AppStrings.viewAndEdit,
    AppStrings.shareOnly,
  ];

  String _permissionValue = permissions[0];

  // showPickerArray(BuildContext context) {
  //   new Picker(
  //     // adapter: PickerDataAdapter<String>(pickerdata: new JsonDecoder().convert(permissions), isArray: true),
  //       adapter: PickerDataAdapter(pickerdata: permissions),
  //       hideHeader: true,
  //       selecteds: [_selectedPermission],
  //       title: new Text("Please Select"),
  //       onConfirm: (Picker picker, List value) {
  //         setState(() {
  //           _selectedPermission = value.first;
  //         });
  //         print(value.toString());
  //         print(picker.getSelectedValues());
  //       }
  //   ).showDialog(context);
  // }

  // TODO: implement initState
  @override
  void initState() {
    super.initState();

    if (widget.isEditSubUser){
      postInit(() {
        _getSubUserDetails();
      });
      _setDataForEditUser();
    }

  }

  // TODO: API calling

  _getSubUserDetails(){
    Dialogs.showLoadingDialog(context, _keyLoader);
    UsersModelView.instance.getSubUserDetails(widget.selectedSubUserData.id.toString()).then(
          (response) {
        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
        if (response.code == 200) {
          setState(() {
            this.userDetails = response.subUserData;
            _setDataForEditUser();
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

  _addEditSubuser(){

    Dialogs.showLoadingDialog(context, _keyLoader);
    UsersModelView.instance.addEditSubUser(para: params, isEdit: widget.isEditSubUser, user: widget.selectedSubUserData).then(
          (response) {
        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
        if (response.code == 200) {
          // Navigator.of(context).pop(true);
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => HomeTabBarController(index: 3,),
              ),
                  (Route route) => false);

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
          CommonFunction.redirectToLogin(context, e);
        }
      },
    );
  }


  // TODO: Custom Functions

  _setDataForEditUser(){
    txtName.text = this.userDetails != null ? userDetails.name : "";
    txtEmail.text = this.userDetails != null ? userDetails.email : "";
    txtMobile.text = this.userDetails != null ? userDetails.mobile : "";
    txtRelation.text = this.userDetails != null ? userDetails.relation : "";

    final tempPer = this.userDetails != null ? userDetails.role.replaceAll("_", " ").capitalizeFirstofEach : "";
    print(tempPer);
    final index  = permissions.indexOf(tempPer);
    if (index >= 0){
      _permissionValue = permissions[permissions.indexOf(tempPer)];
    }

  }

  bool _isValidate(BuildContext context) {
    if (txtName.text.trim().isEmpty) {
      Toast.show('Please enter name', context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      return false;
    } else if (txtEmail.text.trim().isEmpty) {
      Toast.show('Please enter email', context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      return false;
    } else if (txtEmail.text.trim().validateEmail() == false) {
      Toast.show('Please enter valid email', context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      return false;
    } else if (txtMobile.text.trim().isNotEmpty && txtMobile.text.length < 8){
      Toast.show('The Mobile Number must be between 8 and 16 digits.', context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      return false;
    } else if (txtRelation.text.trim().isEmpty) {
      Toast.show('Please enter relation with user', context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final nameTextField = CommonFunction.customTextfield(
        "Enter Name", txtName, TextInputType.text, context);

    final emailTextField = CommonFunction.customTextfield(
        "Enter email", txtEmail, TextInputType.emailAddress, context);

    final mobileTextField = CommonFunction.customTextfield(
        "Enter Mobile Number", txtMobile, TextInputType.number, context, maxLength: 16);

    final relationTextField = CommonFunction.customTextfield(
        "Enter Relation", txtRelation, TextInputType.text, context,
        isLastTextfield: true);

    // final permissionText = Container(
    //   width: MediaQuery.of(context).size.width - 110,
    //   child: Text(
    //       permissions[_selectedPermission],
    //   style: TextStyle(fontSize: 16, color: AppColors.appBlueColor), ),
    //
    // );

    Widget permissionDropDown() {
      return new DropdownButton<String>(
        value: _permissionValue,
        style: TextStyle(fontSize: 16, color: AppColors.appBlueColor),
        underline: Container(
          height: 1,
          color: Colors.grey,
        ),
        isExpanded: true,
        items: permissions.map((String value) {
          return new DropdownMenuItem<String>(
            value: value,
            child: new Text(value),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _permissionValue = value;
          });
        },
      );
    }

    final userFields = new SingleChildScrollView(
      padding: EdgeInsets.only(left: 25, right: 25, top: 20, bottom: 100),
      child: Column(
        children: [
          SizedBox(
            height: 25,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.isEditSubUser ? "Update a User" : "Add a User",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 25,
          ),
          nameTextField,
          SizedBox(
            height: 10,
          ),
          emailTextField,
          SizedBox(
            height: 10,
          ),
          mobileTextField,
          SizedBox(
            height: 10,
          ),
          relationTextField,
          SizedBox(
            height: 25,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Permissions",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          // showPickerArray(context),
          SizedBox(
            height: 25,
          ),
          Container(
            padding: EdgeInsets.only(left: 20, right: 20),
            height: 55,
            child: permissionDropDown(),
          ),
          // GestureDetector(
          //   onTap: () {
          //     print("tap on textfield");
          //     showPickerArray(context);
          //   },
          //   child: Container(
          //     padding: EdgeInsets.only(left: 20, right: 20),
          //     height: 55,
          //     child: permissionDropDown(),
          //     color: Colors.pink,
          //     child: Stack(
          //       children: [
          //         Row(
          //           mainAxisAlignment: (MainAxisAlignment.spaceBetween),
          //           children: [
          //             Container(
          //               width: MediaQuery.of(context).size.width - 110,
          //               color: Colors.blue,
          //               child: new DropdownButton<String>(
          //                 isExpanded: true,
          //                 items: permissions.map((String value) {
          //                   return new DropdownMenuItem<String>(
          //                     value: value,
          //                     child: new Text(value),
          //                   );
          //                 }).toList(),
          //                 onChanged: (_) {},
          //               ),
          //
          //             ),
          //             permissionText,
          //             Container(height: 15, width: 15, child: Image.asset(AppImages.ic_down),),
          //           ],
          //         ),
          //         Positioned(
          //           bottom: 20,
          //           child: Container(
          //             height: 1,
          //             width: MediaQuery.of(context).size.width,
          //             color: Colors.grey,
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
        ],
      ),
    );

    final mainStack = new Stack(
      children: [
        // alltextField,
        userFields,
        Positioned(
          bottom: 25,
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: (MainAxisAlignment.spaceBetween),
              children: [
                Container(),
                Container(
                  child: YellowThemeButton(
                    btnName: "Continue",
                    onPressed: () {

                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(builder: (context) => ProductListForUserView()),
                      // );

                      if (_isValidate(context) == null) {
                        params["name"] = txtName.text.trim();
                        params["email"] = txtEmail.text.trim();
                        params["mobile"] = txtMobile.text.trim();
                        params["relation"] = txtRelation.text.trim();
                        params["role"] = _permissionValue.replaceAll(" ", "_").toLowerCase();

                        print(params);
                        if (_permissionValue == permissions[3]){
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ProductListForUserView(isEditSubUser: widget.isEditSubUser, params: params, selectedSubUserData: userDetails,)),
                          );
                        }else{
                          _addEditSubuser();
                        }

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

    final whiteBG = Container(
      // padding: EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40), topRight: Radius.circular(40))),
      child: mainStack,
    );

    return Scaffold(
      // resizeToAvoidBottomPadding: false,
      backgroundColor: AppColors.appBottleGreenColor,
      appBar: AppBar(
        title: Text(
          "Users",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        shadowColor: Colors.transparent,
        backgroundColor: AppColors.appBottleGreenColor,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: MediaQuery.of(context).size.height - 100,
                  child: whiteBG,
                ),
              ],
            )),
      ),
    );
  }
}


extension CapExtension on String {
  String get inCaps => '${this[0].toUpperCase()}${this.substring(1)}';
  String get allInCaps => this.toUpperCase();
  String get capitalizeFirstofEach => this.split(" ").map((str) => str.inCaps).join(" ");
}