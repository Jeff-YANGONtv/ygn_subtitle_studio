import 'package:flutter_test/flutter_test.dart';
import 'package:ygn_subtitle_studio/subtitle_sync/subtitle_sync.dart';

void main() {
  test('SubtitleEntry toSrt formats correctly', () {
    final entry = SubtitleEntry(
      index: 1,
      start: const Duration(hours: 0, minutes: 0, seconds: 1, milliseconds: 500),
      end: const Duration(hours: 0, minutes: 0, seconds: 4, milliseconds: 0),
      text: 'Hello, world!',
    );
    expect(entry.toSrt(), contains('Hello, world!'));
  });

  test('SubtitleSync parses SRT content', () {
    const srt = '1\n00:00:01,000 --> 00:00:04,000\nTest subtitle\n\n2\n00:00:05,000 --> 00:00:08,000\nSecond subtitle';
    final entries = SubtitleSync.parseSrt(srt);
    expect(entries.length, 2);
    expect(entries[0].text, 'Test subtitle');
    expect(entries[1].text, 'Second subtitle');
  });

  test('SubtitleSync shifts timing', () {
    final entries = [
      SubtitleEntry(
        index: 1,
        start: const Duration(seconds: 1),
        end: const Duration(seconds: 4),
        text: 'Test',
      ),
    ];
    final shifted = SubtitleSync.shiftTiming(entries, const Duration(seconds: 1));
    expect(shifted[0].start.inSeconds, 2);
    expect(shifted[0].end.inSeconds, 5);
  });
}
