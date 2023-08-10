import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:chat_app/app/app_preferences.dart';
import 'package:chat_app/app/constants.dart';
import 'package:chat_app/app/di.dart';
import 'package:chat_app/domain/models/models.dart';
import 'package:chat_app/domain/repository/home_repository.dart';
import 'package:chat_app/domain/repository/notification_repo.dart';
import 'package:chat_app/presentation/common/functions.dart';
import 'package:chat_app/presentation/cubit/app_states.dart';
import 'package:chat_app/presentation/resources/language_manger.dart';
import 'package:chat_app/presentation/resources/strings_manager.dart';
import 'package:image_picker/image_picker.dart';

class ChatAppCubit extends Cubit<ChatAppStates> {
  ChatAppCubit() : super(ChatAppInitialState());
  final HomeRepository _homeRepository = instance<HomeRepository>();
  final AppPreferences appPreferences = instance<AppPreferences>();
  final NotificationRepo _notificationRepo = instance<NotificationRepo>();
  int tabBarIndex = 0;
  File? image;
  String? _imageUrl;

  Future<void> setAppLanguage() async {
    bool isUpdated = false;
    if (await appPreferences.getAppLanguage() ==
        LanguageType.ENGLISH.getValue()) {
      (await _homeRepository
              .setUserDeviceLanguage(LanguageType.ARABIC.getValue()))
          .fold((failure) {}, (success) {
        isUpdated = true;
      });
    } else {
      (await _homeRepository
              .setUserDeviceLanguage(LanguageType.ENGLISH.getValue()))
          .fold((failure) {}, (success) {
        isUpdated = true;
      });
    }
    if (isUpdated) {
      await appPreferences.changeAppLanguage();
    }
  }

  setDeviceToken(String token) async {
    (await _homeRepository.setDeviceToken(token)).fold((failure) {
      emit(SetTokenErrorState(failure.message));
    }, (success) {
      emit(SetTokenSuccessState());
    });
  }

  UserModel? userModel;

  getUserData(String username, {isUID = false}) async {
    emit(GetUserLoadingState());
    (await _homeRepository.getUserData(username, isUID: isUID)).fold((failure) {
      userModel = null;
      emit(GetUserErrorState(failure.message));
    }, (userModel) {
      if (appUserModel == null) {
        appUserModel = userModel;
      } else {
        this.userModel = userModel;
      }
      emit(GetUserSuccessState());
    });
  }

  List<ChatModel> chats = [];
  int? currentChatIndex;

  getChats() async {
    (await _homeRepository.getChats(UID!)).fold((failure) {
      emit(GetChatsErrorState(failure.message));
    }, (stream) async {
      stream.listen((listChatModel) async {
        chats.clear();
        chats.addAll(listChatModel);
        await getChattingUsers();
        emit(GetChatsSuccessState());
      });
    });
  }

  setStatus(status) async {
    (await _homeRepository.setUserStatus(status)).fold((failure) {
      emit(SetUserStatusErrorState(failure.message));
    }, (success) {
      emit(SetUserStatusSuccessState());
    });
  }

  List<UserModel> users = [];
  void createUsersList() {
    users.clear();
    for (var e in chattingUsers.entries) {
      users.add(e.value);
    }
  }

  Future<void> _uploadImage() async {
    emit(UploadImageLoadingState());
    (await _homeRepository.uploadImage(image!)).fold((failure) {
      emit(UploadImageErrorState(failure.message));
    }, (url) {
      _imageUrl = url;
      emit(UploadImageSuccessState());
    });
  }

