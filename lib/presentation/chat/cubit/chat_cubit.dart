import 'package:bloc/bloc.dart';
import 'package:chat_app/app/di.dart';
import 'package:chat_app/domain/repository/group_chat_repo.dart';
import 'package:chat_app/domain/repository/notification_repo.dart';
import 'package:chat_app/domain/repository/single_chat_repo.dart';
import 'package:chat_app/presentation/chat/cubit/chat_states.dart';
import 'package:chat_app/presentation/resources/language_manger.dart';
import 'package:chat_app/presentation/resources/strings_manager.dart';
import '../../../app/constants.dart';
import '../../../domain/models/models.dart';
import '../../cubit/app_cubit.dart';

class InChatCubit extends Cubit<InChatStates> {
  InChatCubit() : super(InChatInitialState());
  final SingleChatRepo _singleChatRepo = instance<SingleChatRepo>();
  final GroupChatRepo _groupChatRepo = instance<GroupChatRepo>();
  final NotificationRepo _notificationRepo = instance<NotificationRepo>();
  late UserModel userModel;
  late bool isGroup;
  late GroupChatModel groupModel;

  final chatAppCubit = instance<ChatAppCubit>();

  List<MessageModel> messages = [];

  Future<void> getMessages(UserModel model) async {
    emit(GetMessagesLoadingState());
    (await _singleChatRepo.getMessages(senderUID: UID!, receiverUID: model.uid))
        .fold((failure) {
      emit(GetMessagesErrorState(failure.message));
    }, (stream) async {
      stream.listen((event) {
        messages = [];
        messages.addAll(event.toList());
        emit(GetMessagesSuccessState());
      });
      await setUnreadMessages(model.uid);
      await getUserStatus(model.uid);
    });
  }

  void sendMessage(String message, {required UserModel receiverModel}) async {
    final time = DateTime.now().toString();
    MessageModel messageModel = MessageModel(message, appUserModel!.uid,
        appUserModel!.username, receiverModel.uid, time);
    messages.insert(Constants.zero, messageModel);
    emit(SendMessagesLoadingState());
    ChatModel chatModel = ChatModel(
        appUserModel!.uid, receiverModel.uid, message, time, Constants.zero,
        messageModel: messageModel);
    (await _singleChatRepo.sendMessage(chatModel)).fold((failure) {
      messageModel.error = true;
      emit(SendMessagesErrorState(failure.message));
    }, (r) {
      emit(SendMessageSuccessState());
    });

    if (state is SendMessageSuccessState) {
      if (receiverModel.userDeviceLang == LanguageType.ENGLISH.getValue()) {
        await sendNotification(
          receiverModel: receiverModel,
          body: AppStrings.notificationChatBodyEN,
          title: AppStrings.notificationTitleEN,
        );
      } else {
        await sendNotification(
          receiverModel: receiverModel,
          body: AppStrings.notificationChatBodyAR,
          title: AppStrings.notificationTitleAR,
        );
      }
    }
  }

  sendNotification(
      {required UserModel receiverModel,
      required String body,
      required String title,
      String? groupName}) async {
    (await _notificationRepo.sendNotification(receiverModel,
            "${appUserModel!.nickName} $body${groupName ?? ""}", title))
        .fold((l) {
      emit(SendMessagesErrorState(l.message));
    }, (r) {
      emit(SendNotificationSuccessState());
    });
  }

  setUnreadMessages(String fromUID) async {
    (await _singleChatRepo.setUnreadMessages(
            toUID: UID!, fromUID: fromUID, isRead: true))
        .fold((l) {
      emit(SetUnreadMessagesErrorState(l.message));
    }, (r) {
      emit(SetUnreadMessagesSuccessState());
    });
  }

  Future<void> getUserStatus(String uid) async {
    (await _singleChatRepo.getUserStatus(uid)).fold((failure) {
      emit(GetUserStatusErrorState(failure.message));
    }, (statusStream) {
      statusStream.listen((status) {
        userModel.status = status;
        emit(GetUserStatusSuccessState());
      });
    });
  }

  void sendGroupMessage(String message,
      {required GroupChatModel groupModel}) async {
    final time = DateTime.now().toString();
    MessageModel messageModel = MessageModel(message, appUserModel!.uid,
        appUserModel!.username, Constants.empty, time);
    messages.insert(0, messageModel);
    emit(SendMessagesLoadingState());
    (await _groupChatRepo.sendGroupMessage(
            messageModel: messageModel, groupModel: groupModel))
        .fold((failure) {
      messageModel.error = true;
      emit(SendMessagesErrorState(failure.message));
    }, (r) {
      emit(SendMessageSuccessState());
    });

    if (state is SendMessageSuccessState) {
      for (var element in chatAppCubit.groupMembers.values) {
        if (!element.isEqual(appUserModel!)) {
          if (element.userDeviceLang == LanguageType.ENGLISH.getValue()) {
            await sendNotification(
                receiverModel: element,
                body: AppStrings.notificationGroupBodyEN,
                title: AppStrings.notificationTitleEN,
                groupName: groupModel.groupName);
          } else {
            await sendNotification(
                receiverModel: element,
                body: AppStrings.notificationGroupBodyAR,
                title: AppStrings.notificationTitleAR,
                groupName: groupModel.groupName);
          }
        }
      }
    }
  }

  void getGroupMessages(String groupID) async {
    emit(GetMessagesLoadingState());
    (await _groupChatRepo.getGroupMessages(groupID)).fold((failure) {
      emit(GetMessagesErrorState(failure.message));
    }, (stream) {
      stream.listen((event) {
        messages = [];
        messages.addAll(event);
        emit(GetMessagesSuccessState());
      });
    });
  }

  setGroupUnreadMessages(
    GroupChatModel groupModel,
  ) async {
    (await _groupChatRepo.setUnreadMessages(groupModel,
            readerUser: appUserModel!.uid))
        .fold((l) {
      emit(SetUnreadMessagesErrorState(l.message));
    }, (r) {
      emit(SetUnreadMessagesSuccessState());
    });
  }
}
