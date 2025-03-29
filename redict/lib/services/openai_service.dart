import 'package:http/http.dart' as http;
import 'dart:convert';

class OpenAIService {
  final String _apiKey = "YOUR_OPENAI_API_KEY";

  Future<String> getSentenceExplanation(String sentence) async {
    final response = await http.post(
      Uri.parse("https://api.openai.com/v1/chat/completions"),
      headers: {
        "Authorization": "Bearer $_apiKey",
        "Content-Type": "application/json"
      },
      body: jsonEncode({
        "model": "gpt-4o",
        "messages": [
          {"role": "system", "content": "문장을 해석하고 주요 단어를 설명해주세요."},
          {"role": "user", "content": sentence}
        ]
      }),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return data["choices"][0]["message"]["content"];
    } else {
      return "해석 실패";
    }
  }
}
