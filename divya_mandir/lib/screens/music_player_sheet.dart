import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class MusicPlayerSheet extends StatefulWidget {
  final AudioPlayer audioPlayer;
  const MusicPlayerSheet({Key? key, required this.audioPlayer}) : super(key: key);

  @override
  State<MusicPlayerSheet> createState() => _MusicPlayerSheetState();
}

class _MusicPlayerSheetState extends State<MusicPlayerSheet> {
  String? _selectedCategoryId;
  String? _selectedCategoryName;
  
  static String? _currentSongId;
  static String? _currentSongTitle;
  static String? _currentSongArtist;
  static String? _currentSongImage;
  
  bool _isPlaying = false;
  bool _isLoadingAudio = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _isPlaying = widget.audioPlayer.state == PlayerState.playing;
    _setupAudioListeners();
    _fetchInitialCategory();
  }
  
  void _setupAudioListeners() {
    widget.audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _isPlaying = state == PlayerState.playing);
    });
    widget.audioPlayer.onDurationChanged.listen((newDuration) {
      if (mounted) setState(() => _duration = newDuration);
    });
    widget.audioPlayer.onPositionChanged.listen((newPosition) {
      if (mounted) setState(() => _position = newPosition);
    });
  }

  Future<void> _fetchInitialCategory() async {
    final snap = await FirebaseFirestore.instance.collection('music_categories').orderBy('created_at').get();
    if (snap.docs.isNotEmpty && mounted) {
      setState(() {
        _selectedCategoryId = snap.docs.first.id;
        _selectedCategoryName = (snap.docs.first.data() as Map<String, dynamic>)['name'];
      });
    }
  }

  Future<void> _playSong(Map<String, dynamic> data, String docId) async {
    if (_currentSongId == docId && _isPlaying) {
      await widget.audioPlayer.pause();
    } else if (_currentSongId == docId && !_isPlaying) {
      await widget.audioPlayer.resume();
    } else {
      setState(() {
        _currentSongId = docId;
        _currentSongTitle = data['title'];
        _currentSongArtist = data['artist'];
        _currentSongImage = data['image_url'];
        _isLoadingAudio = true;
      });
      
      try {
        final url = data['audio_url'];
        // Instant play via Cache Manager
        final file = await DefaultCacheManager().getSingleFile(url);
        await widget.audioPlayer.play(DeviceFileSource(file.path));
      } catch (e) {
        // Fallback to network
        await widget.audioPlayer.play(UrlSource(data['audio_url']));
      } finally {
        if (mounted) setState(() => _isLoadingAudio = false);
      }
    }
  }
  
  String _formatDuration(Duration d) {
    String minutes = d.inMinutes.toString().padLeft(2, '0');
    String seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFFCF8F2), // Light warm background from screenshot
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 16),
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  
                  // Categories Horizontal List
                  SizedBox(
                    height: 100,
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('music_categories').orderBy('created_at').snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) return const SizedBox.shrink();
                        final docs = snapshot.data!.docs;
                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: docs.length,
                          itemBuilder: (context, index) {
                            final data = docs[index].data() as Map<String, dynamic>;
                            final isSelected = _selectedCategoryId == docs[index].id;
                            return GestureDetector(
                              onTap: () => setState(() {
                                _selectedCategoryId = docs[index].id;
                                _selectedCategoryName = data['name'];
                              }),
                              child: Container(
                                margin: const EdgeInsets.only(right: 20),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 65, height: 65,
                                      decoration: BoxDecoration(
                                        color: isSelected ? const Color(0xFFFBECEC) : Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        boxShadow: [
                                          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                                        ]
                                      ),
                                      child: Center(
                                        child: data['image_url'] != null 
                                          ? ClipRRect(
                                              borderRadius: BorderRadius.circular(12),
                                              child: Image.network(data['image_url'], width: 45, height: 45, fit: BoxFit.contain)
                                            )
                                          : Icon(Icons.library_music, color: isSelected ? const Color(0xFF6A1B29) : Colors.grey, size: 30),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      data['name'] ?? '',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                        color: isSelected ? const Color(0xFF6A1B29) : Colors.black87,
                                      ),
                                    ),
                                    if (isSelected)
                                      Container(
                                        margin: const EdgeInsets.only(top: 4),
                                        width: 25, height: 3, 
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF39C12),
                                          borderRadius: BorderRadius.circular(2)
                                        )
                                      )
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      }
                    ),
                  ),
                  
                  // Title Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Popular ${_selectedCategoryName ?? 'Songs'}",
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF6A1B29)),
                        ),
                        const Text(
                          "See All >",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFFC08B39)),
                        ),
                      ],
                    ),
                  ),
                  
                  // Songs Vertical List
                  Expanded(
                    child: _selectedCategoryId == null 
                      ? const Center(child: CircularProgressIndicator())
                      : StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance.collection('songs').where('category_id', isEqualTo: _selectedCategoryId).snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                            final docs = snapshot.data!.docs;
                            if (docs.isEmpty) return const Center(child: Text("No songs found."));
                            
                            return ListView.builder(
                              controller: scrollController,
                              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 100), // padding for mini player
                              itemCount: docs.length,
                              itemBuilder: (context, index) {
                                final data = docs[index].data() as Map<String, dynamic>;
                                final isThisPlaying = _currentSongId == docs[index].id;
                                
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                    leading: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: data['image_url'] != null
                                          ? Image.network(data['image_url'], width: 55, height: 55, fit: BoxFit.cover)
                                          : Container(width: 55, height: 55, color: Colors.grey.shade300, child: const Icon(Icons.music_note, color: Colors.grey)),
                                    ),
                                    title: Row(
                                      children: [
                                        if (isThisPlaying)
                                          const Padding(
                                            padding: EdgeInsets.only(right: 6),
                                            child: Icon(Icons.bar_chart, color: Color(0xFFF37B53), size: 16),
                                          ),
                                        Expanded(
                                          child: Text(
                                            data['title'] ?? '',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: isThisPlaying ? const Color(0xFFF37B53) : Colors.black87,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        data['artist'] ?? '',
                                        style: const TextStyle(fontSize: 13, color: Colors.blueGrey),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        GestureDetector(
                                          onTap: () => _playSong(data, docs[index].id),
                                          child: Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: const Color(0xFFFFF0F0),
                                              border: Border.all(color: const Color(0xFFF37B53), width: 1),
                                            ),
                                            child: Icon(
                                              (isThisPlaying && _isPlaying) ? Icons.pause : Icons.play_arrow,
                                              color: const Color(0xFFF37B53),
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const Icon(Icons.more_vert, color: Colors.blueGrey),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          }
                        ),
                  )
                ],
              ),
            ),
            _buildStickyMiniPlayer(),
          ],
        );
      }
    );
  }

  Widget _buildStickyMiniPlayer() {
    if (_currentSongId == null) return const SizedBox.shrink();
    
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF5A1421), Color(0xFF2E0911)]),
            // No rounded corners as requested
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, -2))
            ]
          ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _currentSongImage != null
                      ? Image.network(_currentSongImage!, width: 45, height: 45, fit: BoxFit.cover)
                      : Container(width: 45, height: 45, color: Colors.white24, child: const Icon(Icons.music_note, color: Colors.white)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_currentSongTitle ?? '', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14), overflow: TextOverflow.ellipsis),
                      Text(_currentSongArtist ?? '', style: const TextStyle(color: Colors.white70, fontSize: 11), overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                // Controls
                const Icon(Icons.skip_previous, color: Colors.white, size: 28),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    if (_isPlaying) widget.audioPlayer.pause();
                    else widget.audioPlayer.resume();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFF39C12), width: 1.5),
                    ),
                    child: _isLoadingAudio 
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Color(0xFFF39C12), strokeWidth: 2))
                      : Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 24),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.skip_next, color: Colors.white, size: 28),
                const SizedBox(width: 8),
                const Icon(Icons.queue_music, color: Colors.white70, size: 24),
              ],
            ),
            const SizedBox(height: 8),
            // Seekbar
            Row(
              children: [
                Text(_formatDuration(_position), style: const TextStyle(color: Colors.white70, fontSize: 10)),
                Expanded(
                  child: SliderTheme(
                    data: const SliderThemeData(
                      trackHeight: 2,
                      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 5),
                      overlayShape: RoundSliderOverlayShape(overlayRadius: 10),
                    ),
                    child: Builder(
                      builder: (context) {
                        double maxVal = _duration.inSeconds.toDouble() > 0 ? _duration.inSeconds.toDouble() : 1.0;
                        double currentVal = _position.inSeconds.toDouble().clamp(0.0, maxVal);
                        return Slider(
                          activeColor: const Color(0xFFF39C12),
                          inactiveColor: Colors.white24,
                          value: currentVal,
                          min: 0.0,
                          max: maxVal,
                          onChanged: (value) {
                            widget.audioPlayer.seek(Duration(seconds: value.toInt()));
                          },
                        );
                      },
                    ),
                  ),
                ),
                Text(_formatDuration(_duration), style: const TextStyle(color: Colors.white70, fontSize: 10)),
              ],
            )
          ],
        ),
      ),
      ),
    );
  }
}




