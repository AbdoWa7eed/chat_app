import 'package:chat_app/app/di.dart';
import 'package:chat_app/app/functions.dart';
import 'package:chat_app/presentation/common/widgets.dart';
import 'package:chat_app/presentation/phone_auth/cubit/cubit.dart';
import 'package:chat_app/presentation/phone_auth/cubit/states.dart';
import 'package:chat_app/presentation/resources/assets_manager.dart';
import 'package:chat_app/presentation/resources/color_manager.dart';
import 'package:chat_app/presentation/resources/routes_manager.dart';
import 'package:chat_app/presentation/resources/strings_manager.dart';
import 'package:chat_app/presentation/resources/values_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class PhoneAuthenticationView extends StatefulWidget {
  const PhoneAuthenticationView({Key? key}) : super(key: key);

  @override
  State<PhoneAuthenticationView> createState() =>
      _PhoneAuthenticationViewState();
}

class _PhoneAuthenticationViewState extends State<PhoneAuthenticationView> {
  final TextEditingController _phoneFiledController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PhoneAuthCubit, PhoneAuthStates>(
      listener: (context, state) {
        _listenerStateValidation(context, state);
      },
      builder: (context, state) {
        return _getContent();
      },
    );
  }

  _listenerStateValidation(BuildContext context, PhoneAuthStates state) {
    if (state is SendCodeLoadingState) {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return getDialogWidget(context,
              animatedImage: JsonAssets.loading,
              title: AppStrings.loading.tr());
        },
      );
    } else if (state is SendCodeErrorState) {
      dismissDialog(context);
      showDialog(
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

  Widget _getContent() {
    var cubit = instance<PhoneAuthCubit>();
    String countryCode = "+20";
    return Scaffold(
      backgroundColor: ColorManager.backgroundColor,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SvgPicture.asset(ImageAssets.mobileAuth),
              Text(
                AppStrings.enterPhoneNumber.tr(),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(
                height: AppSize.s50,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppPadding.p20),
                child: IntlPhoneField(
                  style: Theme.of(context).textTheme.displaySmall,
                  controller: _phoneFiledController,
                  initialCountryCode: "EG",
                  onCountryChanged: (value) {
                    countryCode = value.dialCode;
                  },
                  dropdownTextStyle: Theme.of(context).textTheme.displaySmall,
                  showCountryFlag: false,
                  decoration: InputDecoration(
                    labelText: AppStrings.phoneNumber.tr(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppPadding.p28, vertical: AppPadding.p20),
                child: SizedBox(
                  height: AppSize.s50,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_validation()) {
                        String number =
                            countryCode + _phoneFiledController.text;
                        cubit.sendVerificationCode(
                            phoneNumber: number,
                            codeCent: () {
                              dismissDialog(context);
                              Navigator.of(context)
                                  .pushNamed(Routes.phoneVerifyRoute);
                            });
                      }
                    },
                    child: Text(
                      AppStrings.sendVerificationCode,
                      style: Theme.of(context).textTheme.bodySmall,
                    ).tr(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _validation() {
    return _formKey.currentState?.validate() ?? false;
  }
}
