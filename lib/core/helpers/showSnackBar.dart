// ignore_for_file: file_names

import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String message) {
  if (context.mounted) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
