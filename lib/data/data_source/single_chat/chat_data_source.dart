import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../app/constants.dart';
import '../../network/requests.dart';
import '../firebase_constants.dart';

abstract class SingleChatDataSource {
  Future<void> setChatFields(
      {required String firstUID,
      required String secondUID,
      required ChatRequest chatRequest});

  Future<void> sendMessage(ChatRequest chatRequest);

  Future<Stream<List<MessageRequest>>> getMessages(
      {required String senderUID, required String receiverUID});

  Stream<String> getUserStatus(String uid);

  Future<void> setUnreadMessages(String to, String from, {bool isRead = false});
}

class SingleChatDataSourceImpl implements SingleChatDataSource {
  final FirebaseFirestore _fireStore;

  SingleChatDataSourceImpl(this._fireStore);

  @override
  Future<void> setChatFields(
      {required String firstUID,
      required String secondUID,
      required ChatRequest chatRequest}) async {
    var docRef = _fireStore
        .collection(USERS_COLLECTION_PATH)
        .doc(firstUID)
        .collection(CHATS_COLLECTION_PATH)
        .doc(secondUID);

    var docSnap = await docRef.get();
    if (docSnap.exists) {
      docRef.update(chatRequest.toMap());
    } else {
      docRef.set(chatRequest.toMap());
    }
  }

  @override
  Future<void> sendMessage(ChatRequest chatRequest) async {
    String senderUser;
    String receiverUser;

    if (chatRequest.senderUser == chatRequest.receiverUser) {
      await setChatFields(
          firstUID: chatRequest.senderUser!,
          secondUID: chatRequest.receiverUser!,
          chatRequest: chatRequest);

      await _fireStore
          .collection(USERS_COLLECTION_PATH)
          .doc(chatRequest.senderUser!)
          .collection(CHATS_COLLECTION_PATH)
          .doc(chatRequest.receiverUser!)
          .collection(MESSAGES_COLLECTION_PATH)
          .add(chatRequest.messageRequest!.toMap());

      return;
    }

    for (int i = 0; i < 2; i++) {
      if (i == 0) {
        senderUser = chatRequest.senderUser!;
        receiverUser = chatRequest.receiverUser!;
      } else {
        senderUser = chatRequest.receiverUser!;
        receiverUser = chatRequest.senderUser!;
      }
      await setChatFields(
          firstUID: senderUser,
          secondUID: receiverUser,
          chatRequest: chatRequest);

      await _fireStore
          .collection(USERS_COLLECTION_PATH)
          .doc(senderUser)
          .collection(CHATS_COLLECTION_PATH)
          .doc(receiverUser)
          .collection(MESSAGES_COLLECTION_PATH)
          .add(chatRequest.messageRequest!.toMap());
    }

    await setUnreadMessages(chatRequest.receiverUser!, chatRequest.senderUser!);
  }

  @override
  Future<void> setUnreadMessages(String receiverID, String senderID,
      {bool isRead = false}) async {
    var docRef = _fireStore
        .collection(USERS_COLLECTION_PATH)
        .doc(receiverID)
        .collection(CHATS_COLLECTION_PATH)
        .doc(senderID)
        .get();

    var unreadMessags = isRead
        ? Constants.minusOne
        : (await docRef).data()?[UNREAD_MESSAGES_FIELD_PATH] ?? Constants.zero;

    await _fireStore
        .collection(USERS_COLLECTION_PATH)
        .doc(receiverID)
        .collection(CHATS_COLLECTION_PATH)
        .doc(senderID)
        .update({
      UNREAD_MESSAGES_FIELD_PATH: ++unreadMessags,
    });
  }

  @override
  Future<Stream<List<MessageRequest>>> getMessages(
      {required String senderUID, required String receiverUID}) async {
    await setUnreadMessages(senderUID, receiverUID, isRead: true);
    var snapshot = _fireStore
        .collection(USERS_COLLECTION_PATH)
        .doc(senderUID)
        .collection(CHATS_COLLECTION_PATH)
        .doc(receiverUID)
        .collection(MESSAGES_COLLECTION_PATH)
        .orderBy(DATE_TIME_FIELD_PATH, descending: true)
        .snapshots();

    return snapshot.map((event) => event.docs.map((query) {
          var message = MessageRequest.fromJson(query.data());
          return message;
        }).toList());
  }

  @override
  Stream<String> getUserStatus(String uid) {
    var response =
        _fireStore.collection(USERS_COLLECTION_PATH).doc(uid).snapshots();
    return response.map((event) => event[STATUS_FIELD_PATH]);
  }
}
