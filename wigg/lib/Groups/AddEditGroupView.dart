import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'package:wigg/Groups/GroupModelView.dart';
import 'package:wigg/Groups/Model/group_model.dart';
import 'package:wigg/Utils/AppColors.dart';
import 'package:wigg/Utils/CommonFunctions.dart';
import 'package:wigg/Utils/OnFailure.dart';


class AddEditGroupView extends StatefulWidget {

  static String name = '/AddEditGroup';

  bool isEditGroup;
  GroupData selectedGroup;

  AddEditGroupView({this.isEditGroup = false, this.selectedGroup});

  @override
  _AddEditGroupViewState createState() => _AddEditGroupViewState();
}

class _AddEditGroupViewState extends State<AddEditGroupView> {
  final GlobalKey<State> _keyLoader = new GlobalKey<State>();

  List<String> _addressTypes = ["commercial", "non-commercial"];
  String _selectedAddressType = "";

  TextEditingController txtAddressName = TextEditingController();
  TextEditingController txtAddressLine1 = TextEditingController();
  TextEditingController txtAddressLine2 = TextEditingController();
  TextEditingController txtAddressLine3 = TextEditingController();

  // TODO: implement initState
  @override
  void initState() {
    super.initState();
    _selectedAddressType = _addressTypes[0];

    // txtAddressName.text = "ios Test";
    // txtAddressLine1.text = "adddress";

    if (widget.isEditGroup){
      txtAddressName.text = widget.selectedGroup.name;
      txtAddressLine1.text = widget.selectedGroup.address;
      _selectedAddressType = widget.selectedGroup.type;
    }

  }


  // TODO: API calling

  _addEditGroup(){
    Dialogs.showLoadingDialog(context, _keyLoader);

    String addressLine = "";
    addressLine = txtAddressLine1.text.trim();
    // if (txtAddressLine2.text.trim().isNotEmpty){
    //   addressLine = addressLine + ", " + txtAddressLine2.text.trim();
    // }
    // if (txtAddressLine3.text.trim().isNotEmpty){
    //   addressLine = addressLine + ", " + txtAddressLine3.text.trim();
    // }

    GroupModelView.instance.addEditGroup(addressName: txtAddressName.text.trim(), type: _selectedAddressType, address: addressLine, isEdit: widget.isEditGroup, group: widget.selectedGroup).then(
          (response) {
        Navigator.of(_keyLoader.currentContext, rootNavigator: true).pop();
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

  bool _isValidate(BuildContext context) {
    if (txtAddressName.text.trim().isEmpty) {
      Toast.show('Please enter address name', context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      return false;
    } else if (txtAddressLine1.text.trim().isEmpty) {
      Toast.show('Please enter address', context,
          duration: Toast.LENGTH_SHORT, gravity: Toast.BOTTOM);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {


    Widget addressTypeDropDown() {
      return Container(
        padding: EdgeInsets.only(left: 20, right: 20),
        height: 55,
        child: new DropdownButton<String>(
          value: _selectedAddressType,
          style: TextStyle(fontSize: 16, color: AppColors.appBlueColor),
          underline: Container(
            height: 1,
            color: Colors.grey,
          ),
          isExpanded: true,
          items: _addressTypes.map((String value) {
            return new DropdownMenuItem<String>(
              value: value,
              child: new Text(value),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedAddressType = value;
            });
          },
        ),
      );
    }

    Widget allTextField(){
      return SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            CommonFunction.customTextfield("Add Address Name", txtAddressName, TextInputType.text, context),
            addressTypeDropDown(),
            SizedBox(height: 15,),
            CommonFunction.customTextfield("Add Address", txtAddressLine1, TextInputType.text, context, isLastTextfield: true),
            // CommonFunction.customTextfield("Add Address line 2", txtAddressLine2, TextInputType.text, context),
            // CommonFunction.customTextfield("Add Address line 3", txtAddressLine3, TextInputType.text, context, isLastTextfield: true),
          ],
        ),
      );
    }


    Widget stackView() {
      return Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height - 202,
            // color: Colors.blue,
          ),
          Container(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: allTextField(),
          ),
          new Positioned(
            right: 0,
            bottom: 30,
            child: Container(
              child: YellowThemeButton(
                btnName: widget.isEditGroup ? "Update" : "Add",
                onPressed: () {
                  if (_isValidate(context) == null){
                    _addEditGroup();
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
        child: Text(widget.isEditGroup ? "Edit Address" : "Add Address", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),),
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
          "Address",
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
