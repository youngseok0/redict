import '../models/subtitle_model.dart';

List<SubtitleModel> parseSrtText(String srtText) {
  final lines = srtText.split('\n');
  final subtitles = <SubtitleModel>[];

  int i = 0;
  while (i < lines.length) {
    // 번호 (건너뜀)
    if (lines[i].trim().isEmpty) {
      i++;
      continue;
    }

    // 시간
    final timeLine = lines[i + 1];
    final textLines = <String>[];

    i += 2;

    // 텍스트 줄들
    while (i < lines.length && lines[i].trim().isNotEmpty) {
      textLines.add(lines[i]);
      i++;
    }

    final times = timeLine.split(' --> ');
    final start = _parseSrtTime(times[0]);
    final end = _parseSrtTime(times[1]);

    subtitles.add(SubtitleModel(
      index: subtitles.length + 1,
      start: start,
      end: end,
      text: textLines.join(' '),
    ));

    i++;
  }

  return subtitles;
}

Duration _parseSrtTime(String timeStr) {
  final parts = timeStr.split(RegExp(r'[:,]'));
  return Duration(
    hours: int.parse(parts[0]),
    minutes: int.parse(parts[1]),
    seconds: int.parse(parts[2]),
    milliseconds: int.parse(parts[3]),
  );
}
