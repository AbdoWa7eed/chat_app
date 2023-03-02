


import 'package:flutter/material.dart';

class ColorManager{
  static const int _primaryHex = 0xff0067E0;
  static MaterialColor primarySwatch = MaterialColor(
    _primaryHex,
    <int, Color>{
      50: ColorManager.primary,
      100: ColorManager.primary,
      200: ColorManager.primary,
      300: ColorManager.primary,
      400: ColorManager.primary,
      500: ColorManager.primary,
      600: ColorManager.primary,
      700: ColorManager.primary,
      800: ColorManager.primary,
      900: ColorManager.primary,
    },
  );
  static Color primary = const Color(0xff0067E0);
  static Color lightPrimary = const Color(0x1a0067E0);  // color with 10% opacity
  static Color black = const Color(0xff000000);
  static Color lightBlack = const Color(0x66000000);
  static Color white = const Color(0xffFFFFFF);
  static Color error = const Color(0xffe61f34);
  static Color grey = const Color(0xff737477);
  static Color grey1 = const Color(0xff707070);
  static Color grey2 = const Color(0xff797979);
  static Color lightGrey = const Color(0xff9E9E9E);
  static Color darkGray = const Color(0xff213241);
  static Color sentMessageColor = const Color(0xff424F63);
  static Color backgroundColor = const Color(0xffE2EDF5);
  static Color darkBackgroundColor = const Color(0xffDBE2EC);
  static Color green = const Color(0xff00CC5E);
}