// import 'dart:html';

import 'dart:io';

// import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toast/toast.dart';
import 'package:wigg/Authentication/LoginViewModel.dart';
import 'package:wigg/Authentication/Model/login_model.dart';
import 'package:wigg/Groups/AddEditGroupView.dart';
import 'package:wigg/SubUsers/AddSubUser.dart';
import 'package:wigg/SubUsers/Model/users_model.dart';
import 'package:wigg/SubUsers/UsersModelView.dart';
import 'package:wigg/Utils/AppColors.dart';
import 'package:wigg/Utils/AppImages.dart';
import 'package:wigg/Utils/AppStrings.dart';
import 'package:wigg/Utils/OnFailure.dart';
import 'package:wigg/Utils/Preference.dart';
import 'package:wigg/Utils/CommonFunctions.dart';

import '../HomeTabController.dart';
import 'FilteredGroupListView.dart';

class MyProfileView extends StatefulWidget {
  static String name = '/MyProfile';

  @override
  _MyProfileViewState createState() => _MyProfileViewState();
}

class _MyProfileViewState extends State<MyProfileView> {
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  String _profilePic = "";
  String _userFullName = "";
  String _mobileNumber = "";
  List<SubUsersData> userList = [];

  UserData userProfileDetails;

  ImageCache get imageCache => PaintingBinding.instance.imageCache;
  final ImagePicker _picker = ImagePicker();

  List<File> _selectedImage = [];
  bool isProfileImgChange = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // images = [];

    print(UsersModelView.instance.userRole);


