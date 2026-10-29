class SubVidhanamItem {
  final int number;
  final String title;
  final String subtitle;
  final String? localImage;

  const SubVidhanamItem({
    required this.number,
    required this.title,
    required this.subtitle,
    this.localImage,
  });

  factory SubVidhanamItem.fromMap(Map<String, dynamic> map) {
    return SubVidhanamItem(
      number: (map['number'] as num?)?.toInt() ?? 1,
      title: map['title'] ?? '',
      subtitle: map['subtitle'] ?? '',
      localImage: map['localImage'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'number': number,
      'title': title,
      'subtitle': subtitle,
      'localImage': localImage,
    };
  }
}

class PujaStep {
  final int stepNumber;
  final String title;
  final String mantra;
  final String description;

  const PujaStep({
    required this.stepNumber,
    required this.title,
    required this.mantra,
    required this.description,
  });

  factory PujaStep.fromMap(Map<String, dynamic> map) {
    return PujaStep(
      stepNumber: (map['stepNumber'] as num?)?.toInt() ?? 1,
      title: map['title'] ?? '',
      mantra: map['mantra'] ?? '',
      description: map['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'stepNumber': stepNumber,
      'title': title,
      'mantra': mantra,
      'description': description,
    };
  }
}

class PujaVidhanamModel {
  final String id;
  final String title; // e.g., "గణపతి పూజ"
  final String deity; // e.g., "గణపతి"
  final String shortDesc; // e.g., "విఘ్నాలను తొలగించి శుభకార్యాలకు సిద్ధి ప్రసాదించే పూజ"
  final String tag; // e.g., "విఘ్న నివారణ కోసం", "ఓం నమః శివాయ", "ధన సంపద కోసం"
  final int countText; // e.g., 5 or 6 (shows "5 పూజా విధానాలు")
  final String duration; // e.g., "సుమారు 20-30 నిమిషాలు"
  final String targetAudience; // e.g., "ఎవరైనా చేయవచ్చు"
  final String parichayam; // పూజా పరిచయం వివరణ
  final List<String> favorableTimes; // పూజ చేయడానికి అనుకూల సమయాలు
  final List<SubVidhanamItem> subVidhanalu; // పూజా విధానాల జాబితా
  final String samagri; // పూజా సామాగ్రి
  final String fullVidhanam; // పూర్తి విధానం టెక్స్ట్
  final List<PujaStep> steps; // షోడశోపచార పూజా దశలు
  final String mantralu; // పూజా మంత్రాలు
  final String prayojanalu; // పూజా ప్రయోజనాలు
  final String imageUrl; // Web URL or Firebase Storage URL
  final String? localAssetPath; // Optional local asset fallback
  final String? heroBannerAsset; // Top full-width hero banner image
  final String category; // నిత్య పూజ, పండుగ పూజ, వ్రతం, గ్రహ శాంతి
  final String auspiciousDays; // ఉత్తమ దినములు (ఉదా: మంగళవారం, సంకష్టహర చవితి)
  final bool isActive;
  final int order;

  const PujaVidhanamModel({
    required this.id,
    required this.title,
    required this.deity,
    required this.shortDesc,
    this.tag = '',
    this.countText = 5,
    this.duration = 'సుమారు 20-30 నిమిషాలు',
    this.targetAudience = 'ఎవరైనా చేయవచ్చు',
    this.parichayam = '',
    this.favorableTimes = const [],
    this.subVidhanalu = const [],
    required this.samagri,
    required this.fullVidhanam,
    this.steps = const [],
    this.mantralu = '',
    this.prayojanalu = '',
    required this.imageUrl,
    this.localAssetPath,
    this.heroBannerAsset,
    this.category = 'నిత్య పూజ',
    this.auspiciousDays = 'రోజూ చేయవచ్చు',
    this.isActive = true,
    this.order = 0,
  });

  factory PujaVidhanamModel.fromMap(Map<String, dynamic> map, String id) {
    var rawSteps = map['steps'];
    List<PujaStep> stepList = [];
    if (rawSteps is List) {
      stepList = rawSteps
          .map((s) => PujaStep.fromMap(s as Map<String, dynamic>))
          .toList();
    }

    var rawSubs = map['subVidhanalu'];
    List<SubVidhanamItem> subList = [];
    if (rawSubs is List) {
      subList = rawSubs
          .map((s) => SubVidhanamItem.fromMap(s as Map<String, dynamic>))
          .toList();
    }

    var rawTimes = map['favorableTimes'];
    List<String> timesList = [];
    if (rawTimes is List) {
      timesList = rawTimes.map((t) => t.toString()).toList();
    }

    return PujaVidhanamModel(
      id: id,
      title: map['title'] ?? '',
      deity: map['deity'] ?? '',
      shortDesc: map['shortDesc'] ?? '',
      tag: map['tag'] ?? '',
      countText: (map['countText'] as num?)?.toInt() ?? 5,
      duration: map['duration'] ?? 'సుమారు 20-30 నిమిషాలు',
      targetAudience: map['targetAudience'] ?? 'ఎవరైనా చేయవచ్చు',
      parichayam: map['parichayam'] ?? '',
      favorableTimes: timesList,
      subVidhanalu: subList,
      samagri: map['samagri'] ?? '',
      fullVidhanam: map['fullVidhanam'] ?? '',
      steps: stepList,
      mantralu: map['mantralu'] ?? '',
      prayojanalu: map['prayojanalu'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      localAssetPath: map['localAssetPath'],
      heroBannerAsset: map['heroBannerAsset'],
      category: map['category'] ?? 'నిత్య పూజ',
      auspiciousDays: map['auspiciousDays'] ?? 'రోజూ చేయవచ్చు',
      isActive: map['isActive'] ?? true,
      order: (map['order'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'deity': deity,
      'shortDesc': shortDesc,
      'tag': tag,
      'countText': countText,
      'duration': duration,
      'targetAudience': targetAudience,
      'parichayam': parichayam,
      'favorableTimes': favorableTimes,
      'subVidhanalu': subVidhanalu.map((s) => s.toMap()).toList(),
      'samagri': samagri,
      'fullVidhanam': fullVidhanam,
      'steps': steps.map((s) => s.toMap()).toList(),
      'mantralu': mantralu,
      'prayojanalu': prayojanalu,
      'imageUrl': imageUrl,
      'localAssetPath': localAssetPath,
      'heroBannerAsset': heroBannerAsset,
      'category': category,
      'auspiciousDays': auspiciousDays,
      'isActive': isActive,
      'order': order,
    };
  }
}
