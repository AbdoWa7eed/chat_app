import 'package:chat_app/app/constants.dart';
import 'package:chat_app/app/di.dart';
import 'package:chat_app/presentation/register/cubit/cubit.dart';
import 'package:chat_app/presentation/register/cubit/states.dart';
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
import '../../app/functions.dart';
import '../common/widgets.dart';

class RegisterView extends StatelessWidget {
  RegisterView({Key? key}) : super(key: key);

  final TextEditingController _nickNameController = TextEditingController();

  final TextEditingController _userNameController = TextEditingController();

  final TextEditingController _bioController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
      child: BlocConsumer<RegisterCubit, RegisterStates>(
        listener: (context, state) {
          _listenerStateValidation(context, state);
        },
        builder: (context, state) {
          var cubit = instance<RegisterCubit>();
          return _getContentWidget(context, cubit);
        },
      ),
    );
  }

  Widget _getContentWidget(BuildContext context, RegisterCubit cubit) {
    return Scaffold(
        backgroundColor: ColorManager.backgroundColor,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppPadding.p16),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: AppSize.s50,
                    ),
                    Center(
                      child: Column(
                        children: [
                          Text(
                            AppStrings.completeRegistration.tr(),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(
                            height: AppSize.s30,
                          ),
                          InkWell(
                              onTap: () {
                                showPicker(
                                  context,
                                  onCameraTapped: () {
                                    cubit.imageFromCamera();
                                  },
                                  onGalleryTapped: () {
                                    cubit.imageFromGallery();
                                  },
                                );
                              },
                              child: cubit.image == null
                                  ? SvgPicture.asset(
                                      ImageAssets.upload,
                                    )
                                  : _showImageWidget(cubit)),
                          const SizedBox(
                            height: AppSize.s10,
                          ),
                          Text(
                            AppStrings.uploadAPicture.tr(),
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSize.s40),
                    Text(
                      AppStrings.howAreYouCalled.tr(),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: AppPadding.p8),
                      child: TextFormField(
                        maxLength: AppConstants.textFieldMaxLength,
                        controller: _nickNameController,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return AppStrings.thisFieldIsRequired.tr();
                          }
                          return null;
                        },
                        style: Theme.of(context).textTheme.displaySmall,
                        decoration: InputDecoration(
                          counterText: Constants.empty,
                          hintText: AppStrings.nickName.tr(),
                        ),
                      ),
                    ),
                    Text(
                      AppStrings.yourUsername.tr(),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: AppPadding.p8),
                      child: TextFormField(
                        maxLength: AppConstants.textFieldMaxLength,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return AppStrings.thisFieldIsRequired.tr();
                          } else if (value.contains(" ")) {
                            return AppStrings.userNameCantContainSpaces.tr();
                          }
                          return null;
                        },
                        controller: _userNameController,
                        style: Theme.of(context).textTheme.displaySmall,
                        decoration: InputDecoration(
                          counterText: Constants.empty,
                          hintText: AppStrings.userName.tr(),
                        ),
                      ),
                    ),
                    Text(
                      AppStrings.tellPeopleAboutYou.tr(),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: AppPadding.p8),
                      child: TextFormField(
                        controller: _bioController,
                        minLines: AppConstants.minLines,
                        maxLines: AppConstants.maxLines,
                        maxLength: AppConstants.bioMaxLength,
                        style: Theme.of(context).textTheme.displaySmall,
                        decoration: InputDecoration(
                          counterText: Constants.empty,
                          hintText: AppStrings.bio.tr(),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: AppSize.s30,
                    ),
                    SizedBox(
                      height: AppSize.s50,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            cubit.addUser(
                                username: _userNameController.text,
                                nickName: _nickNameController.text,
                                bio: _bioController.text,
                                onSuccess: (token) {
                                  //dismissDialog(context);
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                      Routes.homeRoute, (route) => false,
                                      arguments: token);
                                });
                          }
                        },
                        child: Text(
                          AppStrings.uploadYourData.tr(),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  Widget _showImageWidget(RegisterCubit cubit) {
    return Container(
      height: AppSize.s100,
      width: AppSize.s100,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Image.file(
        cubit.image!,
        fit: BoxFit.cover,
      ),
    );
  }

  _listenerStateValidation(BuildContext context, RegisterStates state) {
    if (state is AddUserLoadingState) {
      dismissDialog(context);
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
    } else if (state is AddUserErrorState) {
      dismissDialog(context);
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return getDialogWidget(context,
              animatedImage: JsonAssets.error,
              title: state.errorMessage,
              isConfirmation: true);
        },
      );
    }
  }
}
