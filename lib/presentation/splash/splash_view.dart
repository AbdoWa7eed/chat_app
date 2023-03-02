import 'dart:async';

import 'package:chat_app/app/app_preferences.dart';
import 'package:chat_app/app/constants.dart';
import 'package:chat_app/app/di.dart';
import 'package:chat_app/presentation/resources/assets_manager.dart';
import 'package:chat_app/presentation/resources/color_manager.dart';
import 'package:chat_app/presentation/resources/constants_manager.dart';
import 'package:chat_app/presentation/resources/routes_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashView extends StatefulWidget {
  const SplashView({Key? key}) : super(key: key);

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  final AppPreferences _appPreferences = instance<AppPreferences>();
  late Timer _timer;

  @override
  void initState() {
    _timer = Timer(const Duration(seconds: AppConstants.splashDelay), _goNext);
    super.initState();
  }

  _goNext() {
    if (_appPreferences.isOnBoardingScreenViewed() &&
        _appPreferences.isUserRegistered()) {
      Navigator.pushReplacementNamed(context, Routes.homeRoute);
    } else if (_appPreferences.isOnBoardingScreenViewed() &&
        (UID == null)) {
      Navigator.pushReplacementNamed(context, Routes.phoneAuthRoute);
    } else if (_appPreferences.isOnBoardingScreenViewed() &&
        !(_appPreferences.isUserRegistered())) {
      Navigator.pushReplacementNamed(context, Routes.registerRoute);
    } else {
      Navigator.pushReplacementNamed(context, Routes.onBoardingRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
          statusBarColor: ColorManager.backgroundColor,
          statusBarIconBrightness: Brightness.dark),
      child: Scaffold(
        backgroundColor: ColorManager.backgroundColor,
        body: Center(
          child: SvgPicture.asset(ImageAssets.logo),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