  updateUserInfo({
    required String nickName,
    required String username,
    required String bio,
  }) async {
    if (image != null) {
      await _uploadImage();
    }
    emit(UpdateUserDataLoadingState());
    UserModel userModel = UserModel(
        appUserModel!.uid,
        appUserModel!.status,
        username,
        appUserModel!.phoneNumber,
        nickName,
        _imageUrl ?? appUserModel!.imageLink,
        bio,
        appUserModel!.deviceToken,
        appUserModel!.userDeviceLang);
    (await _homeRepository.updateUserData(userModel)).fold((failure) {
      emit(UpdateUserDataErrorState(failure.message));
    }, (success) {
      appUserModel = userModel;
      if (image != null) {
        image = null;
      }
      emit(UpdateUserDataSuccessState());
    });
  }

  createNewGroup(String name) async {
    Map<String, int> groupMembers = {};
    groupMembers[appUserModel!.uid] = 0;
    checkedUsers.forEach((key, value) {
      groupMembers[users[key].uid] = 0;
    });
    GroupChatModel groupModel = GroupChatModel(
        Constants.empty,
        name,
        Constants.defaultUserImage,
        groupMembers,
        Constants.empty,
        Constants.empty,
        Constants.empty);
    emit(CreateGroupLoadingState());
    (await _homeRepository.createNewGroup(groupModel)).fold((failure) {
      emit(CreateGroupErrorState(failure.message));
    }, (r) {
      getUserGroups();
      emit(CreateGroupSuccessState());
    });

    if (state is CreateGroupSuccessState) {
      checkedUsers.forEach((key, value) async {
        await sendNewGroupNotification(userModel: users[key], groupName: name);
      });
      checkedUsers.clear();
    }
  }

  sendNewGroupNotification(
      {required UserModel userModel, required String groupName}) async {
    if (userModel.userDeviceLang == LanguageType.ENGLISH.getValue()) {
      (await _notificationRepo.sendNotification(
              userModel,
              "${appUserModel!.nickName} ${AppStrings.newGroupNotificationBodyEN}$groupName",
              AppStrings.newGroupNotificationTitleEN))
          .fold((l) {
        emit(SendNewGroupNotificationErrorState(l.message));
      }, (r) {
        emit(SendNewGroupNotificationSuccessState());
      });
    } else {
      (await _notificationRepo.sendNotification(
              userModel,
              "${appUserModel!.nickName} ${AppStrings.newGroupNotificationBodyAR}$groupName",
              AppStrings.newGroupNotificationTitleAR))
          .fold((l) {
        emit(SendNewGroupNotificationErrorState(l.message));
      }, (r) {
        emit(SendNewGroupNotificationSuccessState());
      });
    }
  }

  List<GroupChatModel> groups = [];
  getUserGroups() async {
    emit(GetChatsLoadingState());
    (await _homeRepository.getUserGroups(appUserModel!.uid)).fold((failure) {
      emit(GetChatsErrorState(failure.message));
    }, (groupsStream) {
      groupsStream.listen((groupsList) {
        groups.clear();
        groups.addAll(groupsList);
        emit(GetChatsSuccessState());
      });
    });
  }

  Map<String, UserModel> groupMembers = {};

  Future<void> getGroupMembers(GroupChatModel groupModel) async {
    groupMembers.clear();
    groupMembers[UID!] = appUserModel!;
    for (var element in groupModel.groupMembers.keys.toList()) {
      if (element != UID!) {
        await getUserData(element, isUID: true);
        groupMembers[element] = userModel!;
      }
    }
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

  Map<String, UserModel> chattingUsers = {};
  Future<void> getChattingUsers() async {
    checkedUsers.clear();
    emit(GetAllUsersLoadingState());
    (await _homeRepository.getChatUsers(UID!)).fold((failure) {
      emit(GetAllUsersErrorState(failure.message));
    }, (users) {
      chattingUsers = users;
      emit(GetAllUsersSuccessState());
    });
  }

  void setTabBarIndex(int index) {
    tabBarIndex = index;
    emit(TabBarChangeState());
    if (index == 0) {
      getChats();
    } else if (index == 1) {
      getUserGroups();
    }
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

  @override
  Future<void> close() {
    setStatus(DateTime.now().toString());
    return super.close();
  }
}
