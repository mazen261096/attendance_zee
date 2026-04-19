import '../constants/bad_words.dart';

/// Utility class to filter inappropriate content before sending to the server.
///
/// Uses pre-compiled regexes built from [AppBadWords.badWords] to efficiently
/// detect and replace bad words with asterisks.
///
/// Short bad words (≤ 2 chars) are only censored when the containing word is
/// ≤ 4 characters, to avoid false positives like "زبادى" or "بزيادة".
class ContentFilter {
  ContentFilter._();

  /// Character class for Arabic and English letters.
  static const String _wordChars = r'[\u0600-\u06FF\u0750-\u077Fa-zA-Z]';

  /// Regex that matches any of the bad words, but ONLY if they are not preceded
  /// or followed by another word character (i.e. they are standalone words).
  static final RegExp _badWordsRegex = _buildRegex();

  static RegExp _buildRegex() {
    final words = AppBadWords.badWords.toList()
      ..sort((a, b) => b.length.compareTo(a.length));

    if (words.isEmpty) return RegExp(r'(?!)'); // never matches

    final wordsPattern = words.map((w) => RegExp.escape(w)).join('|');
    
    // Negative lookbehind and lookahead to ensure word boundaries
    final pattern = '(?<!$_wordChars)(?:$wordsPattern)(?!$_wordChars)';
    
    return RegExp(pattern, caseSensitive: false, unicode: true);
  }

  /// Filters the given [text] by replacing any standalone bad word occurrences
  /// with asterisks of the same length.
  ///
  /// Example: "hello fuck you" → "hello **** you"
  /// Example: "زبادى" (yogurt) → "زبادى" (not censored, even though it contains a bad substring)
  static String filter(String text) {
    return text.replaceAllMapped(_badWordsRegex, (match) {
      return '*' * match.group(0)!.length;
    });
  }
}
