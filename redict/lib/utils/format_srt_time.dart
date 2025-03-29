String formatSrtTime(double seconds) {
  final int totalMillis = (seconds * 1000).round();

  final int hours = totalMillis ~/ 3600000;
  final int minutes = (totalMillis % 3600000) ~/ 60000;
  final int secs = (totalMillis % 60000) ~/ 1000;
  final int millis = totalMillis % 1000;

  return '${hours.toString().padLeft(2, '0')}:'
      '${minutes.toString().padLeft(2, '0')}:'
      '${secs.toString().padLeft(2, '0')},'
      '${millis.toString().padLeft(3, '0')}';
}
