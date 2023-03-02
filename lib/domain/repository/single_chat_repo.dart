import 'package:dartz/dartz.dart';

import '../../data/network/failure.dart';
import '../models/models.dart';

abstract class SingleChatRepo {
  Future<Either<Failure, Stream<List<MessageModel>>>> getMessages(
      {required String senderUID, required String receiverUID});

  Future<Either<Failure, Stream<String>>> getUserStatus(String uid);

  Future<Either<Failure, void>> sendMessage(ChatModel chatModel);

  Future<Either<Failure, void>> setUnreadMessages(
      {required toUID, required String fromUID, isRead = false});
}
