class KathaModel {
  final String id;
  final String title; // కథ శీర్షిక (e.g., శ్రీ కృష్ణ జనన కథ)
  final String shortSummary; // సంక్షిప్త వివరణ (e.g., శ్రీ కృష్ణుడు జననం, గోకులం, బాలలీలలు...)
  final String fullStory; // పూర్తి ఆధ్యాత్మిక కథ
  final String moral; // నీతి / ఆధ్యాత్మిక సందేశం
  final String category; // పురాణాలు / భగవద్గీత / రామాయణం / పంచతంత్రం
  final String imageUrl; // Banner photo URL
  final String assetPath; // Local fallback asset
  final String date; // YYYY-MM-DD or Display date (e.g., 2026-10-26)
  final bool isFeaturedToday; // నేటి కథ (Active for Today)
  final bool isActive;
  final int viewsCount;
  final int order;

  KathaModel({
    required this.id,
    required this.title,
    required this.shortSummary,
    required this.fullStory,
    this.moral = '',
    this.category = 'పురాణాలు',
    this.imageUrl = '',
    this.assetPath = '',
    this.date = '',
    this.isFeaturedToday = true,
    this.isActive = true,
    this.viewsCount = 108,
    this.order = 0,
  });

  factory KathaModel.fromMap(Map<String, dynamic> map, String docId) {
    return KathaModel(
      id: docId,
      title: map['title'] ?? '',
      shortSummary: map['shortSummary'] ?? '',
      fullStory: map['fullStory'] ?? '',
      moral: map['moral'] ?? '',
      category: map['category'] ?? 'పురాణాలు',
      imageUrl: map['imageUrl'] ?? '',
      assetPath: map['assetPath'] ?? '',
      date: map['date'] ?? '',
      isFeaturedToday: map['isFeaturedToday'] ?? false,
      isActive: map['isActive'] ?? true,
      viewsCount: map['viewsCount'] ?? 108,
      order: map['order'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'shortSummary': shortSummary,
      'fullStory': fullStory,
      'moral': moral,
      'category': category,
      'imageUrl': imageUrl,
      'assetPath': assetPath,
      'date': date,
      'isFeaturedToday': isFeaturedToday,
      'isActive': isActive,
      'viewsCount': viewsCount,
      'order': order,
    };
  }
}
