// ignore_for_file: void_checks
import 'dart:io';

import 'package:chat_app/app/constants.dart';
import 'package:chat_app/data/data_source/home/home_data_source.dart';
import 'package:chat_app/data/mapper/mapper.dart';
import 'package:chat_app/data/network/failure.dart';
import 'package:chat_app/data/network/network_info.dart';
import 'package:chat_app/data/network/requests.dart';
import 'package:chat_app/domain/models/models.dart';
import 'package:chat_app/domain/repository/home_repository.dart';
import 'package:chat_app/presentation/resources/strings_manager.dart';
import 'package:dartz/dartz.dart';
import 'package:easy_localization/easy_localization.dart';

class HomeRepositoryImpl implements HomeRepository {
  final NetworkInfo _networkInfo;
  final HomeDataSource _homeDataSource;

  HomeRepositoryImpl(this._networkInfo, this._homeDataSource);

  @override
  Future<Either<Failure, UserModel>> getUserData(String user,
      {bool isUID = false}) async {
    if (await _networkInfo.isConnected) {
      try {
        UserRequest? response;
        if (!isUID) {
          response = await _homeDataSource.getUserData(user);
        } else {
          response = await _homeDataSource.getUserDataByUID(user);
        }
        if (response != null) {
          return Right(response.toUserModel());
        }
      } catch (error) {
        return Left(Failure(error.toString()));
      }
      return Left(Failure(AppStrings.noUserFound.tr()));
    } else {
      return Left(Failure(AppStrings.connectionError.tr()));
    }
  }

  @override
  Future<Either<Failure, void>> setUserStatus(String status) async {
    if (await _networkInfo.isConnected) {
      try {
        await _homeDataSource.setUserStatus(status);
        return const Right(Constants.zero);
      } catch (error) {
        return Left(Failure(AppStrings.anErrorOccurred.tr()));
      }
    } else {
      return Left(Failure(AppStrings.connectionError.tr()));
    }
  }

  @override
  Future<Either<Failure, Stream<List<ChatModel>>>> getChats(String uid) async {
    if (await _networkInfo.isConnected) {
      try {
        var response = _homeDataSource.getChats(uid);
        return Right(response.map((list) =>
            list.map((chatRequest) => chatRequest.toChatModel()).toList()));
      } catch (error) {
        return Left(Failure(AppStrings.anErrorOccurred.tr()));
      }
    } else {
      return Left(Failure(AppStrings.connectionError.tr()));
    }
  }

  @override
  Future<Either<Failure, Stream<List<GroupChatModel>>>> getUserGroups(
      String uid) async {
    if (await _networkInfo.isConnected) {
      try {
        var response = await _homeDataSource.getUserGroups(uid);
        var list = response.map((responsrList) => responsrList
            .map((groupRequest) => groupRequest.toGroupChatModel())
            .toList());
        return Right(list);
      } catch (error) {
        return Left(Failure(AppStrings.anErrorOccurred.tr()));
      }
    } else {
      return Left(Failure(AppStrings.connectionError.tr()));
    }
  }

  @override
  Future<Either<Failure, void>> createNewGroup(
      GroupChatModel groupModel) async {
    if (await _networkInfo.isConnected) {
      try {
        await _homeDataSource.createNewGroup(groupModel.toGroupChatRequest());
        return const Right(Constants.zero);
      } catch (error) {
        return Left(Failure(error.toString()));
      }
    } else {
      return Left(Failure(AppStrings.connectionError.tr()));
    }
  }

  @override
  Future<Either<Failure, Map<String, UserModel>>> getChatUsers(
      String uid) async {
    if (await _networkInfo.isConnected) {
      try {
        var response = await _homeDataSource.getChatUsers(uid);
        return Right(
            response.map((key, value) => MapEntry(key, value.toUserModel())));
      } catch (error) {
        return Left(Failure(AppStrings.anErrorOccurred.tr()));
      }
    } else {
      return Left(Failure(AppStrings.connectionError.tr()));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserData(UserModel userModel) async {
    if (await _networkInfo.isConnected) {
      try {
        await _homeDataSource.updateUserData(userModel.toUserRequest());
        return const Right(Constants.zero);
      } catch (error) {
        return Left(Failure(AppStrings.anErrorOccurred.tr()));
      }
    } else {
      return Left(Failure(AppStrings.connectionError.tr()));
    }
  }

  @override
  Future<Either<Failure, void>> setDeviceToken(String token) async {
    if (await _networkInfo.isConnected) {
      try {
        await _homeDataSource.setDeviceToken(token);
        return const Right(Constants.zero);
      } catch (error) {
        return Left(Failure(AppStrings.anErrorOccurred.tr()));
      }
    } else {
      return Left(Failure(AppStrings.connectionError.tr()));
    }
  }

  @override
  Future<Either<Failure, void>> setUserDeviceLanguage(String lang) async {
    if (await _networkInfo.isConnected) {
      try {
        await _homeDataSource.setUserDeviceLanguage(lang);
        return const Right(Constants.zero);
      } catch (error) {
        return Left(Failure(AppStrings.anErrorOccurred.tr()));
      }
    } else {
      return Left(Failure(AppStrings.connectionError.tr()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadImage(File file) async {
    if (await _networkInfo.isConnected) {
      try {
        var url = await _homeDataSource.uploadImage(file);
        return Right(url);
      } catch (error) {
        return Left(Failure(AppStrings.errorWhileUploadingImage.tr()));
      }
    } else {
      return Left(Failure(AppStrings.connectionError.tr()));
    }
  }
}
