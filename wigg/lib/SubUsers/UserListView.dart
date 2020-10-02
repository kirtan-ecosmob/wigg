// import 'package:flappy_search_bar/flappy_search_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:toast/toast.dart';
import 'package:wigg/Authentication/Model/login_model.dart';
import 'package:wigg/SubUsers/AddSubUser.dart';
import 'package:wigg/Utils/AppColors.dart';
import 'package:wigg/Utils/AppImages.dart';
import 'package:wigg/Utils/CommonFunctions.dart';
import 'package:wigg/Utils/OnFailure.dart';

import '../HomeTabController.dart';
import 'Model/users_model.dart';
import 'UsersModelView.dart';

class UserListView extends StatefulWidget {
  static String name = '/UserList';

  @override
  _UserListViewState createState() => _UserListViewState();
}

class _UserListViewState extends State<UserListView> {
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  List<SubUsersData> userList = [];
  List<SubUsersData> filteredUserList = [];

  bool isSearchActive = false;
  TextEditingController txtSearch = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    postInit(() {
      getUserList();
    });
  }

  // TODO: API calling and functions

  getUserList() {
    this.userList = [];
    Dialogs.showLoadingDialog(context, _keyLoader);
    UsersModelView.instance.getSubUserList().then(
      (response) {
        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
        if (response.code == 200) {
          setState(() {
            this.userList = response.subUserData;
            this.filteredUserList = response.subUserData;
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

  deleteUser(BuildContext context, SubUsersData subUser) {
    // Dialogs.showLoadingDialog(context, _keyLoader);
    UsersModelView.instance.deleteSubUser(subUser.id.toString()).then(
      (response) {
        // Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
        if (response.code == 200) {
          this.filteredUserList.removeWhere((element) => element.id == subUser.id);
          getUserList();
        } else {

        }
        Toast.show(response.message, context,
            duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
      },
      onError: (e) {
        // Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
        if (e is OnFailure) {
          final res = e;
          Toast.show(res.message, context,
              duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
        }
      },
    );
  }

  Container userProfile(String img) {
    if (img == null) {
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

  Padding _userDataContainer(int index) {
    return new Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Container(
        padding: EdgeInsets.only(left: 20, right: 20),
        height: 70,
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
            color: Color(0xff00001A).withOpacity(0.3),
            //Colors.grey.withOpacity(0.5),
            spreadRadius: 0,
            blurRadius: 3,
            offset: Offset(0, 3),
          ),
        ], color: Colors.white, borderRadius: BorderRadius.circular(14)),
        child: Row(
          children: [
            userProfile(filteredUserList[index].profilePic),
            SizedBox(
              width: 20,
            ),
            Text(
              filteredUserList[index].name,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
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

  @override
  Widget build(BuildContext context) {


    _redirectToAddEdit(bool isEdit, SubUsersData user){
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AddSubUserView(isEditSubUser: isEdit, selectedSubUserData: user,)),
      ).then((isReload) {
        if (isReload != null && isReload){
          setState(() {
            // getGroupList();
          });
        }
      });
    }


    final titleAndSearchContainer = Container(
      height: 60,
      // color: Colors.pinkAccent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "List of users",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Container(
            height: 35,
            width: 35,
            child: IconButton(
                icon: Image.asset(AppImages.ic_search),
                onPressed: () {
                  print("search");
                  setState(() {
                    isSearchActive = true;
                    _searchFocus.requestFocus();
                  });
                }),
          ),
        ],
      ),
    );

    // final searchBar = SearchBar<UsersData>(
    //   // onSearch: search,
    //   onItemFound: (UsersData post, int index) {
    //     return ListTile(
    //       title: Text(post.name),
    //       subtitle: Text(post.relation),
    //     );
    //   },
    // );

    Container _userListView() {
      return new Container(
        height: MediaQuery.of(context).size.height - 320,
        width: MediaQuery.of(context).size.width,
        // color: Colors.pinkAccent,
        child: ListView.builder(
            shrinkWrap: false,
            itemCount: filteredUserList.length,
            itemBuilder: (ctx, index) {
              return Slidable(
                actionPane: SlidableDrawerActionPane(),
                actionExtentRatio: 0.15,
                secondaryActions: [
                  IconSlideAction(
                    // caption: 'More',
                    // color: Colors.black45,
                    iconWidget: Image.asset(AppImages.ic_edit),
                    onTap: () {
                      print("Edit");
                      _redirectToAddEdit(true, filteredUserList[index]);
                    },
                  ),
                  IconSlideAction(
                    // caption: 'Delete',
                    // color: Colors.red,
                    iconWidget: Image.asset(AppImages.ic_delete),
                    onTap: () {
                      print(filteredUserList[index].id);
                      CommonFunction.showAlertDialog(
                          context, "Delete user", "Are you sure you want to delete this user?", (isOk) {
                        if (isOk) {
                          txtSearch.text = "";
                          isSearchActive = false;
                          deleteUser(context, filteredUserList[index]);
                        }
                      });
                    },
                  ),
                ],
                child: _userDataContainer(index),
              );
            }),
      );
    }


    Widget searchTextField(){
      return Container(
        // color: Colors.blue,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: 55,
              width: MediaQuery.of(context).size.width - 100,
              child: TextField(
                focusNode: _searchFocus,
                maxLines: 1,
                controller: txtSearch,
                decoration: InputDecoration(
                  hintText: 'Search...',
                  isDense: true,
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: AppColors.appBlueColor)),
                ),
                onChanged: (text){
                  setState(() {
                    setResults(text);
                  });
                },
              ),
            ),
            Container(
              height: 50,
              // width: 30,
              // color: Colors.blue,
              child: IconButton(
                  icon: Image.asset(AppImages.ic_close),
                  onPressed: () {
                    print("cancel");
                    setState(() {
                      txtSearch.text = "";
                      isSearchActive = false;
                      this.filteredUserList = this.userList;
                    });
                    // _openAlertDialogForSelection(context);
                    // loadAssets();
                  }),
            ),
          ],
        ),
      );
    }

    final mainContainer = Container(
      padding: EdgeInsets.only(top: 50, left: 20, right: 20),
      // color: Colors.black,
      child: Column(
        children: [
          isSearchActive ? searchTextField() : titleAndSearchContainer,
          SizedBox(height: 10,),
          Expanded(
            child: _userListView(),
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("Users",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: AppColors.appBottleGreenColor,
        shadowColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Image.asset(AppImages.ic_add_white),
            onPressed: () {
              print("add sub user");

              if (userList.length >= 8){
                showAlertDialog(context, "Max Limit Reached", "You can add only 8 sub users.");
              }else{
                _redirectToAddEdit(false, null);
              }
            },
          ),
        ],
        leading: CommonFunction.sideMenuBuilder(),
      ),
      drawer: navigationDrawer(),
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40), topRight: Radius.circular(40))),
        child: mainContainer,
      ),
    );
  }

  void setResults(String query) {
    filteredUserList = userList
        .where((elem) =>
    elem.name
        .toLowerCase()
        .contains(query.toLowerCase()) ||
        elem.name
            .toLowerCase()
            .contains(query.toLowerCase()))
        .toList();
  }

}
