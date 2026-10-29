import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_player/video_player.dart';
import 'status_detail_screen.dart';

class StatusScreen extends StatefulWidget {
  const StatusScreen({super.key});

  @override
  State<StatusScreen> createState() => _StatusScreenState();
}

class _StatusScreenState extends State<StatusScreen> {
  String? _selectedCategoryId;
  String _searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Header / Search Bar (Filter wallpapers by title/name)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) => setState(() => _searchQuery = value.toLowerCase().trim()),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Search Status Wallpapers...",
                        icon: const Icon(Icons.search, color: Colors.grey),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: Colors.grey, size: 20),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = "");
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Categories Horizontal List
          SizedBox(
            height: 100,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('status_categories')
                  .where('is_active', isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();
                final categories = snapshot.data!.docs;
                
                // If nothing selected and data exists, select first category
                if (_selectedCategoryId == null && categories.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) setState(() => _selectedCategoryId = categories.first.id);
                  });
                }

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final data = categories[index].data() as Map<String, dynamic>;
                    final docId = categories[index].id;
                    final name = data['name'] ?? '';
                    final imageUrl = data['image_url'];
                    final isSelected = _selectedCategoryId == docId;

                    return GestureDetector(
                      onTap: () => setState(() => _selectedCategoryId = docId),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Column(
                          children: [
                            Container(
                              width: 65,
                              height: 65,
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? const Color(0xFF6A1B29) : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(30),
                                child: imageUrl != null
                                    ? Image.network(imageUrl, fit: BoxFit.cover)
                                    : Container(color: Colors.grey.shade300, child: const Icon(Icons.image, color: Colors.white)),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              name,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? const Color(0xFF6A1B29) : Colors.black87,
                              ),
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

          // Same style Grid View (Images & Video Wallpapers with title bar)
          Expanded(
            child: _selectedCategoryId == null
                ? const Center(child: CircularProgressIndicator())
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('status_photos')
                        .where('category_id', isEqualTo: _selectedCategoryId)
                        .where('is_active', isEqualTo: true)
                        .orderBy('created_at', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return const Center(child: Text("Error fetching wallpapers. Check Firestore index."));
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(child: Text("No wallpapers available.", style: TextStyle(color: Colors.grey)));
                      }

                      final docs = snapshot.data!.docs;
                      // Map all items
                      var mediaItems = docs.map((d) {
                        final data = d.data() as Map<String, dynamic>;
                        final isVideo = data['media_type'] == 'video';
                        final url = (data['image_url'] ?? data['video_url'] ?? '') as String;
                        final title = (data['title'] ?? '').toString();
                        return {
                          'id': d.id,
                          'url': url,
                          'title': title,
                          'media_type': isVideo ? 'video' : 'image',
                          'is_video': isVideo,
                        };
                      }).toList();

                      // Filter by Search Query
                      if (_searchQuery.isNotEmpty) {
                        mediaItems = mediaItems.where((item) {
                          final title = (item['title'] as String).toLowerCase();
                          return title.contains(_searchQuery);
                        }).toList();
                      }

                      if (mediaItems.isEmpty) {
                        return const Center(
                          child: Text("No wallpapers match your search.", style: TextStyle(color: Colors.grey)),
                        );
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.65,
                        ),
                        itemCount: mediaItems.length,
                        itemBuilder: (context, index) {
                          final item = mediaItems[index];
                          final isVideo = item['is_video'] as bool;
                          final url = item['url'] as String;
                          final title = (item['title'] as String?) ?? '';

                          // Entire item card is clickable to open detail page!
                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StatusDetailScreen(
                                    items: mediaItems,
                                    initialIndex: index,
                                    initialCategoryId: _selectedCategoryId,
                                  ),
                                ),
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  // Content: Image or Video First-Frame Thumbnail
                                  Container(
                                    color: Colors.black87,
                                    child: isVideo
                                        ? _VideoThumbnailFrame(videoUrl: url)
                                        : Image.network(
                                            url,
                                            fit: BoxFit.cover,
                                            loadingBuilder: (context, child, loadingProgress) {
                                              if (loadingProgress == null) return child;
                                              return const Center(child: CircularProgressIndicator());
                                            },
                                            errorBuilder: (context, error, stackTrace) =>
                                                const Icon(Icons.image_not_supported, color: Colors.grey),
                                          ),
                                  ),

                                  // Only Video Icon in top corner
                                  if (isVideo)
                                    Positioned(
                                      top: 10,
                                      right: 10,
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.65),
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white24, width: 0.5),
                                        ),
                                        child: const Icon(
                                          Icons.videocam,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),

                                  // Bottom transparent dark black background with white title and ellipsis (...)
                                  if (title.isNotEmpty)
                                    Positioned(
                                      bottom: 0,
                                      left: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.bottomCenter,
                                            end: Alignment.topCenter,
                                            colors: [
                                              Colors.black.withValues(alpha: 0.85),
                                              Colors.black.withValues(alpha: 0.4),
                                              Colors.transparent,
                                            ],
                                          ),
                                        ),
                                        child: Text(
                                          title,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 0.3,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
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
      ),
    );
  }
}

/// Helper widget to extract and display the video's first frame thumbnail cleanly without auto-playing or controls
class _VideoThumbnailFrame extends StatefulWidget {
  final String videoUrl;
  const _VideoThumbnailFrame({required this.videoUrl});

  @override
  State<_VideoThumbnailFrame> createState() => _VideoThumbnailFrameState();
}

class _VideoThumbnailFrameState extends State<_VideoThumbnailFrame> {
  late VideoPlayerController _controller;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        if (mounted) {
          _controller.seekTo(const Duration(milliseconds: 200));
          _controller.pause();
          setState(() => _isLoaded = true);
        }
      }).catchError((_) {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: !_isLoaded
          ? Container(
              color: Colors.grey.shade900,
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white24),
              ),
            )
          : FittedBox(
              fit: BoxFit.cover,
              clipBehavior: Clip.hardEdge,
              child: SizedBox(
                width: _controller.value.size.width,
                height: _controller.value.size.height,
                child: VideoPlayer(_controller),
              ),
            ),
    );
  }
}
