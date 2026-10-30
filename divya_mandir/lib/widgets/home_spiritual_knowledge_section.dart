import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/spiritual_book_model.dart';
import '../screens/spiritual_books_list_screen.dart';
import '../screens/book_reader_screen.dart';
import '../services/language_service.dart';

/// "ఆధ్యాత్మిక జ్ఞానం" (Spiritual Knowledge & E-Books) Home Page Section:
/// Matches user UI layout:
/// - Header: [Flame / Spiritual Icon] "ఆధ్యాత్మిక జ్ఞానం" ----------------- [మరిన్ని →]
/// - Horizontal scrolling row of Book Cards:
///   - Rounded image card with book cover
///   - Book Title (Telugu)
///   - Category / Author name
/// - Tap card opens BookReaderScreen with fast PDF rendering and resume reading!
/// - Tap "మరిన్ని →" opens full SpiritualBooksListScreen (All categories, search, grid view)
class HomeSpiritualKnowledgeSection extends StatelessWidget {
  const HomeSpiritualKnowledgeSection({super.key});

  static List<SpiritualBookModel> get defaultBooks => [
        SpiritualBookModel(
          id: 'bhagavad_gita',
          titleTelugu: 'శ్రీమద్ భగవద్గీత',
          titleEnglish: 'Bhagavad Gita',
          author: 'వేదవ్యాస మహర్షి',
          categoryId: 'gita',
          categoryName: 'భగవద్గీత',
          thumbnailUrl: 'https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?w=600&q=80',
          pdfUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
          totalPages: 18,
          isPopular: true,
          order: 1,
        ),
        SpiritualBookModel(
          id: 'hanuman_chalisa_book',
          titleTelugu: 'హనుమాన్ చాలీసా రహస్యాలు',
          titleEnglish: 'Hanuman Chalisa Secrets',
          author: 'తులసీదాసు',
          categoryId: 'stotralu',
          categoryName: 'స్తోత్రాలు',
          thumbnailUrl: 'https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=600&q=80',
          pdfUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
          totalPages: 40,
          isPopular: true,
          order: 2,
        ),
        SpiritualBookModel(
          id: 'ramayanam_saram',
          titleTelugu: 'శ్రీరామాయణ దివ్య కథలు',
          titleEnglish: 'Ramayanam Divya Stories',
          author: 'వాల్మీకి మహర్షి',
          categoryId: 'puranalu',
          categoryName: 'పురాణాలు',
          thumbnailUrl: 'https://images.unsplash.com/photo-1512820790803-83ca734da794?w=600&q=80',
          pdfUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
          totalPages: 65,
          isPopular: false,
          order: 3,
        ),
        SpiritualBookModel(
          id: 'shiva_puranam',
          titleTelugu: 'శివ మహాపురాణం',
          titleEnglish: 'Shiva Puranam',
          author: 'వ్యాస భగవానుడు',
          categoryId: 'puranalu',
          categoryName: 'పురాణాలు',
          thumbnailUrl: 'https://images.unsplash.com/photo-1532012164546-f432f2e3edd3?w=600&q=80',
          pdfUrl: 'https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf',
          totalPages: 52,
          isPopular: true,
          order: 4,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      // 1. Check if section is enabled/disabled by Admin
      stream: FirebaseFirestore.instance.collection('app_settings').doc('spiritual_books').snapshots(),
      builder: (context, settingsSnap) {
        if (settingsSnap.hasData && settingsSnap.data != null && settingsSnap.data!.exists) {
          final settings = settingsSnap.data!.data() as Map<String, dynamic>?;
          final isEnabled = settings?['isEnabled'] ?? true;
          if (!isEnabled) {
            return const SizedBox.shrink(); // Section disabled by Admin
          }
        }

        // 2. Fetch Active Spiritual Books from Firestore
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('spiritual_books')
              .where('isActive', isEqualTo: true)
              .snapshots(),
          builder: (context, snap) {
            List<SpiritualBookModel> books = [];

            if (snap.hasData && snap.data != null && snap.data!.docs.isNotEmpty) {
              books = snap.data!.docs.map((doc) {
                return SpiritualBookModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
              }).toList();
              // Sort by order
              books.sort((a, b) => a.order.compareTo(b.order));
            }

            // Fallback to defaults if Firestore has no data yet
            if (books.isEmpty) {
              books = defaultBooks;
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBF4), // Warm divine cream container
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFF1E4CE),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8A5A20).withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. TOP HEADER: [Flame Icon] ఆధ్యాత్మిక జ్ఞానం ------------ [మరిన్ని →]
                    Row(
                      children: [
                        // Divine Flame Spiritual Crest Icon
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF4EC),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.local_fire_department_rounded,
                              color: Color(0xFFFF6D00),
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppStrings.spiritualKnowledge,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6B111D),
                            letterSpacing: -0.2,
                          ),
                        ),
                        const Spacer(),
                        // Warm Pill: "మరిన్ని →"
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SpiritualBooksListScreen(),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFDEFD9),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFF0D5AC),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  AppStrings.seeMore,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF6A1B29),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 15,
                                  color: Color(0xFF6A1B29),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // 2. HORIZONTAL SCROLLING ROW OF BOOKS
                    SizedBox(
                      height: 154,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: books.length,
                        separatorBuilder: (context, index) => const SizedBox(width: 12),
                        itemBuilder: (context, idx) {
                          final book = books[idx];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BookReaderScreen(book: book),
                                ),
                              );
                            },
                            child: SizedBox(
                              width: 104,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  // Rounded Book Thumbnail Card with soft shadow
                                  Container(
                                    width: 100,
                                    height: 104,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.1),
                                          blurRadius: 6,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          Image.network(
                                            book.thumbnailUrl,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => Container(
                                              color: const Color(0xFFFFF2DC),
                                              child: const Center(
                                                child: Icon(
                                                  Icons.auto_stories_rounded,
                                                  color: Color(0xFF6A1B29),
                                                  size: 32,
                                                ),
                                              ),
                                            ),
                                          ),
                                          // Subtle gradient overlay for reading look
                                          Positioned(
                                            bottom: 0,
                                            left: 0,
                                            right: 0,
                                            height: 28,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.black.withValues(alpha: 0.6),
                                                    Colors.transparent,
                                                  ],
                                                  begin: Alignment.bottomCenter,
                                                  end: Alignment.topCenter,
                                                ),
                                              ),
                                            ),
                                          ),
                                          if (book.isPopular)
                                            Positioned(
                                              top: 5,
                                              left: 5,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFE53935),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: const Text(
                                                  'HOT',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 8,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  // Book Title
                                  Text(
                                    book.titleTelugu.isNotEmpty ? book.titleTelugu : book.titleEnglish,
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  // Category / Author
                                  Text(
                                    book.categoryName.isNotEmpty
                                        ? book.categoryName
                                        : (book.author.isNotEmpty ? book.author : 'ఆధ్యాత్మికం'),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
