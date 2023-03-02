import 'dart:convert';
import 'package:chat_app/data/network/requests.dart';
import '../../app/constants.dart';
import 'package:http/http.dart' as http;

const authorization = 'Authorization';
const contentType = 'Content-Type';
const applicationJson = 'application/json';
const key = 'key=${Constants.appAPIKey}';
const notification = 'notification';

abstract class NotificationSender {

  Future<void> sentMessageNotification(
      UserRequest userRequest, String body, String title);
}

class NotificationSenderImpl implements NotificationSender {
  
  @override
  Future<void> sentMessageNotification(
      UserRequest userRequest, String body, String title) async {
      NotificationRequest request = NotificationRequest(
        appUserModel!.imageLink, body, title, userRequest.deviceToken!);
    await http.post(
      Uri.parse(Constants.baseUrl),
      headers: <String, String>{
        contentType: applicationJson,
        authorization: key,
      },
      body: jsonEncode(request.toMap()),
      
    );
  }
}
