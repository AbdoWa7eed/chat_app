import 'package:alt_sms_autofill/alt_sms_autofill.dart';
import 'package:bloc/bloc.dart';
import 'package:chat_app/app/app_preferences.dart';
import 'package:chat_app/app/constants.dart';
import 'package:chat_app/app/di.dart';
import 'package:chat_app/domain/repository/auth_repository.dart';
import 'package:chat_app/domain/repository/notification_repo.dart';
import 'package:chat_app/presentation/phone_auth/cubit/states.dart';
import 'package:flutter/services.dart';

class PhoneAuthCubit extends Cubit<PhoneAuthStates> {
  final AuthRepository _authRepository = instance<AuthRepository>();
  final AppPreferences _appPreferences = instance<AppPreferences>();
  final _notificationRepo = instance<NotificationRepo>();
  PhoneAuthCubit() : super(PhoneAuthInitialSates());
  String? _verificationId;
  String? phoneNumber;
  String? code;
  bool isExists = false;

  Future<void> sendVerificationCode(
      {required String phoneNumber, required Function codeCent}) async {
    emit(SendCodeLoadingState());
    (await _authRepository.sendVerificationCode(
            phoneNumber: phoneNumber,
            codeCent: (verificationId, p1) async {
              codeCent();
              _verificationId = verificationId;
              this.phoneNumber = phoneNumber;
              emit(SendCodeSuccessState());
              emit(VerificationStates());
              await initSmsListener();
            }))
        .fold((failure) {
      emit(SendCodeErrorState(failure.message));
    }, (r) {});
  }

  signIn(
      {required String smsCode,
      required Function onVerifiedSuccessfully}) async {
    if (_verificationId != null) {
      emit(VerifyCodeLoadingState());
      (await _authRepository.signInWithCredential(_verificationId!, smsCode))
          .fold((failure) {
        emit(VerifyCodeErrorState(failure.message));
      }, (uid) async {
        await _afterSignIn(uid);
        onVerifiedSuccessfully.call();
        emit(VerifyCodeSuccessState());
      });
    }
  }

  _afterSignIn(String uid) async {
    await _appPreferences.setUserUid(uid);
    await _isUserExists(uid);
    if (!isExists) {
      await _appPreferences.setUserPhoneNumber(phoneNumber!);
    } else {
      await _appPreferences.setUserRegistered();
    }
    UID = uid;
  }

  _isUserExists(String uid) async {
    (await _authRepository.isUserAlreadyExists(uid)).fold((failure) {
      emit(VerifyCodeErrorState(failure.message));
    }, (exists) {
      isExists = exists;
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

  Future<void> initSmsListener() async {
    try {
      code = await AltSmsAutofill().listenForSms;
    } on PlatformException {
      code = null;
    }
    emit(VerificationStates());
    AltSmsAutofill().unregisterListener();
  }
}
