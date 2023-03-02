import 'package:chat_app/data/network/failure.dart';
import 'package:chat_app/domain/models/models.dart';
import 'package:dartz/dartz.dart';

abstract class NotificationRepo {
  Future<Either<Failure, void>> sendNotification(
      UserModel userModel, String body, String title);

  Future<Either<Failure, String>> getDeviceToken();
}
