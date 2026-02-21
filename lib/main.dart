import 'dart:async';
import 'package:finguard_app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

void main() {
  runZonedGuarded(
    () {
      WidgetsFlutterBinding.ensureInitialized();

      FlutterError.onError = (details) {
        FlutterError.presentError(details);
      };

      runApp(const FinguardApp());
    },
    (error, stack) {
      if (kDebugMode) {}
    },
  );
}
