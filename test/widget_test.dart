import 'package:flutter_test/flutter_test.dart';
import 'package:ygn_subtitle_studio/main.dart';

void main() {
  testWidgets('App renders subtitle studio', (WidgetTester tester) async {
    await tester.pumpWidget(const YgnSubtitleStudio());
    await tester.pumpAndSettle();
    expect(find.text('YGN Subtitle Studio'), findsOneWidget);
    expect(find.text('No subtitles loaded'), findsOneWidget);
  });
}
