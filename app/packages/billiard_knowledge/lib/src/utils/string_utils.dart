/// String utilities for billiard knowledge library.
library billiard_knowledge.utils;

/// Normalize a string for search/comparison.
String normalize(String input) {
  return input
      .toLowerCase()
      .trim()
      .replaceAll(RegExp(r'\s+'), ' ');
}

/// Extract keywords from text.
List<String> extractKeywords(String text, {int minLength = 3}) {
  return text
      .toLowerCase()
      .replaceAll(RegExp(r'[^\w\s]'), ' ')
      .split(RegExp(r'\s+'))
      .where((word) => word.length >= minLength)
      .toSet()
      .toList();
}

/// Highlight matching text.
String highlightMatch(String text, String query, {String prefix = '**', String suffix = '**'}) {
  final regex = RegExp(escapeRegex(query), caseSensitive: false);
  return text.replaceAllMapped(regex, (match) => '$prefix${match.group(0)}$suffix');
}

/// Escape special regex characters.
String escapeRegex(String input) {
  return input.replaceAllMapped(
    RegExp(r'[.*+?^${}()|[\]\\]'),
    (match) => '\\${match.group(0)}',
  );
}

/// Truncate text with ellipsis.
String truncate(String text, int maxLength, {String suffix = '...'}) {
  if (text.length <= maxLength) return text;
  return '${text.substring(0, maxLength - suffix.length)}$suffix';
}

/// Format duration in minutes to human readable.
String formatDuration(int minutes) {
  if (minutes < 60) {
    return '$minutes min';
  }
  final hours = minutes ~/ 60;
  final mins = minutes % 60;
  if (mins == 0) {
    return '$hours hr';
  }
  return '$hours hr $mins min';
}

/// Calculate Levenshtein distance between two strings.
int levenshteinDistance(String s1, String s2) {
  if (s1.isEmpty) return s2.length;
  if (s2.isEmpty) return s1.length;

  final m = s1.length;
  final n = s2.length;

  final d = List.generate(m + 1, (_) => List.filled(n + 1, 0));

  for (var i = 0; i <= m; i++) {
    d[i][0] = i;
  }
  for (var j = 0; j <= n; j++) {
    d[0][j] = j;
  }

  for (var i = 1; i <= m; i++) {
    for (var j = 1; j <= n; j++) {
      final cost = s1[i - 1] == s2[j - 1] ? 0 : 1;
      d[i][j] = [
        d[i - 1][j] + 1, // deletion
        d[i][j - 1] + 1, // insertion
        d[i - 1][j - 1] + cost, // substitution
      ].reduce((a, b) => a < b ? a : b);
    }
  }

  return d[m][n];
}

/// Calculate similarity between two strings (0.0 - 1.0).
double stringSimilarity(String s1, String s2) {
  if (s1.isEmpty && s2.isEmpty) return 1.0;
  if (s1.isEmpty || s2.isEmpty) return 0.0;

  final distance = levenshteinDistance(s1.toLowerCase(), s2.toLowerCase());
  final maxLength = s1.length > s2.length ? s1.length : s2.length;

  return 1.0 - (distance / maxLength);
}
