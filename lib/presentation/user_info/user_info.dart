import 'package:chat_app/app/constants.dart';
import 'package:chat_app/app/di.dart';
import 'package:chat_app/app/functions.dart';
import 'package:chat_app/domain/models/models.dart';
import 'package:chat_app/presentation/common/widgets.dart';
import 'package:chat_app/presentation/cubit/app_cubit.dart';
import 'package:chat_app/presentation/cubit/app_states.dart';
import 'package:chat_app/presentation/resources/assets_manager.dart';
import 'package:chat_app/presentation/resources/color_manager.dart';
import 'package:chat_app/presentation/resources/constants_manager.dart';
import 'package:chat_app/presentation/resources/strings_manager.dart';
import 'package:chat_app/presentation/resources/values_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserInfoView extends StatefulWidget {
  const UserInfoView({super.key});

  @override
  State<UserInfoView> createState() => _UserInfoViewState();
}

class _UserInfoViewState extends State<UserInfoView> {
  late UserModel _userModel;
  late bool _isCurrentUser;
  final TextEditingController _nickNameController = TextEditingController();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  _initModel() {
    _userModel = ModalRoute.of(context)?.settings.arguments as UserModel;
    _isCurrentUser = _userModel.isEqual(appUserModel!);
    _initFields();
  }

  _initFields() {
    _nickNameController.text = _userModel.nickName;
    _userNameController.text = _userModel.username;
    _bioController.text = _userModel.bio;
  }

  @override
  Widget build(BuildContext context) {
    _initModel();
    return BlocConsumer<ChatAppCubit, ChatAppStates>(
      listener: (context, state) {
        _listenerStateValidation(state);
      },
      builder: (context, state) {
        return _getContentWidget();
      },
    );
  }

  _listenerStateValidation(ChatAppStates state) {
    if (state is UpdateUserDataLoadingState ||
        state is UploadImageLoadingState) {
      dismissDialog(context);
      showDialog(
        context: context,
        builder: (context) => getDialogWidget(context,
            animatedImage: JsonAssets.loading, title: AppStrings.loading.tr()),
      );
    } else if (state is UpdateUserDataSuccessState) {
      dismissDialog(context);
      showDialog(
        context: context,
        builder: (context) => getDialogWidget(context,
            isConfirmation: true,
            animatedImage: JsonAssets.success,
            title: AppStrings.updatedSuccessfully.tr()),
      );
    } else if (state is UpdateUserDataErrorState) {
      dismissDialog(context);
      showDialog(
        context: context,
        builder: (context) => getDialogWidget(context,
            isConfirmation: true,
            animatedImage: JsonAssets.error,
            title: state.errorMessage),
      );
    }
  }

  Widget _getContentWidget() {
    var cubit = instance<ChatAppCubit>();
    return Scaffold(
      backgroundColor: ColorManager.backgroundColor,
      appBar: AppBar(
        leading: appBarLeading(onPressed: () {
          cubit.image = null;
          Navigator.of(context).pop();
        }),
        title: Text(
          AppStrings.userInfo.tr(),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        systemOverlayStyle:
            const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppPadding.p12, vertical: AppPadding.p20),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: AppSize.s82,
                    backgroundColor: ColorManager.white,
                  ),
                  Stack(alignment: Alignment.bottomRight, children: [
                    CircleAvatar(
                      radius: AppSize.s80,
                      backgroundColor: ColorManager.darkGray,
                      child: Container(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        height: double.infinity,
                        width: double.infinity,
                        decoration: const BoxDecoration(shape: BoxShape.circle),
                        child: cubit.image == null
                            ? Image(
                                image: NetworkImage(_userModel.imageLink),
                                fit: BoxFit.cover,
                              )
                            : Image.file(cubit.image!, fit: BoxFit.cover),
                      ),
                    ),
                    if (_isCurrentUser) ...[
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
                        child: CircleAvatar(
                          backgroundColor: ColorManager.darkGray,
                          child: Icon(Icons.camera_alt_outlined,
                              color: ColorManager.white),
                        ),
                      ),
                    ]
                  ]),
                ],
              ),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: AppSize.s20,
                    ),
                    Text(AppStrings.nickName.tr(),
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(
                      height: AppSize.s6,
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return AppStrings.thisFieldIsRequired.tr();
                        }
                        return null;
                      },
                      controller: _nickNameController,
                      enabled: _isCurrentUser,
                      maxLength: AppConstants.textFieldMaxLength,
                      style: Theme.of(context).textTheme.displaySmall,
                      decoration: const InputDecoration(
                        counterText: Constants.empty,
                      ),
                    ),
                    const SizedBox(
                      height: AppSize.s20,
                    ),
                    Text(AppStrings.userName.tr(),
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(
                      height: AppSize.s6,
                    ),
                    TextFormField(
                      validator: (value) {
                        if (value!.isEmpty) {
                          return AppStrings.thisFieldIsRequired.tr();
                        } else if (value.contains(" ")) {
                          return AppStrings.userNameCantContainSpaces.tr();
                        }
                        return null;
                      },
                      maxLength: AppConstants.textFieldMaxLength,
                      controller: _userNameController,
                      enabled: _isCurrentUser,
                      style: Theme.of(context).textTheme.displaySmall,
                      decoration: const InputDecoration(
                        counterText: Constants.empty,
                      ),
                    ),
                    const SizedBox(
                      height: AppSize.s20,
                    ),
                    Text(AppStrings.bio.tr(),
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(
                      height: AppSize.s6,
                    ),
                    TextField(
                      minLines: AppConstants.minLines,
                      maxLines: AppConstants.maxLines,
                      maxLength: AppConstants.bioMaxLength,
                      controller: _bioController,
                      style: Theme.of(context).textTheme.displaySmall,
                      enabled: _isCurrentUser,
                      decoration: const InputDecoration(
                        counterText: Constants.empty,
                      ),
                    ),
                  ],
                ),
              ),
              if (_isCurrentUser) ...[
                const SizedBox(
                  height: AppSize.s30,
                ),
                SizedBox(
                  width: double.infinity,
                  height: AppSize.s40,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        cubit.updateUserInfo(
                            nickName: _nickNameController.text,
                            username: _userNameController.text,
                            bio: _bioController.text);
                      }
                    },
                    child: Text(
                      AppStrings.uploadYourData.tr(),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
