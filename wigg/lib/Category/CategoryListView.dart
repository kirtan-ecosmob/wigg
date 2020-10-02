import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:toast/toast.dart';
import 'package:wigg/Products/Model/category_model.dart';
import 'package:wigg/Products/ProductModelView.dart';
import 'package:wigg/Utils/AppColors.dart';
import 'package:wigg/Utils/AppImages.dart';
import 'package:wigg/Utils/CommonFunctions.dart';
import 'package:wigg/Utils/OnFailure.dart';

import 'AddEditCategory.dart';

class CategoryListView extends StatefulWidget {
  @override
  _CategoryListViewState createState() => _CategoryListViewState();
}

class _CategoryListViewState extends State<CategoryListView> {
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  List<CategoryData> categoryList = [];


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    postInit(() {
      _getCategoryList();
    });
  }


  // TODO: API calling

  _getCategoryList(){
    Dialogs.showLoadingDialog(context, _keyLoader);
    ProductModelView.instance.getCategoryList().then(
          (response) {
        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
        if (response.code == 200) {
          setState(() {
            categoryList = response.catData;
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
    ProductModelView.instance.deleteCategory(groupId).then(
          (response) {
        // Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
        if (response.code == 200) {
          setState(() {
            this.categoryList.removeWhere((element) => element.id.toString() == groupId);
          });
          _getCategoryList();
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



  @override
  Widget build(BuildContext context) {

    _redirectToAddCategoty(bool isEdit, CategoryData category){
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AddEditCategoryView(isEditCategory: isEdit, selectedCategory: category,)),
      ).then((isReload) {
        if (isReload != null && isReload){
          setState(() {
            _getCategoryList();
          });
        }
      });
    }


    Widget _categoryDataContainer(int index) {
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
              // SizedBox(height: 10,),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    child: Text(
                      categoryList[index].name,
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    Widget _categoryListView() {
      return new Container(
        // height: MediaQuery.of(context).size.height - 320,
        width: MediaQuery.of(context).size.width,
        // color: Colors.pinkAccent,
        child: ListView.builder(
            shrinkWrap: false,
            itemCount: categoryList.length,
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
                      _redirectToAddCategoty(true, categoryList[index]);
                    },
                  ),
                  IconSlideAction(
                    // caption: 'Delete',
                    // color: Colors.red,
                    iconWidget: Image.asset(AppImages.ic_delete),
                    onTap: () {
                      print(categoryList[index].id);
                      deleteGroup(context, categoryList[index].id.toString());
                    },
                  ),
                ],
                child: _categoryDataContainer(index),
              );
            }),
      );
    }


    final title = Container(
      // padding: EdgeInsets.only(top: 0, left: 20, right: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text("List of Categories", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
      ),
    );


    final mainContainer = Container(
      // color: Colors.pink,
      height: MediaQuery.of(context).size.height - 90,
      padding: EdgeInsets.only(top: 50, left: 20, right: 20),
      // color: Colors.black,
      child: Column(
        // mainAxisSize: MainAxisSize.min,
        children: [
          title,
          SizedBox(height: 10,),
          Expanded(
            child: _categoryListView(),
          ),
        ],
      ),
    );


    return Scaffold(
      backgroundColor: AppColors.appBottleGreenColor,
      appBar: AppBar(
        title: Text("Categories",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: AppColors.appBottleGreenColor,
        shadowColor: Colors.transparent,
        actions: [
          IconButton(
            icon: Image.asset(AppImages.ic_add_white),
            onPressed: () {
              print("add category");
              _redirectToAddCategoty(false, null);
            },
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(40), topRight: Radius.circular(40))),
          child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: mainContainer,
          ),
        ),
      ),
    );
  }
}
