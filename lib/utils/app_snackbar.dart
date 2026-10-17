import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppSnackbar {
  static void success(String title, String message) {
    _showAfterFrame(
      title,
      message,
      Colors.green.shade100,
      Colors.green.shade900,
      Icon(Icons.check_circle, color: Colors.green.shade800),
    );
  }

  static void error(String title, String message) {
    _showAfterFrame(title, message, Colors.red.shade50, Colors.red.shade900, null);
  }

  static void _showAfterFrame(
    String title,
    String message,
    Color background,
    Color text,
    Widget? icon,
  ) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _show(title, message, background, text, icon);
    });
  }

  static void _show(
    String title,
    String message,
    Color background,
    Color text,
    Widget? icon,
  ) {
    Get.snackbar(
      title,
      message,
      icon: icon,
      shouldIconPulse: false,
      backgroundColor: background,
      colorText: text,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      duration: const Duration(seconds: 3),
    );
  }
}
