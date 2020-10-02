import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toast/toast.dart';
import 'package:wigg/Authentication/LoginViewModel.dart';
import 'package:wigg/Authentication/Model/login_model.dart';
import 'package:wigg/Utils/AppColors.dart';
import 'package:wigg/Utils/AppImages.dart';
import 'package:wigg/Utils/CommonFunctions.dart';
import 'package:wigg/Utils/OnFailure.dart';
import 'package:wigg/Utils/Helper.dart';
import 'package:wigg/Utils/StateProvider.dart';

class EditMyProfileView extends StatefulWidget {
  static String name = '/Editmyprofile';

  @override
  _EditMyProfileViewState createState() => _EditMyProfileViewState();
}

class _EditMyProfileViewState extends State<EditMyProfileView> {
  String _profilePic = "";

  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  UserData userProfileDetails;
  bool isProfileImgChange = false;
  List<File> _selectedImage = [];
  final ImagePicker _picker = ImagePicker();

  TextEditingController txtName = TextEditingController();
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtMobile = TextEditingController();

  StateProvider _stateProvider = StateProvider();

  // final FocusNode _nodeText1 = FocusNode();
  // final FocusNode _nodeText2 = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    postInit(() {
      _getUserProfile();
    });
  }

  // TODO: API calling and functions

  _getUserProfile() {
    Dialogs.showLoadingDialog(context, _keyLoader);
    LoginViewModel.instance.getUserProfile().then(
      (response) {
        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
        if (response.code == 200) {
          setState(() {
            this.userProfileDetails = response.data;
            _profilePic = this.userProfileDetails.profilePic;

            txtName.text = this.userProfileDetails.name;
            txtEmail.text = this.userProfileDetails.email;
            txtMobile.text = this.userProfileDetails.mobile;
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
        }
      },
    );
  }

  _openAlertDialogForSelection(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Select Option',
              style: TextStyle(
                color: Colors.black,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  GestureDetector(
                    child: Text(
                      'Camera',
                      style: TextStyle(),
                    ),
                    onTap: _openCamera,
                  ),
                  Padding(padding: EdgeInsets.all(10.0)),
                  GestureDetector(
                    child: Text(
                      'Gallery',
                      style: TextStyle(),
                    ),
                    onTap: _openGallery,
                  ),
                ],
              ),
            ),
          );
        });
  }

  Future<File> testCompressAndGetFile(File file, String targetPath) async {
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path, targetPath,
      quality: 50,
      // rotate: 180,
    );

    print(file.lengthSync());
    print(result.lengthSync());

    return result;
  }

  Future<Directory> getTemporaryDirectory() async {
    return Directory.systemTemp;
  }

  Future _imageCompressAndUpload(PickedFile image) async {
    setState(() {
      _selectedImage.add(File(image.path));
      isProfileImgChange = true;
      print(image.path.toString());
      print(image.path.split("/").last);
      _updateProfilePicAPI();
      imageCache.clear();
    });
  }

  Future _openGallery() async {
    Navigator.of(context).pop();
    // var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    var image = await _picker.getImage(source: ImageSource.gallery);

    File _imageFile;
    _imageFile = File(image.path);
    print("FILE SIZE BEFORE: " + _imageFile.lengthSync().toString());

    final dir = await getTemporaryDirectory();
    final targetPath = dir.absolute.path + "/temp.jpg";
    print('TargetPath : $targetPath');

    testCompressAndGetFile(_imageFile, targetPath).then((value) {
      print("FILE SIZE AFTER: " + value.lengthSync().toString());
      _imageCompressAndUpload(image);
    });
  }

  Future _openCamera() async {
    Navigator.of(context).pop();
    // var image = await ImagePicker.pickImage(source: ImageSource.camera);
    var image = await _picker.getImage(source: ImageSource.camera);

    File _imageFile;
    _imageFile = File(image.path);
    print("FILE SIZE BEFORE: " + _imageFile.lengthSync().toString());

    final dir = await getTemporaryDirectory();
    final targetPath = dir.absolute.path + "/temp.jpg";
    print('TargetPath : $targetPath');

    testCompressAndGetFile(_imageFile, targetPath).then((value) {
      print("FILE SIZE AFTER: " + value.lengthSync().toString());
      _imageCompressAndUpload(image);
    });
  }

  _updateProfilePicAPI() {
    Dialogs.showLoadingDialog(context, _keyLoader);
    LoginViewModel.instance.updateProfilePic(_selectedImage.first).then(
      (response) {
        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
        // images = [];
        if (response.code == 200) {
          CommonFunction.saveToPref(response.data);
        } else {
          Toast.show(response.message, context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        }
      },
      onError: (e) {
        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
        // images = [];
        if (e is OnFailure) {
          final res = e;
          Toast.show(res.message, context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        }
      },
    );
  }

  bool _isValidate(BuildContext context) {
    if (txtName.text.trim().isEmpty) {
      Toast.show('Please enter name', context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      return false;
    } else if (txtEmail.text.trim().isEmpty) {
      Toast.show('Please enter email', context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      return false;
    } else if (txtEmail.text.trim().validateEmail() == false) {
      Toast.show('Please enter valid email', context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      return false;
    }
  }

  _updateProfileData(BuildContext context) {
    Dialogs.showLoadingDialog(context, _keyLoader);
    LoginViewModel.instance
        .updateUserDate(
            txtName.text.trim(), txtEmail.text.trim(), txtMobile.text.trim())
        .then(
      (response) {
        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
        if (response.code == 200) {
          CommonFunction.saveToPref(response.data);
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

  Future<bool> _onWillPop() async {
    // Timer(Duration(seconds: 1), (){setState(() {});});
    _stateProvider.notify(ObserverState.VALUE_CHANGED, "");
    Navigator.of(context).pop();
    // return (await showDialog(
    //   context: context,
    //   builder: (context) => new AlertDialog(
    //     title: new Text('Are you sure?'),
    //     content: new Text('Do you want to exit an App'),
    //     actions: <Widget>[
    //       new FlatButton(
    //         onPressed: () => Navigator.of(context).pop(false),
    //         child: new Text('No'),
    //       ),
    //       new FlatButton(
    //         onPressed: () => Navigator.of(context).pop(true),
    //         child: new Text('Yes'),
    //       ),
    //     ],
    //   ),
    // )) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final userProfilePlaceHolder = CircleAvatar(
      backgroundColor: Colors.transparent,
      backgroundImage: AssetImage(AppImages.user_placeholder),
      radius: 80,
    );

    final userImage = ClipRRect(
      borderRadius: BorderRadius.circular(80),
      child: Image.network(
        _profilePic,
        fit: BoxFit.cover,
      ),
    );

    final userImgStackView = Stack(
      overflow: Overflow.visible,
      children: [
        Container(
          height: 160,
          width: 160,
          child: isProfileImgChange
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(80),
                  child: Image.file(
                    _selectedImage.first,
                    fit: BoxFit.fill,
                  ),
                )
              : _profilePic != "" ? userImage : userProfilePlaceHolder,
        ),
        Positioned(
          width: 160,
          bottom: 0,
          child: Row(
            mainAxisAlignment: (MainAxisAlignment.spaceBetween),
            children: [
              Container(),
              Container(
                height: 50,
                width: 50,
                child: IconButton(
                    icon: Image.asset(AppImages.ic_camera),
                    onPressed: () {
                      print("select image");
                      _openAlertDialogForSelection(context);
                      // loadAssets();
                    }),
              ),
            ],
          ),
        ),
      ],
    );

    final mainContainer = Container(
      // height: 1000,
      padding: EdgeInsets.only(top: 20),
      width: MediaQuery.of(context).size.width,
      // color: Colors.pink,
      child: Column(
        children: [
          userImgStackView,
          Text(
              this.userProfileDetails == null
                  ? ""
                  : this.userProfileDetails.name,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
              textAlign: TextAlign.end),
          Text(
              this.userProfileDetails == null
                  ? ""
                  : this.userProfileDetails.mobile,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: AppColors.appGrayColor),
              textAlign: TextAlign.end),
          SizedBox(
            height: 30,
          ),
        ],
      ),
    );

    final nameTextField = CommonFunction.customTextfield(
        "Name", txtName, TextInputType.text, context,
        textColor: Colors.grey);

    final emailTextField = CommonFunction.customTextfield(
        "Email", txtEmail, TextInputType.emailAddress, context,
        textColor: Colors.grey);

    final mobileTextField = CommonFunction.customTextfield(
        "Mobile", txtMobile, TextInputType.number, context,
        textColor: Colors.grey, maxLength: 16, isLastTextfield: true);

    final alltextField = Container(
        padding: EdgeInsets.only(left: 20, right: 20),
        child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                mainContainer,
                nameTextField,
                SizedBox(
                  height: 20,
                ),
                emailTextField,
                SizedBox(
                  height: 20,
                ),
                mobileTextField,
                SizedBox(
                  height: 20,
                ),
              ],
            )));

    final mainStack = new Stack(
      children: [
        alltextField,
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
                    btnName: "Save",
                    onPressed: () {
                      if (_isValidate(context) == null) {
                        _updateProfileData(context);
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

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        // resizeToAvoidBottomPadding: false,
        backgroundColor: AppColors.appBottleGreenColor,
        appBar: AppBar(
          title: Text(
            "My Profile",
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
                    height: MediaQuery.of(context).size.height - 80,
                    child: whiteBG,
                  ),
                ],
              )),
        ),
      ),
    );



    // return Scaffold(
    //   // resizeToAvoidBottomPadding: false,
    //   backgroundColor: AppColors.appBottleGreenColor,
    //   appBar: AppBar(
    //     title: Text(
    //       "My Profile",
    //       style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
    //     ),
    //     shadowColor: Colors.transparent,
    //     backgroundColor: AppColors.appBottleGreenColor,
    //   ),
    //   body: GestureDetector(
    //     onTap: () {
    //       FocusScope.of(context).unfocus();
    //     },
    //     child: SingleChildScrollView(
    //         physics: ClampingScrollPhysics(),
    //         child: Column(
    //           crossAxisAlignment: CrossAxisAlignment.center,
    //           children: [
    //             Container(
    //               height: MediaQuery.of(context).size.height - 100,
    //               child: whiteBG,
    //             ),
    //           ],
    //         )),
    //   ),
    // );
  }
}
