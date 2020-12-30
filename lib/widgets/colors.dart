import 'package:flutter/material.dart';

final textColor = Colors.white;
final mainColor = Colors.blue.withGreen(0);
final secondColor = Colors.red;
final lightTextColor = Colors.white;
final darkTextColor = Colors.black;
final backgroundColorLight = Colors.grey[300];
final backgroundColorDark = Color(0xff121212);
final chatsBackground = Colors.black;
bool darkMode = false;

// Global Functions defined here

void showSnackbar(
  context, {
  @required msg,
  actionLabel,
  onPressed,
  width,
}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    behavior: SnackBarBehavior.floating,
    content: Text(
      msg ?? 'SnackBar Message',
      style: TextStyle(fontFamily: 'GothamBold'),
    ),
    width: width ?? 300,
    action: SnackBarAction(
      label: actionLabel ?? 'OK',
      onPressed: onPressed ?? () {},
    ),
  ));
}
