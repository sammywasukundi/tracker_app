import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';

void showSuccess(BuildContext context, String title, String content) {
  AwesomeDialog(
    context: context,
    dialogType: DialogType.success,
    animType: AnimType.rightSlide,
    title: title,
    desc: content,
    btnCancelOnPress: () {
      Navigator.of(context).pop();
    },
    btnOkOnPress: () {},
  ).show();
}

void showError(BuildContext context, String title, String content) {
  AwesomeDialog(
    context: context,
    dialogType: DialogType.error,
    animType: AnimType.rightSlide,
    title: title,
    desc: content,
    btnCancelOnPress: () {
      Navigator.of(context).pop();
    },
    btnOkOnPress: () {},
  ).show();
}

void showInfo(BuildContext context, String title, String content) {
  AwesomeDialog(
    context: context,
    dialogType: DialogType.info,
    animType: AnimType.rightSlide,
    title: title,
    desc: content,
    btnCancelOnPress: () {
      Navigator.of(context).pop();
    },
    btnOkOnPress: () {},
  ).show();
}
