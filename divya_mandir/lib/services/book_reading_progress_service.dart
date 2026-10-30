import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class BookReadingProgressModel {
  final String bookId;
  final int lastPage;
  final int totalPages;
  final DateTime lastReadTime;

  BookReadingProgressModel({
    required this.bookId,
    required this.lastPage,
    required this.totalPages,
    required this.lastReadTime,
  });

  Map<String, dynamic> toMap() => {
        'bookId': bookId,
        'lastPage': lastPage,
        'totalPages': totalPages,
        'lastReadTime': lastReadTime.toIso8601String(),
      };

  factory BookReadingProgressModel.fromMap(Map<String, dynamic> map) => BookReadingProgressModel(
        bookId: map['bookId'] ?? '',
        lastPage: (map['lastPage'] as num?)?.toInt() ?? 0,
        totalPages: (map['totalPages'] as num?)?.toInt() ?? 0,
        lastReadTime: map['lastReadTime'] != null
            ? DateTime.tryParse(map['lastReadTime']) ?? DateTime.now()
            : DateTime.now(),
      );
}

class BookReadingProgressService {
  static final BookReadingProgressService _instance = BookReadingProgressService._internal();
  factory BookReadingProgressService() => _instance;
  BookReadingProgressService._internal();

  static const String _prefPrefix = 'reading_progress_';

  Future<void> saveProgress({
    required String bookId,
    required int currentPage,
    required int totalPages,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final model = BookReadingProgressModel(
      bookId: bookId,
      lastPage: currentPage,
      totalPages: totalPages,
      lastReadTime: DateTime.now(),
    );
    await prefs.setString('$_prefPrefix$bookId', jsonEncode(model.toMap()));
  }

  Future<BookReadingProgressModel?> getProgress(String bookId) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('$_prefPrefix$bookId');
    if (data == null || data.isEmpty) return null;
    try {
      final decoded = jsonDecode(data);
      return BookReadingProgressModel.fromMap(decoded);
    } catch (_) {
      return null;
    }
  }

  Future<int> getLastPage(String bookId) async {
    final p = await getProgress(bookId);
    return p?.lastPage ?? 0;
  }
}
