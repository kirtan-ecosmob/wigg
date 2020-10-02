import 'dart:io';
import 'dart:math';

import 'package:date_format/date_format.dart';
import 'package:dotted_border/dotted_border.dart';
// import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_document_picker/flutter_document_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:network_to_file_image/network_to_file_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:toast/toast.dart';
import 'package:wigg/Groups/GroupModelView.dart';
import 'package:wigg/Groups/Model/group_model.dart';
import 'package:wigg/Products/Model/category_model.dart';
import 'package:wigg/Products/Model/product_details.dart';
import 'package:wigg/Products/Model/product_model.dart';
import 'package:wigg/Products/ProductModelView.dart';
import 'package:wigg/Utils/AppColors.dart';
import 'package:wigg/Utils/AppImages.dart';
import 'package:wigg/Utils/CommonFunctions.dart';
import 'package:wigg/Utils/OnFailure.dart';
import 'package:christian_picker_image/christian_picker_image.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;


class ProductTab{
  String _title = "";
  bool _isSelected = false;

  String get title => _title;
  bool get isSelectd => _isSelected;

  set isSelectd(bool value){
    this._isSelected = value;
  }
  set title(String value){
    this._title = value;
  }

  ProductTab({String title, bool isSelected}){
    _title = title;
    _isSelected = isSelected;
  }

}

class AddEditProductView extends StatefulWidget {
  static String name = '/AddEditProduct';

  bool isEditProduct;
  Product selectedProduct;

  AddEditProductView({this.isEditProduct = false, this.selectedProduct});


  @override
  _AddEditProductViewState createState() => _AddEditProductViewState();
}

