import 'dart:io';

import 'package:chat_app/presentation/resources/strings_manager.dart';
import 'package:easy_localization/easy_localization.dart';
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

String validateTime(String dateTime) {
  var formatter = DateTime.parse(dateTime);
  var difference = DateTime.now().difference(formatter);
  if (difference.inHours >= 24 && difference.inHours < 48) {
    return AppStrings.yesterday.tr();
  } else if (difference.inHours >= 48) {
    return DateFormat('yyyy-MM-dd').format(formatter);
  } else {
    return DateFormat("h:mma").format(formatter).toString();
  }
}

String validateText(String message) {
  return message
      .split(RegExp(r'(?:\r?\n|\r)'))
      .where((s) => s.trim().isNotEmpty)
      .join('\n');
}
