import 'package:bloc/bloc.dart';
import 'package:chat_app/app/bloc_observer.dart';
import 'package:chat_app/firebase_options.dart';
import 'package:chat_app/presentation/resources/language_manger.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'app/app.dart';
import 'app/di.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initAppModule();
  Bloc.observer = MyBlocObserver();
  runApp(EasyLocalization(
      supportedLocales: const [ARABIC_LOCAL, ENGLISH_LOCAL],
      path: ASSET_PATH_LOCALIZATION,
      child:  MyApp(),));
}
