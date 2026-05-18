class SubtitleEntry {
  final int index;
  final Duration start;
  final Duration end;
  final String text;

  const SubtitleEntry({
    required this.index,
    required this.start,
    required this.end,
    required this.text,
  });

  String toSrt() {
    final startStr = _formatDuration(start);
    final endStr = _formatDuration(end);
    return '$index\n$startStr --> $endStr\n$text\n';
  }

  factory SubtitleEntry.fromSrt(String block) {
    final lines = block.trim().split('\n');
    final idx = int.parse(lines[0].trim());
    final times = lines[1].split(' --> ');
    return SubtitleEntry(
      index: idx,
      start: _parseDuration(times[0].trim()),
      end: _parseDuration(times[1].trim()),
      text: lines.sublist(2).join('\n'),
    );
  }

  static String _formatDuration(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    final ms = (d.inMilliseconds % 1000).toString().padLeft(3, '0');
    return '$h:$m:$s,$ms';
  }

  static Duration _parseDuration(String s) {
    final parts = s.replaceFirst(',', '.').split(':');
    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);
    final seconds = double.parse(parts[2]);
    return Duration(
      hours: hours,
      minutes: minutes,
      seconds: seconds.toInt(),
      milliseconds: ((seconds % 1) * 1000).round(),
    );
  }
}

class SubtitleSync {
  static List<SubtitleEntry> parseSrt(String content) {
    final blocks = content.trim().split('\n\n');
    return blocks
        .where((b) => b.trim().isNotEmpty)
        .map((b) => SubtitleEntry.fromSrt(b))
        .toList();
  }

  static String toSrt(List<SubtitleEntry> entries) {
    return entries.map((e) => e.toSrt()).join('\n');
  }

  static List<SubtitleEntry> shiftTiming(
    List<SubtitleEntry> entries,
    Duration offset,
  ) {
    return entries.map((e) {
      final newStart = e.start + offset;
      final newEnd = e.end + offset;
      return SubtitleEntry(
        index: e.index,
        start: newStart,
        end: newEnd,
        text: e.text,
      );
    }).toList();
  }
}
