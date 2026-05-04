import 'package:flutter/material.dart';

Widget wrapWithMaterialApp(Widget widget, {ThemeData? theme}) {
  return MaterialApp(
    theme: theme ?? ThemeData(fontFamily: 'DMSans'),
    home: Scaffold(body: widget),
  );
}
