import 'package:flutter/material.dart';
import 'screens/subtitle_studio_screen.dart';

void main() {
  runApp(const YgnSubtitleStudio());
}

class YgnSubtitleStudio extends StatelessWidget {
  const YgnSubtitleStudio({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YGN Subtitle Studio',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const SubtitleStudioScreen(),
    );
  }
}
