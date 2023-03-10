import 'dart:io';

import 'package:chat_app/data/network/failure.dart';
import 'package:chat_app/domain/models/models.dart';
import 'package:dartz/dartz.dart';

abstract class HomeRepository {
  Future<Either<Failure, String>> uploadImage(File file);

  Future<Either<Failure, void>> addNewUser(UserModel user);

  Future<Either<Failure, UserModel>> getUserData(String user,
      {bool isUID = false});

  Future<Either<Failure, Map<String, UserModel>>> getChatUsers(String uid);

  Future<Either<Failure, void>> setUserStatus(String status);

  Future<Either<Failure, Stream<List<ChatModel>>>> getChats(String uid);

  Future<Either<Failure, void>> createNewGroup(GroupChatModel groupModel);

  Future<Either<Failure, Stream<List<GroupChatModel>>>> getUserGroups(
      String uid);

  Future<Either<Failure, void>> updateUserData(UserModel userModel);

  Future<Either<Failure, void>> updateGroupData(GroupChatModel groupModel,
      {List<String>? newUsersIDs});

  Future<Either<Failure, void>> exitGroup(GroupChatModel groupModel,
      {required String userID, bool isLastUser = false});

  Future<Either<Failure, void>> setUserDeviceLanguage(String lang);

  Future<Either<Failure, void>> setDeviceToken(String token);
}
