import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/audio_player_service.dart';
import '../services/ringtone_service.dart';
import 'dashboard.dart';
import 'now_playing_screen.dart';

class MusicPlayerSheet extends StatefulWidget {
  const MusicPlayerSheet({super.key});

  @override
  State<MusicPlayerSheet> createState() => _MusicPlayerSheetState();
}

class _MusicPlayerSheetState extends State<MusicPlayerSheet> {
  final AudioPlayerService _audioService = AudioPlayerService();
  final RingtoneService _ringtoneService = RingtoneService();
  String _selectedCategoryId = 'all';
  String _selectedCategoryName = 'All Songs';

  @override
  void initState() {
    super.initState();
    _audioService.addListener(_onServiceUpdate);
    _ringtoneService.addListener(_onServiceUpdate);
  }

  @override
  void dispose() {
    _audioService.removeListener(_onServiceUpdate);
    _ringtoneService.removeListener(_onServiceUpdate);
    super.dispose();
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  void _navigateToSongsPage() {
    Navigator.pop(context); // Close the bottom sheet
    DashboardScreen.switchTab(context, 3); // Switch to Music Tab (Tab index 3)
  }

  String _formatDuration(Duration d) {
    String minutes = d.inMinutes.toString().padLeft(2, '0');
    String seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  Widget _buildSongThumbnail(String? imageUrl, bool isLocal, double size) {
    if (isLocal) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: const Color(0xFF6A1B29).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.music_note_rounded, color: Color(0xFF6A1B29), size: 28),
      );
    }

    if (imageUrl != null && imageUrl.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          imageUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset(
              'assets/images/app_logo.png',
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Container(
                width: size,
                height: size,
                color: const Color(0xFF6A1B29).withValues(alpha: 0.1),
                child: const Icon(Icons.temple_hindu_rounded, color: Color(0xFF6A1B29), size: 28),
              ),
            );
          },
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.asset(
        'assets/images/app_logo.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (c, e, s) => Container(
          width: size,
          height: size,
          color: const Color(0xFF6A1B29).withValues(alpha: 0.1),
          child: const Icon(Icons.temple_hindu_rounded, color: Color(0xFF6A1B29), size: 28),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentSong = _audioService.currentSong;

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
                color: Color(0xFFFCF8F2),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 12),
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  // Categories Horizontal Bar
                  _buildCategoriesBar(),

