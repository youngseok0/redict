import 'dart:math';

import 'package:flutter/material.dart';
import 'package:redict/utils/format_srt_time.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:redict/models/subtitle_model.dart';
import '../services/subtitle_service.dart';
import '../utils/extract_youtube_id.dart';
import 'quiz_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late YoutubePlayerController _youtubePlayerController;
  final TextEditingController _textController = TextEditingController();

  String videoUrl = "https://www.youtube.com/watch?v=D5WyQe-zZVM";
  final SubtitleService _subtitleService = SubtitleService();

  bool _isLoading = false;
  double _videoDuration = 84.0; // default duration (seconds)
  late RangeValues _trimRange; // initial trim range

  @override
  void initState() {
    super.initState();
    _trimRange = RangeValues(0, min(_videoDuration, 300.0));
    _initializeVideo(videoUrl);
  }

  // 유튜브 영상 초기화 및 길이 불러오기
  void _initializeVideo(String url) {
    final videoId = YouTubeIdExtractor.extractYouTubeId(url);
    if (videoId == null) return;

    final controller = YoutubePlayerController(
      params: YoutubePlayerParams(
        mute: false,
        showControls: true,
        showFullscreenButton: true,
      ),
    );

    controller.cueVideoById(videoId: videoId);

    controller.listen((event) async {
      final duration = controller.metadata.duration;
      if (duration != null && duration.inSeconds > 0) {
        setState(() {
          _videoDuration = duration.inSeconds.toDouble();
          if (_trimRange.end > _videoDuration ||
              _trimRange.end - _trimRange.start < 10) {
            _trimRange = RangeValues(0, min(_videoDuration, 300.0));
          }
        });
      }
    });

    _youtubePlayerController = controller;
    _textController.text = url;
  }

  @override
  void dispose() {
    _youtubePlayerController.close();
    _textController.dispose();
    super.dispose();
  }

  void _generateSubtitles(String videoUrl) async {
    setState(() => _isLoading = true);

    try {
      List<SubtitleModel> subtitles =
          await _subtitleService.fetchSubtitlesFromYoutube(
        videoUrl,
        startTime: formatSrtTime(_trimRange.start),
        duration: formatSrtTime(_trimRange.end - _trimRange.start),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("자막 생성 완료!")),
      );

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => QuizScreen(
                  subtitles: subtitles,
                  videoUrl: videoUrl,
                )),
      );
    } catch (e) {
      print("❌ 자막 생성 오류: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("자막 생성 실패!")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _handleYoutubeInput(String url) {
    final videoId = YouTubeIdExtractor.extractYouTubeId(url);
    if (videoId != null) {
      setState(() {
        videoUrl = url;
        _initializeVideo(url);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('동영상이 업데이트되었습니다')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('유효한 YouTube URL이 아닙니다')),
      );
    }
  }

  void _previewStartPosition(double seconds) {
    _youtubePlayerController.seekTo(seconds: seconds);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("REWIND DICTATION")),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                child: YoutubePlayer(
                  key: ValueKey(_youtubePlayerController),
                  controller: _youtubePlayerController,
                  aspectRatio: 16 / 9,
                ),
              ),
              SizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: TextFormField(
                      controller: _textController,
                      onEditingComplete: () {
                        _handleYoutubeInput(_textController.text);
                      },
                      decoration: const InputDecoration(
                        hintText: 'YouTube URL 입력',
                        prefixIcon: Icon(Icons.link),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.75,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("⏱️ 학습 범위 지정 (10초 ~ 300초)",
                        style: TextStyle(fontSize: 16)),
                    RangeSlider(
                      values: _trimRange,
                      min: 0,
                      max: _videoDuration,
                      labels: RangeLabels(
                        _trimRange.start.toStringAsFixed(1),
                        _trimRange.end.toStringAsFixed(1),
                      ),
                      onChanged: (values) {
                        final duration = values.end - values.start;
                        // 최소 10초, 최대 300초 제한
                        if (duration >= 10 && duration <= 300) {
                          setState(() {
                            _trimRange = values;
                          });
                          // 슬라이더 변경 시 시작 지점으로 미리보기 이동
                          _previewStartPosition(values.start);
                        }
                      },
                    ),
                    Text(
                      "시작: ${formatSrtTime(_trimRange.start)} / 종료: ${formatSrtTime(_trimRange.end)}",
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              _isLoading
                  ? Column(
                      children: const [
                        SizedBox(height: 20),
                        CircularProgressIndicator(),
                        SizedBox(height: 10),
                        Text("문제가 준비되고 있어요...", style: TextStyle(fontSize: 16)),
                      ],
                    )
                  : ElevatedButton(
                      onPressed: () => _generateSubtitles(videoUrl),
                      child: const Text("🎬 자막 생성"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
