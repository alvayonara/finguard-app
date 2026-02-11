import 'package:flutter/material.dart';

class AppText {
  static TextStyle title(BuildContext context) =>
      Theme.of(context).textTheme.headlineMedium!;

  static TextStyle body(BuildContext context) =>
      Theme.of(context).textTheme.bodyLarge!;
}