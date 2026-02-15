/// Utility for mapping ghost profile names to their corresponding emoji.
///
/// Backend generates names like "Happy Panda #123".
/// This class extracts the animal name and maps it to the correct emoji.
class EmojiUtils {
  // ── Exact mapping from backend ANIMALS list → emoji ──
  static const Map<String, String> _animalEmoji = {
    // Mammals
    'panda': '🐼',
    'bear': '🐻',
    'polar bear': '🐻',
    'koala': '🐨',
    'tiger': '🐯',
    'lion': '🦁',
    'leopard': '🐆',
    'cheetah': '🐆',
    'wolf': '🐺',
    'fox': '🦊',
    'raccoon': '🦝',
    'cat': '🐱',
    'dog': '🐶',
    'poodle': '🐩',
    'mouse': '🐭',
    'rat': '🐀',
    'hamster': '🐹',
    'rabbit': '🐰',
    'otter': '🦦',
    'badger': '🦡',
    'bat': '🦇',
    'hedgehog': '🦔',
    'squirrel': '🐿️',
    'chipmunk': '🐿️',
    'beaver': '🦫',
    'sloth': '🦥',
    'cow': '🐮',
    'ox': '🐂',
    'buffalo': '🐃',
    'bull': '🐂',
    'pig': '🐷',
    'boar': '🐗',
    'sheep': '🐑',
    'ram': '🐏',
    'goat': '🐐',
    'llama': '🦙',
    'alpaca': '🦙',
    'camel': '🐫',
    'giraffe': '🦒',
    'elephant': '🐘',
    'rhino': '🦏',
    'hippo': '🦛',
    'mammoth': '🐘',
    'gorilla': '🦍',
    'orangutan': '🦧',
    'monkey': '🐵',
    'chimp': '🐵',
    'baboon': '🐵',
    'lemur': '🐒',
    'horse': '🐴',
    'donkey': '🐴',
    'mule': '🐴',
    'zebra': '🦓',
    'deer': '🦌',
    'antelope': '🦌',
    'kangaroo': '🦘',
    'platypus': '🦆',
    'skunk': '🦨',
    'mole': '🦦',
    'dormouse': '🐭',
    'meerkat': '🐿️',
    'groundhog': '🦫',
    'porcupine': '🦔',
    'moose': '�',
    'elk': '�',
    'okapi': '🦒',
    'tapir': '🐖',
    'wombat': '🐨',
    'quokka': '🐨',
    'wallaby': '🦘',
    'dingo': '🐕',

    // Birds
    'eagle': '🦅',
    'hawk': '🦅',
    'falcon': '🦅',
    'owl': '🦉',
    'parrot': '🦜',
    'flamingo': '🦩',
    'peacock': '🦚',
    'swan': '🦢',
    'dove': '🕊️',
    'pigeon': '🐦',
    'duck': '🦆',
    'goose': '�',
    'chicken': '🐔',
    'rooster': '🐓',
    'turkey': '🦃',
    'quail': '🐦',
    'penguin': '🐧',
    'stork': '鹭',
    'toucan': '🦜',
    'dodo': '🦤',
    'phoenix': '🔥',
    'sparrow': '🐦',
    'crow': '🐦',
    'blue jay': '🐦',
    'robin': '🐦',
    'cardinal': '🐦',
    'canary': '🐤',
    'hummingbird': '🐦',
    'woodpecker': '🐦',
    'seagull': '🐦',
    'pelican': '🐦',
    'kingfisher': '🐦',
    'heron': '🐦',
    'crane': '🐦',
    'ostrich': '🐦',
    'emu': '🐦', 'kiwi': '🥝',

    // Reptiles & Amphibians
    'turtle': '🐢',
    'tortoise': '🐢',
    'crocodile': '🐊',
    'alligator': '🐊',
    'snake': '🐍',
    'python': '🐍',
    'viper': '🐍',
    'cobra': '🐍',
    'lizard': '🦎',
    'iguana': '🦎',
    'gecko': '🦎',
    'chameleon': '🦎',
    'dragon': '🐉',
    'dinosaur': '🦖',
    'rex': '🦖',
    'sauropod': '🦕',
    'triceratops': '🦕',
    'pterodactyl': '🦅',
    'frog': '🐸',
    'toad': '🐸',
    'newt': '🦎',
    'salamander': '🦎', 'axolotl': '🦎',

    // Marine
    'whale': '🐳',
    'dolphin': '🐬',
    'porpoise': '🐬',
    'seal': '🦭',
    'walrus': '🦭',
    'manatee': '🦭',
    'shark': '🦈',
    'orca': '🐋',
    'fish': '🐟',
    'blowfish': '🐡',
    'pufferfish': '🐡',
    'tuna': '🐟',
    'salmon': '🐟',
    'carp': '🎏',
    'clownfish': '🐠',
    'seahorse': ' Seahorse',
    'octopus': '🐙',
    'squid': '🦑',
    'jellyfish': '🪼',
    'crab': '🦀',
    'lobster': '🦞',
    'shrimp': '🦐',
    'prawn': '🦐',
    'oyster': '🦪',
    'clam': '🐚',
    'snail': '🐌',
    'slug': '🐌',
    'shell': '🐚',
    'coral': '🪸', 'starfish': '⭐', 'ray': '🦈',

    // Bugs
    'bee': '🐝',
    'wasp': '🐝',
    'hornet': '🐝',
    'bumblebee': '🐝',
    'butterfly': '🦋',
    'moth': '🦋',
    'ladybug': '🐞',
    'beetle': '🪲',
    'cockroach': '🪳',
    'cricket': '🦗',
    'grasshopper': '🦗',
    'cicada': '🦗',
    'ant': '🐜',
    'termite': '🐜',
    'dragonfly': '🪰',
    'mosquito': '🦟',
    'fly': '🪰',
    'worm': '🪱',
    'centipede': '🐛',
    'millipede': '🐛',
    'spider': '🕷️',
    'tarantula': '🕷️',
    'scorpion': '🦂',
    'louse': '🐛',
    'flea': '🐛',
    'tick': '🐛',
    'mantis': '🦗',
    'stick bug': '🦗',

    // Mythical & Others
    'unicorn': '🦄',
    'pegasus': '🐴',
    'kraken': '🐙',
    'yeti': '🦍',
    'bigfoot': '🦍',
    'ghost': '👻',
    'alien': '👽',
    'robot': '🤖',
    'monster': '👾',
    'genie': '🧞',
    'fairy': '🧚',
    'vampire': '🧛',
    'mermaid': '🧜',
    'elf': '🧝',
    'zombie': '🧟',
    'mummy': '🤕',
    'skeleton': '💀',
    'brain': '🧠',
    'heart': '❤️',
    'eye': '👁️',
    'tooth': '🦷',
    'bone': '🦴',
    'microbe': '🦠',
    'virus': '🦠',
    'bacteria': '🦠', 'amoeba': '🦠', 'dna': '🧬',
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
