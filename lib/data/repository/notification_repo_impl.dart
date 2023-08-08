// ignore_for_file: void_checks

import 'package:chat_app/data/data_source/notification/notification_data_source.dart';
import 'package:chat_app/data/mapper/mapper.dart';
import 'package:chat_app/data/network/failure.dart';
import 'package:chat_app/data/network/network_info.dart';
import 'package:chat_app/domain/models/models.dart';
import 'package:chat_app/domain/repository/notification_repo.dart';
import 'package:chat_app/presentation/resources/strings_manager.dart';
import 'package:dartz/dartz.dart';
import 'package:easy_localization/easy_localization.dart';

import '../../app/constants.dart';

class NotificationRepoImpl implements NotificationRepo {
  final NetworkInfo _networkInfo;
  final NotificationDataSource _notificationDataSource;

  NotificationRepoImpl(this._networkInfo, this._notificationDataSource);

  @override
  Future<Either<Failure, void>> sendNotification(
      UserModel userModel, String body, String title) async {
    if (await _networkInfo.isConnected) {
      try {
        await _notificationDataSource.sendNotification(
            userModel.toUserRequest(), body, title);
        return const Right(Constants.zero);
      } catch (error) {
        return Left(Failure(AppStrings.anErrorOccurred.tr()));
      }
    } else {
      return Left(Failure(AppStrings.connectionError.tr()));
    }
  }

  @override
  Future<Either<Failure, String>> getDeviceToken() async {
    if (await _networkInfo.isConnected) {
      try {
        var response = await _notificationDataSource.getDeviceToken();
        return Right(response!);
      } catch (error) {
        return Left(Failure(AppStrings.anErrorOccurred.tr()));
      }
    } else {
      return Left(Failure(AppStrings.connectionError.tr()));
    }
  }
}
