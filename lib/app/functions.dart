import 'package:flutter/material.dart';

_isCurrentDialogActive(BuildContext context) =>
    ModalRoute.of(context)?.isCurrent != true;

dismissDialog(BuildContext context) {
  if (_isCurrentDialogActive(context)) {
    Navigator.of(context, rootNavigator: true).pop(true);
  }
}