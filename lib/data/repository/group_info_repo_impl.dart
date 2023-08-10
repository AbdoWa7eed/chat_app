// ignore_for_file: void_checks

import 'dart:io';

import 'package:chat_app/app/constants.dart';
import 'package:chat_app/data/data_source/group_info/group_info_data_source.dart';
import 'package:chat_app/data/mapper/mapper.dart';
import 'package:chat_app/data/network/failure.dart';
import 'package:chat_app/data/network/network_info.dart';
import 'package:chat_app/domain/models/models.dart';
import 'package:chat_app/domain/repository/group_info_repo.dart';
import 'package:chat_app/presentation/resources/strings_manager.dart';
import 'package:dartz/dartz.dart';
import 'package:easy_localization/easy_localization.dart';

class GroupInfoRepoImpl implements GroupInfoRepo {
  final NetworkInfo _networkInfo;
  final GroupInfoDataSource _groupInfoDataSource;
  GroupInfoRepoImpl(this._networkInfo, this._groupInfoDataSource);

  @override
  Future<Either<Failure, String>> uploadImage(File file) async {
    if (await _networkInfo.isConnected) {
      try {
        var url = await _groupInfoDataSource.uploadImage(file);
        return Right(url);
      } catch (error) {
        return Left(Failure(AppStrings.errorWhileUploadingImage.tr()));
      }
    } else {
      return Left(Failure(AppStrings.connectionError.tr()));
    }
  }

  @override
  Future<Either<Failure, void>> updateGroupData(GroupChatModel groupModel,
      {List<String>? newUsersIDs}) async {
    if (await _networkInfo.isConnected) {
      try {
        await _groupInfoDataSource.updateGroupData(
            groupModel.toGroupChatRequest(),
            newUsersIDs: newUsersIDs);
        return const Right(Constants.zero);
      } catch (error) {
        return Left(Failure(AppStrings.anErrorOccurred.tr()));
      }
    } else {
      return Left(Failure(AppStrings.connectionError.tr()));
    }
  }

  @override
  Future<Either<Failure, void>> exitGroup(GroupChatModel groupModel,
      {required String userID, bool isLastUser = false}) async {
    if (await _networkInfo.isConnected) {
      try {
        await _groupInfoDataSource.exitGroup(
            groupModel.toGroupChatRequest(), userID,
            isLastUser: isLastUser);
        return const Right(Constants.zero);
      } catch (error) {
        return Left(Failure(AppStrings.anErrorOccurred.tr()));
      }
    } else {
      return Left(Failure(AppStrings.connectionError.tr()));
    }
  }
}
