import 'dart:io';

import 'package:chat_app/data/data_source/firebase_constants.dart';
import 'package:chat_app/data/network/requests.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

abstract class RegisterDataSource {
  Future<bool> addUserToFireStore(UserRequest user);

  Future<String> uploadImage(File file);
}

class RegisterDataSourceImpl implements RegisterDataSource {
  final FirebaseStorage _fireStorage;
  final FirebaseFirestore _fireStore;

  RegisterDataSourceImpl(this._fireStorage, this._fireStore);
  @override
  Future<bool> addUserToFireStore(UserRequest user) async {
    bool isUsernameExists = false;
    for (var element
        in (await _fireStore.collection(USERS_COLLECTION_PATH).get()).docs) {
      if (element.data()[USERNAME_FIELD_PATH] == user.username) {
        isUsernameExists = true;
      }
    }

    if (!isUsernameExists) {
      await _fireStore
          .collection(USERS_COLLECTION_PATH)
          .doc(user.uid)
          .set(user.toMap());
      return true;
    }
    return false;
  }

  @override
  Future<String> uploadImage(File image) async {
    final store = _fireStorage
        .ref()
        .child("$IMAGES_FOLDER_PATH${image.path.split('/').last}");
    final snapshot = await store.putFile(image);
    return await snapshot.ref.getDownloadURL();
  }
}
