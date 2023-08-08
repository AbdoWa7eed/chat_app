// ignore_for_file: non_constant_identifier_names

import 'package:chat_app/domain/models/models.dart';

UserModel? appUserModel;
String? UID;

class Constants {
  static const String empty = "";
  static const int minusOne = -1;
  static const int zero = 0;
  static const String defaultUserImage =
      "https://firebasestorage.googleapis.com/v0/b/chat-app-a863d.appspot.com/o/images%2FdefualtUserImage%2Fdefault-user-image.png?alt=media&token=eefe9301-091f-4525-a719-254b3247c26e";

  static const String appAPIKey =
      'AAAAQTZi-as:APA91bHmoGqtOqpjB9yLvglqOf0sEh6NIoEbYe7yOhQ96N20tL6vm_-zNTkpXxFc1phcAV590xbHsljH_rCObzhm5nhYauGPMMsSyemvDZo2zlROrEgmTbgI5zWdohhpfJm5VJfTDUAP';

  static const String baseUrl = 'https://fcm.googleapis.com/fcm/send';
}
