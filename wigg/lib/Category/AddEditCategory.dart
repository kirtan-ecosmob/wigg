import 'package:dart_notification_center/dart_notification_center.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'package:wigg/Products/Model/category_model.dart';
import 'package:wigg/Products/ProductModelView.dart';
import 'package:wigg/Utils/AppColors.dart';
import 'package:wigg/Utils/AppStrings.dart';
import 'package:wigg/Utils/CommonFunctions.dart';
import 'package:wigg/Utils/OnFailure.dart';

class AddEditCategoryView extends StatefulWidget {


  static String name = '/AddEditGroup';

  bool isEditCategory;
  CategoryData selectedCategory;

  AddEditCategoryView({this.isEditCategory = false, this.selectedCategory});

  @override
  _AddEditCategoryViewState createState() => _AddEditCategoryViewState();
}

class _AddEditCategoryViewState extends State<AddEditCategoryView> {
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  TextEditingController txtCategory = TextEditingController();

  // TODO: implement initState
  @override
  void initState() {
    super.initState();

    if (widget.isEditCategory){
      txtCategory.text = widget.selectedCategory.name;
    }
  }

  // TODO: API calling

  _addEditCategory(){
    Dialogs.showLoadingDialog(context, _keyLoader);
    ProductModelView.instance.addEditCategory(categoryName: txtCategory.text.trim(), isEdit: widget.isEditCategory, category: widget.selectedCategory).then(
          (response) {
        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
        if (response.code == 200) {
          DartNotificationCenter.post(channel: AppStrings.updateCategory);
          Navigator.of(context).pop(true);
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


  // TODO: Custon Functions

  bool _isValidate(BuildContext context) {
    if (txtCategory.text.trim().isEmpty) {
      Toast.show('Please enter category name', context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {



    Widget stackView() {
      return Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height - 202,
            // color: Colors.blue,
          ),
          Container(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: CommonFunction.customTextfield("Enter Category Name", txtCategory, TextInputType.text, context, isLastTextfield: true),
            // child: allTextField(),
          ),
          new Positioned(
            right: 0,
            bottom: 30,
            child: Container(
              child: YellowThemeButton(
                btnName: widget.isEditCategory ? "Update" : "Add",
                onPressed: () {
                  if (_isValidate(context) == null){
                    _addEditCategory();
                  }
                },
              ),
            ),
          )
        ],
      );
    }


    final title = Container(
      padding: EdgeInsets.only(top: 50, left: 20, right: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(widget.isEditCategory ? "Update Category" : "Add Category", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
      ),
    );

    final mainContainer = Container(
      // color: Colors.pink,
      // height: MediaQuery.of(context).size.height - 100,
      // padding: EdgeInsets.only(top: 50, left: 20, right: 20),
      // color: Colors.black,
      child: Column(
        children: [
          title,
          SizedBox(height: 30,),
          stackView(),
          // Expanded(// wrap in Expanded
          //   child: Container(
          //     padding: EdgeInsets.only(bottom: 20),
          //     // child: dataContainer(),
          //   ),
          // ),
        ],
      ),
    );



    return Scaffold(
      // resizeToAvoidBottomPadding: false,
      backgroundColor: AppColors.appBottleGreenColor,
      appBar: AppBar(
        title: Text(
          // widget.isEditGroup ? "Edit " : "Add Product",
          "Category",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        shadowColor: Colors.transparent,
        backgroundColor: AppColors.appBottleGreenColor,
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
