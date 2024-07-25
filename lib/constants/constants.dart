import 'package:flutter/material.dart';

const kPrimaryColor = Color.fromARGB(255, 243, 130, 60);
const kPrimaryColorBlur = Color.fromARGB(199, 252, 218, 197);
const kPrimaryLightColor = Color(0xFFF1E6FF);
const kDangerColor = Colors.redAccent;
const double defaultPadding = 16.0;

class AppStringConst {
  AppStringConst._();
  // String
  static const packageName = "com.example.orange_card";
  static const notificationMethodChannel =
      "com.example.orange_card/notification_service";
}


class AppValueConst{
  AppValueConst._();

  static const maxImgUploadSize = 5242880;
  static const maxItemLoad = 50;
  static const minWordInBagToPlay = 5;
  static const timeForQuiz = 30; // seconds
  static const timeForTyping = 15; // seconds
  static const attendancePoint = 1;
  static const attendanceGold = 1;
}
