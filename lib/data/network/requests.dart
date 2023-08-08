class UserAuthenticationRequest {
  String verificationId;
  String smsCode;

  UserAuthenticationRequest(this.verificationId, this.smsCode);
}

class UserRequest {
  String? uid;
  String? status;
  String? username;
  String? phoneNumber;
  String? nickName;
  String? imageLink;
  String? bio;
  String? deviceToken;
  String? userDeviceLang;

  UserRequest(
      this.uid,
      this.status,
      this.username,
      this.phoneNumber,
      this.nickName,
      this.imageLink,
      this.bio,
      this.deviceToken,
      this.userDeviceLang);

  factory UserRequest.fromJson(Map<String, dynamic>? data) {
    if (data == null) {
      return UserRequest(null, null, null, null, null, null, null, null , null);
    } else {
      return UserRequest(
        data['uid'],
        data['status'],
        data['username'],
        data['phoneNumber'],
        data['nickname'],
        data['imageLink'],
        data['bio'],
        data['deviceToken'],
        data['userDeviceLang'],
      );
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'status': status,
      'username': username,
      'nickname': nickName,
      'imageLink': imageLink,
      'phoneNumber': phoneNumber,
      'bio': bio,
      'deviceToken': deviceToken,
      'userDeviceLang': userDeviceLang,
    };
  }
}

class MessageRequest {
  String? message;
  String? senderUID;
  String? senderName;
  String? receiverUID;
  String? dateTime;

  MessageRequest(this.message, this.senderUID, this.senderName,
      this.receiverUID, this.dateTime);

  //from json
  factory MessageRequest.fromJson(Map<String, dynamic>? data) {
    if (data == null) {
      return MessageRequest(null, null, null, null, null);
    } else {
      return MessageRequest(data['message'], data['senderUID'],
          data['senderName'], data['receiverUID'], data['dateTime']);
    }
  }

  //to json
  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'senderUID': senderUID,
      'senderName': senderName,
      'receiverUID': receiverUID,
      'dateTime': dateTime,
    };
  }
}

class ChatRequest {
  String? senderUser;
  String? receiverUser;
  String? lastMessageTime;
  int? unreadMessages;
  String? lastMessage;
  MessageRequest? messageRequest;

  ChatRequest(this.senderUser, this.receiverUser, this.lastMessage,
      this.lastMessageTime, this.unreadMessages,
      {this.messageRequest});

  //from json
  factory ChatRequest.fromJson(Map<String, dynamic>? data) {
    if (data == null) {
      return ChatRequest(null, null, null, null, null);
    } else {
      return ChatRequest(
        data['senderUser'],
        data['receiverUser'],
        data['lastMessage'],
        data['lastMessageTime'],
        data['unreadMessages'],
      );
    }
  }

  //to json
  Map<String, dynamic> toMap() {
    return {
      'senderUser': senderUser,
      'receiverUser': receiverUser,
      'lastMessageTime': lastMessageTime,
      'lastMessage': lastMessage,
    };
  }
}

class NotificationRequest {
  final String image;
  final String body;
  final String title;
  String? priority;
  final String token;
  Map<String, dynamic>? data;

  NotificationRequest(this.image, this.body, this.title, this.token,
      {this.priority, this.data});

  Map<String, dynamic> toMap() {
    return {
      'notification': <String, dynamic>{
        'image': image,
        'body': body,
        'title': title,
      },
      'priority': priority ?? 'high',
      'data': data ??
          {'click_action': 'FLUTTER_NOTIFICATION_CLICK', 'status': 'done'},
      "to": token,
    };
  }
}

class GroupChatRequest {
  Map<String, int>? groupMembers;
  String? uid;
  String? groupName;
  String? groupImage;
  String? lastSender;
  String? lastMessageTime;
  String? lastMessage;

  GroupChatRequest(
    this.uid,
    this.groupName,
    this.groupImage,
    this.groupMembers,
    this.lastSender,
    this.lastMessage,
    this.lastMessageTime,
  );

  //from json
  factory GroupChatRequest.fromJson(Map<String, dynamic>? data) {
    if (data == null) {
      return GroupChatRequest(null, null, null, null, null, null, null);
    } else {
      return GroupChatRequest(
        data['uid'],
        data['groupName'],
        data['groupImage'],
        Map.from(data['groupMembers']),
        data['lastSender'],
        data['lastMessage'],
        data['lastMessageTime'],
      );
    }
  }

  //to json
  Map<String, dynamic> toMap() {
    return {
      'groupName': groupName,
      'groupImage': groupImage,
      'groupMembers': groupMembers,
      'lastMessageTime': lastMessageTime,
      'lastMessage': lastMessage,
    };
  }
}
