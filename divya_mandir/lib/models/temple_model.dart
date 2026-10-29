class TempleModel {
  final String id;
  final String nameTelugu;
  final String nameEnglish;
  final String state; // ఆంధ్రప్రదేశ్ / తెలంగాణ etc.
  final String district;
  final String deity; // ప్రధాన దైవం
  final String imageUrl; // Primary image URL
  final List<String> images; // Multiple slide images
  final String assetPath; // Fallback asset if any
  final String historyStory; // ఆలయ చరిత్ర / స్థల పురాణం
  final String timings; // దర్శన సమయాలు
  final String specialSevas; // ప్రత్యేక సేవలు / ఉత్సవాలు
  final String onlineBookingUrl; // ఆన్‌లైన్ దర్శనం / సేవా బుకింగ్ లింక్
  final String googleMapsUrl; // ఆలయ లొకేషన్ లింక్
  final List<String> hashtags; // Search keywords in English, Telugu, Hinglish (e.g. #tirupati, #balaji, #venkateswara)
  final bool isPopular;
  final bool isActive;
  final int order;

  TempleModel({
    required this.id,
    required this.nameTelugu,
    this.nameEnglish = '',
    required this.state,
    this.district = '',
    this.deity = '',
    this.imageUrl = '',
    List<String>? images,
    this.assetPath = '',
    this.historyStory = '',
    this.timings = 'ఉదయం 6:00 నుండి రాత్రి 9:00 వరకు',
    this.specialSevas = '',
    this.onlineBookingUrl = '',
    this.googleMapsUrl = '',
    List<String>? hashtags,
    this.isPopular = true,
    this.isActive = true,
    this.order = 0,
  })  : images = images ?? [],
        hashtags = hashtags ?? [];

  factory TempleModel.fromMap(Map<String, dynamic> map, String docId) {
    List<String> imgList = [];
    if (map['images'] != null && map['images'] is List) {
      imgList = List<String>.from(map['images'].map((x) => x.toString()));
    } else if (map['imageUrl'] != null && map['imageUrl'].toString().isNotEmpty) {
      imgList = [map['imageUrl'].toString()];
    }

    List<String> tagsList = [];
    if (map['hashtags'] != null && map['hashtags'] is List) {
      tagsList = List<String>.from(map['hashtags'].map((x) => x.toString().toLowerCase().trim()));
    } else if (map['hashtags'] != null && map['hashtags'] is String) {
      tagsList = map['hashtags']
          .toString()
          .split(RegExp(r'[,#\s]+'))
          .where((s) => s.trim().isNotEmpty)
          .map((s) => s.trim().toLowerCase())
          .toList();
    }

    return TempleModel(
      id: docId,
      nameTelugu: map['nameTelugu'] ?? '',
      nameEnglish: map['nameEnglish'] ?? '',
      state: map['state'] ?? 'ఆంధ్రప్రదేశ్',
      district: map['district'] ?? '',
      deity: map['deity'] ?? '',
      imageUrl: map['imageUrl'] ?? (imgList.isNotEmpty ? imgList.first : ''),
      images: imgList,
      assetPath: map['assetPath'] ?? '',
      historyStory: map['historyStory'] ?? '',
      timings: map['timings'] ?? 'ఉదయం 6:00 నుండి రాత్రి 9:00 వరకు',
      specialSevas: map['specialSevas'] ?? '',
      onlineBookingUrl: map['onlineBookingUrl'] ?? '',
      googleMapsUrl: map['googleMapsUrl'] ?? '',
      hashtags: tagsList,
      isPopular: map['isPopular'] ?? true,
      isActive: map['isActive'] ?? true,
      order: map['order'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nameTelugu': nameTelugu,
      'nameEnglish': nameEnglish,
      'state': state,
      'district': district,
      'deity': deity,
      'imageUrl': imageUrl,
      'images': images,
      'assetPath': assetPath,
      'historyStory': historyStory,
      'timings': timings,
      'specialSevas': specialSevas,
      'onlineBookingUrl': onlineBookingUrl,
      'googleMapsUrl': googleMapsUrl,
      'hashtags': hashtags,
      'isPopular': isPopular,
      'isActive': isActive,
      'order': order,
    };
  }
}
