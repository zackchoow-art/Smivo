/// Severity-aware result of a content filter check.
class ContentFilterResult {
  final List<String> blockMatches;
  final List<String> warnMatches;

  const ContentFilterResult({
    required this.blockMatches,
    required this.warnMatches,
  });

  bool get hasBlock => blockMatches.isNotEmpty;
  bool get hasWarn => warnMatches.isNotEmpty;
  bool get clean => !hasBlock && !hasWarn;

  // Backward compatibility
  bool get passed => !hasBlock;
  List<String> get matchedWords => [...blockMatches, ...warnMatches];
}

/// Client-side sensitive word filter.
///
/// Uses case-insensitive word boundary matching to check text against
/// downloaded word lists. Multi-word phrases use substring matching.
class ContentFilter {
  final List<String> _blockWords;
  final List<String> _warnWords;

  ContentFilter({
    required List<String> blockWords,
    required List<String> warnWords,
  }) : _blockWords = blockWords,
       _warnWords = warnWords;

  /// Checks [text] against the sensitive word lists.
  ContentFilterResult check(String text) {
    if (text.trim().isEmpty) {
      return const ContentFilterResult(blockMatches: [], warnMatches: []);
    }

    final lowerText = text.toLowerCase();

    List<String> findMatches(List<String> dictionary) {
      final matched = <String>[];
      for (final word in dictionary) {
        final lowerWord = word.toLowerCase();
        final isAscii = RegExp(r'^[\x00-\x7F]+$').hasMatch(lowerWord);
        if (!isAscii || lowerWord.contains(' ')) {
          if (lowerText.contains(lowerWord)) {
            matched.add(word);
          }
        } else {
          final pattern = RegExp(r'\b' + RegExp.escape(lowerWord) + r'\b');
          if (pattern.hasMatch(lowerText)) {
            matched.add(word);
          }
        }
      }
      return matched;
    }

    return ContentFilterResult(
      blockMatches: findMatches(_blockWords),
      warnMatches: findMatches(_warnWords),
    );
  }

  /// Masks matched block words in the text, e.g. "word" -> "****"
  String mask(String text) {
    var result = text;
    // Process longer words first to avoid partial masking of sub-words
    final sortedBlockWords = List<String>.from(_blockWords);
    sortedBlockWords.sort((a, b) => b.length.compareTo(a.length));

    for (final word in sortedBlockWords) {
      // Find matches using the same word-boundary logic, but case-insensitive
      RegExp pattern;
      final isAscii = RegExp(r'^[\x00-\x7F]+$').hasMatch(word);
      if (!isAscii || word.contains(' ')) {
        pattern = RegExp(RegExp.escape(word), caseSensitive: false);
      } else {
        pattern = RegExp(
          r'\b' + RegExp.escape(word) + r'\b',
          caseSensitive: false,
        );
      }

      result = result.replaceAllMapped(pattern, (match) {
        final matchedString = match.group(0)!;
        return '*' * matchedString.length;
      });
    }
    return result;
  }
}
