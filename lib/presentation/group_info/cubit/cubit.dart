import 'dart:io';

import 'package:chat_app/app/constants.dart';
import 'package:chat_app/app/di.dart';
import 'package:chat_app/domain/models/models.dart';
import 'package:chat_app/domain/repository/group_info_repo.dart';
import 'package:chat_app/presentation/common/functions.dart';
import 'package:chat_app/presentation/cubit/app_cubit.dart';
import 'package:chat_app/presentation/group_info/cubit/states.dart';
import 'package:chat_app/presentation/resources/strings_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class GroupInfoCubit extends Cubit<GroupInfoStates> {
  GroupInfoCubit() : super(GroupInfoInitialState());

  File? image;
  ChatAppCubit chatAppCubit = instance<ChatAppCubit>();
  String? _imageUrl;
  final GroupInfoRepo _groupInfoRepo = instance<GroupInfoRepo>();

  Map<String, UserModel> groupMembers = {};
  initGroupMembers() {
    groupMembers = chatAppCubit.groupMembers;
  }

  Future<void> _uploadImage() async {
    emit(UploadImageLoadingState());
    (await _groupInfoRepo.uploadImage(image!)).fold((failure) {
      emit(UploadImageErrorState(failure.message));
    }, (url) {
      _imageUrl = url;
      emit(UploadImageSuccessState());
    });
  }

  updateGroupInfo(
    GroupChatModel groupModel, {
    required String name,
  }) async {
    if (image != null) {
      await _uploadImage();
      groupModel.groupImage = _imageUrl!;
    }
    emit(UpdateGroupDataLoadingState());
    groupModel.groupName = name;
    (await _groupInfoRepo.updateGroupData(groupModel)).fold((failure) {
      emit(UpdateGroupDataErrorState(failure.message));
    }, (success) {
      if (image != null) {
        image = null;
      }
      emit(UpdateGroupDataSuccessState());
    });
  }

  Map<int, bool> checkedUsers = {};
  addCheckedStateToMap(int index, bool? value) {
    if (value == true) {
      checkedUsers[index] = value!;
    } else {
      checkedUsers.remove(index);
    }
    emit(CheckBoxState());
  }

  addNewMembers(GroupChatModel groupModel) async {
    Map<String, int> newMembers = {};
    bool isExists = false;
    checkedUsers.forEach((key, value) {
      newMembers[chatAppCubit.users[key].uid] = 0;
      groupMembers[chatAppCubit.users[key].uid] = chatAppCubit.users[key];
      if (groupModel.groupMembers.containsKey(chatAppCubit.users[key].uid)) {
        isExists = true;
        emit(UpdateGroupDataErrorState(AppStrings.userIsExists.tr()));
      }
    });
    if (isExists) {
      checkedUsers.clear();
      return;
    }
    emit(UpdateGroupDataLoadingState());
    groupModel.groupMembers.addAll(newMembers);
    (await _groupInfoRepo.updateGroupData(groupModel,
            newUsersIDs: newMembers.keys.toList()))
        .fold((failure) {
      emit(UpdateGroupDataErrorState(failure.message));
    }, (success) {
      emit(UpdateGroupDataSuccessState());
    });

    if (state is UpdateGroupDataSuccessState) {
      chatAppCubit.checkedUsers.forEach((key, value) async {
        await chatAppCubit.sendNewGroupNotification(
            userModel: chatAppCubit.users[key],
            groupName: groupModel.groupName);
      });
      checkedUsers.clear();
    }
  }

  exitGroup(GroupChatModel groupModel, {required Function onExit}) async {
    groupModel.groupMembers.remove(appUserModel!.uid);
    chatAppCubit.groups.remove(groupModel);
    groupMembers.remove(appUserModel!.uid);
    bool isLastUser = groupMembers.isEmpty;
    (await _groupInfoRepo.exitGroup(groupModel,
            userID: appUserModel!.uid, isLastUser: isLastUser))
        .fold((failure) {
      emit(ExitGroupErrorState(failure.message));
    }, (success) {
      onExit();
      groupMembers.clear();
      chatAppCubit.setTabBarIndex(0);
      emit(ExitGroupSuccessState());
    });
  }

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
