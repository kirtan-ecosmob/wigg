import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:toast/toast.dart';
import 'package:wigg/Products/AddEditProductView.dart';
import 'package:wigg/Products/Model/category_model.dart';
import 'package:wigg/Products/Model/product_model.dart';
import 'package:wigg/Products/ProductModelView.dart';
import 'package:wigg/SubUsers/UsersModelView.dart';
import 'package:wigg/Utils/AppColors.dart';
import 'package:wigg/Utils/AppImages.dart';
import 'package:wigg/Utils/CommonFunctions.dart';
import 'package:wigg/Utils/OnFailure.dart';

import '../HomeTabController.dart';
import 'Model/users_model.dart';

class ProductListForUserView extends StatefulWidget {

  bool isEditSubUser;
  var params = {};
  SubUsersData selectedSubUserData;

  ProductListForUserView({this.isEditSubUser = false, this.params, this.selectedSubUserData});


  @override
  _ProductListForUserViewState createState() => _ProductListForUserViewState();
}

class _ProductListForUserViewState extends State<ProductListForUserView> {

  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  List<Product> productList = [];
  List<CategoryData> categoryList = [];
  List<String> selectedProduct = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (widget.isEditSubUser){
      selectedProduct = widget.selectedSubUserData.productIds.split(",");
      print(selectedProduct);
      _setSelectedProduct();
    }

