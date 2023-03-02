
import 'package:chat_app/app/app_preferences.dart';
import 'package:chat_app/app/constants.dart';
import 'package:chat_app/app/di.dart';
import 'package:chat_app/presentation/cubit/app_cubit.dart';
import 'package:chat_app/presentation/phone_auth/cubit/cubit.dart';
import 'package:chat_app/presentation/resources/routes_manager.dart';
import 'package:chat_app/presentation/resources/theme_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyApp extends StatefulWidget {

  const MyApp._internal();

  static const MyApp _instance = MyApp._internal(); // singleton or single instance

  factory MyApp() => _instance; // factory

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppPreferences _appPreferences = instance<AppPreferences>();

  @override
  void didChangeDependencies() {
    _appPreferences.getLocale().then((locale) => context.setLocale(locale));
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(providers: [
      if(UID == null)...[
        BlocProvider<PhoneAuthCubit>.value(value: instance<PhoneAuthCubit>(),)
      ],
      BlocProvider<ChatAppCubit>.value(value: instance<ChatAppCubit>()),
    ],
        child: MaterialApp(
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          debugShowCheckedModeBanner: false,
          onGenerateRoute: RouteGenerator.getRoute,
          initialRoute: Routes.splashRoute,
          theme: getApplicationTheme(),
        ));
  }
}
