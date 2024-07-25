import 'package:flutter/material.dart';

class MessageUtils {
  static void showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating, // Thêm dòng này để tăng kích thước
      ),
    );
  }

  static void showFailureMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating, // Thêm dòng này để tăng kích thước
      ),
    );
  }

  static void showWarningMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.amber,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating, // Thêm dòng này để tăng kích thước
      ),
    );
  }
}