    postInit(() {
      _getUserProfile();
      _getSubUserList();
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
            this._profilePic = response.data.profilePic;
            this._userFullName = response.data.name;
            this._mobileNumber = response.data.mobile;
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

  _getSubUserList() {
    this.userList = [];
    UsersModelView.instance.getSubUserList().then(
          (response) {
        // Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
        if (response.code == 200) {
          setState(() {
            this.userList = response.subUserData;
          });
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

  // TODO: Custom Functions

  Container userProfile(String img) {
    if (img == null || img == "") {
      return Container(
        child: CircleAvatar(
          backgroundColor: Colors.transparent,
          backgroundImage: AssetImage(AppImages.user_placeholder),
          radius: 20,
        ),
      );
    } else {
      return Container(
        height: 40,
        width: 40,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.network(
            img,
            fit: BoxFit.cover,
          ),
        ),
      );
    }
  }

  showAlertDialog(BuildContext context, String title, String message) {
    // set up the button
    Widget okButton = FlatButton(
      child: Text("OK"),
      onPressed: () {Navigator.of(context).pop();},
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
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

  Widget buildSubUserData(String name, String image, double height,
      {bool isRounded = true}) {
    return Column(
      children: [
        Container(
          // height: 50,
          // width: 50,
          padding: const EdgeInsets.all(8),
          child: Container(
            height: height,
            width: height,
            decoration: BoxDecoration(
              borderRadius: isRounded
                  ? BorderRadius.circular(height / 2)
                  : BorderRadius.circular(0),
            ),
            child: userProfile(image),
          ),
        ),
        Expanded(
          child: Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 12,),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget leftAlignTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
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

      setState(() {
        _selectedImage.add(File(image.path));
        isProfileImgChange = true;
        print(image.path.toString());
        print(image.path.split("/").last);
        _updateProfilePicAPI();
        imageCache.clear();
      });
    });
  }

  Future _openCamera() async {
    Navigator.of(context).pop();
    // var image = await ImagePicker.pickImage(source: ImageSource.camera);
    var image = await _picker.getImage(source: ImageSource.camera);

    File _imageFile;
    _imageFile = await File(image.path);
    print("FILE SIZE BEFORE: " + _imageFile.lengthSync().toString());

    // await CompressImage.compress(imageSrc: image.path, desiredQuality: 50);

    print("FILE SIZE  AFTER: " + _imageFile.lengthSync().toString());

    setState(() {
      _selectedImage.add(File(image.path));
      isProfileImgChange = true;
      _updateProfilePicAPI();
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

  @override
  Widget build(BuildContext context) {
    String _error = 'No Error Dectected';

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

    final addresses = Row(
      mainAxisAlignment: (MainAxisAlignment.spaceBetween),
      children: [
        Container(
          height: 75,
          width: MediaQuery.of(context).size.width - 85,
          child: GridView.count(
            childAspectRatio: 1.25,
            primary: false,
            // padding: const EdgeInsets.all(20),
            // crossAxisSpacing: 10,
            // mainAxisSpacing: 10,
            crossAxisCount: 1,
            scrollDirection: Axis.horizontal,
            children: <Widget>[
              Column(
                children: [
                  Container(
                    height: 45,
                    // width: 50,
                    // color: Colors.black,
                    child: IconButton(
                        icon: Image.asset(AppImages.ic_home),
                        onPressed: () {
                          print("home");
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => FilteredGroupListView(groupType: "non-commercial")),
                          );
                        }),
                  ),
                  Text(
                    "Home",
                  style: TextStyle(fontSize: 12),),
                ],
              ),

              Column(
                children: [
                  Container(
                    height: 45,
                    // width: 50,
                    // color: Colors.black,
                    child: IconButton(
                        icon: Image.asset(AppImages.ic_office),
                        onPressed: () {
                          print("office");
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => FilteredGroupListView(groupType: "commercial")),
                          );
                        }),
                  ),
                  Text(
                    "Office",
                    style: TextStyle(fontSize: 12),),
                ],
              ),

            ],
          ),
        ),
        // Container(height: 50, width: 50, color: Colors.black,),
        Container(
          height: 40,
          width: 40,
          // color: Colors.black,
          child: IconButton(
              icon: Image.asset(AppImages.ic_add),
              onPressed: () {
                print("Add address");
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddEditGroupView()),
                );
              }),
        ),
      ],
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
                  // AssetThumb(
                  //   asset: _profileImg,
                  //   width: 100,
                  //   height: 100,
                  //   quality: 80,
                  // ),
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


    Widget addUserButton(){
      if (UsersModelView.instance.isParent || UsersModelView.instance.userRole == AppStrings.full_access){
        return Container(
          height: 40,
          width: 40,
          // color: Colors.black,
          child: IconButton(
              icon: Image.asset(AppImages.ic_add),
              onPressed: () {
                print("Add sub user");
                if (userList.length >= 8){
                  showAlertDialog(context, "Max Limit Reached", "You can add only 8 sub users.");
                }else{
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddSubUserView()),
                  );
                }
              }),
        );
      }else{
        return Container();
      }
    }

    Widget _sharedUserGrid(){
      return Container(
        child: Row(
          mainAxisAlignment: (MainAxisAlignment.spaceBetween),
          children: [
            Container(
              height: 75,
              width: (UsersModelView.instance.isParent || UsersModelView.instance.userRole == AppStrings.full_access) ? MediaQuery.of(context).size.width - 85 : MediaQuery.of(context).size.width - 40,
              child: this.userList.length == 0 ? Container() : GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 1),
                  primary: false,
                  itemCount: this.userList.length,
                  // padding: const EdgeInsets.all(20),
                  // crossAxisSpacing: 10,
                  // mainAxisSpacing: 10,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (ctx, index) {
                    return GestureDetector(
                      onTap: () {
                        print(userList[index].id);
                      },
                      child: buildSubUserData(userList[index].name, userList[index].profilePic, 40),
                      // child: listViewChild(index),
                    );
                  }),

            ),
            // Container(height: 50, width: 50, color: Colors.black,),
            addUserButton(),
          ],
        ),
      );
    }

    final mainContainer = Container(
      // height: 1000,
      width: MediaQuery.of(context).size.width,
      // color: Colors.pink,
      child: Column(
        children: [
          userImgStackView,
          // _profilePic != "" ? userImage : userProfilePlaceHolder,
          Text(_userFullName,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
              textAlign: TextAlign.end),
          Text(_mobileNumber,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  color: AppColors.appGrayColor),
              textAlign: TextAlign.end),
          SizedBox(
            height: 30,
          ),
          leftAlignTitle("Shared Users"),
          SizedBox(
            height: 15,
          ),
          _sharedUserGrid(),
          SizedBox(
            height: 30,
          ),
          leftAlignTitle("My Addresses"),
          SizedBox(
            height: 15,
          ),
          addresses,
        ],
      ),
    );

    return Scaffold(
//      resizeToAvoidBottomInset: false,
//       resizeToAvoidBottomPadding: true,
      appBar: AppBar(
        title: Text("My Profile", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: AppColors.appBottleGreenColor,
        shadowColor: Colors.transparent,
        leading: CommonFunction.sideMenuBuilder(),
      ),
      drawer: navigationDrawer(),
      backgroundColor: Colors.transparent,
      body: Container(
        // height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40), topRight: Radius.circular(40))),
        child: ListView(
          padding: EdgeInsets.only(left: 20, right: 20, top: 20),
          children: [
            mainContainer,
            // Text("Shared Users", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
          ],
        ),
      ),
    );
  }
}
