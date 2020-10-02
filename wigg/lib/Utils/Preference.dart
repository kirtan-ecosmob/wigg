

import 'dart:developer';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wigg/Utils/AppStrings.dart';

import 'DeviceHeaders.dart';

import 'dart:async';


GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: <String>[
    'email',
    'https://www.googleapis.com/auth/contacts.readonly',
  ],
);

Future<bool> logout() async {
  DeviceHeaders.instance.isLogin = false;
  _googleSignIn.disconnect();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final output = prefs.setBool(AppStrings.isLogin, false);
  log('@@logout : $output');

  return output;
}

Future<int> getUserId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString(AppStrings.userId);
  log('@@userId : $userId');
  return userId ?? 0;
}

Future<String> getAuthToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final authToken = prefs.getString(AppStrings.authToken);
  log('@@authToken : $authToken');
  return authToken ?? "";
}

Future<String> getProfileImage() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final profilePic = prefs.getString(AppStrings.profile_pic);
  log('@@profile_pic : $profilePic');
  return profilePic ?? "";
}

Future<String> getFullname() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final name = prefs.getString(AppStrings.name);
  log('@@name : $name');
  return name ?? "";
}

Future<String> getMobileNumber() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final mobile = prefs.getString(AppStrings.mobile);
  log('@@mobile : $mobile');
  return mobile ?? "";
}

Future<String> getRole() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final role = prefs.getString(AppStrings.role);
  log('@@role : $role');
  return role ?? "";
}


Future<int> getWarrantyExpireDays() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  // final warranty = prefs.getString(AppStrings.warrantyExpireDays);
  final warranty = prefs.getInt(AppStrings.warrantyExpireDays);
  log('@@warranty : $warranty');
  return warranty ?? 0;
}

Future<bool> isUserLogin() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final isLogin = prefs.getBool(AppStrings.isLogin);
  log('@@isLogin : $isLogin');
  return isLogin ?? false;
}