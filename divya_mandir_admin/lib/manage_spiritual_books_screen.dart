import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as img;

class ManageSpiritualBooksScreen extends StatefulWidget {
  const ManageSpiritualBooksScreen({super.key});

  @override
  State<ManageSpiritualBooksScreen> createState() => _ManageSpiritualBooksScreenState();
}

class _ManageSpiritualBooksScreenState extends State<ManageSpiritualBooksScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String _searchQuery = '';
  String _selectedCategoryFilter = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6A1B29),
        foregroundColor: Colors.white,
        title: const Text(
          "ఆధ్యాత్మిక గ్రంథాలయం & కేటగిరీల నిర్వహణ (Spiritual Books & E-Books)",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFF1C40F),
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          tabs: const [
            Tab(icon: Icon(Icons.menu_book_rounded), text: "పుస్తకాలు (Manage Books)"),
            Tab(icon: Icon(Icons.category_rounded), text: "కేటగిరీలు (Manage Categories)"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBooksTab(),
          _buildCategoriesTab(),
        ],
      ),
    );
  }

  // ==========================================
  // TAB 1: MANAGE BOOKS
  // ==========================================
  Widget _buildBooksTab() {
    return Column(
      children: [
        // Top Action Bar: Search, Category Filter, and Add Book Button
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            children: [
              // Search input
              Expanded(
                flex: 2,
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
                  decoration: InputDecoration(
                    hintText: "పుస్తకం పేరు లేదా రచయిత పేరుతో వెతకండి...",
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF6A1B29)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Category dropdown filter
              StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('spiritual_categories').orderBy('order').snapshots(),
                builder: (context, catSnap) {
                  List<DropdownMenuItem<String>> items = [
                    const DropdownMenuItem(value: 'all', child: Text("అన్ని కేటగిరీలు (All Categories)")),
                  ];
                  if (catSnap.hasData && catSnap.data != null) {
                    for (var doc in catSnap.data!.docs) {
                      final data = doc.data() as Map<String, dynamic>;
                      final name = data['nameTelugu'] ?? data['nameEnglish'] ?? doc.id;
                      items.add(DropdownMenuItem(value: doc.id, child: Text(name)));
                    }
                  }
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCategoryFilter,
                        items: items,
                        onChanged: (v) {
                          if (v != null) setState(() => _selectedCategoryFilter = v);
                        },
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 14),

              // Add Book Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A1B29),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => _openBookEditDialog(null),
                icon: const Icon(Icons.add, color: Color(0xFFF1C40F)),
                label: const Text("కొత్త పుస్తకం అప్‌లోడ్ చేయండి (Upload Book)", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),

        // Books Stream Table / Cards
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('spiritual_books').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF6A1B29)));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.menu_book_outlined, size: 64, color: Colors.grey),
                      const SizedBox(height: 12),
                      const Text("ఇంకా ఎలాంటి పుస్తకాలు అప్‌లోడ్ చేయలేదు.", style: TextStyle(fontSize: 16, color: Colors.grey)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A1B29)),
                        onPressed: () => _openBookEditDialog(null),
                        child: const Text("మొదటి పుస్తకాన్ని అప్‌లోడ్ చేయండి", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              }

              var docs = snapshot.data!.docs;

              // Filter by category
              if (_selectedCategoryFilter != 'all') {
                docs = docs.where((d) {
                  final data = d.data() as Map<String, dynamic>;
                  return data['categoryId'] == _selectedCategoryFilter;
                }).toList();
              }

              // Filter by search query
              if (_searchQuery.isNotEmpty) {
                docs = docs.where((d) {
                  final data = d.data() as Map<String, dynamic>;
                  final titleTe = (data['titleTelugu'] ?? '').toString().toLowerCase();
                  final titleEn = (data['titleEnglish'] ?? '').toString().toLowerCase();
                  final author = (data['author'] ?? '').toString().toLowerCase();
                  return titleTe.contains(_searchQuery) ||
                      titleEn.contains(_searchQuery) ||
                      author.contains(_searchQuery);
                }).toList();
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: docs.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final titleTe = data['titleTelugu'] ?? '';
                  final titleEn = data['titleEnglish'] ?? '';
                  final author = data['author'] ?? '';
                  final catName = data['categoryName'] ?? '';
                  final thumbUrl = data['thumbnailUrl'] ?? '';
                  final pdfUrl = data['pdfUrl'] ?? '';
                  final isActive = data['isActive'] ?? true;
                  final isPopular = data['isPopular'] ?? false;
                  final readCount = data['readCount'] ?? 0;
                  final totalPages = data['totalPages'] ?? 0;

                  return Card(
                    elevation: 1.5,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          // Thumbnail Preview
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: thumbUrl.isNotEmpty
                                ? Image.network(
                                    thumbUrl,
                                    width: 60,
                                    height: 80,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      width: 60,
                                      height: 80,
                                      color: Colors.grey.shade200,
                                      child: const Icon(Icons.broken_image, color: Colors.grey),
                                    ),
                                  )
                                : Container(
                                    width: 60,
                                    height: 80,
                                    color: Colors.grey.shade200,
                                    child: const Icon(Icons.picture_as_pdf, color: Colors.red),
                                  ),
                          ),
                          const SizedBox(width: 14),

                          // Book info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        titleTe.isNotEmpty ? titleTe : titleEn,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                    ),
                                    if (isPopular)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        margin: const EdgeInsets.only(left: 6),
                                        decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(4)),
                                        child: const Text('HOT', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "రచయిత: ${author.isNotEmpty ? author : 'తెలియదు'} • కేటగిరీ: ${catName.isNotEmpty ? catName : 'సాధారణ'}",
                                  style: TextStyle(fontSize: 12.5, color: Colors.grey.shade700),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.menu_book, size: 14, color: Colors.blue.shade700),
                                    const SizedBox(width: 4),
                                    Text("పేజీలు: $totalPages", style: TextStyle(fontSize: 12, color: Colors.grey.shade800)),
                                    const SizedBox(width: 14),
                                    const Icon(Icons.visibility_outlined, size: 14, color: Colors.green),
                                    const SizedBox(width: 4),
                                    Text("చదివినవారు: $readCount", style: TextStyle(fontSize: 12, color: Colors.grey.shade800)),
                                    const SizedBox(width: 14),
                                    if (pdfUrl.isNotEmpty)
                                      const Text("PDF లభ్యత: ✅ కలదు", style: TextStyle(fontSize: 11.5, color: Colors.green, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Status Switch
                          Column(
                            children: [
                              const Text("ఆన్/ఆఫ్", style: TextStyle(fontSize: 11, color: Colors.grey)),
                              Switch(
                                value: isActive,
                                activeThumbColor: const Color(0xFF6A1B29),
                                onChanged: (val) {
                                  _firestore.collection('spiritual_books').doc(doc.id).update({'isActive': val});
                                },
                              ),
                            ],
                          ),
                          const SizedBox(width: 10),

                          // Edit and Delete buttons
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            tooltip: 'సవరించండి (Edit / Replace)',
                            onPressed: () => _openBookEditDialog(doc),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            tooltip: 'తొలగించండి (Delete)',
                            onPressed: () => _confirmDeleteBook(doc.id, titleTe.isNotEmpty ? titleTe : titleEn),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // ==========================================
  // TAB 2: MANAGE CATEGORIES
  // ==========================================
  Widget _buildCategoriesTab() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "భక్తి పుస్తకాల కేటగిరీలు (Devotional Book Categories)",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF6A1B29)),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A1B29),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => _openCategoryEditDialog(null),
                icon: const Icon(Icons.add, color: Color(0xFFF1C40F)),
                label: const Text("కొత్త కేటగిరీ జోడించండి (Add Category)", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('spiritual_categories').orderBy('order').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Color(0xFF6A1B29)));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.category_outlined, size: 60, color: Colors.grey),
                      const SizedBox(height: 12),
                      const Text("ఇంకా కేటగిరీలు లేవు.", style: TextStyle(fontSize: 15, color: Colors.grey)),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A1B29)),
                        onPressed: () => _createDefaultCategories(),
                        child: const Text("ప్రాథమిక కేటగిరీలను ఆటోమేటిక్‌గా జోడించండి (Add Default Categories)", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                );
              }

              final docs = snapshot.data!.docs;

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: docs.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final doc = docs[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final nameTe = data['nameTelugu'] ?? '';
                  final nameEn = data['nameEnglish'] ?? '';
                  final order = data['order'] ?? 0;
                  final isActive = data['isActive'] ?? true;

                  return Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF6A1B29).withValues(alpha: 0.1),
                        child: Text('${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6A1B29))),
                      ),
                      title: Text(nameTe, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      subtitle: Text("English: $nameEn • Order: $order"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Switch(
                            value: isActive,
                            activeThumbColor: const Color(0xFF6A1B29),
                            onChanged: (val) {
                              _firestore.collection('spiritual_categories').doc(doc.id).update({'isActive': val});
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _openCategoryEditDialog(doc),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _confirmDeleteCategory(doc.id, nameTe),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  // ==========================================
  // DIALOG: CREATE / EDIT BOOK (WITH COMPRESSION)
  // ==========================================
  void _openBookEditDialog(DocumentSnapshot? existingDoc) {
    final isEditing = existingDoc != null;
    final data = isEditing ? existingDoc.data() as Map<String, dynamic> : null;

    final titleTeCtrl = TextEditingController(text: data?['titleTelugu'] ?? '');
    final titleEnCtrl = TextEditingController(text: data?['titleEnglish'] ?? '');
    final authorCtrl = TextEditingController(text: data?['author'] ?? '');
    final descCtrl = TextEditingController(text: data?['description'] ?? '');
    final pagesCtrl = TextEditingController(text: (data?['totalPages'] ?? 0).toString());
    final orderCtrl = TextEditingController(text: (data?['order'] ?? 0).toString());

    String selectedCategoryId = data?['categoryId'] ?? '';
    String selectedCategoryName = data?['categoryName'] ?? '';
    bool isPopular = data?['isPopular'] ?? false;
    bool isActive = data?['isActive'] ?? true;

    // Thumbnail upload & compression state
    Uint8List? pickedThumbnailBytes;
    String existingThumbnailUrl = data?['thumbnailUrl'] ?? '';
    String thumbnailCompressionInfo = '';

    // PDF upload state
    Uint8List? pickedPdfBytes;
    String existingPdfUrl = data?['pdfUrl'] ?? '';
    String pdfSizeInfo = '';

    bool isUploading = false;
    String uploadStatusMessage = '';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Function to pick & compress thumbnail image
            Future<void> pickAndCompressThumbnail() async {
              try {
                final result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
                  allowMultiple: false,
                  withData: true,
                );

                if (result == null || result.files.isEmpty) return;
                final file = result.files.first;
                if (file.bytes == null) return;

                setDialogState(() {
                  uploadStatusMessage = "థంబ్‌నెయిల్ ఇమేజ్ కంప్రెస్ చేస్తోంది (Compressing Image)...";
                });

                final rawBytes = file.bytes!;
                final originalKb = (rawBytes.lengthInBytes / 1024).toStringAsFixed(1);

                Uint8List compressedBytes = rawBytes;
                try {
                  final decoded = img.decodeImage(rawBytes);
                  if (decoded != null) {
                    img.Image resized = decoded;
                    // Resize to standard book cover dimensions (max 900px)
                    if (decoded.width > 900 || decoded.height > 900) {
                      if (decoded.width >= decoded.height) {
                        resized = img.copyResize(decoded, width: 900);
                      } else {
                        resized = img.copyResize(decoded, height: 900);
                      }
                    }
                    // Compress to quality 82 JPG
                    final encoded = img.encodeJpg(resized, quality: 82);
                    compressedBytes = Uint8List.fromList(encoded);
                  }
                } catch (_) {}

                final finalKb = (compressedBytes.lengthInBytes / 1024).toStringAsFixed(1);

                setDialogState(() {
                  pickedThumbnailBytes = compressedBytes;
                  thumbnailCompressionInfo = "$originalKb KB ➔ $finalKb KB (Compressed)";
                  uploadStatusMessage = '';
                });
              } catch (e) {
                setDialogState(() {
                  uploadStatusMessage = "చిత్రం ఎంపికలో లోపం: $e";
                });
              }
            }

            // Function to pick PDF file
            Future<void> pickPdfFile() async {
              try {
                final result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['pdf'],
                  allowMultiple: false,
                  withData: true,
                );

                if (result == null || result.files.isEmpty) return;
                final file = result.files.first;
                if (file.bytes == null) return;

                final mbSize = (file.bytes!.lengthInBytes / (1024 * 1024)).toStringAsFixed(2);

                setDialogState(() {
                  pickedPdfBytes = file.bytes!;
                  pdfSizeInfo = "$mbSize MB (${file.name})";
                });
              } catch (e) {
                setDialogState(() {
                  uploadStatusMessage = "PDF ఎంపికలో లోపం: $e";
                });
              }
            }

            // Function to upload both and save to Firestore
            Future<void> saveBook() async {
              if (titleTeCtrl.text.trim().isEmpty && titleEnCtrl.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("దయచేసి పుస్తకం పేరు నమోదు చేయండి.")),
                );
                return;
              }

              if (!isEditing && pickedPdfBytes == null && existingPdfUrl.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("దయచేసి PDF ఫైల్‌ను ఎంచుకోండి.")),
                );
                return;
              }

              setDialogState(() {
                isUploading = true;
                uploadStatusMessage = "ఫైల్స్ అప్‌లోడ్ అవుతున్నాయి... దయచేసి వేచి ఉండండి.";
              });

              String finalThumbnailUrl = existingThumbnailUrl;
              String finalPdfUrl = existingPdfUrl;

              final timestamp = DateTime.now().millisecondsSinceEpoch;

              // 1. Upload compressed thumbnail to Firebase Storage
              if (pickedThumbnailBytes != null) {
                try {
                  setDialogState(() => uploadStatusMessage = "థంబ్‌నెయిల్ అప్‌లోడ్ అవుతోంది...");
                  final thumbRef = _storage.ref().child("spiritual_books/thumbnails/${timestamp}_thumb.jpg");
                  final uploadTask = await thumbRef.putData(
                    pickedThumbnailBytes!,
                    SettableMetadata(contentType: 'image/jpeg'),
                  );
                  finalThumbnailUrl = await uploadTask.ref.getDownloadURL();
                } catch (e) {
                  debugPrint("Thumbnail upload error: $e");
                }
              }

              // 2. Upload PDF file to Firebase Storage
              if (pickedPdfBytes != null) {
                try {
                  setDialogState(() => uploadStatusMessage = "PDF ఫైల్ అప్‌లోడ్ అవుతోంది...");
                  final pdfRef = _storage.ref().child("spiritual_books/pdfs/${timestamp}_book.pdf");
                  final uploadTask = await pdfRef.putData(
                    pickedPdfBytes!,
                    SettableMetadata(contentType: 'application/pdf'),
                  );
                  finalPdfUrl = await uploadTask.ref.getDownloadURL();
                } catch (e) {
                  debugPrint("PDF upload error: $e");
                }
              }

              // 3. Save / Update Document in Firestore
              final bookData = {
                'titleTelugu': titleTeCtrl.text.trim(),
                'titleEnglish': titleEnCtrl.text.trim(),
                'author': authorCtrl.text.trim(),
                'description': descCtrl.text.trim(),
                'categoryId': selectedCategoryId,
                'categoryName': selectedCategoryName,
                'thumbnailUrl': finalThumbnailUrl,
                'pdfUrl': finalPdfUrl,
                'totalPages': int.tryParse(pagesCtrl.text.trim()) ?? 0,
                'order': int.tryParse(orderCtrl.text.trim()) ?? 0,
                'isPopular': isPopular,
                'isActive': isActive,
                'updatedAt': FieldValue.serverTimestamp(),
              };

              if (!isEditing) {
                bookData['readCount'] = 0;
                bookData['createdAt'] = FieldValue.serverTimestamp();
                await _firestore.collection('spiritual_books').add(bookData);
              } else {
                await _firestore.collection('spiritual_books').doc(existingDoc.id).update(bookData);
              }

              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }
            }

            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: SizedBox(
                width: 720,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isEditing ? "పుస్తకాన్ని సవరించండి (Edit / Replace Book)" : "నూతన భక్తి పుస్తకం అప్‌లోడ్ (Upload New Book)",
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF6A1B29)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: isUploading ? null : () => Navigator.pop(dialogContext),
                          ),
                        ],
                      ),
                      const Divider(height: 24),

                      // Text Fields Row 1: Telugu & English Title
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: titleTeCtrl,
                              decoration: InputDecoration(
                                labelText: "పుస్తకం పేరు (తెలుగు)",
                                hintText: "ఉదా: శ్రీమద్ భగవద్గీత",
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: TextField(
                              controller: titleEnCtrl,
                              decoration: InputDecoration(
                                labelText: "Book Title (English)",
                                hintText: "e.g. Srimad Bhagavad Gita",
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Row 2: Author & Category
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: authorCtrl,
                              decoration: InputDecoration(
                                labelText: "రచయిత / సంపాదకుడు (Author)",
                                hintText: "ఉదా: వేదవ్యాసుడు",
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: StreamBuilder<QuerySnapshot>(
                              stream: _firestore.collection('spiritual_categories').orderBy('order').snapshots(),
                              builder: (context, catSnap) {
                                List<DropdownMenuItem<String>> items = [];
                                if (catSnap.hasData && catSnap.data != null) {
                                  for (var doc in catSnap.data!.docs) {
                                    final d = doc.data() as Map<String, dynamic>;
                                    final name = d['nameTelugu'] ?? d['nameEnglish'] ?? doc.id;
                                    items.add(DropdownMenuItem(value: doc.id, child: Text(name)));
                                    if (selectedCategoryId.isEmpty && items.isNotEmpty) {
                                      selectedCategoryId = doc.id;
                                      selectedCategoryName = name;
                                    }
                                  }
                                }
                                return DropdownButtonFormField<String>(
                                  value: selectedCategoryId.isNotEmpty ? selectedCategoryId : null,
                                  decoration: InputDecoration(
                                    labelText: "కేటగిరీ ఎంచుకోండి (Select Category)",
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  items: items,
                                  onChanged: (v) {
                                    if (v != null) {
                                      final selectedDoc = catSnap.data!.docs.firstWhere((element) => element.id == v);
                                      final d = selectedDoc.data() as Map<String, dynamic>;
                                      setDialogState(() {
                                        selectedCategoryId = v;
                                        selectedCategoryName = d['nameTelugu'] ?? d['nameEnglish'] ?? '';
                                      });
                                    }
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Row 3: Pages & Display Order
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: pagesCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: "మొత్తం పేజీలు (Total Pages)",
                                hintText: "ఉదా: 50",
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: TextField(
                              controller: orderCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: "డిస్‌ప్లే ఆర్డర్ (Display Order)",
                                hintText: "ఉదా: 1",
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Description
                      TextField(
                        controller: descCtrl,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: "పుస్తకం సంక్షిప్త వివరణ (Description)",
                          hintText: "ఈ ఆధ్యాత్మిక పుస్తకంలో గల ముఖ్య విశేషాలు...",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // THUMBNAIL UPLOAD SECTION (WITH AUTO COMPRESSION)
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF9EE),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFF1D8B4)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.image_outlined, color: Color(0xFF6A1B29), size: 20),
                                const SizedBox(width: 8),
                                const Text(
                                  "పుస్తకం కవర్ పేజీ థంబ్‌నెయిల్ (Thumbnail with Auto Compression)",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF6A1B29)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A1B29)),
                                  onPressed: isUploading ? null : pickAndCompressThumbnail,
                                  icon: const Icon(Icons.upload_file, color: Colors.white, size: 18),
                                  label: Text(
                                    existingThumbnailUrl.isNotEmpty ? "థంబ్‌నెయిల్ మార్చండి (Change Thumbnail)" : "థంబ్‌నెయిల్ ఎంచుకోండి (Pick Image)",
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                if (thumbnailCompressionInfo.isNotEmpty)
                                  Expanded(
                                    child: Text(
                                      "సైజ్: $thumbnailCompressionInfo",
                                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                  )
                                else if (existingThumbnailUrl.isNotEmpty)
                                  const Text("ప్రస్తుతం ఇమేజ్ ఉంది ✅", style: TextStyle(color: Colors.blue, fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // PDF FILE UPLOAD SECTION
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F4FF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFC7D7FE)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.picture_as_pdf_rounded, color: Colors.red, size: 20),
                                const SizedBox(width: 8),
                                const Text(
                                  "పుస్తకం PDF ఫైల్ (Book PDF File)",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E3A8A)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E3A8A)),
                                  onPressed: isUploading ? null : pickPdfFile,
                                  icon: const Icon(Icons.attach_file, color: Colors.white, size: 18),
                                  label: Text(
                                    existingPdfUrl.isNotEmpty ? "PDF ఫైల్ మార్చండి (Replace PDF)" : "PDF ఎంచుకోండి (Pick PDF)",
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                if (pdfSizeInfo.isNotEmpty)
                                  Expanded(
                                    child: Text(
                                      "ఎంచుకున్న ఫైల్: $pdfSizeInfo",
                                      style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                  )
                                else if (existingPdfUrl.isNotEmpty)
                                  const Text("ప్రస్తుతం PDF ఉంది ✅", style: TextStyle(color: Colors.blue, fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Popular & Active Checkboxes
                      Row(
                        children: [
                          Checkbox(
                            value: isPopular,
                            activeColor: const Color(0xFF6A1B29),
                            onChanged: (v) => setDialogState(() => isPopular = v ?? false),
                          ),
                          const Text("ప్రముఖమైనది (Popular / Featured / HOT)", style: TextStyle(fontWeight: FontWeight.w600)),
                          const SizedBox(width: 24),
                          Checkbox(
                            value: isActive,
                            activeColor: const Color(0xFF6A1B29),
                            onChanged: (v) => setDialogState(() => isActive = v ?? true),
                          ),
                          const Text("యాక్టివ్‌గా ఉంచు (Active)", style: TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),

                      if (uploadStatusMessage.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(8)),
                          child: Row(
                            children: [
                              const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF6A1B29))),
                              const SizedBox(width: 10),
                              Text(uploadStatusMessage, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF6A1B29))),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),

                      // Action Buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: isUploading ? null : () => Navigator.pop(dialogContext),
                            child: const Text("రద్దు (Cancel)"),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6A1B29),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: isUploading ? null : saveBook,
                            child: Text(
                              isEditing ? "మార్పులను భద్రపరచండి (Update Book)" : "అప్‌లోడ్ చేయండి (Upload Book)",
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ==========================================
  // DIALOG: CREATE / EDIT CATEGORY
  // ==========================================
  void _openCategoryEditDialog(DocumentSnapshot? existingDoc) {
    final isEditing = existingDoc != null;
    final data = isEditing ? existingDoc.data() as Map<String, dynamic> : null;

    final teCtrl = TextEditingController(text: data?['nameTelugu'] ?? '');
    final enCtrl = TextEditingController(text: data?['nameEnglish'] ?? '');
    final orderCtrl = TextEditingController(text: (data?['order'] ?? 0).toString());
    bool isActive = data?['isActive'] ?? true;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(
                isEditing ? "కేటగిరీని సవరించండి" : "కొత్త కేటగిరీని జోడించండి",
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6A1B29)),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: teCtrl,
                    decoration: InputDecoration(
                      labelText: "కేటగిరీ పేరు (తెలుగు)",
                      hintText: "ఉదా: భగవద్గీత, పురాణాలు",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: enCtrl,
                    decoration: InputDecoration(
                      labelText: "Category Name (English)",
                      hintText: "e.g. Bhagavad Gita, Puranas",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: orderCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "ఆర్డర్ (Order)",
                      hintText: "ఉదా: 1",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Checkbox(
                        value: isActive,
                        activeColor: const Color(0xFF6A1B29),
                        onChanged: (v) => setDialogState(() => isActive = v ?? true),
                      ),
                      const Text("యాక్టివ్ (Active)"),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text("రద్దు"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A1B29)),
                  onPressed: () async {
                    if (teCtrl.text.trim().isEmpty && enCtrl.text.trim().isEmpty) return;
                    final catData = {
                      'nameTelugu': teCtrl.text.trim(),
                      'nameEnglish': enCtrl.text.trim(),
                      'order': int.tryParse(orderCtrl.text.trim()) ?? 0,
                      'isActive': isActive,
                    };
                    if (isEditing) {
                      await _firestore.collection('spiritual_categories').doc(existingDoc.id).update(catData);
                    } else {
                      await _firestore.collection('spiritual_categories').add(catData);
                    }
                    if (dialogContext.mounted) Navigator.pop(dialogContext);
                  },
                  child: const Text("సేవ్ చేయండి", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Confirm delete book
  void _confirmDeleteBook(String bookId, String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text("పుస్తకాన్ని తొలగించాలా?", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
        content: Text("'$title' పుస్తకాన్ని ఖచ్చితంగా తొలగించాలనుకుంటున్నారా?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("రద్దు")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await _firestore.collection('spiritual_books').doc(bookId).delete();
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text("తొలగించు", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Confirm delete category
  void _confirmDeleteCategory(String catId, String title) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text("కేటగిరీని తొలగించాలా?", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
        content: Text("'$title' కేటగిరీని తొలగించాలనుకుంటున్నారా?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("రద్దు")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await _firestore.collection('spiritual_categories').doc(catId).delete();
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text("తొలగించు", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Initialize default categories
  Future<void> _createDefaultCategories() async {
    final defaultCategories = [
      {'nameTelugu': 'భగవద్గీత', 'nameEnglish': 'Bhagavad Gita', 'order': 1, 'isActive': true},
      {'nameTelugu': 'పురాణాలు', 'nameEnglish': 'Puranas', 'order': 2, 'isActive': true},
      {'nameTelugu': 'స్తోత్రాలు & మంత్రాలు', 'nameEnglish': 'Stotras & Mantras', 'order': 3, 'isActive': true},
      {'nameTelugu': 'ఉపనిషత్తులు', 'nameEnglish': 'Upanishads', 'order': 4, 'isActive': true},
      {'nameTelugu': 'రామాయణం & భారతం', 'nameEnglish': 'Itihasas', 'order': 5, 'isActive': true},
      {'nameTelugu': 'భక్తి కీర్తనలు', 'nameEnglish': 'Keerthanas', 'order': 6, 'isActive': true},
      {'nameTelugu': 'ఆధ్యాత్మిక జీవితం', 'nameEnglish': 'Spiritual Life', 'order': 7, 'isActive': true},
    ];

    for (var cat in defaultCategories) {
      await _firestore.collection('spiritual_categories').add(cat);
    }
  }
}
