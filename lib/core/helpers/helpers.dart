import 'package:flutter/material.dart';

class Helpers {
  static void showSnackbar(String message, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
            )),
        backgroundColor: Colors.red,
      ),
    );
  }
}
