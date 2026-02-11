/// Utility for mapping ghost profile names to their corresponding emoji.
///
/// Backend generates names like "Happy Panda #123".
/// This class extracts the animal name and maps it to the correct emoji.
class EmojiUtils {
  // ── Exact mapping from backend ANIMALS list → emoji ──
  static const Map<String, String> _animalEmoji = {
    'panda': '🐼',
    'eagle': '🦅',
    'lion': '🦁',
    'tiger': '🐯',
    'bear': '🐻',
    'wolf': '🐺',
    'fox': '🦊',
    'rabbit': '🐰',
    'koala': '🐨',
    'sloth': '🦥',
    'otter': '🦦',
    'penguin': '🐧',
    'owl': '🦉',
    'hawk': '🦅',
    'deer': '🦌',
    'elephant': '🐘',
    'giraffe': '🦒',
    'zebra': '🦓',
    'monkey': '🐵',
    'cat': '🐱',
    'dog': '🐶',
    'whale': '🐳',
    'dolphin': '🐬',
    'shark': '🦈',
  };

  /// Extract the emoji from a ghost display name like "Happy Panda #123".
  /// Searches for a known animal keyword in the name.
  /// Returns the matching emoji, or a fallback based on hash.
  static String getEmojiForName(String displayName) {
    final lower = displayName.toLowerCase();

    for (final entry in _animalEmoji.entries) {
      if (lower.contains(entry.key)) {
        return entry.value;
      }
    }

    // Fallback: deterministic emoji from hash (for names that don't match any animal)
    final emojis = _animalEmoji.values.toList();
    final hash = lower.codeUnits.fold(0, (prev, c) => prev + c);
    return emojis[hash % emojis.length];
  }

  /// Parse the tag number from a ghost name like "Happy Panda #123" → "#123"
  static String getTagFromName(String displayName) {
    final match = RegExp(r'#(\d+)').firstMatch(displayName);
    return match != null ? '#${match.group(1)}' : '';
  }

  /// Get display name WITHOUT the tag: "Happy Panda #123" → "Happy Panda"
  static String getNameWithoutTag(String displayName) {
    return displayName.replaceAll(RegExp(r'\s*#\d+$'), '').trim();
  }

  /// Format for display: emoji + name + tag
  /// e.g. "🐼 Happy Panda #123"
  static String getFormattedIdentity(String displayName) {
    final emoji = getEmojiForName(displayName);
    return '$emoji $displayName';
  }
}
