import 'package:firebase_messaging/firebase_messaging.dart';

import '../../network/app_api.dart';
import '../../network/requests.dart';

abstract class NotificationDataSource {

  Future<void> sendNotification(
      UserRequest userRequest, String body, String title);

  Future<String?> getDeviceToken();
}

class NotificationDataSourceImpl implements NotificationDataSource {
  final NotificationSender _notificationSender;
  final FirebaseMessaging _firebaseMessaging;

  NotificationDataSourceImpl(this._notificationSender , this._firebaseMessaging);

  @override
  Future<void> sendNotification(
      UserRequest userRequest, String body, String title) async {
    return await _notificationSender.sentMessageNotification(
        userRequest, body, title);
  }

  @override
  Future<String?> getDeviceToken() async {
    return await _firebaseMessaging.getToken();
  }
}
