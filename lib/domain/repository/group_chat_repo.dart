import 'package:chat_app/domain/models/models.dart';
import 'package:dartz/dartz.dart';

import '../../data/network/failure.dart';

abstract class GroupChatRepo {
  Future<Either<Failure, void>> sendGroupMessage(
      {required MessageModel messageModel, required GroupChatModel groupModel});

  Future<Either<Failure, Stream<List<MessageModel>>>> getGroupMessages(
      String groupID);

  Future<Either<Failure , void>> setUnreadMessages(GroupChatModel group, {String? readerUser});
}
