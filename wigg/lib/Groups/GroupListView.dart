import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:toast/toast.dart';
import 'package:wigg/Groups/GroupModelView.dart';
import 'package:wigg/Groups/Model/group_model.dart';
import 'package:wigg/Utils/AppColors.dart';
import 'package:wigg/Utils/AppImages.dart';
import 'package:wigg/Utils/CommonFunctions.dart';
import 'package:wigg/Utils/OnFailure.dart';

import '../HomeTabController.dart';
import 'AddEditGroupView.dart';

class GroupListView extends StatefulWidget {
  static String name = '/GroupList';

  GroupListView({Key key}) : super(key: key);

  @override
  _GroupListViewState createState() => _GroupListViewState();
}

class _GroupListViewState extends State<GroupListView> {
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  List<GroupData> groupList = [];
  List<GroupData> filteredGroupList = [];

  bool isSearchActive = false;
  TextEditingController txtSearch = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  // TODO: implement initState
  @override
  void initState() {
    super.initState();

    postInit(() {
      getGroupList();
    });
  }

  // TODO: API calling

  getGroupList() {
    Dialogs.showLoadingDialog(context, _keyLoader);
    GroupModelView.instance.getGroupList().then(
      (response) {
        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
        if (response.code == 200) {
          setState(() {
            this.groupList = response.groupData;
            this.filteredGroupList = response.groupData;
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

  deleteGroup(BuildContext context, String groupId) {
    // Dialogs.showLoadingDialog(context, _keyLoader);
    GroupModelView.instance.deleteGroup(groupId).then(
          (response) {
        // Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
        if (response.code == 200) {
          setState(() {
            this.filteredGroupList.removeWhere((element) => element.id.toString() == groupId);
          });
          getGroupList();
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
          CommonFunction.redirectToLogin(context, e);
        }
      },
    );
  }

  // TODO: Custon Functions

  @override
  Widget build(BuildContext context) {

    _redirectToAddEdit(bool isEdit, GroupData group){
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AddEditGroupView(isEditGroup: isEdit, selectedGroup: group,)),
      ).then((isReload) {
        if (isReload != null && isReload){
          setState(() {
            getGroupList();
          });
        }
      });
    }


    Widget _groupDataContainer(int index) {
      return new Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: Container(
          padding: EdgeInsets.only(left: 20, right: 20),
          // height: 70,
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
              color: Color(0xff00001A).withOpacity(0.3),
              //Colors.grey.withOpacity(0.5),
              spreadRadius: 0,
              blurRadius: 3,
              offset: Offset(0, 3),
            ),
          ], color: Colors.white, borderRadius: BorderRadius.circular(14)),
          child: Column(
            children: [
              SizedBox(height: 10,),
              Row(
                children: [
                  Container(
                    height: 20,
                    width: 20,
                    child: Image.asset(filteredGroupList[index].type.toLowerCase() == "commercial" ? AppImages.ic_office_color : AppImages.ic_home_color),
                  ),
                  SizedBox(width: 10,),
                  Container(
                    child: Text(
                      filteredGroupList[index].name,
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10,),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(filteredGroupList[index].address, style: TextStyle(color: AppColors.appLightGrayColor),),
              ),
              SizedBox(height: 10,),
            ],
          ),
        ),
      );
    }

    Widget _groupListView() {
      return new Container(
        // height: MediaQuery.of(context).size.height - 320,
        width: MediaQuery.of(context).size.width,
        // color: Colors.pinkAccent,
        child: ListView.builder(
            shrinkWrap: false,
            itemCount: filteredGroupList.length,
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
                      _redirectToAddEdit(true, filteredGroupList[index]);
                    },
                  ),
                  IconSlideAction(
                    // caption: 'Delete',
                    // color: Colors.red,
                    iconWidget: Image.asset(AppImages.ic_delete),
                    onTap: () {
                      print(filteredGroupList[index].id);
                      txtSearch.text = "";
                      isSearchActive = false;
                      deleteGroup(context, filteredGroupList[index].id.toString());
                    },
                  ),
                ],
                child: _groupDataContainer(index),
              );
            }),
      );
    }

    final titleAndSearchContainer = Container(
      height: 60,
      // color: Colors.pinkAccent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "List of Address",
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
                      this.filteredGroupList = this.groupList;
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
      // color: Colors.pink,
      // height: MediaQuery.of(context).size.height - 100,
      padding: EdgeInsets.only(top: 50, left: 20, right: 20),
      // color: Colors.black,
      child: Column(
        children: [
          isSearchActive ? searchTextField() : titleAndSearchContainer,
          SizedBox(height: 10,),
          Expanded(
            child: _groupListView(),
          ),
        ],
      ),
    );


    return Scaffold(
      appBar: AppBar(
        title: Text("Address",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: AppColors.appBottleGreenColor,
        shadowColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Image.asset(AppImages.ic_add_white),
            onPressed: () {
              print("add Address");
              _redirectToAddEdit(false, null);
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
    filteredGroupList = groupList
        .where((elem) =>
    elem.name
        .toLowerCase()
        .contains(query.toLowerCase()) ||
        elem.address
            .toLowerCase()
            .contains(query.toLowerCase()))
        .toList();
  }

}