                  // Title Row with "See All >"
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "Popular $_selectedCategoryName",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6A1B29),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        InkWell(
                          onTap: _navigateToSongsPage,
                          borderRadius: BorderRadius.circular(8),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: Row(
                              children: [
                                Text(
                                  "See All >",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFC08B39),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Songs Vertical List
                  Expanded(
                    child: _buildSongsList(scrollController),
                  ),
                ],
              ),
            ),

            // Persistent Mini Player at bottom of Sheet
            if (currentSong != null) _buildStickyMiniPlayer(currentSong),
          ],
        );
      },
    );
  }

  Widget _buildCategoriesBar() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('music_categories')
          .orderBy('created_at', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        List<Map<String, dynamic>> categories = [
          {
            'id': 'all',
            'name': 'All Songs',
            'image_url': null,
            'icon': Icons.music_note,
          },
          {
            'id': 'ringtones',
            'name': 'రింగ్‌టోన్స్ (Ringtones)',
            'image_url': null,
            'icon': Icons.ring_volume_rounded,
          },
          {
            'id': 'favorites',
            'name': 'నా ఇష్టమైనవి (Favorites)',
            'image_url': null,
            'icon': Icons.favorite,
          },
          {
            'id': 'local',
            'name': 'నా పాటలు (My Device)',
            'image_url': null,
            'icon': Icons.phone_android,
          },
        ];

        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            categories.add({
              'id': doc.id,
              'name': data['name'] ?? 'Category',
              'image_url': data['image_url'],
              'icon': Icons.library_music,
            });
          }
        }

        return SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final isSelected = _selectedCategoryId == cat['id'];

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategoryId = cat['id'];
                    _selectedCategoryName = cat['name'];
                  });
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 18),
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFFBECEC) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected ? const Color(0xFF6A1B29) : Colors.grey.shade200,
                            width: isSelected ? 1.8 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: cat['image_url'] != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    cat['image_url'],
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.contain,
                                  ),
                                )
                              : Icon(
                                  cat['icon'] as IconData,
                                  color: isSelected ? const Color(0xFF6A1B29) : (cat['id'] == 'favorites' ? Colors.red.shade400 : Colors.grey.shade600),
                                  size: 28,
                                ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: 70,
                        child: Text(
                          cat['name'] ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? const Color(0xFF6A1B29) : Colors.black87,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Container(
                          margin: const EdgeInsets.only(top: 3),
                          width: 22,
                          height: 3,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF39C12),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSongsList(ScrollController scrollController) {
    // 1. My Device Local Songs
    if (_selectedCategoryId == 'local') {
      final localSongs = _audioService.userLocalSongs;
      if (localSongs.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              "మీ మొబైల్ లోని పాటలు ఏవీ లేవు.\nSongs పేజీ నుండి పాటలను ఎంచుకోవచ్చు.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, fontSize: 13),
            ),
          ),
        );
      }

      return ListView.builder(
        controller: scrollController,
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 90),
        itemCount: localSongs.length,
        itemBuilder: (context, index) {
          final song = localSongs[index];
          return _buildSongItem(song, localSongs);
        },
      );
    }

    // 2b. Ringtone Songs Tab
    if (_selectedCategoryId == 'ringtones') {
      final ringtoneIds = _ringtoneService.ringtoneSongIds;

      return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('songs').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF6A1B29)));
          }

          final docs = snapshot.data!.docs;
          final ringtoneSongs = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return data['is_ringtone'] == true || ringtoneIds.contains(doc.id);
          }).map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return SongModel(
              id: doc.id,
              title: data['title'] ?? 'Devotional Ringtone',
              artist: data['artist'] ?? 'Divya Mandir',
              imageUrl: data['image_url'],
              audioUrl: data['audio_url'] ?? '',
              categoryId: data['category_id'],
            );
          }).toList();

          for (var localSong in _audioService.userLocalSongs) {
            if (ringtoneIds.contains(localSong.id) && !ringtoneSongs.any((s) => s.id == localSong.id)) {
              ringtoneSongs.add(localSong);
            }
          }

          if (ringtoneSongs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.ring_volume_rounded, size: 48, color: Colors.grey),
                    SizedBox(height: 12),
                    Text(
                      "రింగ్‌టోన్స్ ఏవీ లేవు.\nపాటల ప్రక్కన ఉన్న బెల్ (🔔) గుర్తును నొక్కి రింగ్‌టోన్‌గా సెట్ చేయండి.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 90),
            itemCount: ringtoneSongs.length,
            itemBuilder: (context, index) {
              final song = ringtoneSongs[index];
              return _buildSongItem(song, ringtoneSongs);
            },
          );
        },
      );
    }

    // 2. Favorites Tab
    if (_selectedCategoryId == 'favorites') {
      final favIds = _audioService.favoriteIds;
      if (favIds.isEmpty) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border, size: 50, color: Colors.grey),
                SizedBox(height: 12),
                Text(
                  "ఇష్టమైన పాటలు ఏవీ లేవు.\nపాటల ప్రక్కన ఉన్న హార్ట్ (Heart) గుర్తును నొక్కి చేర్చుకోండి.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ],
            ),
          ),
        );
      }

      return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('songs').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF6A1B29)));
          }

          final docs = snapshot.data!.docs;
          final favSongs = docs.where((doc) => favIds.contains(doc.id)).map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return SongModel(
              id: doc.id,
              title: data['title'] ?? 'Unknown Devotional Song',
              artist: data['artist'] ?? 'Divya Mandir',
              imageUrl: data['image_url'],
              audioUrl: data['audio_url'] ?? '',
              categoryId: data['category_id'],
            );
          }).toList();

          for (var localSong in _audioService.userLocalSongs) {
            if (favIds.contains(localSong.id) && !favSongs.any((s) => s.id == localSong.id)) {
              favSongs.add(localSong);
            }
          }

          if (favSongs.isEmpty) {
            return const Center(
              child: Text(
                "ఇష్టమైన పాటలు ఏవీ లేవు.",
                style: TextStyle(color: Colors.black54, fontSize: 13),
              ),
            );
          }

          return ListView.builder(
            controller: scrollController,
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 90),
            itemCount: favSongs.length,
            itemBuilder: (context, index) {
              final song = favSongs[index];
              return _buildSongItem(song, favSongs);
            },
          );
        },
      );
    }

    // 3. Category or All Songs from Firestore
    Query query = FirebaseFirestore.instance.collection('songs');
    if (_selectedCategoryId != 'all') {
      query = query.where('category_id', isEqualTo: _selectedCategoryId);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF6A1B29)));
        }

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return const Center(child: Text("పాటలు కనుగొనబడలేదు (No songs found)."));
        }

        final songList = docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return SongModel(
            id: doc.id,
            title: data['title'] ?? 'Unknown Song',
            artist: data['artist'] ?? 'Divya Mandir',
            imageUrl: data['image_url'],
            audioUrl: data['audio_url'] ?? '',
            categoryId: data['category_id'],
          );
        }).toList();

        return ListView.builder(
          controller: scrollController,
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 90),
          itemCount: songList.length,
          itemBuilder: (context, index) {
            final song = songList[index];
            return _buildSongItem(song, songList);
          },
        );
      },
    );
  }

  Widget _buildSongItem(SongModel song, List<SongModel> currentList) {
    final isCurrent = _audioService.currentSong?.id == song.id;
    final isPlaying = isCurrent && _audioService.isPlaying;
    final isFavorite = _audioService.isFavorite(song.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isCurrent ? const Color(0xFFF1C40F) : Colors.grey.shade200,
          width: isCurrent ? 1.6 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        leading: _buildSongThumbnail(song.imageUrl, song.isLocal, 50),
        title: Row(
          children: [
            if (isCurrent)
              const Padding(
                padding: EdgeInsets.only(right: 6),
                child: Icon(Icons.bar_chart, color: Color(0xFF6A1B29), size: 16),
              ),
            Expanded(
              child: Text(
                song.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isCurrent ? const Color(0xFF6A1B29) : Colors.black87,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Text(
            song.artist,
            style: const TextStyle(fontSize: 12, color: Colors.blueGrey),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ringtone Button
            IconButton(
              icon: Icon(
                _ringtoneService.isRingtoneSong(song.id)
                    ? Icons.ring_volume_rounded
                    : Icons.notifications_none_rounded,
                color: _ringtoneService.isRingtoneSong(song.id)
                    ? const Color(0xFF6A1B29)
                    : Colors.grey.shade500,
                size: 20,
              ),
              tooltip: 'Set as Ringtone',
              onPressed: () {
                RingtoneService.showSetRingtoneSheet(
                  context: context,
                  songId: song.id,
                  songTitle: song.title,
                  audioUrl: song.audioUrl,
                  isLocal: song.isLocal,
                );
              },
            ),
            // Favorite Button
            IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? const Color(0xFFE74C3C) : Colors.grey.shade400,
                size: 22,
              ),
              onPressed: () => _audioService.toggleFavorite(song.id),
            ),
            // Play/Pause circular button
            GestureDetector(
              onTap: () {
                if (isCurrent) {
                  _audioService.togglePlayPause();
                } else {
                  _audioService.playSong(song, newPlaylist: currentList);
                }
              },
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCurrent ? const Color(0xFF6A1B29) : const Color(0xFFFFF0F0),
                  border: Border.all(color: const Color(0xFF6A1B29), width: 1),
                ),
                child: Icon(
                  isPlaying ? Icons.pause : Icons.play_arrow,
                  color: isCurrent ? const Color(0xFFF1C40F) : const Color(0xFF6A1B29),
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStickyMiniPlayer(SongModel song) {
    final isPlaying = _audioService.isPlaying;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        top: false,
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NowPlayingScreen()),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF5A1421), Color(0xFF2E0911)],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    _buildSongThumbnail(song.imageUrl, song.isLocal, 44),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            song.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            song.artist,
                            style: const TextStyle(color: Color(0xFFF1C40F), fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_previous, color: Colors.white, size: 26),
                      onPressed: _audioService.playPrevious,
                    ),
                    GestureDetector(
                      onTap: _audioService.togglePlayPause,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFF39C12), width: 1.5),
                        ),
                        child: _audioService.isLoading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Color(0xFFF39C12),
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(
                                isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.white,
                                size: 22,
                              ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next, color: Colors.white, size: 26),
                      onPressed: _audioService.playNext,
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                // Tiny Seekbar
                Row(
                  children: [
                    Text(
                      _formatDuration(_audioService.position),
                      style: const TextStyle(color: Colors.white70, fontSize: 10),
                    ),
                    Expanded(
                      child: SliderTheme(
                        data: const SliderThemeData(
                          trackHeight: 2,
                          thumbShape: RoundSliderThumbShape(enabledThumbRadius: 4),
                          overlayShape: RoundSliderOverlayShape(overlayRadius: 8),
                        ),
                        child: Slider(
                          activeColor: const Color(0xFFF39C12),
                          inactiveColor: Colors.white24,
                          value: (_audioService.duration.inSeconds > 0)
                              ? _audioService.position.inSeconds
                                  .toDouble()
                                  .clamp(0.0, _audioService.duration.inSeconds.toDouble())
                              : 0.0,
                          min: 0.0,
                          max: (_audioService.duration.inSeconds > 0)
                              ? _audioService.duration.inSeconds.toDouble()
                              : 1.0,
                          onChanged: (value) {
                            _audioService.seek(Duration(seconds: value.toInt()));
                          },
                        ),
                      ),
                    ),
                    Text(
                      _formatDuration(_audioService.duration),
                      style: const TextStyle(color: Colors.white70, fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
