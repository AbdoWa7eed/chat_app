import 'package:chat_app/app/constants.dart';
import 'package:chat_app/app/di.dart';
import 'package:chat_app/app/functions.dart';
import 'package:chat_app/domain/models/models.dart';
import 'package:chat_app/presentation/common/widgets.dart';
import 'package:chat_app/presentation/group_info/cubit/cubit.dart';
import 'package:chat_app/presentation/group_info/cubit/states.dart';
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

class GroupInfoView extends StatefulWidget {
  const GroupInfoView({super.key});

  @override
  State<GroupInfoView> createState() => _GroupInfoViewState();
}

class _GroupInfoViewState extends State<GroupInfoView> {
  late GroupChatModel _groupModel;
  final _groupNameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  _initModel() {
    _groupModel = ModalRoute.of(context)?.settings.arguments as GroupChatModel;
    _groupNameController.text = _groupModel.groupName;
  }

  @override
  Widget build(BuildContext context) {
    _initModel();

    return BlocProvider<GroupInfoCubit>.value(
      value: instance<GroupInfoCubit>(),
      child: BlocConsumer<GroupInfoCubit, GroupInfoStates>(
        listener: (context, state) {
          _listenerStateValidation(state);
        },
        builder: (context, state) {
          return _getContentWidget();
        },
      ),
    );
  }

  _listenerStateValidation(GroupInfoStates state) {
    if (state is UpdateGroupDataLoadingState ||
        state is UploadImageLoadingState) {
      dismissDialog(context);
      showDialog(
        context: context,
        builder: (context) => getDialogWidget(context,
            animatedImage: JsonAssets.loading, title: AppStrings.loading.tr()),
      );
    } else if (state is UpdateGroupDataSuccessState) {
      dismissDialog(context);
      showDialog(
        context: context,
        builder: (context) => getDialogWidget(context,
            isConfirmation: true,
            animatedImage: JsonAssets.success,
            title: AppStrings.updatedSuccessfully.tr()),
      );
    } else if (state is UpdateGroupDataErrorState) {
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
    var cubit = instance<GroupInfoCubit>();
    return Scaffold(
      backgroundColor: ColorManager.backgroundColor,
      appBar: AppBar(
        systemOverlayStyle:
            const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
        leading: appBarLeading(onPressed: () {
          cubit.image = null;
          Navigator.of(context).pop();
        }),
        title: Text(
          AppStrings.groupInfo.tr(),
          style: Theme.of(context).textTheme.bodyMedium,
        ),
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
                                image: NetworkImage(_groupModel.groupImage),
                                fit: BoxFit.cover,
                              )
                            : Image.file(cubit.image!, fit: BoxFit.cover),
                      ),
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
                      child: CircleAvatar(
                        backgroundColor: ColorManager.darkGray,
                        child: Icon(Icons.camera_alt_outlined,
                            color: ColorManager.white),
                      ),
                    ),
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
                    Text(AppStrings.groupName.tr(),
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
                      controller: _groupNameController,
                      style: Theme.of(context).textTheme.displaySmall,
                      maxLength: AppConstants.textFieldMaxLength,
                      enabled: true,
                      decoration:
                          const InputDecoration(counterText: Constants.empty),
                    ),
                    const SizedBox(
                      height: AppSize.s20,
                    ),
                    Text(AppStrings.members.tr(),
                        style: Theme.of(context).textTheme.titleMedium),
                    _getMembersListWidget(cubit),
                    ListTile(
                      onTap: () {
                        cubit.chatAppCubit.createUsersList();
                        showDialog(
                            context: context,
                            builder: (context) =>
                                _getAddMembersDialogWidget(cubit));
                      },
                      iconColor: ColorManager.primary,
                      leading: const Icon(
                        Icons.person,
                      ),
                      title: Text(AppStrings.addNewMembers.tr(),
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(color: ColorManager.primary)),
                    ),
                    ListTile(
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          cubit.updateGroupInfo(_groupModel,
                              name: _groupNameController.text);
                        }
                      },
                      iconColor: ColorManager.primary,
                      leading: const Icon(Icons.update_outlined),
                      title: Text(AppStrings.updateGroupData.tr(),
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(color: ColorManager.primary)),
                    ),
                    ListTile(
                      onTap: () {
                        cubit.exitGroup(_groupModel, onExit: () {
                          Navigator.pushNamedAndRemoveUntil(
                              context, Routes.homeRoute, (route) => false);
                        });
                      },
                      iconColor: ColorManager.error,
                      leading: const Icon(Icons.exit_to_app),
                      title: Text(AppStrings.exitGroup.tr(),
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(color: ColorManager.error)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getMembersListWidget(GroupInfoCubit cubit) {
    List groupMembers = cubit.groupMembers.values.toList();
    return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return _getUserItem(groupMembers[index]);
        },
        separatorBuilder: (context, index) =>
            const SizedBox(height: AppSize.s6),
        itemCount: groupMembers.length);
  }

  Widget _getUserItem(UserModel user) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed(Routes.userInfoRoute, arguments: user);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppPadding.p8),
        child: Row(
          children: [
            CircleAvatar(
              radius: AppSize.s25,
              backgroundImage: NetworkImage(user.imageLink),
              backgroundColor: ColorManager.darkGray,
            ),
            const SizedBox(
              width: AppSize.s10,
            ),
            Expanded(
              child: Text(
                user.nickName,
                maxLines: AppConstants.minLines,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getAddMembersDialogWidget(GroupInfoCubit cubit) {
    return BlocProvider<GroupInfoCubit>.value(
      value: instance<GroupInfoCubit>(),
      child: BlocConsumer<GroupInfoCubit, GroupInfoStates>(
        listener: (context, state) {
          _listenerStateValidation(state);
        },
        builder: (context, state) {
          return Dialog(
            backgroundColor: ColorManager.backgroundColor,
            child: Padding(
              padding: const EdgeInsets.all(AppPadding.p12),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const SizedBox(
                  height: AppSize.s20,
                ),
                Text(
                  AppStrings.selectMembers.tr(),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                getUsersListWidget(
                  cubit.chatAppCubit,
                  checkedUsers: cubit.checkedUsers,
                  onChanged: (value, index) {
                    cubit.addCheckedStateToMap(index, value);
                  },
                ),
                SizedBox(
                  width: double.infinity,
                  height: AppSize.s40,
                  child: ElevatedButton(
                    onPressed: () {
                      cubit.addNewMembers(_groupModel);
                    },
                    child: Text(AppStrings.addNewMembers.tr(),
                        style: Theme.of(context).textTheme.bodySmall),
                  ),
                ),
              ]),
            ),
          );
        },
      ),
    );
  }
}
