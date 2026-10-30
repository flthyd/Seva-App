import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/spiritual_book_model.dart';
import '../services/book_reading_progress_service.dart';
import 'book_reader_screen.dart';

class SpiritualBooksListScreen extends StatefulWidget {
  final String? initialCategoryId;

  const SpiritualBooksListScreen({super.key, this.initialCategoryId});

  @override
  State<SpiritualBooksListScreen> createState() => _SpiritualBooksListScreenState();
}

class _SpiritualBooksListScreenState extends State<SpiritualBooksListScreen> {
  final BookReadingProgressService _progressService = BookReadingProgressService();
  String _selectedCategoryId = 'all';
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  final Map<String, BookReadingProgressModel> _readingProgressMap = {};

  @override
  void initState() {
    super.initState();
    if (widget.initialCategoryId != null) {
      _selectedCategoryId = widget.initialCategoryId!;
    }
    _loadAllProgress();
  }

  Future<void> _loadAllProgress() async {
    // Reload reading progress for all books
    final snap = await FirebaseFirestore.instance.collection('spiritual_books').get();
    for (var doc in snap.docs) {
      final p = await _progressService.getProgress(doc.id);
      if (p != null && mounted) {
        setState(() {
          _readingProgressMap[doc.id] = p;
        });
      }
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF7EE),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A1B29),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "ఆధ్యాత్మిక గ్రంథాలయం (E-Books)",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                decoration: InputDecoration(
                  hintText: 'పుస్తకం లేదా రచయిత పేరు వెతకండి...',
                  hintStyle: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF6A1B29), size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // 1. Categories Horizontal Filter Chips
          _buildCategoryFilterBar(),

          // 2. Books Grid / List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('spiritual_books')
                  .where('isActive', isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF6A1B29)));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState();
                }

                List<SpiritualBookModel> books = snapshot.data!.docs.map((d) {
                  return SpiritualBookModel.fromMap(d.data() as Map<String, dynamic>, d.id);
                }).toList();

                // Filter by category
                if (_selectedCategoryId != 'all') {
                  books = books.where((b) => b.categoryId == _selectedCategoryId).toList();
                }

                // Filter by search query
                if (_searchQuery.isNotEmpty) {
                  books = books.where((b) {
                    final tTel = b.titleTelugu.toLowerCase();
                    final tEng = b.titleEnglish.toLowerCase();
                    final auth = b.author.toLowerCase();
                    return tTel.contains(_searchQuery) ||
                        tEng.contains(_searchQuery) ||
                        auth.contains(_searchQuery);
                  }).toList();
                }

                // Sort by order & popularity
                books.sort((a, b) => a.order.compareTo(b.order));

                if (books.isEmpty) {
                  return _buildEmptyState(message: 'మీరు వెతికిన పుస్తకాలు దొరకలేదు.');
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(14),
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.62,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 14,
                  ),
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final book = books[index];
                    final progress = _readingProgressMap[book.id];
                    return _buildBookCard(book, progress);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilterBar() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('spiritual_categories')
          .where('isActive', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        List<SpiritualCategoryModel> categories = [];
        if (snapshot.hasData && snapshot.data != null) {
          categories = snapshot.data!.docs.map((d) {
            return SpiritualCategoryModel.fromMap(d.data() as Map<String, dynamic>, d.id);
          }).toList();
          categories.sort((a, b) => a.order.compareTo(b.order));
        }

        return Container(
          color: Colors.white,
          height: 52,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            children: [
              _buildFilterChip('all', 'అన్నీ (All)'),
              ...categories.map((c) => _buildFilterChip(c.id, c.nameTelugu.isNotEmpty ? c.nameTelugu : c.nameEnglish)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(String id, String label) {
    final isSelected = _selectedCategoryId == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategoryId = id),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6A1B29) : const Color(0xFFFBF4EA),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF6A1B29) : const Color(0xFFEAD8C3),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF6A1B29),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookCard(SpiritualBookModel book, BookReadingProgressModel? progress) {
    final hasRead = progress != null && progress.lastPage > 0;

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => BookReaderScreen(book: book)),
        );
        _loadAllProgress();
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF1E4CE), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6A1B29).withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail Image with badges
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                    child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: Image.network(
                        book.thumbnailUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFFFFF2DC),
                          child: const Center(
                            child: Icon(Icons.menu_book_rounded, size: 48, color: Color(0xFF6A1B29)),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Reading Resume Pill
                  if (hasRead)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6A1B29).withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFF1C40F), width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.bookmark_rounded, size: 10, color: Color(0xFFF1C40F)),
                            const SizedBox(width: 3),
                            Text(
                              'P. ${progress.lastPage + 1}',
                              style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Popular / Free Badge
                  if (book.isPopular)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE53935),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'HOT',
                          style: TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Book Details
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.titleTelugu.isNotEmpty ? book.titleTelugu : book.titleEnglish,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D1810),
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    book.author.isNotEmpty ? book.author : 'ఆధ్యాత్మిక రచన',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Read Action Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        hasRead ? 'చదవడం కొనసాగించండి' : 'ఉచితంగా చదవండి',
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6A1B29),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6A1B29).withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: Color(0xFF6A1B29)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({String? message}) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: const BoxDecoration(
              color: Color(0xFFFFF2DC),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_stories_rounded, size: 48, color: Color(0xFF6A1B29)),
          ),
          const SizedBox(height: 14),
          Text(
            message ?? 'త్వరలో మరిన్ని ఆధ్యాత్మిక గ్రంథాలు జోడించబడతాయి.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF6A1B29)),
          ),
          const SizedBox(height: 6),
          const Text(
            'అడ్మిన్ ప్యానెల్ ద్వారా నూతన భక్తి పుస్తకాలను అప్‌లోడ్ చేయవచ్చు.',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
