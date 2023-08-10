import 'dart:io';

import 'package:chat_app/data/network/failure.dart';
import 'package:chat_app/domain/models/models.dart';
import 'package:dartz/dartz.dart';

abstract class GroupInfoRepo {
  Future<Either<Failure, String>> uploadImage(File file);

  Future<Either<Failure, void>> updateGroupData(GroupChatModel groupModel,
      {List<String>? newUsersIDs});

  Future<Either<Failure, void>> exitGroup(GroupChatModel groupModel,
      {required String userID, bool isLastUser = false});
}
