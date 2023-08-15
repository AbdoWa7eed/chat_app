import 'dart:io';

import 'package:chat_app/data/data_source/firebase_constants.dart';
import 'package:chat_app/data/data_source/upload_image/upload_image.dart';
import 'package:chat_app/data/network/requests.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class GroupInfoDataSource {
  Future<String> uploadImage(File image);
  Future<void> updateGroupData(GroupChatRequest groupRequest,
      {List<String>? newUsersIDs});

  Future<void> exitGroup(GroupChatRequest groupRequest, String userID,
      {bool isLastUser = false});
}

class GroupInfoDataSourceImpl implements GroupInfoDataSource {
  final FirebaseFirestore _fireStore;
  final UploadImageDataSource _uploadImageDataSource;
  GroupInfoDataSourceImpl(this._fireStore, this._uploadImageDataSource);
  @override
  Future<void> updateGroupData(GroupChatRequest groupRequest,
      {List<String>? newUsersIDs}) async {
    await _fireStore
        .collection(GROUPS_COLLECTION_PATH)
        .doc(groupRequest.uid)
        .update(groupRequest.toMap());

    if (newUsersIDs != null) {
      for (var element in newUsersIDs) {
        await _addGroupToUserDoc(element, groupRequest.uid!);
      }
    }
  }

  @override
  Future<String> uploadImage(File image) async {
    return await _uploadImageDataSource.uploadImage(image);
  }

  Future<void> _addGroupToUserDoc(String uid, String groupUID) async {
    await _fireStore
        .collection(USERS_COLLECTION_PATH)
        .doc(uid)
        .collection(MYGROUP_COLLECTION_PATH)
        .doc(groupUID)
        .set({});
  }

  @override
  Future<void> exitGroup(GroupChatRequest groupRequest, String userID,
      {bool isLastUser = false}) async {
    if (isLastUser) {
      await _fireStore
          .collection(GROUPS_COLLECTION_PATH)
          .doc(groupRequest.uid)
          .delete();
    } else {
      await _fireStore
          .collection(GROUPS_COLLECTION_PATH)
          .doc(groupRequest.uid)
          .update({
        GROUP_MEMBERS_FIELD_PATH: groupRequest.groupMembers,
      });
    }

    await _fireStore
        .collection(USERS_COLLECTION_PATH)
        .doc(userID)
        .collection(MYGROUP_COLLECTION_PATH)
        .doc(groupRequest.uid)
        .delete();
  }
}
