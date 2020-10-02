import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:toast/toast.dart';
import 'package:wigg/Groups/GroupModelView.dart';
import 'package:wigg/Groups/Model/group_model.dart';
import 'package:wigg/Utils/AppColors.dart';
import 'package:wigg/Utils/AppImages.dart';
import 'package:wigg/Utils/CommonFunctions.dart';
import 'package:wigg/Utils/OnFailure.dart';

import 'Model/category_model.dart';
import 'Model/product_details.dart';
import 'Model/product_model.dart';
import 'ProductModelView.dart';

class ProductDetailView extends StatefulWidget {
  static String name = '/ProductDetail';

  Product selectedProduct;
  ProductDetailView({this.selectedProduct});

  @override
  _ProductDetailViewState createState() => _ProductDetailViewState();
}

class _ProductDetailViewState extends State<ProductDetailView> {
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  final List<int> _arrYear = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25];
  final List<int> _arrMonth = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];

  List<GroupData> groupList = [];
  GroupData selectedGroup;

  List<CategoryData> categoryList = [];
  CategoryData selectedCategory;

  ProductDetailsData _productDetail;
  int _selectedYear = 0;
  int _selectedMonth = 0;
  String _warrentyDuration = "";


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    postInit(() {
      _getGroupList();
      _getCategoryList();
    });
    _getProductDetails();

    _warrentyDuration = "$_selectedYear Years $_selectedMonth months";
  }

  // TODO: API calling

  _getProductDetails() {
    ProductModelView.instance
        .getProductDetails(widget.selectedProduct.id.toString())
        .then(
          (response) {
        if (response.code == 200) {
          setState(() {
            this._productDetail = response.data;
            _setProductDetails();
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

  _getCategoryList(){
    ProductModelView.instance.getCategoryList().then(
          (response) {
        // Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
        if (response.code == 200) {
          setState(() {
            categoryList = response.catData;
            if (categoryList.length > 0){
              selectedCategory = categoryList.first;
              _setSelectedGroupAndCategory();
            }
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

  _getGroupList(){
    Dialogs.showLoadingDialog(context, _keyLoader);
    GroupModelView.instance.getGroupList().then(
          (response) {
        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
        if (response.code == 200) {
          setState(() {
            this.groupList = response.groupData;
            if (groupList.length > 0){
              selectedGroup = groupList.first;
              _setSelectedGroupAndCategory();
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




  // TODO:Custom Functions



  _setProductDetails(){
    // txtProductName.text = _productDetail.name;
    // txtDesc.text = _productDetail.description;
    // txtBrand.text = _productDetail.productBrand;
    // txtModel.text = _productDetail.productModel;
    // txtStoreUrl.text = _productDetail.purchaseFrom;
    // txtPrice.text = _productDetail.price;
    //
    //
    //
    // if (_productDetail.latitude != null || _productDetail.longitude != null){
    //   _currentPosition = Position(latitude: _productDetail.latitude, longitude: _productDetail.longitude);
    //   _currentLocationSring = "${_currentPosition.latitude.toStringAsFixed(4)}, ${_currentPosition.longitude.toStringAsFixed(4)}";
    // }
    //
    // _dateOfPurchase = _productDetail.purchaseDate;
    //
    // _setSelectedGroupAndCategory();
    //
    //
    final date1 = new DateFormat("yyyy-MM-dd").parse(_productDetail.expireDate);
    final date2 = new DateFormat("yyyy-MM-dd").parse(_productDetail.purchaseDate);

    int year = date1.difference(date2).inDays ~/ 365;
    int month = (date1.difference(date2).inDays % 365) ~/ 30;

    _selectedYear = _arrYear[year];
    _selectedMonth = _arrMonth[month];
    _warrentyDuration = "$_selectedYear Years $_selectedMonth months";
    //
    // if (_productDetail.images.length > 0){
    //   _productDetail.images.forEach((element) async {
    //     print("image:--------- $element");
    //     imgUrlToFile(element);
    //   });
    // }
    //
    //
    //
    // if (_productDetail.documents.length > 0){
    //   _docNames = _productDetail.documentTitle;
    //
    //   _productDetail.documents.forEach((element) async {
    //     print("Doc:--------- $element");
    //     final url = Uri.parse(element);
    //     print(url.pathSegments);
    //     _urlToFile(element, url.pathSegments.last, true, false);
    //   });
    // }
    //
    // if (_productDetail.barcodeFile != null && _productDetail.barcodeFile != ""){
    //   print("Barcode:--------- ${_productDetail.barcodeFile}");
    //
    //   final url = Uri.parse(_productDetail.barcodeFile);
    //   print(url.pathSegments);
    //   _urlToFile(_productDetail.barcodeFile, url.pathSegments.last, false, true);
    // }
  }

  _setSelectedGroupAndCategory(){

    if (categoryList.length > 0){
      selectedCategory = categoryList.where((element) => element.id == _productDetail.categoryId).toList().first;
    }

    if (groupList.length > 0){
      selectedGroup = groupList.where((element) => element.id == _productDetail.groupId).toList().first;
    }

  }




  @override
  Widget build(BuildContext context) {


    Color getColorFromExpiry(ProductDetailsData product){
      final expiryDate = product != null ? new DateFormat("yyyy-MM-dd").parse(product.expireDate) : DateTime.now();
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

    double getPercentageBetweenTwoDate(ProductDetailsData product){
      final purchaseDate = product != null ? new DateFormat("yyyy-MM-dd").parse(product.purchaseDate) : new DateFormat("yyyy-MM-dd").parse(widget.selectedProduct.purchaseDate);
      final expiryDate =  product != null ? new DateFormat("yyyy-MM-dd").parse(product.expireDate) : new DateFormat("yyyy-MM-dd").parse(widget.selectedProduct.expiryDate);
      final currentDate = DateTime.now();
      int totalDays = expiryDate.difference(purchaseDate).inDays;
      int fromTodayRemainDays = expiryDate.difference(currentDate).inDays;
      // return (fromTodayRemainDays)/totalDays;
      if (fromTodayRemainDays/totalDays > 0){
        return (fromTodayRemainDays)/totalDays;
      }else{
        return 0;
      }
    }

    final linerView = LinearPercentIndicator(
      // width: MediaQuery.of(context).size.width - 80,
      lineHeight: 5.0,
      percent: _productDetail != null ? getPercentageBetweenTwoDate(this._productDetail) : 0.0,
      progressColor: getColorFromExpiry(this._productDetail),
    );


    Container detailContainer(String data, String placeholder){
      return Container(
        // height: 50,
        // width: MediaQuery.of(context).size.width - 40,
        child: Stack(
          overflow: Overflow.visible,
          children: [
            Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    child: Text(placeholder,
                      style: TextStyle(fontSize: 12)
                      ,),
                  ),
                ),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    child: Text(data == null ? "" : data,
                      style: TextStyle(fontSize: 16,
                        color: data == null ? Colors.grey[500] : AppColors.appBottleGreenColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: -8,
              child: Container(
                height: 1,
                width: MediaQuery.of(context).size.width - 40,
                color: Colors.grey,
              ),
            ),
            // SizedBox(height: 5,)
          ],
        ),
      );
    }

    Widget durationOfWarranty(){
      return Container(
        // padding: EdgeInsets.only(right: 20, left: 20),
        // height: 55,
        // color: Colors.pink,
        child: Row(
          mainAxisAlignment: (MainAxisAlignment.spaceBetween),
          children: [
            Text("Duration of Warranty", style: TextStyle(fontSize: 14, color: Colors.grey),),
            Expanded(
              child: Text(
                _warrentyDuration,
                textAlign: TextAlign.end,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.appBottleGreenColor,
                ),),
            ),
          ],
        ),
      );
    }

    Widget selectyearMonth() {
      return Container(
        height: 55,
        child: Row(
          mainAxisAlignment: (MainAxisAlignment.spaceBetween),
          children: [
            Container(
              child: Column(
                children: [
                  Text("$_selectedYear years", style: TextStyle(color: AppColors.appBottleGreenColor, fontSize: 16),),
                  SizedBox(height: 8,),
                  Container(
                    height: 1,
                    width: MediaQuery.of(context).size.width / 2 - 40,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
            Container(
              child: Column(
                children: [
                  Text("$_selectedMonth months", style: TextStyle(color: AppColors.appBottleGreenColor, fontSize: 16),),
                  SizedBox(height: 8,),
                  Container(
                    height: 1,
                    width: MediaQuery.of(context).size.width / 2 - 40,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    Widget titleContainer(String title){
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          // padding: EdgeInsets.only(left: 20, right: 20),
          child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),),
        ),
      );
    }


    //TODO:- Images
    Widget imgContainer(String img){
      return Container(
        padding: EdgeInsets.only(right: 8),
        // height: 60,
        width: 88,
        // color: Colors.blue,
        child: ClipRRect(
          // borderRadius: BorderRadius.circular(30),
          child: Image.network(
            img,
            fit: BoxFit.cover,
          ),
        ),
      );
    }

    Widget imgListView() {
      if (_productDetail == null || _productDetail.images.length == 0) {
        return Container(
          height: 0,
        );
      } else {
        return Container(
          height: 80,
          child: ListView.builder(
              itemCount: _productDetail.images.length,
              // shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              itemBuilder: (BuildContext context, int index) {
                return imgContainer(_productDetail.images[index]);
              }),
        );
      }
    }


    //TODO:- Documents

    Widget docContainer(String doc) {
      return Container(
        padding: EdgeInsets.only(bottom: 8),
        height: 50,
        child: DottedBorder(
          dashPattern: [4, 4],
          borderType: BorderType.RRect,
          radius: Radius.circular(10),
          padding: EdgeInsets.all(5),
          child: Container(
            // height: 60,
            padding: EdgeInsets.only(left: 10),
            child: Align(alignment: Alignment.centerLeft, child: Text(doc, style: TextStyle(fontSize: 16),),),
          ),
        ),
      );
    }

    Widget docListView() {
      if (_productDetail == null || _productDetail.documents.length == 0) {
        return Container(
          height: 0,
        );
      } else {
        return GestureDetector(
          onTap: () {},
          child: Container(
            height: _productDetail.documents.length * 50.0,
            child: ListView.builder(
                itemCount: _productDetail.documents.length,
                physics: NeverScrollableScrollPhysics(),
                // scrollDirection: Axis.vertical,
                itemBuilder: (BuildContext context, int index) {
                  return docContainer(_productDetail.documentTitle[index]);
                }),
          ),
        );
        // return Expanded(
        //
        // );
      }
    }


    //TODO:- Purchase Added By

    final userProfilePlaceHolder = CircleAvatar(
      backgroundColor: Colors.transparent,
      backgroundImage: AssetImage(AppImages.user_placeholder),
      radius: 20,
    );

    Widget purchaseAddedBy(){
      return Container(
        height: 70,
        decoration: BoxDecoration(
            color: Color(0xffF4F0F0),
            borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            SizedBox(width: 20,),
            // userProfilePlaceHolder,
            // SizedBox(width: 20,),
            Text(_productDetail == null ? "" : _productDetail.purchaseAddedBy, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
          ],
        ),
      );
    }



    final mainContainer = SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(height: 20,),
            _productDetail != null ? linerView : Container(),
            SizedBox(height: 4,),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                CommonFunction.remainYearsMonthDayFromDate(widget.selectedProduct.expiryDate, "MM-dd-yyyy"),
                style: TextStyle(fontSize: 12, color: AppColors.appLightGrayColor),
              ),
            ),
            SizedBox(height: 20,),
            detailContainer(_productDetail == null ? "" : _productDetail.name, "Product Name"),
            SizedBox(height: 20,),
            detailContainer(_productDetail == null ? "" : _productDetail.description, "Product Description"),
            SizedBox(height: 20,),
            detailContainer(_productDetail == null ? "" : _productDetail.productBrand, "Brand"),
            SizedBox(height: 20,),
            detailContainer(_productDetail == null ? "" : _productDetail.productModel, "Model"),
            SizedBox(height: 20,),
            detailContainer(selectedCategory == null ? "" : selectedCategory.name, "Category"),
            SizedBox(height: 20,),
            detailContainer(_productDetail == null ? "" : _productDetail.purchaseFrom, "Store or URL"),
            SizedBox(height: 20,),
            detailContainer(_productDetail == null ? "" : _productDetail.price, "Price"),
            SizedBox(height: 20,),
            detailContainer(selectedGroup == null ? "" : selectedGroup.name, "Group Name"),
            SizedBox(height: 20,),
            detailContainer(_productDetail == null ? "" : "${_productDetail.latitude}, ${_productDetail.longitude}", "GPS Location"),
            SizedBox(height: 20,),
            detailContainer(_productDetail == null ? "" : _productDetail.purchaseDate, "Date of Purchase"),
            SizedBox(height: 20,),
            durationOfWarranty(),
            SizedBox(height: 10,),
            selectyearMonth(),
            titleContainer("Images"),
            SizedBox(height: 10,),
            imgListView(),
            SizedBox(height: 10,),
            titleContainer("Docs"),
            SizedBox(height: 10,),
            docListView(),
            SizedBox(height: 20,),
            purchaseAddedBy(),
            SizedBox(height: 20,),
          ],
        ),
      ),
    );


    return Scaffold(
      // resizeToAvoidBottomPadding: false,
      backgroundColor: AppColors.appBottleGreenColor,
      appBar: AppBar(
        title: Text(
          widget.selectedProduct.name,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        shadowColor: Colors.transparent,
        backgroundColor: AppColors.appBottleGreenColor,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40), topRight: Radius.circular(40))),
        child: _productDetail != null ? mainContainer : Container(),
      ),
    );
  }
}
