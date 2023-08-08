// ignore_for_file: constant_identifier_names

import 'package:chat_app/app/constants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../presentation/resources/language_manger.dart';

const String PREFS_KEY_ONBOARDING_SCREEN_VIEWED =
    "PREFS_KEY_ONBOARDING_SCREEN_VIEWED";
const String PREFS_KEY_USER_UID = "PREFS_KEY_USER_UID";
const String PREFS_KEY_USER_PHONE_NUMBER = "PREFS_KEY_USER_PHONE_NUMBER";
const String PREFS_KEY_IS_USER_NAME = "PREFS_KEY_IS_USER_NAME";
const String PREFS_KEY_IS_USER_REGISTERED = "PREFS_KEY_IS_USER_REGISTERED";
const String PREFS_KEY_LANG = "PREFS_KEY_LANG";
const String PREFS_KEY_DEVICE_TOKEN = "PREFS_KEY_DEVICE_TOKEN";

class AppPreferences {
  final SharedPreferences _sharedPreferences;
  AppPreferences(this._sharedPreferences);

  Future<void> setOnBoardingScreenViewed() async {
    await _sharedPreferences.setBool(PREFS_KEY_ONBOARDING_SCREEN_VIEWED, true);
  }

  bool isOnBoardingScreenViewed() {
    return _sharedPreferences.getBool(PREFS_KEY_ONBOARDING_SCREEN_VIEWED) ??
        false;
  }

  Future<void> setUserUid(String uid) async {
    await _sharedPreferences.setString(PREFS_KEY_USER_UID, uid);
  }

  String? getUserUid() {
    return _sharedPreferences.getString(PREFS_KEY_USER_UID);
  }

  Future<void> setUserPhoneNumber(String phoneNumber) async {
    await _sharedPreferences.setString(
        PREFS_KEY_USER_PHONE_NUMBER, phoneNumber);
  }

  String? getUserPhoneNumber() {
    return _sharedPreferences.getString(PREFS_KEY_USER_PHONE_NUMBER);
  }

  Future<void> setUserRegistered() async {
    await _sharedPreferences.setBool(PREFS_KEY_IS_USER_REGISTERED, true);
  }

  bool isUserRegistered() {
    return _sharedPreferences.getBool(PREFS_KEY_IS_USER_REGISTERED) ?? false;
  }

  Future<void> deletePhoneNumber() async {
    await _sharedPreferences.remove(PREFS_KEY_USER_PHONE_NUMBER);
  }

  Future<void> logOut() async {
    await _sharedPreferences.remove(PREFS_KEY_USER_UID);
    await _sharedPreferences.setBool(PREFS_KEY_IS_USER_REGISTERED, false);
  }

  Future<String> getAppLanguage() async {
    String? language = _sharedPreferences.getString(PREFS_KEY_LANG);

    if (language != null) {
      return language;
    } else {
      return LanguageType.ENGLISH.getValue();
    }
  }

  Future<void> changeAppLanguage() async {
    String currentLanguage = await getAppLanguage();

    if (currentLanguage == LanguageType.ARABIC.getValue()) {
      await _sharedPreferences.setString(
          PREFS_KEY_LANG, LanguageType.ENGLISH.getValue());
    } else {
      await _sharedPreferences.setString(
          PREFS_KEY_LANG, LanguageType.ARABIC.getValue());
    }
  }

  Future<Locale> getLocale() async {
    String currentLanguage = await getAppLanguage();
    if (currentLanguage == LanguageType.ARABIC.getValue()) {
      return ARABIC_LOCAL;
    } else {
      return ENGLISH_LOCAL;
    }
  }

  Future<void> setDeviceToken(String token) async {
    await _sharedPreferences.setString(PREFS_KEY_DEVICE_TOKEN, token);
  }

  String getDeviceToken() {
    return _sharedPreferences.getString(PREFS_KEY_DEVICE_TOKEN) ??
        Constants.empty;
  }
}
