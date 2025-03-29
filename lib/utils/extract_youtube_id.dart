/// A utility class to extract YouTube video IDs from various YouTube URL formats.
class YouTubeIdExtractor {
  /// Regular expressions for different YouTube URL formats
  static final RegExp _standardYoutubeRegex = RegExp(
    r'^https?:\/\/(?:www\.)?youtube\.com\/watch\?(?=.*v=([a-zA-Z0-9_-]+)).*$',
  );
  
  static final RegExp _shortYoutubeRegex = RegExp(
    r'^https?:\/\/youtu\.be\/([a-zA-Z0-9_-]+)(?:\?.*)?$',
  );
  
  static final RegExp _embedYoutubeRegex = RegExp(
    r'^https?:\/\/(?:www\.)?youtube\.com\/embed\/([a-zA-Z0-9_-]+)(?:\?.*)?$',
  );
  
  static final RegExp _shortenerYoutubeRegex = RegExp(
    r'^https?:\/\/(?:www\.)?youtube\.com\/shorts\/([a-zA-Z0-9_-]+)(?:\?.*)?$',
  );

  /// Extracts the YouTube video ID from a given URL
  /// 
  /// Returns the video ID as a String if found, otherwise returns null.
  static String? extractYouTubeId(String url) {
    // Check for standard YouTube URL (youtube.com/watch?v=...)
    var match = _standardYoutubeRegex.firstMatch(url);
    if (match != null && match.groupCount >= 1) {
      return match.group(1);
    }

    // Check for short YouTube URL (youtu.be/...)
    match = _shortYoutubeRegex.firstMatch(url);
    if (match != null && match.groupCount >= 1) {
      return match.group(1);
    }

    // Check for embed YouTube URL (youtube.com/embed/...)
    match = _embedYoutubeRegex.firstMatch(url);
    if (match != null && match.groupCount >= 1) {
      return match.group(1);
    }
    
    // Check for shorts YouTube URL (youtube.com/shorts/...)
    match = _shortenerYoutubeRegex.firstMatch(url);
    if (match != null && match.groupCount >= 1) {
      return match.group(1);
    }

    // No match found
    return null;
  }
}