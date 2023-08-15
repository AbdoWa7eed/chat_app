import 'dart:io';
import 'package:chat_app/data/data_source/firebase_constants.dart';
import 'package:firebase_storage/firebase_storage.dart';

abstract class UploadImageDataSource {
  Future<String> uploadImage(File file);
}

class UploadImageDataSourceImpl implements UploadImageDataSource {
  final FirebaseStorage _fireStorage;
  UploadImageDataSourceImpl(this._fireStorage);
  @override
  Future<String> uploadImage(File image) async {
    final store = _fireStorage
        .ref()
        .child("$IMAGES_FOLDER_PATH${image.path.split('/').last}");
    final snapshot = await store.putFile(image);
    return await snapshot.ref.getDownloadURL();
  }
}
