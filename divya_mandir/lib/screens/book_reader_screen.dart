import 'dart:io';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/spiritual_book_model.dart';
import '../services/book_reading_progress_service.dart';

class BookReaderScreen extends StatefulWidget {
  final SpiritualBookModel book;

  const BookReaderScreen({super.key, required this.book});

  @override
  State<BookReaderScreen> createState() => _BookReaderScreenState();
}

class _BookReaderScreenState extends State<BookReaderScreen> {
  final BookReadingProgressService _progressService = BookReadingProgressService();
  late PdfViewerController _pdfViewerController;

  File? _cachedPdfFile;
  bool _isLoading = true;
  String _loadingMessage = 'పుస్తకాన్ని సిద్ధం చేస్తోంది... (Loading Book...)';

  int _totalPages = 0;
  int _currentPage = 1; // Syncfusion 1-based index
  bool _nightMode = false;
  int _savedResumePage = 1;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    _loadPdfFile();
    _incrementReadCount();
  }

  void _incrementReadCount() {
    try {
      FirebaseFirestore.instance.collection('spiritual_books').doc(widget.book.id).update({
        'readCount': FieldValue.increment(1),
      });
    } catch (_) {}
  }

  Future<void> _loadPdfFile() async {
    try {
      final saved = await _progressService.getLastPage(widget.book.id);
      _savedResumePage = saved > 0 ? saved : 1;
      _currentPage = _savedResumePage;

      setState(() {
        _loadingMessage = 'PDF డౌన్‌లోడ్ అవుతోంది... (Downloading PDF...)';
      });

      // Use CacheManager for instant caching across all platforms (Android, Windows, iOS, Web)
      final file = await DefaultCacheManager().getSingleFile(
        widget.book.pdfUrl,
        key: 'pdf_book_${widget.book.id}',
      );

      if (mounted) {
        setState(() {
          _cachedPdfFile = file;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingMessage = 'PDF లోడ్ చేయడంలో లోపం ఏర్పడింది: $e';
        });
      }
    }
  }

  void _saveCurrentPage(int page) {
    _progressService.saveProgress(
      bookId: widget.book.id,
      currentPage: page,
      totalPages: _totalPages,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _nightMode ? const Color(0xFF1E1E1E) : const Color(0xFFF9F6F0);
    final headerColor = _nightMode ? const Color(0xFF2C2C2C) : const Color(0xFF6A1B29);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: headerColor,
        foregroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.book.titleTelugu.isNotEmpty
                  ? widget.book.titleTelugu
                  : widget.book.titleEnglish,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (widget.book.author.isNotEmpty)
              Text(
                widget.book.author,
                style: const TextStyle(fontSize: 11, color: Color(0xFFF1D8B4)),
              ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: _nightMode ? 'లైట్ మోడ్ (Light)' : 'డార్క్ మోడ్ (Night)',
            icon: Icon(_nightMode ? Icons.light_mode : Icons.dark_mode_outlined),
            onPressed: () {
              setState(() {
                _nightMode = !_nightMode;
              });
            },
          ),
          IconButton(
            tooltip: 'పేజీకి వెళ్లండి (Go to page)',
            icon: const Icon(Icons.pin_outlined),
            onPressed: _totalPages > 0 ? _showJumpToPageDialog : null,
          ),
        ],
      ),
      body: Stack(
        children: [
          if (_isLoading)
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                margin: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Color(0xFF6A1B29)),
                    const SizedBox(height: 16),
                    Text(
                      _loadingMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF6A1B29)),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'మొదటిసారి కాస్త సమయం పడుతుంది, తర్వాతి నుండి వేగంగా లోడ్ అవుతుంది.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11.5, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          else if (_cachedPdfFile == null)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(_loadingMessage),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _loadPdfFile,
                    child: const Text('మళ్ళీ ప్రయత్నించండి (Retry)'),
                  ),
                ],
              ),
            )
          else
            ColorFiltered(
              colorFilter: _nightMode
                  ? const ColorFilter.matrix([
                      -1.0, 0.0, 0.0, 0.0, 255.0, // R
                      0.0, -1.0, 0.0, 0.0, 255.0, // G
                      0.0, 0.0, -1.0, 0.0, 255.0, // B
                      0.0, 0.0, 0.0, 1.0, 0.0,    // A
                    ])
                  : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
              child: SfPdfViewer.file(
                _cachedPdfFile!,
                controller: _pdfViewerController,
                canShowScrollHead: true,
                canShowScrollStatus: true,
                enableDoubleTapZooming: true,
                onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                  setState(() {
                    _totalPages = details.document.pages.count;
                  });
                  // Resume to user's saved page!
                  if (_savedResumePage > 1 && _savedResumePage <= _totalPages) {
                    _pdfViewerController.jumpToPage(_savedResumePage);
                  }
                },
                onPageChanged: (PdfPageChangedDetails details) {
                  setState(() {
                    _currentPage = details.newPageNumber;
                  });
                  _saveCurrentPage(details.newPageNumber);
                },
              ),
            ),

          // Bottom floating reading bar (Page indicator & navigation)
          if (!_isLoading && _totalPages > 0)
            Positioned(
              bottom: 16,
              left: 20,
              right: 20,
              child: SafeArea(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6A1B29).withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left, color: Colors.white, size: 26),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: _currentPage > 1
                            ? () => _pdfViewerController.previousPage()
                            : null,
                      ),
                      Text(
                        'పేజీ $_currentPage / $_totalPages',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right, color: Colors.white, size: 26),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: _currentPage < _totalPages
                            ? () => _pdfViewerController.nextPage()
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showJumpToPageDialog() {
    final textController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('పేజీ నంబర్‌కి వెళ్లండి (Go to Page)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: textController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: '1 నుండి $_totalPages వరకు',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('రద్దు (Cancel)'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A1B29)),
            onPressed: () {
              final pageNum = int.tryParse(textController.text.trim());
              if (pageNum != null && pageNum >= 1 && pageNum <= _totalPages) {
                _pdfViewerController.jumpToPage(pageNum);
                Navigator.pop(ctx);
              }
            },
            child: const Text('వెళ్లండి (Go)', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
