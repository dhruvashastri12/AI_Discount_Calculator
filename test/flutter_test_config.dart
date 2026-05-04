import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  final fontFiles = {
    'DMSans-Regular': 'assets/fonts/DMSans-Regular.ttf',
    'DMSans-Medium': 'assets/fonts/DMSans-Medium.ttf',
    'DMSans-SemiBold': 'assets/fonts/DMSans-SemiBold.ttf',
    'DMSans-Bold': 'assets/fonts/DMSans-Bold.ttf',
    'DMSans-Black': 'assets/fonts/DMSans-Black.ttf',
    'JetBrainsMono-Regular': 'assets/fonts/JetBrainsMono-Regular.ttf',
    'JetBrainsMono-SemiBold': 'assets/fonts/JetBrainsMono-SemiBold.ttf',
    'JetBrainsMono-Bold': 'assets/fonts/JetBrainsMono-Bold.ttf',
    'JetBrainsMono-ExtraBold': 'assets/fonts/JetBrainsMono-ExtraBold.ttf',
  };

  for (final entry in fontFiles.entries) {
    final fontName = entry.key;
    final fontPath = entry.value;
    final file = File(fontPath);
    if (await file.exists()) {
      final bytes = await file.readAsBytes();
      final fontLoader = FontLoader(fontName);
      fontLoader.addFont(Future.value(ByteData.view(bytes.buffer)));
      await fontLoader.load();
    }
  }

  await testMain();
}
