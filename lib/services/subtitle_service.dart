import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:redict/models/subtitle_model.dart';

import '../utils/parse_srt.dart';

class SubtitleService {
  Future<List<SubtitleModel>> fetchSubtitlesFromYoutube(String youtubeUrl,
      {String startTime = "00:00:00,000",
      String duration = "00:00:30,000"}) async {
    final response = await http.post(
      Uri.parse('http://localhost:8000/api/subtitles'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'youtube_url': youtubeUrl,
        'model_size': 'small',
        "start_time": startTime,
        "duration": duration,
      }),
    );

    if (response.statusCode == 200) {
      final srtText = jsonDecode(response.body)['srt_text'];
      return parseSrtText(srtText);
    } else {
      throw Exception('서버 오류: ${response.statusCode} ${response.body}');
    }
  }
}
