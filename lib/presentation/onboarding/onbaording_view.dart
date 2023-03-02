import 'package:chat_app/app/app_preferences.dart';
import 'package:chat_app/app/di.dart';
import 'package:chat_app/presentation/resources/assets_manager.dart';
import 'package:chat_app/presentation/resources/color_manager.dart';
import 'package:chat_app/presentation/resources/routes_manager.dart';
import 'package:chat_app/presentation/resources/strings_manager.dart';
import 'package:chat_app/presentation/resources/values_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class OnBoardingView extends StatelessWidget {
  OnBoardingView({Key? key}) : super(key: key);
  final AppPreferences _appPreferences = instance<AppPreferences>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(),
        backgroundColor: ColorManager.backgroundColor,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppPadding.p18),
              child: Text(AppStrings.onBoardingText,
                  style: Theme.of(context).textTheme.bodyLarge).tr(),
            ),
            Image.asset(ImageAssets.onBoardingLogo),
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppPadding.p28, vertical: AppPadding.p20),
                  child: SizedBox(
                    height: AppSize.s50,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: ()  {
                         _appPreferences
                            .setOnBoardingScreenViewed()
                            .then((value) {
                          Navigator.pushReplacementNamed(
                              context, Routes.phoneAuthRoute);
                        });
                      },
                      child: Text(
                        AppStrings.getStarted.tr(),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
