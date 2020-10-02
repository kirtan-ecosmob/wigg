
class DeviceHeaders {
  DeviceHeaders._privateConstructor() {
//    initPlatformState();
//    getAppVersion().then((version) {
//      this._appVersion = version;
//    });
//    getApplicationId().then((id) {
//      projectAppID = id;
//    });
//    getLocale().then((locale) {
//      this.locale = locale;
//    });
  }

  static final DeviceHeaders _singleton = DeviceHeaders._privateConstructor();

  static DeviceHeaders get instance => _singleton;

  var _platform = "";
  var _osVersion = "";
  var _device = "";
  var _appVersion = "1.0";

  var _deviceToken = "";
  bool _isLogin = false;
  var _userId = "";
  var _authToken = "";


//  get deviceToken {
//    return _deviceToken;
//  }
//
 set deviceToken(String value) {
   this._deviceToken = value;
 }
  
  set platform(String value){
    this._platform = value;
  }

  set osVersion(String value){
    this._osVersion = value;
  }

  set device(String value){
    this._device = value;
  }

  set appVersion(String value){
    this._appVersion = value;
  }

  set isLogin(bool value){
    this._isLogin = value;
  }

  set userId(String value){
    this._userId = value;
  }

  set authToken(String value){
    this._authToken = value;
  }

  String get deviceToken => _deviceToken;


  Map<String, String> getHeaders({Map<String, String> additionalHeaders}) {
    Map<String, String> _headers = <String, String>{};

    if (additionalHeaders != null) _headers = additionalHeaders;

    _headers['Content-Type'] = "application/json";
    _headers['X-localization'] = "en_US";
    _headers['X-platform'] = _platform;
    _headers['X-OSVersion'] = _osVersion;
    _headers['X-device'] = _device;
    _headers['X-appVersion'] = _appVersion;

    if (_isLogin){
      _headers['id'] = _userId;
      _headers['authtoken'] = _authToken;
    }


    print("HEADERS ::: $_headers");
    return _headers;
  }
}