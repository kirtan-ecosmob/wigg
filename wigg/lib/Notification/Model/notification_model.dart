/// code : 200
/// message : "Data fetched successfully"
/// data : [{"notification_id":2,"user_id":1,"notification_type":"purchase","notification_text":"test","read_status":"Y","created_at":"2020-10-06 08:34:48","type_id":2},{"notification_id":1,"user_id":1,"notification_type":"purchase","notification_text":"test","read_status":"N","created_at":"2020-10-06 08:29:21","type_id":1}]

class NotificationModel {
  int _code;
  String _message;
  List<NotificationData> _notificationData;

  int get code => _code;
  String get message => _message;
  List<NotificationData> get notificationData => _notificationData;

  NotificationModel({
      int code, 
      String message, 
      List<NotificationData> data}){
    _code = code;
    _message = message;
    _notificationData = data;
}

  NotificationModel.fromJson(dynamic json) {
    _code = json["code"];
    _message = json["message"];
    if (json["data"] != null) {
      _notificationData = [];
      json["data"].forEach((v) {
        _notificationData.add(NotificationData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["code"] = _code;
    map["message"] = _message;
    if (_notificationData != null) {
      map["data"] = _notificationData.map((v) => v.toJson()).toList();
    }
    return map;
  }

}

/// notification_id : 2
/// user_id : 1
/// notification_type : "purchase"
/// notification_text : "test"
/// read_status : "Y"
/// created_at : "2020-10-06 08:34:48"
/// type_id : 2

class NotificationData {
  int _notificationId;
  int _userId;
  String _notificationType;
  String _notificationText;
  String _readStatus;
  String _createdAt;
  int _typeId;

  int get notificationId => _notificationId;
  int get userId => _userId;
  String get notificationType => _notificationType;
  String get notificationText => _notificationText;
  String get readStatus => _readStatus;
  String get createdAt => _createdAt;
  int get typeId => _typeId;

  set readStatus(String value){
    this._readStatus = value;
  }


  Data({
      int notificationId, 
      int userId, 
      String notificationType, 
      String notificationText, 
      String readStatus, 
      String createdAt, 
      int typeId}){
    _notificationId = notificationId;
    _userId = userId;
    _notificationType = notificationType;
    _notificationText = notificationText;
    _readStatus = readStatus;
    _createdAt = createdAt;
    _typeId = typeId;
}

  NotificationData.fromJson(dynamic json) {
    _notificationId = json["notification_id"];
    _userId = json["user_id"];
    _notificationType = json["notification_type"];
    _notificationText = json["notification_text"];
    _readStatus = json["read_status"];
    _createdAt = json["created_at"];
    _typeId = json["type_id"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["notification_id"] = _notificationId;
    map["user_id"] = _userId;
    map["notification_type"] = _notificationType;
    map["notification_text"] = _notificationText;
    map["read_status"] = _readStatus;
    map["created_at"] = _createdAt;
    map["type_id"] = _typeId;
    return map;
  }

}