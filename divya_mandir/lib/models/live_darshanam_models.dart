class TempleDarshanModel {
  final String id;
  final String name; // e.g. శ్రీ వేంకటేశ్వర స్వామి
  final String templeLocation; // e.g. తిరుమల
  final String state; // e.g. ఆంధ్రప్రదేశ్, తెలంగాణ, ఉత్తర భారతదేశం
  final String youtubeUrl; // Live YouTube link / ID
  final String bannerImage; // High-res temple gopuram banner
  final String deityImage; // Deity image / photo
  final String viewerCount; // e.g. 12.4K
  final bool isLive; // true / false
  final String description; // Temple sthala puranam / details
  final List<DarshanScheduleItem> schedules; // Timings
  final List<AartiItem> aartis; // Aartis & sevas
  final List<PoojaSevaItem> poojaSevas; // Pooja sevas & booking price
  final List<PrasadamItem> prasadams; // Famous prasadams
  final List<String> galleryImages; // Temple photos
  final bool isFavorite;

  TempleDarshanModel({
    required this.id,
    required this.name,
    required this.templeLocation,
    required this.state,
    required this.youtubeUrl,
    required this.bannerImage,
    required this.deityImage,
    this.viewerCount = '10.5K',
    this.isLive = true,
    this.description = '',
    this.schedules = const [],
    this.aartis = const [],
    this.poojaSevas = const [],
    this.prasadams = const [],
    this.galleryImages = const [],
    this.isFavorite = false,
  });

  factory TempleDarshanModel.fromMap(String id, Map<String, dynamic> data) {
    return TempleDarshanModel(
      id: id,
      name: data['title'] ?? data['name'] ?? 'శ్రీ దేవాలయం',
      templeLocation: data['templeLocation'] ?? 'పుణ్యక్షేత్రం',
      state: data['state'] ?? 'ఆంధ్రప్రదేశ్',
      youtubeUrl: data['youtubeUrl'] ?? '',
      bannerImage: data['bannerImage'] ?? data['customThumbnail'] ?? 'https://images.unsplash.com/photo-1621360841013-c7683c659ec6?w=800&q=80',
      deityImage: data['deityImage'] ?? data['bannerImage'] ?? 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=800&q=80',
      viewerCount: data['viewerCount'] ?? '12.4K',
      isLive: data['isActive'] ?? data['isLive'] ?? true,
      description: data['description'] ?? 'పరమ పవిత్రమైన పుణ్యక్షేత్రం మరియు స్వయంభూ క్షేత్రం.',
      schedules: (data['schedules'] as List<dynamic>?)
              ?.map((e) => DarshanScheduleItem.fromMap(e as Map<String, dynamic>))
              .toList() ??
          _defaultSchedules(),
      aartis: (data['aartis'] as List<dynamic>?)
              ?.map((e) => AartiItem.fromMap(e as Map<String, dynamic>))
              .toList() ??
          _defaultAartis(),
      poojaSevas: (data['poojaSevas'] as List<dynamic>?)
              ?.map((e) => PoojaSevaItem.fromMap(e as Map<String, dynamic>))
              .toList() ??
          _defaultPoojaSevas(),
      prasadams: (data['prasadams'] as List<dynamic>?)
              ?.map((e) => PrasadamItem.fromMap(e as Map<String, dynamic>))
              .toList() ??
          _defaultPrasadams(),
      galleryImages: (data['galleryImages'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
          [
            'https://images.unsplash.com/photo-1621360841013-c7683c659ec6?w=600&q=80',
            'https://images.unsplash.com/photo-1542838132-92c53300491e?w=600&q=80',
            'https://images.unsplash.com/photo-1609766857041-ed402ea8069a?w=600&q=80',
          ],
      isFavorite: data['isFavorite'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': name,
      'name': name,
      'templeLocation': templeLocation,
      'state': state,
      'youtubeUrl': youtubeUrl,
      'bannerImage': bannerImage,
      'customThumbnail': bannerImage,
      'deityImage': deityImage,
      'viewerCount': viewerCount,
      'isActive': isLive,
      'isLive': isLive,
      'description': description,
    };
  }

  static List<DarshanScheduleItem> _defaultSchedules() => [
        DarshanScheduleItem(title: 'సుప్రభాతం', time: '03:00 AM – 03:30 AM', category: 'హారతి'),
        DarshanScheduleItem(title: 'తోమాలసేవ', time: '03:30 AM – 04:00 AM', category: 'సేవ'),
        DarshanScheduleItem(title: 'వేకువ దర్శనం', time: '04:00 AM – 05:00 AM', category: 'దర్శనం'),
        DarshanScheduleItem(title: 'సర్వదర్శనం', time: '06:00 AM – 01:00 PM', category: 'దర్శనం'),
        DarshanScheduleItem(title: 'మధ్యాహ్న హారతి', time: '12:00 PM – 12:30 PM', category: 'హారతి'),
        DarshanScheduleItem(title: 'సాయంత్ర దర్శనం', time: '04:00 PM – 08:00 PM', category: 'దర్శనం'),
        DarshanScheduleItem(title: 'రాత్రి హారతి', time: '08:00 PM – 08:30 PM', category: 'హారతి'),
        DarshanScheduleItem(title: 'ఏకాంత సేవ', time: '09:00 PM – 09:30 PM', category: 'సేవ'),
      ];

  static List<AartiItem> _defaultAartis() => [
        AartiItem(title: 'సుప్రభాతం', time: '03:00 AM', icon: '🌅'),
        AartiItem(title: 'తోమాల సేవ', time: '04:00 AM', icon: '🌸'),
        AartiItem(title: 'అర్చన', time: '05:00 AM', icon: '🙏'),
        AartiItem(title: 'నైవేద్యం', time: '11:00 AM', icon: '🍚'),
        AartiItem(title: 'మధ్యాహ్న హారతి', time: '12:00 PM', icon: '🪔'),
        AartiItem(title: 'సాయంత్ర హారతి', time: '06:30 PM', icon: '✨'),
        AartiItem(title: 'రాత్రి హారతి', time: '08:00 PM', icon: '🔔'),
        AartiItem(title: 'ఏకాంత సేవ', time: '09:00 PM', icon: '🌙'),
      ];

  static List<PoojaSevaItem> _defaultPoojaSevas() => [
        PoojaSevaItem(title: 'అర్చన', price: 116, category: 'ప్రత్యేక సేవలు'),
        PoojaSevaItem(title: 'అభిషేకం', price: 516, category: 'ప్రత్యేక సేవలు'),
        PoojaSevaItem(title: 'నిత్య కళ్యాణం', price: 1116, category: 'నిత్య సేవలు'),
        PoojaSevaItem(title: 'సహస్రనామ అర్చన', price: 516, category: 'నిత్య సేవలు'),
      ];

  static List<PrasadamItem> _defaultPrasadams() => [
        PrasadamItem(title: 'తిరుపతి లడ్డూ', price: 50, unit: 'ఒకటి'),
        PrasadamItem(title: 'అర్చన ప్రసాదం', price: 30, unit: 'ప్యాకెట్'),
        PrasadamItem(title: 'వడ ప్రసాదం', price: 40, unit: 'ఒకటి'),
        PrasadamItem(title: 'పులిహోర ప్రసాదం', price: 30, unit: 'కప్పు'),
        PrasadamItem(title: 'చక్కెర పొంగలి', price: 40, unit: 'కప్పు'),
      ];
}

class DarshanScheduleItem {
  final String title;
  final String time;
  final String category;

  DarshanScheduleItem({required this.title, required this.time, required this.category});

  factory DarshanScheduleItem.fromMap(Map<String, dynamic> map) {
    return DarshanScheduleItem(
      title: map['title'] ?? '',
      time: map['time'] ?? '',
      category: map['category'] ?? 'దర్శనం',
    );
  }
}

class AartiItem {
  final String title;
  final String time;
  final String icon;

  AartiItem({required this.title, required this.time, required this.icon});

  factory AartiItem.fromMap(Map<String, dynamic> map) {
    return AartiItem(
      title: map['title'] ?? '',
      time: map['time'] ?? '',
      icon: map['icon'] ?? '🪔',
    );
  }
}

class PoojaSevaItem {
  final String title;
  final int price;
  final String category;

  PoojaSevaItem({required this.title, required this.price, required this.category});

  factory PoojaSevaItem.fromMap(Map<String, dynamic> map) {
    return PoojaSevaItem(
      title: map['title'] ?? '',
      price: map['price'] ?? 100,
      category: map['category'] ?? 'ప్రత్యేక సేవలు',
    );
  }
}

class PrasadamItem {
  final String title;
  final int price;
  final String unit;

  PrasadamItem({required this.title, required this.price, required this.unit});

  factory PrasadamItem.fromMap(Map<String, dynamic> map) {
    return PrasadamItem(
      title: map['title'] ?? '',
      price: map['price'] ?? 50,
      unit: map['unit'] ?? 'ఒకటి',
    );
  }
}