class _AddEditProductViewState extends State<AddEditProductView> {
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();
  final List<int> _arrYear = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25];
  final List<int> _arrMonth = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11];
  // final List<String> _arrYear = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25 Years"];
  // final List<String> _arrMonth = ["0 month", "1 month", "2 months", "3 months", "4 months", "5 months", "6 months", "7 months", "8 months", "9 months", "10 months", "11 months"];

  ProductDetailsData _productDetail;
  bool isChangesInImages = false;
  bool isChangesInDoc = false;
  bool isChangesInBarcode = false;

  Position _currentPosition;
  String _currentLocationSring = "";//"Ahmedabad (21.0000, 72.45465)";//
  String _dateOfPurchase = "";
  String _expiryDate = "";
  String _viewTitle = "Add Product";

  List<ProductTab> _tabs = [];
  List<GroupData> groupList = [];
  GroupData selectedGroup;

  List<CategoryData> categoryList = [];
  CategoryData selectedCategory;



  String _warrentyDuration = "";
  int _selectedYear = 0;
  int _selectedMonth = 0;

  List<File> _productImages = [];
  List<File> _productDocs = [];
  List<String> _docNames = [];
  File _barCodeTextfile;
  String _scanString = "";

  QRViewController controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  TextEditingController txtProductName = TextEditingController();
  TextEditingController txtDesc = TextEditingController();
  TextEditingController txtBrand = TextEditingController();
  TextEditingController txtModel = TextEditingController();
  TextEditingController txtAddress = TextEditingController();
  TextEditingController txtStoreUrl = TextEditingController();
  TextEditingController txtPrice = TextEditingController();
  TextEditingController txtGroupName = TextEditingController();

  TextEditingController _textFieldController = TextEditingController();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _initTabs();

    postInit(() {
      _getGroupList();
      _getCategoryList();

      if (widget.isEditProduct){
        _getProductDetails();
      }else{
        _getCurrentLocation();
        _warrentyDuration = "$_selectedYear Years $_selectedMonth months";
      }

    });

    // if (widget.isEditProduct){
    //   _getProductDetails();
    // }else{
    //   _getCurrentLocation();
    //   _warrentyDuration = "$_selectedYear Years $_selectedMonth months";
    // }
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
              if (widget.isEditProduct){
                _setSelectedGroupAndCategory();
              }
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
          CommonFunction.redirectToLogin(context, e);
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

              if (widget.isEditProduct){
                _setSelectedGroupAndCategory();
              }
            }
            // if (widget.isEditProduct){
            //
            // }else{
            //   if (groupList.length > 0){
            //     selectedGroup = groupList.first;
            //   }
            // }
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


  _addEditProductAPI(){
      Dialogs.showLoadingDialog(context, _keyLoader);
      ProductModelView.instance.addEditProduct(
        productName: txtProductName.text.trim(),
        desc: txtDesc.text.trim(),
        price: txtPrice.text.trim(),
        group: selectedGroup,
        category: selectedCategory,
        latitude: _currentPosition == null ? "" : _currentPosition.latitude.toString(),
        longitude: _currentPosition == null ? "" : _currentPosition.longitude.toString(),
        warrantyDate: _expiryDate,
        purchaseDate: _dateOfPurchase,
        purchaseFrom: txtStoreUrl.text.trim(),
        productBrand: txtBrand.text.trim(),
        productModel: txtModel.text.trim(),
        productImages: _productImages,
        productDocs: _productDocs,
        docTitles: _docNames,
        barcodeFile: _barCodeTextfile,
        isEdit: widget.isEditProduct,
        product: widget.selectedProduct,
        isChangesInImages: isChangesInImages,
        isChangesInDoc: isChangesInDoc,
        isChangesInBarcode: isChangesInBarcode,
      ).then(
            (response) {
          Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
          // images = [];
          if (response.code == 200) {
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
          // images = [];
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

  // Future<File> imageFile(String filename) async {
  //   Directory dir = await getTemporaryDirectory();
  //   // String pathName = dir.path+"/"+filename;
  //   String pathName = p.join(dir.path, filename);
  //   _productImages.add(File(pathName));
  //   print("image File: ------------------ ${File(pathName)}");
  //   // return File(pathName);
  // }
  //
  // Future<Widget> imgUrlToFile(String strUrl) async {
  //   final url = Uri.parse(strUrl);
  //   print(url.pathSegments);
  //   final tempFile = await imageFile('${url.pathSegments.last}');
  //   NetworkToFileImage(
  //     url: strUrl,
  //     debug: true,
  //     file: tempFile,
  //   );
  // }

  _urlToFile({String imageUrl, String name, bool isDoc, bool isBarcode, bool isImg}) async {
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    File file = new File('$tempPath' + "/" + name);
    http.Response response = await http.get(imageUrl);
    await file.writeAsBytes(response.bodyBytes);

    setState(() {
      if (isDoc){
        _productDocs.add(file);
      }else if (isBarcode){
        _barCodeTextfile = file;
        _read();
      }else if (isImg){
        _productImages.add(file);
      }
      print("File: ------------------ $file");
    });
  }

  _setProductDetails(){
    txtProductName.text = _productDetail.name;
    txtDesc.text = _productDetail.description;
    txtBrand.text = _productDetail.productBrand;
    txtModel.text = _productDetail.productModel;
    txtStoreUrl.text = _productDetail.purchaseFrom;
    txtPrice.text = _productDetail.price;



    if (_productDetail.latitude != null || _productDetail.longitude != null){
      _currentPosition = Position(latitude: _productDetail.latitude, longitude: _productDetail.longitude);
      _currentLocationSring = "${_currentPosition.latitude.toStringAsFixed(4)}, ${_currentPosition.longitude.toStringAsFixed(4)}";
    }

    _dateOfPurchase = _productDetail.purchaseDate;

    _setSelectedGroupAndCategory();


    final date1 = new DateFormat("yyyy-MM-dd").parse(_productDetail.expireDate);
    final date2 = new DateFormat("yyyy-MM-dd").parse(_productDetail.purchaseDate);

    int year = date1.difference(date2).inDays ~/ 365;
    int month = (date1.difference(date2).inDays % 365) ~/ 30;

    _selectedYear = _arrYear[year];
    _selectedMonth = _arrMonth[month];
    _warrentyDuration = "$_selectedYear Years $_selectedMonth months";

    if (_productDetail.images.length > 0){
      _productDetail.images.forEach((element) async {
        print("image:--------- $element");
        // imgUrlToFile(element);

        print("Doc:--------- $element");
        final url = Uri.parse(element);
        print(url.pathSegments);
        // _urlToFile(element, url.pathSegments.last, true, false, false);
        _urlToFile(imageUrl: element, name: url.pathSegments.last, isDoc: false, isBarcode: false, isImg: true);

      });
    }



    if (_productDetail.documents.length > 0){
      _docNames = _productDetail.documentTitle;

      _productDetail.documents.forEach((element) async {
        print("Doc:--------- $element");
        final url = Uri.parse(element);
        print(url.pathSegments);
        // _urlToFile(element, url.pathSegments.last, true, false, false);
        _urlToFile(imageUrl: element, name: url.pathSegments.last, isDoc: true, isBarcode: false, isImg: false);
      });

    }

    if (_productDetail.barcodeFile != null && _productDetail.barcodeFile != ""){
      print("Barcode:--------- ${_productDetail.barcodeFile}");

      final url = Uri.parse(_productDetail.barcodeFile);
      print(url.pathSegments);
      // _urlToFile(_productDetail.barcodeFile, url.pathSegments.last, false, true, false);
      _urlToFile(imageUrl: _productDetail.barcodeFile, name: url.pathSegments.last, isDoc: false, isBarcode: true, isImg: false);
    }
  }

  _setSelectedGroupAndCategory(){

    if (categoryList.length > 0){
      selectedCategory = categoryList.where((element) => element.id == _productDetail.categoryId).toList().first;
    }

    if (groupList.length > 0){
      selectedGroup = groupList.where((element) => element.id == _productDetail.groupId).toList().first;
    }

  }

  _getCurrentLocation() async {
    Position position = await getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    _currentPosition = position;
    print("location $_currentPosition");
    final coordinates = new Coordinates(_currentPosition.latitude, _currentPosition.longitude);

    // print("location name ${await Geocoder.local.findAddressesFromCoordinates(coordinates)}");
    final addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
    final first = addresses.first;
    print("${first.featureName} : ${first.locality}");
    setState(() {
      // _currentLocationSring = "${first.locality}(${_currentPosition.latitude.toStringAsFixed(4)},${_currentPosition.longitude.toStringAsFixed(4)})";
      _currentLocationSring = "(${_currentPosition.latitude.toStringAsFixed(4)},${_currentPosition.longitude.toStringAsFixed(4)})";
    });

    // txtGPSLocation.text = "${first.locality}(${_currentPosition.latitude.toStringAsFixed(4)}, ${_currentPosition.longitude.toStringAsFixed(4)})";
  }

  _initTabs(){
    ProductTab details = ProductTab(title: "Details", isSelected: true);
    ProductTab doc = ProductTab(title: "Photo/Doc", isSelected: false);
    ProductTab barcode = ProductTab(title: "Scan Barcode", isSelected: false);
    _tabs = [details, doc, barcode];
  }

  _write(String text) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/${DateTime.now().millisecondsSinceEpoch}_barcode.txt');
    await file.writeAsString(text);
    setState(() {
      isChangesInBarcode = true;
      _barCodeTextfile = file;
      print('codefile path $_barCodeTextfile');
    });
  }

  _read() async {
    // String text = "";
    try {
      // final Directory directory = await getApplicationDocumentsDirectory();
      final File file = _barCodeTextfile;
      // text = await file.readAsString();
      _scanString = await file.readAsString();
    } catch (e) {
      print("Couldn't read file");
      _scanString = "";
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

  bool _isValidateProductDetails(BuildContext context) {
    if (txtProductName.text.trim().isEmpty) {
      Toast.show('Please enter product name', context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      return false;
    } else if (txtDesc.text.trim().isEmpty) {
      Toast.show('Please enter product description', context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      return false;
    } else if (txtBrand.text.trim().isEmpty) {
      Toast.show('Please enter brand name', context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      return false;
    } else if (txtModel.text.trim().isEmpty) {
      Toast.show('Please enter model', context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      return false;
    } else if (selectedCategory == null){
      Toast.show('Please select category', context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      return false;
    } else if (txtStoreUrl.text.trim().isEmpty) {
      Toast.show('Please enter store name or URL', context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      return false;
    } else if (txtPrice.text.trim().isEmpty) {
      Toast.show('Please enter price', context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      return false;
    } else if (selectedGroup == null){
      Toast.show('Please select group', context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      return false;
    } else if (_dateOfPurchase == ""){
      Toast.show('Please select date of purchase', context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      return false;
    }
  }

  purchasePickerDate(BuildContext context) {
    Picker(
        itemExtent: 50,
        hideHeader: true,
        adapter: DateTimePickerAdapter(maxValue: DateTime.now()),
        title: Text("Date Of Purchase"),
        selectedTextStyle: TextStyle(color: AppColors.appBottleGreenColor),
        onConfirm: (Picker picker, List value) {
          print((picker.adapter as DateTimePickerAdapter).value);
          print(formatDate((picker.adapter as DateTimePickerAdapter).value, [yyyy, '-', mm, '-', dd]));
          setState(() {
            _dateOfPurchase = formatDate((picker.adapter as DateTimePickerAdapter).value, [yyyy, '-', mm, '-', dd]);
          });
        }
    ).showDialog(context);
  }

  _selectedTabTitle(){
    if (_tabs[0].isSelectd){
      setState(() {
        _viewTitle = "Add Product";
      });
    } else if (_tabs[1].isSelectd){
      setState(() {
        _viewTitle = "Add Photo/Doc";
      });
    }  else if (_tabs[2].isSelectd){
      setState(() {
        _viewTitle = "Scan Barcode";
      });
    }
  }

  _onNextOrChipPressedhandle(BuildContext context){

    if (_tabs[0].isSelectd){
      this._tabs.forEach((element) {element.isSelectd = false;});
      this._tabs[1].isSelectd = true;
    } else if (_tabs[1].isSelectd){
      this._tabs.forEach((element) {element.isSelectd = false;});
      this._tabs[2].isSelectd = true;
    }  else if (_tabs[2].isSelectd){

      if (_isValidateProductDetails(context) == null){
        DateTime date = DateFormat("yyyy-MM-dd").parse(_dateOfPurchase);
        int totalDays = (_selectedYear * 365) + (_selectedMonth * 30);
        _expiryDate = formatDate(date.add(Duration(days: totalDays)), [yyyy, '-', mm, '-', dd]);
        print(_expiryDate);
        print("Done");
        _addEditProductAPI();
        // if (widget.isEditProduct){
        //   print("edit product");
        // }else{
        //   _addEditProductAPI();
        // }
      }else{
        print("error");
      }
    }
    _selectedTabTitle();
  }


  Future<File> testCompressAndGetFile(File file, String targetPath) async {
    var result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path, targetPath,
      quality: 50,
    );
    print(file.lengthSync());
    print(result.lengthSync());
    return result;
  }

  Future<Directory> getTemporaryDirectory() async {
    return Directory.systemTemp;
  }

  void takeImage(BuildContext context) async {
    print("takeImage");
    List<File> images  = await ChristianPickerImage.pickImages(maxImages: 5 - _productImages.length);
    print(images);
    setState(() {
      isChangesInImages = true;
      images.forEach((element) {_productImages.add(element);});
    });
    Navigator.of(context).pop();
    print("dissmiss11");
  }

  Future _pickImage(BuildContext context) async {

    //takeImage(context);
    var isPopup = false;

    showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) {
          if (!isPopup) {
            isPopup = true;
            takeImage(context);
          }
          return Center();
        });
  }


  // final _utiController = TextEditingController(
  //   text: 'com.sidlatau.example.mwfbak',
  // );
  //
  // final _mimeTypeController = TextEditingController(
  //   text: 'application/pdf',
  //   // image/png
  // );
  //
  // final _extensionController = TextEditingController(
  //   text: 'mwfbak',
  // );


  _displayDialog(BuildContext context, Function(String, bool) onPressed) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('File Title'),
            content: TextField(
              controller: _textFieldController,
              decoration: InputDecoration(hintText: "Enter file title"),
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text('CANCEL'),
                onPressed: () {
                  Navigator.of(context).pop();
                  onPressed("", false);
                  _textFieldController.text = "";
                },
              ),
              new FlatButton(
                child: new Text('SUBMIT'),
                onPressed: () {
                  if (_textFieldController.text.trim().isEmpty){
                    Toast.show('Please enter file title', context,
                        duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
                  }else{
                    Navigator.of(context).pop();
                    onPressed(_textFieldController.text, true);
                    _textFieldController.text = "";
                  }
                },
              ),
            ],
          );
        });
  }



  Future _picDocument(BuildContext context) async {
    String result;

    // FlutterDocumentPickerParams params = FlutterDocumentPickerParams(
    //   allowedFileExtensions: _extensionController.text
    //       .split(' ')
    //       .where((x) => x.isNotEmpty)
    //       .toList(),
    //   allowedUtiTypes:
    //   _utiController.text.split(' ').where((x) => x.isNotEmpty).toList(),
    //   allowedMimeTypes: _mimeTypeController.text
    //       .split(' ')
    //       .where((x) => x.isNotEmpty)
    //       .toList(),
    // );

    FlutterDocumentPickerParams params = FlutterDocumentPickerParams(
      // allowedFileExtensions: ['mwfbak'],
      // allowedUtiTypes: ['com.sidlatau.example.mwfbak'],
      // allowedMimeTypes: ['application/*'],
      allowedMimeTypes: ['application/pdf', 'application/msword'],
      invalidFileNameSymbols: ['/'],
    );

    result = await FlutterDocumentPicker.openDocument(params: params);

    if(result != null) {
      setState(() {
        _displayDialog(context, (value, isSubmit) {
          if (isSubmit){
            print(result);
            isChangesInDoc = true;
            _productDocs.add(File(result));
            _docNames.add(value);
          }else{
            print("cancel");
          }
        });

      });
    }

  }


  //TODO:- build
  @override
  Widget build(BuildContext context) {

    Widget bottomButton() {
      return Row(
        mainAxisAlignment: (MainAxisAlignment.spaceBetween),
        children: [
          Container(),
          YellowThemeButton(
            btnName: "Next",
            onPressed: () {
              _onNextOrChipPressedhandle(context);
            },
          )
        ],
      );
    }


    //TODO: Details

    Widget categoryDropDown() {
      if (selectedCategory == null) {
        return GestureDetector(
          onTap: () {
            print("please add category");
            showAlertDialog(context, "Category", "Please add category first.");
          },
          child: Container(
            padding: EdgeInsets.only(right: 20, left: 20),
            height: 55,
            // width: MediaQuery.of(context).size.width,
            // color: Colors.blue,
            child: Stack(
              children: [
                Container(width: MediaQuery.of(context).size.width,child: Text("Category", style: TextStyle(fontSize: 16, color: Colors.grey[500]),),),
                Positioned(
                  bottom: 15,
                  child: Container(
                    height: 1,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.grey,
                  ),
                ),
                // SizedBox(height: 5,)
              ],
            ),

          ),
        );
      } else {
        return Container(
          // color: Colors.blue,
          padding: EdgeInsets.only(right: 20, left: 20),
          child: new DropdownButton<CategoryData>(
              value: this.selectedCategory == null ? "" : this.selectedCategory,
              style: TextStyle(fontSize: 18, color: AppColors.appBlueColor),
              isExpanded: true,
              underline: Container(
                height: 1,
                color: Colors.grey,
              ),
              // selectedItemBuilder: (BuildContext context) {
              //   return categoryList.map<Widget>((CategoryData item) {
              //     return Text(item == null ? "" : item.name);
              //   }).toList();
              // },
              items: categoryList.map((CategoryData e) {
                return new DropdownMenuItem<CategoryData>(
                  value: e,
                  // child: e.nameAndAddress(),
                  child: Text(e.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                });
              }),
        );
      }
    }

    Widget groupDropDown() {
      if (selectedGroup == null) {
        return GestureDetector(
          onTap: () {
            print("please add group");
            showAlertDialog(context, "Group Name", "Please add group first.");
            },
          child: Container(
            padding: EdgeInsets.only(right: 20, left: 20),
            height: 55,
            // width: MediaQuery.of(context).size.width,
            // color: Colors.blue,
            child: Stack(
              children: [
                Container(width: MediaQuery.of(context).size.width,child: Text("Group Name", style: TextStyle(fontSize: 16, color: Colors.grey[500]),),),
                Positioned(
                  bottom: 15,
                  child: Container(
                    height: 1,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.grey,
                  ),
                ),
                // SizedBox(height: 5,)
              ],
            ),

          ),
        );
      } else {
        return Container(
          // color: Colors.blue,
          padding: EdgeInsets.only(right: 20, left: 20),
          child: new DropdownButton<GroupData>(
              value: this.selectedGroup == null ? "" : this.selectedGroup,
              style: TextStyle(fontSize: 18, color: AppColors.appBlueColor),
              isExpanded: true,
              underline: Container(
                height: 1,
                color: Colors.grey,
              ),
              selectedItemBuilder: (BuildContext context) {
                return groupList.map<Widget>((GroupData item) {
                  return Text(item == null ? "" : item.name);
                }).toList();
              },
              items: groupList.map((GroupData e) {
                return new DropdownMenuItem<GroupData>(
                  value: e,
                  child: e.nameAndAddress(),
                  // child: Text(e.name),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedGroup = value;
                });
              }),
        );
      }
    }

    Widget locationContainer(){
      return Container(
        padding: EdgeInsets.only(right: 20, left: 20),
        // height: 55,
        // color: Colors.orange,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: (MainAxisAlignment.spaceBetween),
              children: [
                Container(
                  // height: 150,
                  child: Expanded(
                    child: Text(
                      _currentLocationSring == "" ? "GPS Location" : _currentLocationSring,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: TextStyle(
                        fontSize: 17,
                        color: _currentLocationSring == "" ? Colors.grey : AppColors.appBlueColor,
                      ),
                    ),
                  ),

                ),
                Container(
                  width: 35,
                  child: IconButton(
                      icon: Image.asset(AppImages.ic_current_location),
                      onPressed: () {
                        print("select location");
                        _getCurrentLocation();
                        // _openAlertDialogForSelection(context);
                        // loadAssets();
                      }),
                ),
              ],
            ),
            Container(
              height: 1,
              width: MediaQuery.of(context).size.width,
              color: Colors.grey,
            ),
          ],
        ),
      );
    }

    Widget dateOfPurchase(){
      return GestureDetector(
        onTap: () {
          print("open date picker");
          purchasePickerDate(context);
        },
        child: Container(
          padding: EdgeInsets.only(right: 20, left: 20),
          // height: 55,
          // color: Colors.blue,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: (MainAxisAlignment.spaceBetween),
                children: [
                  Container(
                    // height: 55,
                    child: Expanded(
                      child: Text(
                        _dateOfPurchase == "" ? "Date of Purchase" : _dateOfPurchase,
                        // overflow: TextOverflow.ellipsis,
                        // maxLines: 2,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 17,
                          color: _dateOfPurchase == "" ? Colors.grey : AppColors.appBlueColor,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    // padding: EdgeInsets.only(right: 10, bottom: 10),
                    // height: 25,
                    width: 35,
                    // child:  Image.asset(AppImages.ic_calendar),
                    child: IconButton(
                        icon: Image.asset(AppImages.ic_calendar),
                        onPressed: () {}),
                  ),
                ],
              ),
              Container(
                height: 1,
                width: MediaQuery.of(context).size.width,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      );
    }

    Widget durationOfWarranty(){
      return Container(
        padding: EdgeInsets.only(right: 20, left: 20),
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
        padding: EdgeInsets.only(right: 20, left: 20),
        height: 55,
        // color: Colors.pink,
        child: Row(
          mainAxisAlignment: (MainAxisAlignment.spaceBetween),
          children: [
           Container(
             width: (MediaQuery.of(context).size.width / 2) - 30,
             // color: Colors.blue,
             child: new DropdownButton(
                 value: _selectedYear.toString(),
                 style: TextStyle(fontSize: 16, color: AppColors.appBlueColor),
                 isExpanded: true,
                 underline: Container(
                   height: 1,
                   color: Colors.grey,
                 ),
                 selectedItemBuilder: (BuildContext context) {
                   return _arrYear.map<Widget>((int item) {
                     return Align(alignment: Alignment.centerLeft, child: Text('$item' + " years"),);
                   }).toList();
                 },
                 items: _arrYear.map((int e) {
                   return new DropdownMenuItem<String>(
                     value: e.toString(),
                     child: new Text('$e'),
                     // child: Text(e.name),
                   );
                 }).toList(),
                 onChanged: (value) {
                   setState(() {
                     _selectedYear = int.parse(value);
                     _warrentyDuration = "$_selectedYear Years $_selectedMonth months";
                   });
                 }),
           ),
            Container(
              width: (MediaQuery.of(context).size.width / 2) - 30,
              // color: Colors.blue,
              child:  DropdownButton<String>(
                value: _selectedMonth.toString(),
                style: TextStyle(fontSize: 16, color: AppColors.appBlueColor),
                underline: Container(
                  height: 1,
                  color: Colors.grey,
                ),
                isExpanded: true,
                selectedItemBuilder: (BuildContext context) {
                  return _arrMonth.map<Widget>((int item) {
                    return Align(alignment: Alignment.centerLeft, child: Text('$item' + " months"),);
                  }).toList();
                },
                items: _arrMonth.map((int value) {
                  return new DropdownMenuItem<String>(
                    value: value.toString(),
                    child: new Text('$value'),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedMonth = int.parse(value);
                    _warrentyDuration = "$_selectedYear Years $_selectedMonth months";
                  });
                },
              ),
            ),
          ],
        ),
      );
    }

    final detailContainer = Container(
      child: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Container(
          // height: 500,
          // color: Colors.blue,
          child: Column(
            children: [
              CommonFunction.customTextfield("Product Name", txtProductName, TextInputType.text, context),
              CommonFunction.customTextfield("Product Description", txtDesc, TextInputType.text, context),
              CommonFunction.customTextfield("Brand", txtBrand, TextInputType.text, context),
              CommonFunction.customTextfield("Model", txtModel, TextInputType.text, context),
              categoryDropDown(),
              SizedBox(height: 12,),
              CommonFunction.customTextfield("Store or URL", txtStoreUrl, TextInputType.text, context),
              CommonFunction.customTextfield("Price", txtPrice, TextInputType.numberWithOptions(decimal: true), context, maxLength: 8),
              groupDropDown(),
              locationContainer(),
              SizedBox(height: 8,),
              dateOfPurchase(),
              SizedBox(height: 8,),
              durationOfWarranty(),
              SizedBox(height: 8,),
              selectyearMonth(),
              SizedBox(height: 30,),
              bottomButton(),
              SizedBox(height: 30,),
            ],
          ),
        ),
      ),
    );



    //TODO: Photos/Doc


    Widget mediaAttachContainer(bool isImage, String img, String title) {
      return GestureDetector(
        onTap: () {
          if (isImage) {
            if (_productImages.length >= 5){
             showAlertDialog(context, "Max limit", "You can select max 5 images.");
            }else{
              _pickImage(context);
            }
          } else {
            print("pic document");
            if (_productDocs.length >= 5){
              showAlertDialog(context, "Max limit", "You can select max 5 documents.");
            }else{
              _picDocument(context);
            }
          }
        },
        child: DottedBorder(
          dashPattern: [4, 4],
          borderType: BorderType.RRect,
          radius: Radius.circular(10),
          padding: EdgeInsets.all(5),
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            child: Container(
              height: 120,
              width: 120,
              // color: Colors.amber,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(img),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    title,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    Widget imageContainer(int index){
      return Container(
        padding: EdgeInsets.only(left: 10),
        child: DottedBorder(
          dashPattern: [4, 4],
          borderType: BorderType.RRect,
          radius: Radius.circular(10),
          padding: EdgeInsets.all(5),
          child: Stack(
            overflow: Overflow.visible,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                child: Container(
                  height: 120,
                  width: 120,
                  child: Image.file(
                    _productImages[index],
                    fit: BoxFit.fill,
                  ),
                  // color: Colors.amber,
                ),
              ),
              Positioned(
                top: -10,
                right: -10,
                child: Container(
                  height: 40,
                  width: 40,
                  // color: Colors.black,
                  child: IconButton(
                      icon: Image.asset(AppImages.ic_close),
                      onPressed: () {
                        setState(() {
                          CommonFunction.showAlertDialog(context, "Remove Image", "Are you sure you want to remove this image?", (isOk) {
                            if (isOk){
                              setState(() {
                                isChangesInImages = true;
                                _productImages.removeAt(index);
                              });
                            }
                          });
                        });
                        // loadAssets();
                      }),
                ),
              ),
            ],
          ),
        ),
      );
    }
    

    Widget titleContainer(String title){
      return Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: EdgeInsets.only(left: 20, right: 20),
          child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),),
        ),
      );
    }


    Widget imagesListView() {
      return Container(
        padding: EdgeInsets.only(left: 10, right: 10),
        height: 130,
        child: ListView.builder(
            itemCount: _productImages.length + 1,
            // shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return mediaAttachContainer(true, AppImages.ic_camera_grey, "Add Image");
              } else {
                return imageContainer(index - 1);
              }
            }),
      );
    }

    Widget docContainer(int index) {
      return Container(
        padding: EdgeInsets.only(left: 10),
        child: GestureDetector(
          child: DottedBorder(
            dashPattern: [4, 4],
            borderType: BorderType.RRect,
            radius: Radius.circular(10),
            padding: EdgeInsets.all(5),
            child: Stack(
              overflow: Overflow.visible,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  child: Container(
                    height: 120,
                    width: 120,
                    // color: Colors.amber,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(AppImages.ic_document),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          _docNames[index],
                          style:
                              TextStyle(color: AppColors.appBottleGreenColor),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: -10,
                  right: -10,
                  child: Container(
                    height: 40,
                    width: 40,
                    // color: Colors.black,
                    child: IconButton(
                        icon: Image.asset(AppImages.ic_close),
                        onPressed: () {
                          CommonFunction.showAlertDialog(context, "Remove Doc",
                              "Are you sure you want to remove this doc?",
                              (isOk) {
                            if (isOk) {
                              setState(() {
                                isChangesInDoc = true;
                                _docNames.removeAt(index);
                                _productDocs.removeAt(index);
                              });
                            }
                          });
                          // loadAssets();
                        }),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget docsListView() {
      return Container(
        padding: EdgeInsets.only(left: 10, right: 10),
        height: 130,
        child: ListView.builder(
            itemCount: _productDocs.length + 1,
            // shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return mediaAttachContainer(false, AppImages.ic_add_file, "Open Files");
              } else {
                return docContainer(index - 1);
              }
            }),
      );
    }

    final photoDocContainer = Container(
      child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
        child: Container(
        // height: 500,
        // color: Colors.blue,
          child: Column(
            children: [
              titleContainer("Images"),
              SizedBox(height: 10,),
              imagesListView(),
              SizedBox(height: 20,),
              titleContainer("Docs"),
              SizedBox(height: 10,),
              docsListView(),
              // SizedBox(height: 5,),
              // Align(
              //   alignment: Alignment.centerLeft,
              //   child: Container(
              //     padding: EdgeInsets.only(left: 20, right: 20),
              //     child:  Text("Note: Long press to remove document."),
              //   ),
              // ),
              SizedBox(height: 30,),
              bottomButton(),
              SizedBox(height: 30,),
            ],
          ),
      ),
      ),
    );



    //TODO: Scan Barcode

    Widget barcodeContainer = Container(
      // color: Colors.pink,
      padding: EdgeInsets.only(left: 20, right: 20),
      height: MediaQuery.of(context).size.height - 400,
      child: DottedBorder(
        dashPattern: [4, 4],
        borderType: BorderType.RRect,
        radius: Radius.circular(10),
        padding: EdgeInsets.all(5),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          child: Container(
            // color: Colors.amber,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.red,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 300,
              ),
            ),
          ),
        ),
      ),
    );


    Widget scanDataContainer = Container(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: DottedBorder(
        dashPattern: [4, 4],
        borderType: BorderType.RRect,
        radius: Radius.circular(10),
        padding: EdgeInsets.all(5),
        child: Container(
          // height: 55,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child:  _barCodeTextfile == null ? Text("") : Text(_scanString),
                ),
              ),

              Container(
                height: 40,
                width: 40,
                // color: Colors.black,
                child: IconButton(
                    icon: Image.asset(AppImages.ic_close),
                    onPressed: () {
                      CommonFunction.showAlertDialog(context, "Remove Barcode",
                          "Are you sure you want to remove this barcode?",
                              (isOk) {
                            if (isOk) {
                              setState(() {
                                isChangesInBarcode = true;
                                _barCodeTextfile = null;
                                _scanString = "";
                                // controller.resumeCamera();
                              });
                            }
                          });
                      // loadAssets();
                    }),
              ),
            ],
          ),
        ),
      ),
    );


    final scanBarcodeContainer = Container(
      // color: Colors.orange,
      child: Column(
        children: [
          _barCodeTextfile == null ? barcodeContainer : scanDataContainer,
          SizedBox(height: 20,),
          bottomButton()
        ],
      ),
    );




    final categoryChipView = Wrap(
      children: List<Widget>.generate(
        this._tabs.length,
            (int index) {
          return Container(
            padding: EdgeInsets.only(right: 10),
            child: ChoiceChip(
              // disabledColor: Colors.blueGrey,//Color(0xffF4F0F0),
              padding: EdgeInsets.only(top: 8, bottom: 10),
              backgroundColor: Colors.grey[100],
              selectedColor: AppColors.appBottleGreenColor,
              label: Text("${_tabs[index].title}", style: TextStyle(color: _tabs[index].isSelectd ? Colors.white : AppColors.appLightGrayColor, fontSize: 14),),
              selected: this._tabs[index].isSelectd,
              onSelected: (bool selected) {
                setState(() {
                  this._tabs.forEach((element) {element.isSelectd = false;});
                  this._tabs[index].isSelectd = true;
                  _selectedTabTitle();
                  // _onNextOrChipPressedhandle(context);
                });
              },
            ),
          );
        },
      ).toList(),
    );

    final titleAndFilter = Container(
      padding: EdgeInsets.only(top: 50, left: 20, right: 20),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(widget.isEditProduct ? "Edit Product" : _viewTitle, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
          ),
          SizedBox(height: 10,),
          Align(
            alignment: Alignment.centerLeft,
            child: categoryChipView,
          ),
          // categoryChipView,
        ],
      ),
    );


    Container dataContainer(){
      if (_tabs[0].isSelectd){
        return detailContainer;
      } else if (_tabs[1].isSelectd){
        return photoDocContainer;
      }  else if (_tabs[2].isSelectd){
        return scanBarcodeContainer;
      }
    }

    final mainContainer = Container(
      // color: Colors.pink,
      // height: MediaQuery.of(context).size.height - 100,
      // padding: EdgeInsets.only(top: 50, left: 20, right: 20),
      // color: Colors.black,
      child: Column(
        children: [
          titleAndFilter,
          SizedBox(height: 30,),
          Expanded(// wrap in Expanded
            child: Container(
              padding: EdgeInsets.only(bottom: 20),
              child: dataContainer(),
            ),
          ),
        ],
      ),
    );



    return Scaffold(
      // resizeToAvoidBottomPadding: false,
      backgroundColor: AppColors.appBottleGreenColor,
      appBar: AppBar(
        title: Text(
          widget.isEditProduct ? "Edit Product" : "Add Product",
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
          child: mainContainer,
        ),
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        controller.pauseCamera();
        _scanString = scanData;
        print('scan data $_scanString');
      });

      _write(scanData);
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

}
