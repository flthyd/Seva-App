class SpiritualCategoryModel {
  final String id;
  final String nameTelugu;
  final String nameEnglish;
  final String? icon;
  final int order;
  final bool isActive;

  SpiritualCategoryModel({
    required this.id,
    required this.nameTelugu,
    required this.nameEnglish,
    this.icon,
    this.order = 0,
    this.isActive = true,
  });

  factory SpiritualCategoryModel.fromMap(Map<String, dynamic> map, String docId) {
    return SpiritualCategoryModel(
      id: docId,
      nameTelugu: map['nameTelugu'] ?? '',
      nameEnglish: map['nameEnglish'] ?? '',
      icon: map['icon'],
      order: (map['order'] as num?)?.toInt() ?? 0,
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nameTelugu': nameTelugu,
      'nameEnglish': nameEnglish,
      'icon': icon,
      'order': order,
      'isActive': isActive,
    };
  }
}

class SpiritualBookModel {
  final String id;
  final String titleTelugu;
  final String titleEnglish;
  final String author;
  final String description;
  final String categoryId;
  final String categoryName;
  final String thumbnailUrl;
  final String pdfUrl;
  final int totalPages;
  final String fileSizeBytes;
  final int readCount;
  final bool isPopular;
  final int order;
  final bool isActive;
  final DateTime? createdAt;

  SpiritualBookModel({
    required this.id,
    required this.titleTelugu,
    required this.titleEnglish,
    this.author = '',
    this.description = '',
    required this.categoryId,
    this.categoryName = '',
    required this.thumbnailUrl,
    required this.pdfUrl,
    this.totalPages = 0,
    this.fileSizeBytes = '',
    this.readCount = 0,
    this.isPopular = false,
    this.order = 0,
    this.isActive = true,
    this.createdAt,
  });

  factory SpiritualBookModel.fromMap(Map<String, dynamic> map, String docId) {
    return SpiritualBookModel(
      id: docId,
      titleTelugu: map['titleTelugu'] ?? '',
      titleEnglish: map['titleEnglish'] ?? '',
      author: map['author'] ?? '',
      description: map['description'] ?? '',
      categoryId: map['categoryId'] ?? '',
      categoryName: map['categoryName'] ?? '',
      thumbnailUrl: map['thumbnailUrl'] ?? '',
      pdfUrl: map['pdfUrl'] ?? '',
      totalPages: (map['totalPages'] as num?)?.toInt() ?? 0,
      fileSizeBytes: map['fileSizeBytes'] ?? '',
      readCount: (map['readCount'] as num?)?.toInt() ?? 0,
      isPopular: map['isPopular'] ?? false,
      order: (map['order'] as num?)?.toInt() ?? 0,
      isActive: map['isActive'] ?? true,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] is DateTime
              ? map['createdAt'] as DateTime
              : (map['createdAt'] as dynamic).toDate())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'titleTelugu': titleTelugu,
      'titleEnglish': titleEnglish,
      'author': author,
      'description': description,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'thumbnailUrl': thumbnailUrl,
      'pdfUrl': pdfUrl,
      'totalPages': totalPages,
      'fileSizeBytes': fileSizeBytes,
      'readCount': readCount,
      'isPopular': isPopular,
      'order': order,
      'isActive': isActive,
      'createdAt': createdAt ?? DateTime.now(),
    };
  }
}
