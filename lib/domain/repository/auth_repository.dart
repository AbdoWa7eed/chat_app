import 'package:chat_app/data/network/failure.dart';
import 'package:dartz/dartz.dart';

abstract class AuthRepository {
  Future<Either<Failure, void>> sendVerificationCode({
    required String phoneNumber,
    required Function(String , int?) codeCent,
  });

  Future<Either<Failure, String>> signInWithCredential(String verificationId , String smsCode);

  Future<Either<Failure, bool>> isUserAlreadyExists(String uid);
}
