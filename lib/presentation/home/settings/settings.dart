import 'package:chat_app/app/app_preferences.dart';
import 'package:chat_app/app/constants.dart';
import 'package:chat_app/app/di.dart';
import 'package:chat_app/presentation/cubit/app_cubit.dart';
import 'package:chat_app/presentation/cubit/app_states.dart';
import 'package:chat_app/presentation/resources/color_manager.dart';
import 'package:chat_app/presentation/resources/routes_manager.dart';
import 'package:chat_app/presentation/resources/strings_manager.dart';
import 'package:chat_app/presentation/resources/values_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restart_app/restart_app.dart';

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({super.key});

  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  final _appPrefrences = instance<AppPreferences>();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatAppCubit, ChatAppStates>(
      listener: (context, state) {},
      builder: (context, state) {
        return _getDialogWidget();
      },
    );
  }

  Widget _getDialogWidget() {
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            onTap: () {
              Navigator.of(context).pop();
              Navigator.pushNamed(context, Routes.userInfoRoute,
                  arguments: appUserModel);
            },
            iconColor: ColorManager.black,
            leading: const Icon(Icons.person),
            title: Text(AppStrings.personalInfo.tr(),
                style: Theme.of(context).textTheme.displaySmall),
          ),
          const SizedBox(
            height: AppSize.s10,
          ),
          ListTile(
            onTap: () {
              _changeLangauge();
            },
            iconColor: ColorManager.black,
            leading: const Icon(Icons.update_outlined),
            title: Text(AppStrings.changeAppLanguage.tr(),
                style: Theme.of(context).textTheme.displaySmall),
          ),
          const SizedBox(
            height: AppSize.s10,
          ),
          ListTile(
            onTap: () {
              _logout();
            },
            iconColor: ColorManager.error,
            leading: const Icon(Icons.exit_to_app),
            title: Text(AppStrings.logOut.tr(),
                style: Theme.of(context)
                    .textTheme
                    .displaySmall
                    ?.copyWith(color: ColorManager.error)),
          ),
        ],
      ),
    );
  }

  _changeLangauge() async {
    await instance<ChatAppCubit>().setAppLanguage().then((value) {
      instance<ChatAppCubit>().setTabBarIndex(0);
      Restart.restartApp(webOrigin: Routes.splashRoute);
    });
  }

  _logout() {
    Navigator.of(context)
        .pushNamedAndRemoveUntil(Routes.phoneAuthRoute, (route) => false);
    _appPrefrences.logOut();
  }
}
