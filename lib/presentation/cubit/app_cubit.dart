import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:chat_app/app/app_preferences.dart';
import 'package:chat_app/app/constants.dart';
import 'package:chat_app/app/di.dart';
import 'package:chat_app/domain/models/models.dart';
import 'package:chat_app/domain/repository/home_repository.dart';
import 'package:chat_app/domain/repository/notification_repo.dart';
import 'package:chat_app/presentation/cubit/app_states.dart';
import 'package:chat_app/presentation/resources/language_manger.dart';
import 'package:chat_app/presentation/resources/strings_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:image_picker/image_picker.dart';

class ChatAppCubit extends Cubit<ChatAppStates> {
  ChatAppCubit() : super(ChatAppInitialState());
  final HomeRepository _homeRepository = instance<HomeRepository>();
  final AppPreferences _appPreferences = instance<AppPreferences>();
  final NotificationRepo _notificationRepo = instance<NotificationRepo>();
  File? image;
  String? _imageUrl;
  int tabBarIndex = 0;
  bool isGroup = false;

  //Calling Firebase Functions
  void addUser(
      {required String username,
      required String nickName,
      String? bio,
      required Function onSuccess}) async {
    emit(AddUserLoadingState());
    if (image != null) {
      await _uploadImage();
    }
    String phoneNumber =
        _appPreferences.getUserPhoneNumber() ?? Constants.empty;
    String token = await getToken();
    await _appPreferences.setDeviceToken(token);
    userModel = UserModel(
        UID!,
        AppStrings.online,
        username,
        phoneNumber,
        nickName,
        _imageUrl ?? Constants.defaultUserImage,
        bio ?? Constants.empty,
        token,
        LanguageType.ENGLISH.getValue());
    (await _homeRepository.addNewUser(userModel!)).fold((failure) {
      emit(AddUserErrorState(failure.message));
    }, (r) async {
      _afterRegisterCompleted(username);
      onSuccess.call();
      emit(AddUserSuccessState());
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

  Future<void> setAppLanguage() async {
    print(await _appPreferences.getAppLanguage());
    bool isUpdated = false;
    if (await _appPreferences.getAppLanguage() ==
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
    if(isUpdated){
      await _appPreferences.changeAppLanguage();
    }
  }

  setDeviceToken(String token) async {
    (await _homeRepository.setDeviceToken(token)).fold((failure) {
      print(failure.message);
      emit(SetTokenErrorState(failure.message));
    }, (success) {
      emit(SetTokenSuccessState());
    });
  }

  void _afterRegisterCompleted(String username) {
    _appPreferences.deletePhoneNumber();
    _appPreferences.setUserRegistered();
    image = null;
    _imageUrl = null;
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
  int? currentChatIndex = null;

  getChats() async {
    emit(GetChatsLoadingState());
    (await _homeRepository.getChats(UID!)).fold((failure) {
      emit(GetChatsErrorState(failure.message));
    }, (stream) async {
      stream.listen((listChatModel) async {
        chats.clear();
        chats.addAll(listChatModel);
        getChattingUsers();
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
    chattingUsers.entries.forEach((e) => users.add(e.value));
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
    (await _homeRepository.updateGroupData(groupModel)).fold((failure) {
      emit(UpdateGroupDataErrorState(failure.message));
    }, (success) {
      if (image != null) {
        image = null;
      }
      emit(UpdateGroupDataSuccessState());
    });
  }

  addNewMembers(GroupChatModel groupModel) async {
    Map<String, int> newMembers = {};
    bool isExists = false;
    checkedUsers.forEach((key, value) {
      newMembers[users[key].uid] = 0;
      groupMembers[users[key].uid] = users[key];
      if (groupModel.groupMembers.containsKey(users[key].uid)) {
        emit(UpdateGroupDataErrorState(AppStrings.userIsExists.tr()));
        isExists = true;
      }
    });
    if (isExists) {
      return;
    }

    emit(UpdateGroupDataLoadingState());
    groupModel.groupMembers.addAll(newMembers);
    (await _homeRepository.updateGroupData(groupModel,
            newUsersIDs: newMembers.keys.toList()))
        .fold((failure) {
      emit(UpdateGroupDataErrorState(failure.message));
    }, (success) {
      emit(UpdateGroupDataSuccessState());
    });

    if (state is UpdateUserDataSuccessState) {
      checkedUsers.forEach((key, value) async {
        await sendNewGroupNotification(
            userModel: users[key], groupName: groupModel.groupName);
      });
      checkedUsers.clear();
    }
  }

  exitGroup(GroupChatModel groupModel, {required Function onExit}) async {
    groupModel.groupMembers.remove(appUserModel!.uid);
    groups.remove(groupModel);
    groupMembers.remove(appUserModel!.uid);
    bool isLastUser = groupMembers.isEmpty;
    (await _homeRepository.exitGroup(groupModel,
            userID: appUserModel!.uid, isLastUser: isLastUser))
        .fold((failure) {
      emit(ExitGroupErrorState(failure.message));
    }, (success) {
      onExit();
      groupMembers.clear();
      setTabBarIndex(0);
      emit(ExitGroupSuccessState());
    });
  }

  //UI Functions
  late ImagePicker _imagePicker;

  imageFromGallery() async {
    _imagePicker = instance<ImagePicker>();
    String? path =
        (await _imagePicker.pickImage(source: ImageSource.gallery))?.path;
    if (path != null) {
      image = File(path);
    }
    emit(PickedImageState());
  }

  imageFromCamera() async {
    _imagePicker = instance<ImagePicker>();
    String? path =
        (await _imagePicker.pickImage(source: ImageSource.camera))?.path;
    if (path != null) {
      image = File(path);
    }
    emit(PickedImageState());
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

  //private Functions
  Future<void> _uploadImage() async {
    emit(UploadImageLoadingState());
    (await _homeRepository.uploadImage(image!)).fold((failure) {
      emit(UploadImageErrorState(failure.message));
    }, (url) {
      _imageUrl = url;
      emit(UploadImageSuccessState());
    });
  }

  //close function
  @override
  Future<void> close() {
    setStatus(DateTime.now().toString());
    return super.close();
  }
}
