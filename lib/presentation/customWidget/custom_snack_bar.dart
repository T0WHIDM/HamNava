import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';

SnackBar buildCustomSnackBar({
  required String title,
  required String message,
  required Color color,
  required ContentType type,
}) {
  return SnackBar(
    duration: const Duration(seconds: 1),
    
    elevation: 0,
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    content: Directionality(
      textDirection: .rtl,
      child: AwesomeSnackbarContent(
        messageTextStyle: const TextStyle(
          fontFamily: 'cr',
          color: Colors.white,
        ),
        titleTextStyle: const TextStyle(fontFamily: 'cr', color: Colors.white),
        title: title,
        message: message,
        contentType: type,
        color: color,
      ),
    ),
  );
}