    postInit(() {
      getCategoryList();
      getProductList();
    });
  }


  // TODO: API calling

  _addEditSubuser(){

    if (selectedProduct.length > 0){
      widget.params["product_id"] = selectedProduct.join(",");
    }

    Dialogs.showLoadingDialog(context, _keyLoader);
    UsersModelView.instance.addEditSubUser(para: widget.params, isEdit: widget.isEditSubUser, user: widget.selectedSubUserData).then(
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

  getProductList() {
    this.productList = [];
    String _catId = "";

    if (categoryList.length > 0) {
      List<CategoryData> _selectedCat = this.categoryList.where((
          element) => element.isSelectd).toList();
      _catId = _selectedCat.length > 0 ? _selectedCat.first.id == null ? "" : _selectedCat.first.id.toString() : "";
      print(_catId);
    }


    Dialogs.showLoadingDialog(context, _keyLoader);
    ProductModelView.instance.getProductList(categoryId: _catId).then(
          (response) {
        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
        if (response.code == 200) {
          setState(() {
            this.productList = response.productData;
            if (widget.isEditSubUser){
              _setSelectedProduct();
            }
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

  getCategoryList(){
    this.categoryList = [];
    CategoryData _showAll = CategoryData(name: "Show all", isSelected: true);

    ProductModelView.instance.getCategoryList().then(
          (response) {
        // Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
        if (response.code == 200) {
          setState(() {
            // response.catData.map((e) => this.categoryList.add(e));
            this.categoryList = response.catData;
            this.categoryList.insert(0, _showAll);
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
        }
      },
    );
  }

  deleteProduct(BuildContext context, Product product) {
    // Dialogs.showLoadingDialog(context, _keyLoader);
    ProductModelView.instance.deleteProduct(product.id.toString()).then(
          (response) {
        // Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
        if (response.code == 200) {
          this.productList.removeWhere((element) => element.id == product.id);
          getProductList();
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





  // TODO:Custom Functions

  _setSelectedProduct(){
    productList.forEach((element) {
      selectedProduct.forEach((id) {
        if (element.id.toString() == id){
          element.isSelected = true;
        }
      });
    });
  }

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

  Row nameAndImage(int index){
    return Row(
      children: [
        userProfile(productList[index].images.length == 0 ? "" : productList[index].images.first),
        SizedBox(
          width: 20,
        ),
        Expanded(
          child: Text(
            productList[index].name,
            // CommonFunction.remainYearsMonthDayFromDate("11-25-2022"),

            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  Color getColorFromExpiry(Product product){
    final expiryDate =  new DateFormat("MM-dd-yyyy").parse(product.expiryDate);
    final currentDate = DateTime.now();
    int remainDays = expiryDate.difference(currentDate).inDays;
    if (remainDays >= 90){
      return Colors.green;
    }else if (remainDays >30 && remainDays <90){
      return Colors.orange;
    }else{
      return Colors.red;
    }
  }


  double getPercentageBetweenTwoDate(Product product){
    final purchaseDate = new DateFormat("MM-dd-yyyy").parse(product.purchaseDate);
    final expiryDate =  new DateFormat("MM-dd-yyyy").parse(product.expiryDate);
    final currentDate = DateTime.now();
    int totalDays = expiryDate.difference(purchaseDate).inDays;
    int fromTodayRemainDays = expiryDate.difference(currentDate).inDays;

    if (fromTodayRemainDays/totalDays > 0){
      return (fromTodayRemainDays)/totalDays;
    }else{
      return 0;
    }
  }

  Widget productDataView(int index) {
    return Container(
      // height: 50,
      // width: 50,
      // color: Colors.pink,
      child: Padding(
        padding: EdgeInsets.only(bottom: 10),
        child: Row(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              height: 20,
              // width: 20,
              // color: Colors.black,
              child: productList[index].isSelected ? Image.asset(AppImages.ic_selected) : Image.asset(AppImages.ic_deselected),
            ),
            SizedBox(width: 10,),
            Container(
              // padding: EdgeInsets.only(left: 20, right: 20),
              padding: EdgeInsets.all(10),
              width: MediaQuery.of(context).size.width - 80,
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
                  nameAndImage(index),
                  SizedBox(height: 16,),
                  new LinearPercentIndicator(
                    // width: MediaQuery.of(context).size.width - 80,
                    // width: 100,
                    lineHeight: 5.0,
                    percent: getPercentageBetweenTwoDate(productList[index]),
                    progressColor: getColorFromExpiry(productList[index]),
                  ),
                  SizedBox(height: 4,),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      CommonFunction.remainYearsMonthDayFromDate(productList[index].expiryDate, "MM-dd-yyyy"),
                      style: TextStyle(fontSize: 12, color: AppColors.appLightGrayColor),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final categoryChipView = Wrap(
      children: List<Widget>.generate(
        this.categoryList.length,
            (int index) {
          return Container(
            padding: EdgeInsets.only(right: 10),
            child: ChoiceChip(
              // disabledColor: Colors.blueGrey,//Color(0xffF4F0F0),
              padding: EdgeInsets.only(top: 8, bottom: 10),
              backgroundColor: Colors.grey[100],
              selectedColor: Colors.grey,
              label: Text("${categoryList[index].name}", style: TextStyle(color: categoryList[index].isSelectd ? Colors.white : AppColors.appLightGrayColor, fontSize: 14),),
              selected: this.categoryList[index].isSelectd,
              onSelected: (bool selected) {
                setState(() {
                  this.categoryList.forEach((element) {element.isSelectd = false;});
                  this.categoryList[index].isSelectd = true;
                  getProductList();
                });
              },
            ),
          );
        },
      ).toList(),
    );

    Container _productListView() {
      return new Container(
        child: ListView.builder(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            itemCount: productList.length,
            itemBuilder: (ctx, index) {
              return GestureDetector(
                onTap: () {
                  print(productList[index].id);
                  setState(() {
                    productList[index].isSelected = !productList[index].isSelected;
                  });
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(builder: (context) => ProductDetailView(selectedProduct: productList[index],)),
                  // );
                },
                // child: _userDataContainer(index),
                child: productDataView(index),
              );
            }),
      );
    }

    final titleAndFilter = Container(
      padding: EdgeInsets.only(top: 50, left: 20, right: 20),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text("You have ${productList.length} Products", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: categoryChipView,
          ),
          // categoryChipView,
        ],
      ),
    );


    Widget stackView() {
      return Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height - 300,
          ),
          Container(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: _productListView(),
          ),
          new Positioned(
            right: 0,
            bottom: 30,
            child: Container(
              child: YellowThemeButton(
                btnName: "Share",
                onPressed: () {

                  selectedProduct = productList.where((element) => element.isSelected).toList().map((e) => e.id.toString()).toList();
                  print(selectedProduct);

                  _addEditSubuser();



                  // if (_isValidate(context) == null){
                  //   _addEditCategory();
                  // }
                },
              ),
            ),
          )
        ],
      );
    }

    final mainContainer = Container(
      child: Column(
        children: [
          titleAndFilter,
          stackView(),
        ],
      ),
    );


    return Scaffold(
      appBar: AppBar(
        title: Text("My Products", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: AppColors.appBottleGreenColor,
        shadowColor: Colors.transparent,
      ),
      // drawer: navigationDrawer(),
      backgroundColor: AppColors.appBottleGreenColor,
      body: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40), topRight: Radius.circular(40))),
        child: mainContainer,
      ),
    );
  }

}
