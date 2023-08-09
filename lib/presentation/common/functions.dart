import 'dart:io';

import 'package:image_picker/image_picker.dart';

Future<File?> pickImageFromGallery(ImagePicker imagePicker) async {
  String? path =
      (await imagePicker.pickImage(source: ImageSource.gallery))?.path;
  if (path != null) {
    var image = File(path);
    return image;
  }
  return null;
}

Future<File?> pickImageFromCamera(ImagePicker imagePicker) async {
  String? path =
      (await imagePicker.pickImage(source: ImageSource.camera))?.path;
  if (path != null) {
    var image = File(path);
    return image;
  }
  return null;
}
