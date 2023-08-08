// ignore_for_file: void_checks

import 'package:chat_app/data/data_source/single_chat/chat_data_source.dart';
import 'package:chat_app/data/mapper/mapper.dart';
import 'package:chat_app/data/network/failure.dart';
import 'package:chat_app/data/network/network_info.dart';
import 'package:chat_app/domain/models/models.dart';
import 'package:chat_app/presentation/resources/strings_manager.dart';
import 'package:dartz/dartz.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../app/constants.dart';
import '../../domain/repository/single_chat_repo.dart';

class SingleChatRepoImpl implements SingleChatRepo {
  final NetworkInfo _networkInfo;
  final SingleChatDataSource _singleChatDataSource;

  SingleChatRepoImpl(this._networkInfo, this._singleChatDataSource);

  @override
  Future<Either<Failure, void>> sendMessage(ChatModel chatModel) async {
    if (await _networkInfo.isConnected) {
      try {
        await _singleChatDataSource.sendMessage(chatModel.toChatRequest());
        return const Right(Constants.zero);
      } catch (error) {
        return Left(Failure(AppStrings.anErrorOccurred.tr()));
      }
    } else {
      return Left(Failure(AppStrings.connectionError.tr()));
    }
  }

  @override
  Future<Either<Failure, void>> setUnreadMessages(
      {required toUID, required String fromUID, isRead = false}) async {
    if (await _networkInfo.isConnected) {
      try {
        await _singleChatDataSource.setUnreadMessages(toUID, fromUID,
            isRead: isRead);
        return const Right(Constants.zero);
      } catch (error) {
        return Left(Failure(AppStrings.anErrorOccurred.tr()));
      }
    } else {
      return Left(Failure(AppStrings.connectionError.tr()));
    }
  }

  @override
  Future<Either<Failure, Stream<List<MessageModel>>>> getMessages(
      {required String senderUID, required String receiverUID}) async {
    if (await _networkInfo.isConnected) {
      try {
        var response = await _singleChatDataSource.getMessages(
            receiverUID: receiverUID, senderUID: senderUID);
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
  Future<Either<Failure, Stream<String>>> getUserStatus(String uid) async {
    if (await _networkInfo.isConnected) {
      try {
        var response = _singleChatDataSource.getUserStatus(uid);
        return Right(response);
      } catch (error) {
        return Left(Failure(AppStrings.anErrorOccurred.tr()));
      }
    } else {
      return Left(Failure(AppStrings.connectionError.tr()));
    }
  }
}
