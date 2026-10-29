class SearchUtils {
  /// Normalize text: lowercase, remove special characters, trim whitespace
  static String normalize(String text) {
    return text.toLowerCase().replaceAll(RegExp(r'[^a-zA-Z0-9\u0C00-\u0C7F]'), '').trim();
  }

  /// Maps common phonetic letters between Hinglish/Telugu English
  static String getPhoneticKey(String text) {
    String s = text.toLowerCase().trim();
    // Common Telugu/English phonetic variations
    s = s.replaceAll('shw', 'sw');
    s = s.replaceAll('sh', 's');
    s = s.replaceAll('ch', 'c');
    s = s.replaceAll('ee', 'i');
    s = s.replaceAll('oo', 'u');
    s = s.replaceAll('ou', 'au');
    s = s.replaceAll('dh', 'd');
    s = s.replaceAll('th', 't');
    s = s.replaceAll('bh', 'b');
    s = s.replaceAll('kh', 'k');
    s = s.replaceAll('gh', 'g');
    s = s.replaceAll('ph', 'p');
    s = s.replaceAll('v', 'w');
    s = s.replaceAll('aa', 'a');
    return s;
  }

  /// Check if the query matches temple fields (English, Telugu, Hinglish, Deity, District, State, Hashtags)
  static bool matchesTemple({
    required String query,
    required String nameTelugu,
    required String nameEnglish,
    required String deity,
    required String district,
    required String state,
    required List<String> hashtags,
  }) {
    if (query.trim().isEmpty) return true;

    // Clean query
    String cleanQ = query.trim().toLowerCase();
    String normQ = normalize(cleanQ);
    String phoneticQ = getPhoneticKey(cleanQ);

    // 1. Direct contains check across all standard fields
    if (nameTelugu.toLowerCase().contains(cleanQ) ||
        nameEnglish.toLowerCase().contains(cleanQ) ||
        deity.toLowerCase().contains(cleanQ) ||
        district.toLowerCase().contains(cleanQ) ||
        state.toLowerCase().contains(cleanQ)) {
      return true;
    }

    // 2. Hashtags check (e.g. #tirupati, #balaji, #govinda, #sitaram)
    for (final tag in hashtags) {
      final cleanTag = tag.replaceAll('#', '').toLowerCase().trim();
      if (cleanTag.contains(cleanQ) || cleanQ.contains(cleanTag)) {
        return true;
      }
      if (normQ.isNotEmpty && normalize(cleanTag).contains(normQ)) {
        return true;
      }
    }

    // 3. Phonetic Hinglish check (e.g., "tirupathi" matching "tirupati", "sreesailam" matching "srisailam")
    String phoneticNameEn = getPhoneticKey(nameEnglish);
    String phoneticDeity = getPhoneticKey(deity);
    String phoneticDistrict = getPhoneticKey(district);

    if (phoneticNameEn.contains(phoneticQ) ||
        phoneticDeity.contains(phoneticQ) ||
        phoneticDistrict.contains(phoneticQ)) {
      return true;
    }

    // Check individual words in query
    final queryWords = cleanQ.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (queryWords.length > 1) {
      bool allMatch = queryWords.every((word) {
        return nameTelugu.toLowerCase().contains(word) ||
            nameEnglish.toLowerCase().contains(word) ||
            deity.toLowerCase().contains(word) ||
            district.toLowerCase().contains(word) ||
            hashtags.any((t) => t.toLowerCase().contains(word));
      });
      if (allMatch) return true;
    }

    return false;
  }
}
