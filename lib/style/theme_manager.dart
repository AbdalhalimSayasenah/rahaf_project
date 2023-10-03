import 'package:flutter/material.dart';

abstract class ThemeManager {
  static ThemeData getAppTheme() {
    return ThemeData(
      fontFamily: "IBMPlex",
      useMaterial3: true,
      appBarTheme: const AppBarTheme(centerTitle: true),
      dialogTheme: DialogTheme(
        backgroundColor: Colors.white,
      ),
    );
  }
}
