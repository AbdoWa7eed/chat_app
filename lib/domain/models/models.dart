class UserModel {
  String uid;
  String status;
  String username;
  String phoneNumber;
  String nickName;
  String imageLink;
  String bio;
  String deviceToken;
  String userDeviceLang;

  UserModel(this.uid, this.status, this.username, this.phoneNumber,
      this.nickName, this.imageLink, this.bio, this.deviceToken , this.userDeviceLang);


  bool isEqual(UserModel userModel){
    if(uid == userModel.uid){
      return true;
    }else{
      return false;
    }
  }    
}

class MessageModel {
  String message;
  String senderUID;
  String senderName;
  String receiverUID;
  String dateTime;
  bool isError;

  MessageModel(this.message, this.senderUID,this.senderName,this.receiverUID, this.dateTime,
      {this.isError = false});

  set error(bool isError) {
    this.isError = isError;
  }
}

class ChatModel {
  String senderUser;
  String receiverUser;
  String lastMessage;
  String lastMessageTime;
  int unreadMessages;
  MessageModel? messageModel;

  ChatModel(this.senderUser, this.receiverUser, this.lastMessage,
      this.lastMessageTime, this.unreadMessages,
      {this.messageModel});
}

class GroupChatModel {
  String groupName;
  String groupImage;
  String uid;
  Map<String , int> groupMembers;
  String lastSender;
  String lastMessageTime;
  String lastMessage;

  GroupChatModel(this.uid , this.groupName, this.groupImage, this.groupMembers ,this.lastSender,
      this.lastMessageTime,this.lastMessage);
}
