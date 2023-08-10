import 'package:chat_app/app/di.dart';
import 'package:chat_app/presentation/chat/chat_view/chat_view.dart';
import 'package:chat_app/presentation/group_info/group_info.dart';
import 'package:chat_app/presentation/home/home_view/home_view.dart';
import 'package:chat_app/presentation/onboarding/onbaording_view.dart';
import 'package:chat_app/presentation/phone_auth/phone_auth_view/phone_auth_view.dart';
import 'package:chat_app/presentation/phone_auth/verify_code/verify_code_view.dart';
import 'package:chat_app/presentation/register/register_view.dart';
import 'package:chat_app/presentation/resources/strings_manager.dart';
import 'package:chat_app/presentation/splash/splash_view.dart';
import 'package:chat_app/presentation/user_info/user_info.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class Routes {
  static const String splashRoute = "/";
  static const String phoneAuthRoute = "/login";
  static const String phoneVerifyRoute = "/verify";
  static const String onBoardingRoute = "/onBoarding";
  static const String registerRoute = "/register";
  static const String homeRoute = "/home";
  static const String searchRoute = "/search";
  static const String chatRoute = "/chat";
  static const String userInfoRoute = "/userInfo";
  static const String groupInfoRoute = "/groupInfo";
}

class RouteGenerator {
  static Route<dynamic> getRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.splashRoute:
        return MaterialPageRoute(builder: (context) => const SplashView());
      case Routes.onBoardingRoute:
        return MaterialPageRoute(builder: (context) => OnBoardingView());
      case Routes.phoneAuthRoute:
        initPhoneAuthModule();
        return MaterialPageRoute(
            builder: (context) => const PhoneAuthenticationView());
      case Routes.phoneVerifyRoute:
        return MaterialPageRoute(builder: (context) => VerifyCodeView());
      case Routes.registerRoute:
        initRegisterModule();
        return MaterialPageRoute(builder: (context) => RegisterView());
      case Routes.homeRoute:
        initHomeModule();
        return MaterialPageRoute(
            builder: (context) => const HomeView(), settings: settings);
      case Routes.chatRoute:
        initChatModule();
        return MaterialPageRoute(
            builder: (context) => const ChatView(), settings: settings);
      case Routes.userInfoRoute:
        initImagePickerInstance();
        return MaterialPageRoute(
            builder: (context) => const UserInfoView(), settings: settings);
      case Routes.groupInfoRoute:
        initGroupInfoModule();
        return MaterialPageRoute(
            builder: (context) => const GroupInfoView(), settings: settings);
      default:
        return unDefinedRoute();
    }
  }

  static Route<dynamic> unDefinedRoute() {
    return MaterialPageRoute(
        builder: (_) => Scaffold(
              appBar: AppBar(
                title: const Text(AppStrings.noRouteFound).tr(),
              ),
              body: Center(child: const Text(AppStrings.noRouteFound).tr()),
            ));
  }
}
