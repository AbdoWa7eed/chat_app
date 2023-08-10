import 'package:chat_app/app/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../network/requests.dart';
import '../firebase_constants.dart';

abstract class GroupChatDataSource {
  Future<void> sendGroupMessage(
      MessageRequest message, GroupChatRequest groupRequest);

  Stream<List<MessageRequest>> getGroupMessages(String groupID);

  Future<void> setUnreadMessages(GroupChatRequest group, {String? readerUser});
}

class GroupChatDataSourceImpl implements GroupChatDataSource {
  final FirebaseFirestore _fireStore;
  GroupChatDataSourceImpl(this._fireStore);

  @override
  Future<void> sendGroupMessage(
      MessageRequest message, GroupChatRequest groupRequest) async {
    await _fireStore
        .collection(GROUPS_COLLECTION_PATH)
        .doc(groupRequest.uid)
        .collection(MESSAGES_COLLECTION_PATH)
        .add(message.toMap());

    await setUnreadMessages(groupRequest);

    await _updateGroupLastMessage(message, groupRequest.uid!);
  }

  @override
  Stream<List<MessageRequest>> getGroupMessages(String groupID) {
    var snapshot = _fireStore
        .collection(GROUPS_COLLECTION_PATH)
        .doc(groupID)
        .collection(MESSAGES_COLLECTION_PATH)
        .orderBy(DATE_TIME_FIELD_PATH, descending: true)
        .snapshots();

    return snapshot.map((event) => event.docs.map((query) {
          var message = MessageRequest.fromJson(query.data());
          return message;
        }).toList());
  }

  Future<void> _updateGroupLastMessage(
      MessageRequest message, String groupID) async {
    await _fireStore.collection(GROUPS_COLLECTION_PATH).doc(groupID).update({
      LAST_MESSAGES_FIELD_PATH: message.message,
      LAST_MESSAGES_TIME_FIELD_PATH: message.dateTime,
    });
  }

  @override
  Future<void> setUnreadMessages(GroupChatRequest group,
      {String? readerUser}) async {
    var data = (await _fireStore
            .collection(GROUPS_COLLECTION_PATH)
            .doc(group.uid)
            .get())
        .data()?[GROUP_MEMBERS_FIELD_PATH];

    if (readerUser == null) {
      group.groupMembers = Map.from(data);
      group.groupMembers?.updateAll((key, value) {
        if (key == appUserModel!.uid) {
          return Constants.zero;
        }
        return ++value;
      });
    } else {
      group.groupMembers = Map.from(data);
      if (group.groupMembers?.containsKey(readerUser) ?? false) {
        group.groupMembers?.update(readerUser, (value) => Constants.zero);
      }
    }

    await _fireStore.collection(GROUPS_COLLECTION_PATH).doc(group.uid).update({
      GROUP_MEMBERS_FIELD_PATH: group.groupMembers,
    });
  }
}
