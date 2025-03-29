import 'package:flutter/material.dart';
import 'package:redict/models/subtitle_model.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import '../utils/extract_youtube_id.dart';

class QuizScreen extends StatefulWidget {
  final List<SubtitleModel> subtitles;
  final String videoUrl;

  const QuizScreen({
    super.key,
    required this.subtitles,
    required this.videoUrl,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late YoutubePlayerController _youtubePlayerController;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final List<GlobalKey> _subtitleKeys = [];

  int _currentSubtitleIndex = -1;
  late List<bool> isSolvedList;

  @override
  void initState() {
    super.initState();
    isSolvedList = List.generate(widget.subtitles.length, (_) => false);
    final videoId = YouTubeIdExtractor.extractYouTubeId(widget.videoUrl);
    if (videoId == null) return;

    _youtubePlayerController = YoutubePlayerController(
      params: const YoutubePlayerParams(
        mute: false,
        showControls: false,
        showFullscreenButton: false,
      ),
    )..cueVideoById(videoId: videoId);

    _subtitleKeys
        .addAll(List.generate(widget.subtitles.length, (_) => GlobalKey()));
  }

  void _scrollToSubtitle(int index) {
    final keyContext = _subtitleKeys[index].currentContext;
    if (keyContext == null) return;

    final box = keyContext.findRenderObject() as RenderBox?;
    if (box == null) return;

    final position =
        box.localToGlobal(Offset.zero, ancestor: context.findRenderObject());
    final size = box.size;
    final screenHeight = MediaQuery.of(context).size.height;

    final targetOffset = _scrollController.offset +
        position.dy +
        size.height / 2 -
        screenHeight / 2;

    _scrollController.animateTo(
      targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _youtubePlayerController.close();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("퀴즈 화면"),
      ),
      body: SizedBox(
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              flex: 1,
              child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.4,
                        child: YoutubePlayer(
                          key: ValueKey(_youtubePlayerController),
                          controller: _youtubePlayerController,
                          aspectRatio: 16 / 9,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Flexible(
              flex: 1,
              child: Center(
                child: Column(
                  children: [
                    Text("자막 퀴즈",
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 20),
                    StreamBuilder<YoutubeVideoState>(
                      stream: _youtubePlayerController.videoStateStream,
                      builder: (context, snapshot) {
                        final currentTime =
                            snapshot.data?.position.inMilliseconds.toDouble() ??
                                0;

                        return SizedBox(
                          height: MediaQuery.of(context).size.height * 0.8,
                          child: ListView.builder(
                            controller: _scrollController,
                            padding: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * 0.4,
                              bottom: MediaQuery.of(context).size.height * 0.4,
                            ),
                            itemCount: widget.subtitles.length,
                            itemBuilder: (context, index) {
                              final subtitle = widget.subtitles[index];
                              final isCurrentSubtitle = currentTime >=
                                      subtitle.start.inMilliseconds
                                          .toDouble() &&
                                  currentTime <=
                                      subtitle.end.inMilliseconds.toDouble();

                              if (isCurrentSubtitle &&
                                  index != _currentSubtitleIndex) {
                                _currentSubtitleIndex = index;
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  _scrollToSubtitle(index);
                                });
                              }

                              return AnimatedContainer(
                                key: _subtitleKeys[index],
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                duration: const Duration(milliseconds: 150),
                                transform: Matrix4.identity()
                                  ..scale(isCurrentSubtitle ? 1.05 : 1.0),
                                child: Card(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 16),
                                  color: isCurrentSubtitle
                                      ? Theme.of(context).cardColor
                                      : Theme.of(context)
                                          .cardColor
                                          .withAlpha(180),
                                  elevation: isCurrentSubtitle ? 8 : 1,
                                  child: ListTile(
                                    title: isSolvedList[index]
                                        ? Text(
                                            subtitle.text,
                                            style: TextStyle(
                                              fontWeight: isCurrentSubtitle
                                                  ? FontWeight.bold
                                                  : FontWeight.normal,
                                              color: isCurrentSubtitle
                                                  ? null
                                                  : Colors.black54,
                                            ),
                                          )
                                        : TextField(
                                            onSubmitted: (value) {
                                              if (value == subtitle.text) {
                                                setState(() {
                                                  isSolvedList[index] = true;
                                                });
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                      "정답입니다! ${subtitle.text}",
                                                      style: const TextStyle(
                                                          fontSize: 16),
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      "틀렸습니다. 다시 시도해보세요.",
                                                      style: TextStyle(
                                                          fontSize: 16),
                                                    ),
                                                  ),
                                                );
                                              }
                                            },
                                            decoration: InputDecoration(
                                              hintText: "정답을 입력하세요",
                                              border: InputBorder.none,
                                              hintStyle: TextStyle(
                                                color: isCurrentSubtitle
                                                    ? null
                                                    : Colors.black38,
                                              ),
                                            ),
                                          ),
                                    subtitle: Text(
                                      '${subtitle.start} - ${subtitle.end}',
                                      style: TextStyle(
                                        color: isCurrentSubtitle
                                            ? null
                                            : Colors.black38,
                                      ),
                                    ),
                                    onTap: () {
                                      _youtubePlayerController.seekTo(
                                        seconds: subtitle.start.inMilliseconds
                                                .toDouble() /
                                            1000,
                                        allowSeekAhead: true,
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
