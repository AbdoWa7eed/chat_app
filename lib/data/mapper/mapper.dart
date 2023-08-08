import 'package:chat_app/app/constants.dart';
import 'package:chat_app/app/extensions.dart';
import 'package:chat_app/data/network/requests.dart';
import 'package:chat_app/domain/models/models.dart';

extension UserModelMapper on UserModel {
  UserRequest toUserRequest() {
    return UserRequest(uid, status, username, phoneNumber, nickName, imageLink,
        bio, deviceToken, userDeviceLang);
  }
}

extension UserRequestMapper on UserRequest? {
  UserModel toUserModel() {
    return UserModel(
        this?.uid.orEmpty() ?? Constants.empty,
        this?.status.orEmpty() ?? Constants.empty,
        this?.username.orEmpty() ?? Constants.empty,
        this?.phoneNumber.orEmpty() ?? Constants.empty,
        this?.nickName.orEmpty() ?? Constants.empty,
        this?.imageLink.orEmpty() ?? Constants.empty,
        this?.bio.orEmpty() ?? Constants.empty,
        this?.deviceToken.orEmpty() ?? Constants.empty,
        this?.userDeviceLang.orEmpty() ?? Constants.empty);
  }
}

extension MessageRequestMapper on MessageRequest? {
  MessageModel toMessageModel() {
    return MessageModel(
        this?.message.orEmpty() ?? Constants.empty,
        this?.senderUID.orEmpty() ?? Constants.empty,
        this?.senderName.orEmpty() ?? Constants.empty,
        this?.receiverUID.orEmpty() ?? Constants.empty,
        this?.dateTime.orEmpty() ?? Constants.empty);
  }
}

extension MessageModelMapper on MessageModel? {
  MessageRequest toMessageRequest() {
    return MessageRequest(
        this?.message.orEmpty() ?? Constants.empty,
        this?.senderUID.orEmpty() ?? Constants.empty,
        this?.senderName.orEmpty() ?? Constants.empty,
        this?.receiverUID.orEmpty() ?? Constants.empty,
        this?.dateTime.orEmpty() ?? Constants.empty);
  }
}

extension ChatRequsetMapper on ChatRequest? {
  ChatModel toChatModel() {
    return ChatModel(
      this?.senderUser?.orEmpty() ?? Constants.empty,
      this?.receiverUser?.orEmpty() ?? Constants.empty,
      this?.lastMessage.orEmpty() ?? Constants.empty,
      this?.lastMessageTime.orEmpty() ?? Constants.empty,
      this?.unreadMessages.orZero() ?? Constants.zero,
      messageModel: this?.messageRequest.toMessageModel(),
    );
  }
}

extension ChatModelMapper on ChatModel {
  ChatRequest toChatRequest() {
    return ChatRequest(
        senderUser, receiverUser, lastMessage, lastMessageTime, unreadMessages,
        messageRequest: messageModel.toMessageRequest());
  }
}

extension GroupChatRequestMapper on GroupChatRequest? {
  GroupChatModel toGroupChatModel() {
    return GroupChatModel(
      this?.uid.orEmpty() ?? Constants.empty,
      this?.groupName.orEmpty() ?? Constants.empty,
      this?.groupImage.orEmpty() ?? Constants.empty,
      this?.groupMembers ?? {},
      this?.lastSender ?? Constants.empty,
      this?.lastMessageTime ?? Constants.empty,
      this?.lastMessage ?? Constants.empty,
    );
  }
}

extension GroupChatModelMapper on GroupChatModel {
  GroupChatRequest toGroupChatRequest() {
    return GroupChatRequest(uid, groupName, groupImage, groupMembers,
        lastSender, lastMessage, lastMessageTime);
  }
}
