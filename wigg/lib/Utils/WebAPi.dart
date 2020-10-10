class WebApi {

  static const String staging = "http://95.217.176.189:8084/api/";
  static const String live = "http://95.217.176.189:8084/";

  static const String version = "v1/";

  static const String host = staging;
  static const String baseUrl = host + version;

  static const String login = baseUrl + "login";
  static const String register = baseUrl + "register";
  static const String sendCode = baseUrl + "sendCode";
  static const String verifyCode = baseUrl + "verifyCode";
  static const String logout = baseUrl + "logout";

  static const String dashboard = baseUrl + "dashboard";


  static const String getProfile = baseUrl + "getProfile";
  static const String updateProfile = baseUrl + "updateProfile";


  //Subuser
  static const String userList = baseUrl + "user/list";
  static const String userDelete = baseUrl + "user/delete";
  static const String addUser = baseUrl + "user/create";
  static const String editUser = baseUrl + "user/update";
  static const String userDetails = baseUrl + "user/view";

  //Product
  static const String productList = baseUrl + "product/list";
  static const String productDelete = baseUrl + "product/delete";
  static const String productDetails = baseUrl + "product/view";

  static const String addProduct = baseUrl + "product/create";
  static const String editProduct = baseUrl + "product/update";

  //Group
  static const String groupList = baseUrl + "group/list";
  static const String addGroup = baseUrl + "group/create";
  static const String editGroup = baseUrl + "group/update";
  static const String deleteGroup = baseUrl + "group/delete";

  //Category
  static const String categoryList = baseUrl + "category/list";
  static const String addCategory = baseUrl + "category/create";
  static const String editCategory = baseUrl + "category/update";
  static const String deleteCategory = baseUrl + "category/delete";


  //Ticket
  static const String submitTicket = baseUrl + "submit/ticket";
  static const String cmsPage = baseUrl + "page/";

  //Setting
  static const String setNotification = baseUrl + "set/notification";

  //Notification
  static const String notificationList = baseUrl + "notification/list";
  static const String readNotification = baseUrl + "notification/read";



}