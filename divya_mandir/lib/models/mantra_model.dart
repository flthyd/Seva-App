class MantraModel {
  final String id;
  final String name; // e.g. "ఓం నమః శివాయ"
  final String deity; // e.g. "శివుడు"
  final String audioUrl; // Remote Firebase Storage URL or CDN
  final String? localAssetPath; // Fallback asset if any
  final String meaning; // Telugu explanation of mantra benefits
  final int defaultTargetCount; // usually 108 or 11, 21, 54, 1008
  final int loopDelayMs; // Delay between loops (default 0 for zero delay continuous)
  final bool isActive;
  final int order;
  final String? bannerColor;

  const MantraModel({
    required this.id,
    required this.name,
    required this.deity,
    required this.audioUrl,
    this.localAssetPath,
    required this.meaning,
    this.defaultTargetCount = 108,
    this.loopDelayMs = 0,
    this.isActive = true,
    this.order = 0,
    this.bannerColor,
  });

  factory MantraModel.fromMap(Map<String, dynamic> map, String id) {
    return MantraModel(
      id: id,
      name: map['name'] ?? '',
      deity: map['deity'] ?? '',
      audioUrl: map['audioUrl'] ?? '',
      localAssetPath: map['localAssetPath'],
      meaning: map['meaning'] ?? '',
      defaultTargetCount: (map['defaultTargetCount'] as num?)?.toInt() ?? 108,
      loopDelayMs: (map['loopDelayMs'] as num?)?.toInt() ?? 0,
      isActive: map['isActive'] ?? true,
      order: (map['order'] as num?)?.toInt() ?? 0,
      bannerColor: map['bannerColor'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'deity': deity,
      'audioUrl': audioUrl,
      'localAssetPath': localAssetPath,
      'meaning': meaning,
      'defaultTargetCount': defaultTargetCount,
      'loopDelayMs': loopDelayMs,
      'isActive': isActive,
      'order': order,
      'bannerColor': bannerColor,
    };
  }
}
