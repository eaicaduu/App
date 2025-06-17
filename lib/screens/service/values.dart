import 'package:flutter/material.dart';

Color getBackgroundColor(BuildContext context) {
  return Theme.of(context).brightness == Brightness.light
      ? Colors.white
      : Colors.black;
}
