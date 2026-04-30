/// Result of a content filter check.
class ContentFilterResult {
  final bool passed;
  final List<String> matchedWords;

  const ContentFilterResult({
    required this.passed,
    required this.matchedWords,
  });
}

/// Client-side sensitive word filter.
///
/// Uses case-insensitive word boundary matching to check text against
/// a downloaded word list. Multi-word phrases use substring matching.
class ContentFilter {
  final List<String> _words;

  ContentFilter(this._words);

  /// Checks [text] against the sensitive word list.
  /// Returns a result indicating whether the text passed and which words matched.
  ContentFilterResult check(String text) {
    if (_words.isEmpty || text.trim().isEmpty) {
      return const ContentFilterResult(passed: true, matchedWords: []);
    }

    final lowerText = text.toLowerCase();
    final matched = <String>[];

    for (final word in _words) {
      final lowerWord = word.toLowerCase();
      // Multi-word phrases: simple substring match
      if (lowerWord.contains(' ')) {
        if (lowerText.contains(lowerWord)) {
          matched.add(word);
        }
      } else {
        // Single words: word boundary regex to avoid false positives
        // e.g. "assess" should NOT match "ass"
        final pattern = RegExp(r'\b' + RegExp.escape(lowerWord) + r'\b');
        if (pattern.hasMatch(lowerText)) {
          matched.add(word);
        }
      }
    }

    return ContentFilterResult(
      passed: matched.isEmpty,
      matchedWords: matched,
    );
  }
}
