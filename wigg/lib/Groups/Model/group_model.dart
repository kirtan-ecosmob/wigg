import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// code : 200
/// message : "Data fetched successfully"
/// data : [{"id":3,"name":"kirtan","address":"gondal","type":"commercial"}]

class GroupModel {
  int _code;
  String _message;
  List<GroupData> _data;

  int get code => _code;
  String get message => _message;
  List<GroupData> get groupData => _data;

  GroupModel({
      int code, 
      String message, 
      List<GroupData> data}){
    _code = code;
    _message = message;
    _data = data;
}

  GroupModel.fromJson(dynamic json) {
    _code = json["code"];
    _message = json["message"];
    if (json["data"] != null) {
      _data = [];
      json["data"].forEach((v) {
        _data.add(GroupData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["code"] = _code;
    map["message"] = _message;
    if (_data != null) {
      map["data"] = _data.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// id : 3
/// name : "kirtan"
/// address : "gondal"
/// type : "commercial"

class GroupData {
  int _id;
  String _name;
  String _address;
  String _type;

  int get id => _id;
  String get name => _name;
  String get address => _address;
  String get type => _type;

  GroupData({
      int id, 
      String name, 
      String address, 
      String type}){
    _id = id;
    _name = name;
    _address = address;
    _type = type;
}

  GroupData.fromJson(dynamic json) {
    _id = json["id"];
    _name = json["name"];
    _address = json["address"];
    _type = json["type"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["id"] = _id;
    map["name"] = _name;
    map["address"] = _address;
    map["type"] = _type;
    return map;
  }

  Widget nameAndAddress(){


   return RichText(
      text: TextSpan(
        text: name,
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16,),
        children: <TextSpan>[
          TextSpan(
            text: '\n$address',
            style: TextStyle(
              // color: Colors.green,
              // decoration: TextDecoration.underline,
              fontSize: 14,
              fontWeight: FontWeight.normal,
              decorationStyle: TextDecorationStyle.wavy,
            ),
            // recognizer: _longPressRecognizer,
          ),
          // TextSpan(text: 'secret?'),
        ],
      ),
    );

    // return Container(
    //   padding: EdgeInsets.only(left: 20, right: 20),
    //   child: Column(
    //     children: [
    //       Align(
    //         alignment: Alignment.centerLeft,
    //         child: Text(name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
    //       ),
    //       Align(
    //         alignment: Alignment.centerLeft,
    //         child: Text(address,),
    //       ),
    //     ],
    //   ),
    // );
  }



}