import 'dart:io';

import 'package:chat_app/data/network/failure.dart';
import 'package:chat_app/domain/models/models.dart';
import 'package:dartz/dartz.dart';

abstract class RegisterRepository {
  Future<Either<Failure, String>> uploadImage(File file);

  Future<Either<Failure, void>> addNewUser(UserModel user);
}
