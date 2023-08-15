import 'package:chat_app/app/app_preferences.dart';
import 'package:chat_app/app/constants.dart';
import 'package:chat_app/data/data_source/auth/auth_data_srouce.dart';
import 'package:chat_app/data/data_source/group_chat/group_data_source.dart';
import 'package:chat_app/data/data_source/group_info/group_info_data_source.dart';
import 'package:chat_app/data/data_source/home/home_data_source.dart';
import 'package:chat_app/data/data_source/notification/notification_data_source.dart';
import 'package:chat_app/data/data_source/register/register_data_source.dart';
import 'package:chat_app/data/data_source/single_chat/chat_data_source.dart';
import 'package:chat_app/data/data_source/upload_image/upload_image.dart';
import 'package:chat_app/data/network/app_api.dart';
import 'package:chat_app/data/network/network_info.dart';
import 'package:chat_app/data/repository/auth_repository_impl.dart';
import 'package:chat_app/data/repository/group_info_repo_impl.dart';
import 'package:chat_app/data/repository/group_repo_impl.dart';
import 'package:chat_app/data/repository/home_repo_impl.dart';
import 'package:chat_app/data/repository/notification_repo_impl.dart';
import 'package:chat_app/data/repository/register_repo_impl.dart';
import 'package:chat_app/data/repository/single_chat_repo_impl.dart';
import 'package:chat_app/domain/repository/group_chat_repo.dart';
import 'package:chat_app/domain/repository/group_info_repo.dart';
import 'package:chat_app/domain/repository/home_repository.dart';
import 'package:chat_app/domain/repository/notification_repo.dart';
import 'package:chat_app/domain/repository/register_repo.dart';
import 'package:chat_app/domain/repository/single_chat_repo.dart';
import 'package:chat_app/presentation/chat/cubit/chat_cubit.dart';
import 'package:chat_app/presentation/cubit/app_cubit.dart';
import 'package:chat_app/presentation/group_info/cubit/cubit.dart';
import 'package:chat_app/presentation/phone_auth/cubit/cubit.dart';
import 'package:chat_app/presentation/register/cubit/cubit.dart';
import 'package:chat_app/presentation/resources/strings_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:image_picker/image_picker.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/repository/auth_repository.dart';

final instance = GetIt.instance;

initAppModule() async {
  final sharedPrefs = await SharedPreferences.getInstance();
  instance.registerLazySingleton<SharedPreferences>(() => sharedPrefs);

  instance.registerLazySingleton<AppPreferences>(
      () => AppPreferences(instance<SharedPreferences>()));

  instance.registerLazySingleton<NetworkInfo>(
      () => NetworkInfoImpl(InternetConnectionChecker()));

  instance.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);

  instance.registerLazySingleton<FirebaseFirestore>(
      () => FirebaseFirestore.instance);

  instance
      .registerLazySingleton<FirebaseStorage>(() => FirebaseStorage.instance);

  instance.registerLazySingleton<FirebaseMessaging>(
    () => FirebaseMessaging.instance,
  );

  instance.registerLazySingleton<UploadImageDataSource>(
      () => UploadImageDataSourceImpl(instance<FirebaseStorage>()));

  instance.registerLazySingleton<NotificationSender>(
      () => NotificationSenderImpl());

  instance.registerLazySingleton<NotificationDataSource>(() =>
      NotificationDataSourceImpl(
          instance<NotificationSender>(), instance<FirebaseMessaging>()));

  instance.registerLazySingleton<NotificationRepo>(() => NotificationRepoImpl(
      instance<NetworkInfo>(), instance<NotificationDataSource>()));

  UID = instance<AppPreferences>().getUserUid();
}

initPhoneAuthModule() {
  if (!GetIt.I.isRegistered<AuthDataSource>()) {
    instance.registerLazySingleton<AuthDataSource>(() => AuthDataSourceImpl(
        instance<FirebaseAuth>(), instance<FirebaseFirestore>()));
    instance.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(
        instance<AuthDataSource>(), instance<NetworkInfo>()));
  }
  if (!GetIt.I.isRegistered<PhoneAuthCubit>()) {
    instance.registerLazySingleton<PhoneAuthCubit>(() => PhoneAuthCubit());
  }
}

initImagePickerInstance() {
  if (!GetIt.I.isRegistered<ImagePicker>()) {
    instance.registerFactory<ImagePicker>(() => ImagePicker());
  }
}

initHomeModule() async {
  if (!GetIt.I.isRegistered<HomeDataSource>()) {
    instance.registerLazySingleton<HomeDataSource>(() => HomeDataSourceImpl(
        instance<UploadImageDataSource>(), instance<FirebaseFirestore>()));
    instance.registerLazySingleton<HomeRepository>(() => HomeRepositoryImpl(
        instance<NetworkInfo>(), instance<HomeDataSource>()));
  }
  if (!GetIt.I.isRegistered<ChatAppCubit>()) {
    instance.registerLazySingleton<ChatAppCubit>(() => ChatAppCubit());
  }
  var cubit = instance<ChatAppCubit>();
  await cubit.getUserData(UID!, isUID: true);
  await cubit.getChattingUsers();
  await cubit.getChats();
  await cubit.setStatus(AppStrings.online.tr());
}

initRegisterModule() async {
  await initImagePickerInstance();
  if (!GetIt.I.isRegistered<RegisterDataSource>()) {
    instance.registerLazySingleton<RegisterDataSource>(() =>
        RegisterDataSourceImpl(
            instance<UploadImageDataSource>(), instance<FirebaseFirestore>()));
    instance.registerLazySingleton<RegisterRepository>(() => RegisterRepoImpl(
        instance<NetworkInfo>(), instance<RegisterDataSource>()));
  }
  if (!GetIt.I.isRegistered<RegisterCubit>()) {
    instance.registerLazySingleton<RegisterCubit>(() => RegisterCubit());
  }
}

initChatModule() async {
  if (!GetIt.I.isRegistered<GroupChatDataSource>()) {
    instance.registerLazySingleton<GroupChatDataSource>(
        () => GroupChatDataSourceImpl(instance<FirebaseFirestore>()));

    instance.registerLazySingleton<GroupChatRepo>(() => GroupChatRepoImpl(
        instance<NetworkInfo>(), instance<GroupChatDataSource>()));
  }

  if (!GetIt.I.isRegistered<SingleChatDataSource>()) {
    instance.registerLazySingleton<SingleChatDataSource>(
        () => SingleChatDataSourceImpl(instance<FirebaseFirestore>()));

    instance.registerLazySingleton<SingleChatRepo>(() => SingleChatRepoImpl(
        instance<NetworkInfo>(), instance<SingleChatDataSource>()));
  }

  if (!GetIt.I.isRegistered<InChatCubit>()) {
    instance.registerLazySingleton<InChatCubit>(() => InChatCubit());
  }
}

initGroupInfoModule() async {
  await initImagePickerInstance();
  if (!GetIt.I.isRegistered<GroupInfoDataSource>()) {
    instance.registerLazySingleton<GroupInfoDataSource>(() =>
        GroupInfoDataSourceImpl(
            instance<FirebaseFirestore>(), instance<UploadImageDataSource>()));
    instance.registerLazySingleton<GroupInfoRepo>(() => GroupInfoRepoImpl(
        instance<NetworkInfo>(), instance<GroupInfoDataSource>()));
  }
  if (!GetIt.I.isRegistered<GroupInfoCubit>()) {
    instance.registerLazySingleton<GroupInfoCubit>(() => GroupInfoCubit());
  }
  instance<GroupInfoCubit>().initGroupMembers();
}
