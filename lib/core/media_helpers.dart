class MediaHelpers {
  /// Extracts the Google Drive File ID from various Drive URL formats
  static String? extractGoogleDriveId(String url) {
    if (url.isEmpty) return null;

    final regexPattern = RegExp(
        r'(?:https?:\/\/)?(?:drive\.google\.com\/(?:file\/d\/|open\?id=|uc\?id=)|docs\.google\.com\/.*[?&]id=)([-_a-zA-Z0-9]{25,33})');
    
    final match = regexPattern.firstMatch(url);
    if (match != null && match.groupCount >= 1) {
      return match.group(1);
    }
    return null;
  }

  /// Generates an embeddable URL for webview given a Drive URL or ID
  static String? generateDriveEmbedUrl(String rawUrl) {
    final id = extractGoogleDriveId(rawUrl);
    if (id != null) {
      // preview endpoint works nicely in iframes / webviews
      return 'https://drive.google.com/file/d/$id/preview';
    }
    return null;
  }
}
