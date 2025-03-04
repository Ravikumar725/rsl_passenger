import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'data/data.dart';
import '../network/services.dart';

class GetStorageController extends GetxController {
  final storage = GetStorage();
  static final GetStorageController _instance = GetStorageController._instance;

  void saveAccessToken({required String value}) {
    storage.write("token", value);
  }

  Future<String> getAccessToken() async {
    final token = await storage.read("token") ?? "";
    return token;
  }

  void removeAccessToken() {
    storage.remove("token");
  }

  void saveRefreshToken({required String value}) {
    storage.write("refresh_token", value);
  }

  Future<String> getRefreshToken() async {
    final token = await storage.read("refresh_token") ?? "";
    return token;
  }

  void removeRefreshToken() {
    storage.remove("refresh_token");
  }

/////USER ID
  void saveuserId({required String id}) {
    storage.write("userId", id);
  }

  void removeUserId() {
    storage.write("userId", "");
  }

  ///appRating
  void saveAppRating({required double rating}) {
    storage.write("rating", rating);
  }

  Future<double> getAppRating() async {
    final rating = await storage.read("rating") ?? 0.0;
    return rating;
  }

  void removeAppRating() {
    storage.write("rating", 0.0);
  }

  Future<String> getUserId() async {
    var userId;
    try {
      userId = await storage.read("userId") ?? "";
    } catch (error) {
      userId = "";
    }

    return userId;
  }

  ////USER INFO
  void saveuserInfo({
    required String userInfo,
    required String userId,
  }) {
    printLogs("saveuserInfo info: $userInfo");
    storage.write("userId", userId);
    storage.write("userInfo", userInfo);
  }

  Future<UserInfo?> getUserInfo() async {
    String userInfo = await storage.read("userInfo") ?? "";
    if (userInfo.isEmpty) {
      return Future.value(null);
    }
    Map<String, dynamic> userData = jsonDecode(userInfo);
    printLogs("getUserInfo info: $userData");
    UserInfo response = UserInfo(
      userId: userData['userId'],
      name: userData['name'],
      email: userData['email'],
      countryCode: userData['countryCode'],
      mobile: userData['mobile'],
      rslId: userData['rslId'],
      profileUrl: userData['profileUrl'],
      profileImage: userData['profile_image'],
    );
    return response;
  }

  void removeUserInfo() {
    storage.write("userId", "");
    storage.write("userInfo", "");
  }

  void saveFirebaseTokenData({required String value}) {
    storage.write("FCMtoken", value);
  }

  Future<String> getDeviceToken() async {
    String? token = "";
    try {
      token = await storage.read("FCMtoken") ?? "";
    } catch (error) {
      token = "";
    }
    return token.toString();
  }

/////DEVICE INFO DETAILS

  // void saveDeviceInfo({required AppInfoPlusArgs info}) {
  //   final value = json.encode(info);
  //   storage.write("deviceInfo", value);
  // }

  // Future<AppInfoPlusArgs> getDeviceInfo() async {
  //   final info = await storage.read("deviceInfo") ?? "";
  //   AppInfoPlusArgs appinfo = AppInfoPlusArgs.fromJson(info);
  //   return appinfo;
  // }

  ////CURRENCY
  void saveAppCurrency({required String id}) {
    storage.write("cur", id);
  }

  void removeAppCurrency() {
    storage.write("cur", "");
  }

  Future<String> getAppCurrency() async {
    var cur;
    try {
      cur = await storage.read("cur");
    } catch (error) {
      cur = "aed";
    }

    return cur;
  }

  Future<void> saveAppLanguage(String language) async {
    storage.write('selectedLanguage', language);
  }

  // Get the saved language from GetStorage
  Future<String> getAppLanguage() async {
    return storage.read('selectedLanguage') ?? 'English (UK)'; // Default to English if no language is saved
  }

  Future<void> saveAppRegion(String regionCode) async {
    storage.write('selectedRegion', regionCode);
  }

  // Get the saved region code
  Future<String> getAppRegion() async {
    return storage.read('selectedRegion') ?? 'US'; // Default to 'US' if no region is saved
  }


  void appCommonRemover() {
    removeAccessToken();
    removeUserInfo();
    removeUserId();
    removeWalletInfoStatus();
    removeAppRating();
  }

  Future<String> getWalletInfoStatus() async {
    var walletInfo;
    try {
      walletInfo = await storage.read("walletInfo");
    } catch (error) {
      walletInfo = "0";
    }

    return walletInfo ?? "0";
  }

  void saveWalletInfoStatus({required String id}) {
    storage.write("walletInfo", id);
  }

  void removeWalletInfoStatus() {
    storage.write("walletInfo", "0");
  }

  void saveAppInstall({required int type}) {
    storage.write("AppInstall", type);
  }

  Future<int> getAppInstall() async {
    return await storage.read("AppInstall") ?? 0;
  }

  void saveAppOpen({required int type}) {
    storage.write("AppOpen", type);
  }

  Future<int> getAppOpen() async {
    return await storage.read("AppOpen") ?? 1;
  }

  saveTripId({required String tripid}) {
    storage.write("saveTripId", tripid);
  }

  Future<String> getTripid() async {
    return await storage.read("saveTripId") ?? "";
  }

  saveQBPushSubscribeId({required String qBSubscribeId}) {
    storage.write("saveQBPushSubscribeId", qBSubscribeId);
  }

  Future<String> getQBPushSubscribeId() async {
    return await storage.read("saveQBPushSubscribeId") ?? "";
  }

  saveEstimatedTime({required String saveEstimatedTime}) {
    storage.write("saveEstimatedTime", saveEstimatedTime);
  }

  Future<String> getEstimatedTime() async {
    return await storage.read("saveEstimatedTime") ?? "";
  }


  savePromoCode({required String savePromoCode}) {
    storage.write("savePromoCode", savePromoCode);
  }

  Future<String> getPromoCode() async {
    return await storage.read("savePromoCode") ?? "";
  }

}

class StorageX {
  static final StorageX _instance = StorageX._internal();
  static final storage = GetStorage();

  factory StorageX() {
    return _instance;
  }

  StorageX._internal();
}

extension AppLanguageXExtension on StorageX {
  Future<String> getAppLanguage() async {
    try {
      final value = await StorageX.storage.read("appLanguage");
      return value ?? 'en';
    } catch (e) {
      return 'en';
    }
  }

  Future<void> updateAppLanguage(String language) async {
    try {
      switch (language) {
        case 'en':
        case 'ar':
          await StorageX.storage.write("appLanguage", language);
          break;
        default:
          await StorageX.storage.write("appLanguage", 'en');
      }
    } catch (e) {
      // Handle error
    }
  }
}

extension ThemeXExtension on StorageX {
  Future<ThemeMode> getThemeMode() async {
    try {
      final value = await StorageX.storage.read("themeMode");
      if (value == "light") {
        return ThemeMode.light;
      } else if (value == "dark") {
        return ThemeMode.dark;
      } else {
        return ThemeMode.system;
      }
    } catch (e) {
      return ThemeMode.system;
    }
  }

  Future<void> updateThemeMode(ThemeMode themeMode) async {
    try {
      String theme = themeMode == ThemeMode.dark
          ? "dark"
          : themeMode == ThemeMode.light
              ? "light"
              : "system";
      await StorageX.storage.write("themeMode", theme);
    } catch (e) {
      // Handle error
    }
  }
}
