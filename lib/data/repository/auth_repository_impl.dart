// ignore_for_file: void_checks

import 'package:chat_app/app/constants.dart';
import 'package:chat_app/data/data_source/auth/auth_data_srouce.dart';
import 'package:chat_app/data/network/failure.dart';
import 'package:chat_app/data/network/network_info.dart';
import 'package:chat_app/data/network/requests.dart';
import 'package:chat_app/domain/repository/auth_repository.dart';
import 'package:chat_app/presentation/resources/strings_manager.dart';
import 'package:dartz/dartz.dart';
import 'package:easy_localization/easy_localization.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource _authDataSource;
  final NetworkInfo _networkInfo;

  AuthRepositoryImpl(this._authDataSource, this._networkInfo);

  @override
  Future<Either<Failure, void>> sendVerificationCode({
    required String phoneNumber,
    required Function(String, int?) codeCent,
  }) async {
    if (await _networkInfo.isConnected) {
      await _authDataSource.sendVerificationCode(
        phoneNumber: phoneNumber,
        codeCent: (verificationId, p1) {
          codeCent(verificationId, p1);
        },
      );
      return const Right(Constants.zero);
    } else {
      return Left(Failure(AppStrings.connectionError.tr()));
    }
  }

  @override
  Future<Either<Failure, String>> signInWithCredential(
      String verificationId, String smsCode) async {
    if (await _networkInfo.isConnected) {
      try {
        UserAuthenticationRequest user =
            UserAuthenticationRequest(verificationId, smsCode);
        var uid = await _authDataSource.signInWithCredential(user);
        return Right(uid ?? Constants.empty);
      } catch (error) {
        return Left(Failure(AppStrings.wrongCode.tr()));
      }
    } else {
      return Left(Failure(AppStrings.connectionError.tr()));
    }
  }

  @override
  Future<Either<Failure, bool>> isUserAlreadyExists(String uid) async {
    if (await _networkInfo.isConnected) {
      try {
        var exists = await _authDataSource.isUserAleardyExists(uid);
        return Right(exists);
      } catch (error) {
        return Left(Failure(AppStrings.anErrorOccurred.tr()));
      }
    } else {
      return Left(Failure(AppStrings.connectionError.tr()));
    }
  }
}
