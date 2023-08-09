// ignore_for_file: void_checks

import 'dart:io';

import 'package:chat_app/app/constants.dart';
import 'package:chat_app/data/data_source/register/register_data_source.dart';
import 'package:chat_app/data/mapper/mapper.dart';
import 'package:chat_app/data/network/failure.dart';
import 'package:chat_app/data/network/network_info.dart';
import 'package:chat_app/domain/models/models.dart';
import 'package:chat_app/domain/repository/register_repo.dart';
import 'package:chat_app/presentation/resources/strings_manager.dart';
import 'package:dartz/dartz.dart';
import 'package:easy_localization/easy_localization.dart';

class RegisterRepoImpl implements RegisterRepository {
  final NetworkInfo _networkInfo;
  final RegisterDataSource _registerDataSource;

  RegisterRepoImpl(this._networkInfo, this._registerDataSource);

  @override
  Future<Either<Failure, void>> addNewUser(UserModel user) async {
    if (await _networkInfo.isConnected) {
      bool isAdded =
          await _registerDataSource.addUserToFireStore(user.toUserRequest());
      if (isAdded) {
        return const Right(Constants.zero);
      } else {
        return Left(Failure(AppStrings.userIsExists.tr()));
      }
    } else {
      return Left(Failure(AppStrings.connectionError.tr()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadImage(File file) async {
    if (await _networkInfo.isConnected) {
      try {
        var url = await _registerDataSource.uploadImage(file);
        return Right(url);
      } catch (error) {
        return Left(Failure(AppStrings.errorWhileUploadingImage.tr()));
      }
    } else {
      return Left(Failure(AppStrings.connectionError.tr()));
    }
  }
}
