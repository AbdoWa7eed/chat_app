import 'dart:io';

import 'package:chat_app/app/constants.dart';
import 'package:chat_app/data/data_source/upload_image/upload_image.dart';
import 'package:chat_app/data/network/requests.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_constants.dart';

abstract class HomeDataSource {
  Future<UserRequest?> getUserData(username);

  Future<void> setUserStatus(String status);

  Stream<List<ChatRequest>> getChats(String uid);

  Future<Stream<List<GroupChatRequest>>> getUserGroups(String uid);

  Future<void> createNewGroup(GroupChatRequest groupRequst);

  Future<UserRequest?> getUserDataByUID(String uid);

  Future<Map<String, UserRequest?>> getChatUsers(String uid);

  Future<void> updateUserData(UserRequest userRequest);

  Future<void> setUserDeviceLanguage(String lang);

  Future<void> setDeviceToken(String token);

  Future<String> uploadImage(File image);
}

class HomeDataSourceImpl implements HomeDataSource {
  final UploadImageDataSource _uploadImageDataSource;
  final FirebaseFirestore _fireStore;

  HomeDataSourceImpl(this._uploadImageDataSource, this._fireStore);

  @override
  Future<UserRequest?> getUserData(username) async {
    Map<String, dynamic>? response;
    for (var element
        in (await _fireStore.collection(USERS_COLLECTION_PATH).get()).docs) {
      if (element.data()[USERNAME_FIELD_PATH] == username) {
        response = element.data();
      }
    }
    if (response == null) {
      return null;
    }
    return UserRequest.fromJson(response);
  }

  @override
  Future<UserRequest?> getUserDataByUID(String uid) async {
    var response =
        await _fireStore.collection(USERS_COLLECTION_PATH).doc(uid).get();
    return UserRequest.fromJson(response.data());
  }

  @override
  Future<void> setUserStatus(String status) async {
    await _fireStore
        .collection(USERS_COLLECTION_PATH)
        .doc(appUserModel!.uid)
        .update({STATUS_FIELD_PATH: status});
  }

  @override
  Stream<List<ChatRequest>> getChats(String uid) {
    var response = _fireStore
        .collection(USERS_COLLECTION_PATH)
        .doc(uid)
        .collection(CHATS_COLLECTION_PATH)
        .snapshots();

    return response.map((snapshot) => snapshot.docs.map((query) {
          var user = ChatRequest.fromJson(query.data());
          return user;
        }).toList());
  }

  @override
  Future<Map<String, UserRequest?>> getChatUsers(String uid) async {
    var response = await _fireStore
        .collection(USERS_COLLECTION_PATH)
        .doc(uid)
        .collection(CHATS_COLLECTION_PATH)
        .get();

    Map<String, UserRequest?> users = {};
    for (var element in response.docs) {
      var data = await getUserDataByUID(element.id);
      users[element.id] = data;
    }
    return users;
  }

  @override
  Future<Stream<List<GroupChatRequest>>> getUserGroups(String uid) async {
    var userGroups = await _fireStore
        .collection(USERS_COLLECTION_PATH)
        .doc(uid)
        .collection(MYGROUP_COLLECTION_PATH)
        .get();

    var groupsSnapshot =
        _fireStore.collection(GROUPS_COLLECTION_PATH).snapshots();

    return groupsSnapshot.map((collection) => collection.docs
        .where((element) {
          bool exists = false;
          for (var doc in userGroups.docs) {
            if (element.id == doc.id) {
              exists = true;
            }
          }
          return exists;
        })
        .map((doc) => GroupChatRequest.fromJson(doc.data()))
        .toList());
  }

  @override
  Future<void> createNewGroup(GroupChatRequest groupRequst) async {
    var ref = await _fireStore
        .collection(GROUPS_COLLECTION_PATH)
        .add(groupRequst.toMap());

    await _fireStore
        .collection(GROUPS_COLLECTION_PATH)
        .doc(ref.id)
        .set({'uid': ref.id}, SetOptions(merge: true));

    groupRequst.groupMembers?.forEach((key, value) async {
      await _addGroupToUserDoc(key, ref.id);
    });
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
  Future<void> updateUserData(UserRequest userRequest) async {
    await _fireStore
        .collection(USERS_COLLECTION_PATH)
        .doc(userRequest.uid)
        .update(userRequest.toMap());
  }

  @override
  Future<void> setUserDeviceLanguage(String lang) async {
    await _fireStore.collection(USERS_COLLECTION_PATH).doc(UID!).update({
      USER_DEVICE_LANG_PATH_FIELD: lang,
    });
  }

  @override
  Future<void> setDeviceToken(String token) async {
    await _fireStore.collection(USERS_COLLECTION_PATH).doc(UID!).update({
      USER_DEVICE_TOKEN_PATH_FIELD: token,
    });
  }

  @override
  Future<String> uploadImage(File image) async {
    return await _uploadImageDataSource.uploadImage(image);
  }
}
