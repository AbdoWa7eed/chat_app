// ignore_for_file: void_checks

import 'package:chat_app/app/constants.dart';
import 'package:chat_app/data/data_source/group_chat/group_data_source.dart';
import 'package:chat_app/data/mapper/mapper.dart';
import 'package:chat_app/data/network/failure.dart';
import 'package:chat_app/data/network/network_info.dart';
import 'package:chat_app/domain/models/models.dart';
import 'package:chat_app/domain/repository/group_chat_repo.dart';
import 'package:chat_app/presentation/resources/strings_manager.dart';
import 'package:dartz/dartz.dart';
import 'package:easy_localization/easy_localization.dart';

class GroupChatRepoImpl implements GroupChatRepo {
  final NetworkInfo _networkInfo;
  final GroupChatDataSource _groupChatDataSource;

  GroupChatRepoImpl(this._networkInfo, this._groupChatDataSource);

  @override
  Future<Either<Failure, void>> sendGroupMessage(
      {required MessageModel messageModel,
      required GroupChatModel groupModel}) async {
    if (await _networkInfo.isConnected) {
      try {
        await _groupChatDataSource.sendGroupMessage(
            messageModel.toMessageRequest(), groupModel.toGroupChatRequest());
        return const Right(Constants.zero);
      } catch (error) {
        return Left(Failure(AppStrings.anErrorOccurred.tr()));
      }
    } else {
      return Left(Failure(AppStrings.connectionError.tr()));
    }
  }

  @override
  Future<Either<Failure, Stream<List<MessageModel>>>> getGroupMessages(
      String groupID) async {
    if (await _networkInfo.isConnected) {
      try {
        var response = _groupChatDataSource.getGroupMessages(groupID);
        return Right(response.map((list) => list
            .map((messageRequest) => messageRequest.toMessageModel())
            .toList()));
      } catch (error) {
        return Left(Failure(AppStrings.anErrorOccurred.tr()));
      }
    } else {
      return Left(Failure(AppStrings.connectionError.tr()));
    }
  }

  @override
  Future<Either<Failure, void>> setUnreadMessages(GroupChatModel group,
      {String? readerUser}) async {
    if (await _networkInfo.isConnected) {
      try {
        _groupChatDataSource.setUnreadMessages(group.toGroupChatRequest(),
            readerUser: readerUser);
        return const Right(Constants.zero);
      } catch (error) {
        return Left(Failure(AppStrings.anErrorOccurred.tr()));
      }
    } else {
      return Left(Failure(AppStrings.connectionError.tr()));
    }
  }
}
