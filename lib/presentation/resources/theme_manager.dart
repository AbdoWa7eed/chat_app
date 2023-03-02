import 'package:chat_app/presentation/resources/fonts_manager.dart';
import 'package:chat_app/presentation/resources/styles_manager.dart';
import 'package:chat_app/presentation/resources/values_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'color_manager.dart';

ThemeData getApplicationTheme() {
  return ThemeData(
    // main colors
    primarySwatch: ColorManager.primarySwatch,
    primaryColor: ColorManager.primary,
    primaryColorLight: ColorManager.lightPrimary,
    disabledColor: ColorManager.grey1,
    splashColor: ColorManager.lightPrimary,
    // ripple effect color
    // cardview theme
    cardTheme: CardTheme(
        color: ColorManager.white,
        shadowColor: ColorManager.grey,
        elevation: AppSize.s4),
    // app bar theme
    appBarTheme: AppBarTheme(
        centerTitle: true,
        color: ColorManager.backgroundColor,
        titleSpacing: 0,
        elevation: AppSize.s0,
        shadowColor: ColorManager.lightPrimary,
        systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: ColorManager.backgroundColor,
            statusBarIconBrightness: Brightness.dark,
            statusBarBrightness: Brightness.dark),
        titleTextStyle:
            getRegularStyle(fontSize: FontSize.s16, color: ColorManager.white)),
    // button theme
    buttonTheme: ButtonThemeData(
        shape: const StadiumBorder(),
        disabledColor: ColorManager.grey1,
        buttonColor: ColorManager.primary,
        splashColor: ColorManager.lightPrimary),
    // elevated button them
    textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
      overlayColor:
          MaterialStateColor.resolveWith((states) => ColorManager.lightPrimary),
    )),
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
            foregroundColor: ColorManager.white,
            splashFactory: NoSplash.splashFactory,
            elevation: AppSize.s0,
            textStyle: getRegularStyle(color: ColorManager.lightPrimary),
            backgroundColor: ColorManager.primary,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSize.s12)))),
    textTheme: TextTheme(
        bodyLarge: getSemiBoldStyle(
            color: ColorManager.primary, fontSize: FontSize.s32),
        bodyMedium:
            getSemiBoldStyle(color: ColorManager.black, fontSize: FontSize.s20),
        labelMedium:getSemiBoldStyle(color: ColorManager.black, fontSize: FontSize.s16),
        bodySmall:
            getRegularStyle(color: ColorManager.white, fontSize: FontSize.s16),
        displaySmall: getRegularStyle(color: ColorManager.black, fontSize: FontSize.s16),
        titleSmall: getRegularStyle(
              color: ColorManager.lightGrey, fontSize: FontSize.s14),
        labelSmall: getRegularStyle(
            color: ColorManager.grey1, fontSize: FontSize.s12),
        titleMedium: getRegularStyle(
            color: ColorManager.grey1, fontSize: FontSize.s16),
        titleLarge: getMediumStyle(color: ColorManager.black , fontSize: FontSize.s16)
    ),

    // input decoration theme (text form field)
    inputDecorationTheme: InputDecorationTheme(
        fillColor: ColorManager.white,
        filled: true,
        // content padding
        contentPadding: const EdgeInsets.all(AppPadding.p8),
        // hint style
        hintStyle:
            getRegularStyle(color: ColorManager.grey, fontSize: FontSize.s14),
        labelStyle:
            getRegularStyle(color: ColorManager.grey, fontSize: FontSize.s14),
        errorStyle: getRegularStyle(color: ColorManager.error),

        // enabled border style
        enabledBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: ColorManager.white, width: AppSize.s1),
            borderRadius: const BorderRadius.all(Radius.circular(AppSize.s8))),


        //disabled border style  
        disabledBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: ColorManager.white, width: AppSize.s1),
            borderRadius: const BorderRadius.all(Radius.circular(AppSize.s8))),   

        // focused border style
        focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: ColorManager.primary, width: AppSize.s1),
            borderRadius: const BorderRadius.all(Radius.circular(AppSize.s8))),

        // error border style
        errorBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: ColorManager.error, width: AppSize.s1),
            borderRadius: const BorderRadius.all(Radius.circular(AppSize.s8))),
        // focused border style
        focusedErrorBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: ColorManager.primary, width: AppSize.s1),
            borderRadius: const BorderRadius.all(Radius.circular(AppSize.s8)))),
  );
}
