import 'package:chat_app/app/di.dart';
import 'package:chat_app/presentation/common/widgets.dart';
import 'package:chat_app/presentation/phone_auth/cubit/cubit.dart';
import 'package:chat_app/presentation/phone_auth/cubit/states.dart';
import 'package:chat_app/presentation/resources/assets_manager.dart';
import 'package:chat_app/presentation/resources/color_manager.dart';
import 'package:chat_app/presentation/resources/constants_manager.dart';
import 'package:chat_app/presentation/resources/routes_manager.dart';
import 'package:chat_app/presentation/resources/strings_manager.dart';
import 'package:chat_app/presentation/resources/values_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:pinput/pinput.dart';

import '../../../app/functions.dart';

class VerifyCodeView extends StatelessWidget {
  VerifyCodeView({Key? key}) : super(key: key);
  final TextEditingController _pinPutController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PhoneAuthCubit>.value(
      value: instance<PhoneAuthCubit>(),
      child: BlocConsumer<PhoneAuthCubit, PhoneAuthStates>(
        listener: (context, state) {
          var cubit = instance<PhoneAuthCubit>();
          _autoFillPin(context, cubit);
          _listenerStateValidation(context, state);
        },
        builder: (context, state) {
          return _getContentWidget(context);
        },
      ),
    );
  }

  _listenerStateValidation(BuildContext context, PhoneAuthStates state) {
    if (state is VerifyCodeLoadingState) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return getDialogWidget(
            context,
            animatedImage: JsonAssets.loading,
            title: AppStrings.loading.tr(),
          );
        },
      );
    } else if (state is VerifyCodeErrorState) {
      dismissDialog(context);
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return getDialogWidget(
            context,
            animatedImage: JsonAssets.error,
            title: state.errorMessage,
            isConfirmation: true,
          );
        },
      );
    }
  }

  _autoFillPin(BuildContext context, PhoneAuthCubit cubit) {
    if (cubit.code != null) {
      _pinPutController.text = cubit.code!.substring(0, 6);
    }
  }

  Widget _getContentWidget(BuildContext context) {
    var cubit = instance<PhoneAuthCubit>();
    return Scaffold(
      backgroundColor: ColorManager.backgroundColor,
      appBar: AppBar(
        systemOverlayStyle:
            const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,
              size: AppSize.s20, color: ColorManager.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              SvgPicture.asset(
                ImageAssets.verifyCode,
                height: MediaQuery.of(context).size.height / 2,
              ),
              Text(
                AppStrings.verification,
                style: Theme.of(context).textTheme.bodyMedium,
              ).tr(),
              const SizedBox(
                height: AppSize.s10,
              ),
              Text(
                AppStrings.verificationMessage,
                style: Theme.of(context).textTheme.titleMedium,
              ).tr(),
              const SizedBox(
                height: AppSize.s10,
              ),
              Pinput(
                controller: _pinPutController,
                length: AppConstants.pinPutLength,
                pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                showCursor: true,
                onChanged: (value) {
                  if (_pinPutController.text.length == 6) {
                    cubit.signIn(
                        smsCode: _pinPutController.text,
                        onVerifiedSuccessfully: () async {
                          if (cubit.isExists) {
                            String token = await cubit.getToken();
                            if (context.mounted) {
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                  Routes.homeRoute, (route) => false , arguments: token);
                            }
                          } else {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              Routes.registerRoute,
                              (route) => false,
                            );
                          }
                        });
                  }
                },
                defaultPinTheme: PinTheme(
                  decoration: BoxDecoration(
                    color: ColorManager.white,
                    borderRadius: BorderRadius.circular(AppSize.s4),
                  ),
                  width: AppSize.s40,
                  height: AppSize.s40,
                ),
              ),
              const SizedBox(
                height: AppSize.s15,
              ),
              Text(AppStrings.didReceiveACode.tr(),
                  style: Theme.of(context).textTheme.titleMedium),
              TextButton(
                  onPressed: () {
                    cubit.sendVerificationCode(
                        phoneNumber: cubit.phoneNumber!, codeCent: () {});
                  },
                  child: Text(
                    AppStrings.resend.tr(),
                    style: Theme.of(context).textTheme.titleMedium,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
