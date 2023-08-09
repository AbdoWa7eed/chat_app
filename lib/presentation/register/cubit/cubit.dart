import 'dart:io';

import 'package:chat_app/app/app_preferences.dart';
import 'package:chat_app/app/constants.dart';
import 'package:chat_app/app/di.dart';
import 'package:chat_app/domain/models/models.dart';
import 'package:chat_app/domain/repository/notification_repo.dart';
import 'package:chat_app/domain/repository/register_repo.dart';
import 'package:chat_app/presentation/common/functions.dart';
import 'package:chat_app/presentation/register/cubit/states.dart';
import 'package:chat_app/presentation/resources/language_manger.dart';
import 'package:chat_app/presentation/resources/strings_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class RegisterCubit extends Cubit<RegisterStates> {
  RegisterCubit() : super(RegisterInitialState());
  final RegisterRepository _registerRepository = instance<RegisterRepository>();
  final AppPreferences _appPreferences = instance<AppPreferences>();
  final NotificationRepo _notificationRepo = instance<NotificationRepo>();
  File? image;
  String? _imageUrl;

  void addUser(
      {required String username,
      required String nickName,
      String? bio,
      required Function(String) onSuccess}) async {
    emit(AddUserLoadingState());
    if (image != null) {
      await _uploadImage();
    }
    String phoneNumber =
        _appPreferences.getUserPhoneNumber() ?? Constants.empty;
    String token = await getToken();
    await _appPreferences.setDeviceToken(token);
    var userModel = UserModel(
        UID!,
        AppStrings.online,
        username,
        phoneNumber,
        nickName,
        _imageUrl ?? Constants.defaultUserImage,
        bio ?? Constants.empty,
        token,
        LanguageType.ENGLISH.getValue());
    (await _registerRepository.addNewUser(userModel)).fold((failure) {
      emit(AddUserErrorState(failure.message));
    }, (success) async {
      await _afterRegisterCompleted(username);
      onSuccess.call(token);
      emit(AddUserSuccessState());
    });
  }

  Future<void> _afterRegisterCompleted(String username) async {
    await _appPreferences.deletePhoneNumber();
    await _appPreferences.setUserRegistered();
  }

  Future<void> _uploadImage() async {
    emit(UploadImageLoadingState());
    (await _registerRepository.uploadImage(image!)).fold((failure) {
      emit(UploadImageErrorState(failure.message));
    }, (url) {
      _imageUrl = url;
      emit(UploadImageSuccessState());
    });
  }

  Future<String> getToken() async {
    String token = "";
    (await _notificationRepo.getDeviceToken()).fold((failure) {},
        (deviceToken) {
      token = deviceToken;
    });
    return token;
  }

  //UI Functions
  late ImagePicker _imagePicker;

  imageFromGallery() async {
    _imagePicker = instance<ImagePicker>();
    image = await pickImageFromGallery(_imagePicker);
    emit(PickedImageState());
  }

  imageFromCamera() async {
    _imagePicker = instance<ImagePicker>();
    image = await pickImageFromCamera(_imagePicker);
    emit(PickedImageState());
  }
}
