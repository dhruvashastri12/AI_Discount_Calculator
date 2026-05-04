import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));

  for (final file in files) {
    String content = file.readAsStringSync();
    bool modified = false;

    if (content.contains('GoogleFonts.dmSans(')) {
      content = content.replaceAll('GoogleFonts.dmSans(', 'TextStyle(fontFamily: \'DMSans\', ');
      modified = true;
    }
    
    if (content.contains('GoogleFonts.dmSans()')) {
      content = content.replaceAll('GoogleFonts.dmSans()', 'TextStyle(fontFamily: \'DMSans\')');
      modified = true;
    }

    if (content.contains('GoogleFonts.jetBrainsMono(')) {
      content = content.replaceAll('GoogleFonts.jetBrainsMono(', 'TextStyle(fontFamily: \'JetBrainsMono\', ');
      modified = true;
    }
    
    if (content.contains('GoogleFonts.jetBrainsMono()')) {
      content = content.replaceAll('GoogleFonts.jetBrainsMono()', 'TextStyle(fontFamily: \'JetBrainsMono\')');
      modified = true;
    }

    if (content.contains("import 'package:google_fonts/google_fonts.dart';")) {
      content = content.replaceAll("import 'package:google_fonts/google_fonts.dart';", "");
      modified = true;
    }

    if (modified) {
      file.writeAsStringSync(content);
      print('Updated \${file.path}');
    }
  }
}
