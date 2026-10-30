import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../services/audio_player_service.dart';
import '../services/ringtone_service.dart';
import 'now_playing_screen.dart';
import 'dashboard.dart';

class MusicScreen extends StatefulWidget {
  final String initialCategoryId;
  const MusicScreen({super.key, this.initialCategoryId = 'all'});

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {
  final AudioPlayerService _audioService = AudioPlayerService();
  final RingtoneService _ringtoneService = RingtoneService();
  late String _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.initialCategoryId;
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

  // Pick media/audio file from user mobile device (kept strictly local, no Firebase upload)
  Future<void> _pickUserLocalAudio() async {
    try {
      final picker = ImagePicker();
      final XFile? media = await picker.pickMedia();

      if (media != null) {
        String title = media.name;
        if (title.contains('.')) {
          title = title.substring(0, title.lastIndexOf('.'));
        }
        final song = SongModel(
          id: 'local_${DateTime.now().millisecondsSinceEpoch}_${media.name}',
          title: title,
          artist: 'Local Device Audio',
          imageUrl: null,
          audioUrl: media.path,
          isLocal: true,
        );
        _audioService.addUserLocalSong(song);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('స్థానిక ఆడియో చేర్చబడింది (Added locally)'),
              backgroundColor: Color(0xFF6A1B29),
            ),
          );
          setState(() {
            _selectedCategoryId = 'local';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ఫైల్ ఎంచుకోవడంలో సమస్య: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
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
        child: const Icon(Icons.music_note_rounded, color: Color(0xFF6A1B29), size: 30),
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
                child: const Icon(Icons.temple_hindu_rounded, color: Color(0xFF6A1B29), size: 30),
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
          child: const Icon(Icons.temple_hindu_rounded, color: Color(0xFF6A1B29), size: 30),
        ),
      ),
    );
  }

  void _openNowPlaying() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NowPlayingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentSong = _audioService.currentSong;

    return Scaffold(
      backgroundColor: const Color(0xFFFCF8F2),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFF1C40F)),
          tooltip: 'వెనక్కి (Back)',
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              DashboardScreen.switchTab(context, 0); // Navigate to Home tab
            }
          },
        ),
        title: const Text(
          'దివ్య సంగీతం (Divine Music)',
          style: TextStyle(
            color: Color(0xFFF1C40F),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFF6A1B29),
        elevation: 2,
        centerTitle: true,
        actions: [
          // Button to add personal local songs from phone storage
          IconButton(
            tooltip: 'Add Local Songs from Phone',
            icon: const Icon(Icons.library_add, color: Color(0xFFF1C40F)),
            onPressed: _pickUserLocalAudio,
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Filter Tabs (from Firestore + 'All' + 'నా పాటలు / My Device')
          _buildCategoryFilterTabs(),

          // Main Song List / Grid
          Expanded(
            child: _buildSongsList(),
          ),

          // Persistent Bottom Mini-Player Bar
          if (currentSong != null) _buildMiniPlayer(currentSong),
        ],
      ),
    );
  }

  // Dynamic Horizontal Categories Bar
  Widget _buildCategoryFilterTabs() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('music_categories')
          .orderBy('created_at', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        List<Map<String, String>> categories = [
          {'id': 'all', 'name': 'All Songs'},
          {'id': 'ringtones', 'name': 'రింగ్‌టోన్స్ (Ringtones)'},
          {'id': 'favorites', 'name': 'నా ఇష్టమైనవి (My Favorites)'},
          {'id': 'local', 'name': 'నా పాటలు (My Device)'},
        ];

        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            categories.add({
              'id': doc.id,
              'name': data['name'] ?? 'Category',
            });
          }
        }

        return Container(
          height: 52,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final isSelected = _selectedCategoryId == cat['id'];

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: FilterChip(
                  label: Text(cat['name']!),
                  selected: isSelected,
                  onSelected: (val) {
                    setState(() {
                      _selectedCategoryId = cat['id']!;
                    });
                  },
                  backgroundColor: const Color(0xFFFCF8F2),
                  selectedColor: const Color(0xFF6A1B29),
                  labelStyle: TextStyle(
                    color: isSelected ? const Color(0xFFF1C40F) : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    fontSize: 13,
                  ),
                  checkmarkColor: const Color(0xFFF1C40F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isSelected ? const Color(0xFF6A1B29) : Colors.grey.shade300,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // Songs List View (Local device songs or Firestore categorized songs)
  Widget _buildSongsList() {
    // If user selected 'local', show only device songs
    if (_selectedCategoryId == 'local') {
      final localSongs = _audioService.userLocalSongs;
      if (localSongs.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.phone_android_rounded, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                const Text(
                  'మీ మొబైల్ లోని పాటలు ఇక్కడ చేర్చండి',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF6A1B29)),
                ),
                const SizedBox(height: 8),
                const Text(
                  'ఇవి కేవలం మీ ఫోన్ నుండి మాత్రమే ప్లే అవుతాయి (No upload to server).',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _pickUserLocalAudio,
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text('పాటలను ఎంచుకోండి (Select Songs)', style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6A1B29),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: localSongs.length,
        itemBuilder: (context, index) {
          final song = localSongs[index];
          final isCurrent = _audioService.currentSong?.id == song.id;
          final isPlaying = isCurrent && _audioService.isPlaying;

          return _buildSongCard(
            song: song,
            isCurrent: isCurrent,
            isPlaying: isPlaying,
            onTap: () {
              _audioService.playSong(song, newPlaylist: localSongs);
            },
            onDelete: () {
              _audioService.removeUserLocalSong(song.id);
            },
          );
        },
      );
    }

    // If user selected 'ringtones', show songs marked as ringtone or query ringtones
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
            final bool isExplicitRingtone = data['is_ringtone'] == true;
            return isExplicitRingtone || ringtoneIds.contains(doc.id);
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

          // Also check user's local songs if set as ringtone
          for (var localSong in _audioService.userLocalSongs) {
            if (ringtoneIds.contains(localSong.id) && !ringtoneSongs.any((s) => s.id == localSong.id)) {
              ringtoneSongs.add(localSong);
            }
          }

          if (ringtoneSongs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6A1B29).withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.ring_volume_rounded, size: 50, color: Color(0xFF6A1B29)),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'రింగ్‌టోన్స్ ఏవీ లేవు',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF6A1B29)),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'ఏదైనా పాట ప్రక్కన ఉన్న బెల్ గుర్తు (🔔) ను నొక్కి మీ ఫోన్ రింగ్‌టోన్, నోటిఫికేషన్ లేదా అలారంగా సెట్ చేయండి.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.black54, height: 1.4),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: ringtoneSongs.length,
            itemBuilder: (context, index) {
              final song = ringtoneSongs[index];
              final isCurrent = _audioService.currentSong?.id == song.id;
              final isPlaying = isCurrent && _audioService.isPlaying;

              return _buildSongCard(
                song: song,
                isCurrent: isCurrent,
                isPlaying: isPlaying,
                onTap: () {
                  _audioService.playSong(song, newPlaylist: ringtoneSongs);
                },
              );
            },
          );
        },
      );
    }

    // If user selected 'favorites', show only user favorited songs
    if (_selectedCategoryId == 'favorites') {
      final favIds = _audioService.favoriteIds;
      if (favIds.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                const Text(
                  'ఇష్టమైన పాటలు ఏవీ లేవు',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF6A1B29)),
                ),
                const SizedBox(height: 8),
                const Text(
                  'పాటల ప్రక్కన ఉన్న హార్ట్ (Heart) గుర్తును నొక్కి మీ ఇష్టమైన జాబితాలోకి చేర్చుకోండి.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.black54),
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
              title: data['title'] ?? 'Unknown Song',
              artist: data['artist'] ?? 'Divya Mandir',
              imageUrl: data['image_url'],
              audioUrl: data['audio_url'] ?? '',
              categoryId: data['category_id'],
            );
          }).toList();

          // Also include local songs if favorited
          for (var localSong in _audioService.userLocalSongs) {
            if (favIds.contains(localSong.id) && !favSongs.any((s) => s.id == localSong.id)) {
              favSongs.add(localSong);
            }
          }

          if (favSongs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.favorite_border, size: 64, color: Colors.grey.shade400),
                    const SizedBox(height: 16),
                    const Text(
                      'ఇష్టమైన పాటలు ఏవీ లేవు',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF6A1B29)),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'పాటల ప్రక్కన ఉన్న హార్ట్ గుర్తును నొక్కి మీ ఇష్టమైన జాబితాలోకి చేర్చుకోండి.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: favSongs.length,
            itemBuilder: (context, index) {
              final song = favSongs[index];
              final isCurrent = _audioService.currentSong?.id == song.id;
              final isPlaying = isCurrent && _audioService.isPlaying;

              return _buildSongCard(
                song: song,
                isCurrent: isCurrent,
                isPlaying: isPlaying,
                onTap: () {
                  _audioService.playSong(song, newPlaylist: favSongs);
                },
              );
            },
          );
        },
      );
    }

    // Otherwise query Firestore songs
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
          // If no songs yet in Firebase, show high quality fallback divine sample songs
          final fallbackSongs = [
            SongModel(
              id: 'fb_1',
              title: 'Govinda Namalu',
              artist: 'Annamacharya Keerthanalu',
              imageUrl: 'https://images.unsplash.com/photo-1544816155-12df9643f363?auto=format&fit=crop&w=400&q=80',
              audioUrl: 'https://actions.google.com/sounds/v1/water/waves_crashing_on_rock_beach.ogg',
            ),
            SongModel(
              id: 'fb_2',
              title: 'Hanuman Chalisa',
              artist: 'Gulshan Kumar',
              imageUrl: 'https://images.unsplash.com/photo-1582650625119-3a31f841839d?auto=format&fit=crop&w=400&q=80',
              audioUrl: 'https://actions.google.com/sounds/v1/weather/rain_heavy_loud.ogg',
            ),
            SongModel(
              id: 'fb_3',
              title: 'Sri Venkateswara Suprabhatam',
              artist: 'M.S. Subbulakshmi',
              imageUrl: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?auto=format&fit=crop&w=400&q=80',
              audioUrl: 'https://actions.google.com/sounds/v1/water/waves_crashing_on_rock_beach.ogg',
            ),
            SongModel(
              id: 'fb_4',
              title: 'Om Namah Shivaya',
              artist: 'Hariharan',
              imageUrl: 'https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?auto=format&fit=crop&w=400&q=80',
              audioUrl: 'https://actions.google.com/sounds/v1/weather/rain_heavy_loud.ogg',
            ),
          ];

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: fallbackSongs.length,
            itemBuilder: (context, index) {
              final song = fallbackSongs[index];
              final isCurrent = _audioService.currentSong?.id == song.id;
              final isPlaying = isCurrent && _audioService.isPlaying;

              return _buildSongCard(
                song: song,
                isCurrent: isCurrent,
                isPlaying: isPlaying,
                onTap: () {
                  _audioService.playSong(song, newPlaylist: fallbackSongs);
                },
              );
            },
          );
        }

        final songsList = docs.map((doc) {
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

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: songsList.length,
          itemBuilder: (context, index) {
            final song = songsList[index];
            final isCurrent = _audioService.currentSong?.id == song.id;
            final isPlaying = isCurrent && _audioService.isPlaying;

            return _buildSongCard(
              song: song,
              isCurrent: isCurrent,
              isPlaying: isPlaying,
              onTap: () {
                _audioService.playSong(song, newPlaylist: songsList);
              },
            );
          },
        );
      },
    );
  }

  // Premium Song Card
  Widget _buildSongCard({
    required SongModel song,
    required bool isCurrent,
    required bool isPlaying,
    required VoidCallback onTap,
    VoidCallback? onDelete,
  }) {
    final isFavorite = _audioService.isFavorite(song.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrent ? const Color(0xFFF1C40F) : Colors.grey.shade200,
          width: isCurrent ? 1.8 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isCurrent
                ? const Color(0xFFF1C40F).withValues(alpha: 0.15)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        onTap: onTap,
        leading: _buildSongThumbnail(song.imageUrl, song.isLocal, 52),
        title: Text(
          song.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: isCurrent ? const Color(0xFF6A1B29) : Colors.black87,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Row(
            children: [
              if (song.isLocal)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6A1B29).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('Local', style: TextStyle(fontSize: 10, color: Color(0xFF6A1B29), fontWeight: FontWeight.bold)),
                ),
              Expanded(
                child: Text(
                  song.artist,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ),
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Set as Ringtone Button
            IconButton(
              icon: Icon(
                _ringtoneService.isRingtoneSong(song.id)
                    ? Icons.ring_volume_rounded
                    : Icons.notifications_none_rounded,
                color: _ringtoneService.isRingtoneSong(song.id)
                    ? const Color(0xFF6A1B29)
                    : Colors.grey.shade500,
                size: 22,
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
            IconButton(
              icon: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? const Color(0xFFE74C3C) : Colors.grey.shade400,
                size: 22,
              ),
              onPressed: () => _audioService.toggleFavorite(song.id),
            ),
            if (onDelete != null)
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                onPressed: onDelete,
              ),
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: isCurrent ? const Color(0xFF6A1B29) : const Color(0xFFFCF8F2),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF6A1B29).withValues(alpha: 0.2)),
              ),
              child: Icon(
                isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: isCurrent ? const Color(0xFFF1C40F) : const Color(0xFF6A1B29),
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration d) {
    String minutes = d.inMinutes.toString().padLeft(2, '0');
    String seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  // Floating Mini Player (Quick Play/Pause + Tap to open Full Screen Player + Swipe to dismiss)
  Widget _buildMiniPlayer(SongModel song) {
    final isPlaying = _audioService.isPlaying;

    return Dismissible(
      key: ValueKey('mini_player_${song.id}'),
      direction: DismissDirection.horizontal,
      onDismissed: (_) {
        _audioService.closePlayer();
      },
      background: Container(
        color: const Color(0xFF6A1B29),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerLeft,
        child: const Row(
          children: [
            Icon(Icons.close, color: Colors.white, size: 24),
            SizedBox(width: 8),
            Text('Close Player', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      secondaryBackground: Container(
        color: const Color(0xFF6A1B29),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerRight,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text('Close Player', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            SizedBox(width: 8),
            Icon(Icons.close, color: Colors.white, size: 24),
          ],
        ),
      ),
      child: GestureDetector(
        onTap: _openNowPlaying,
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: const Color(0xFF220A0F),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: Column(
            children: [
              // Tiny Golden Linear Progress Indicator
              LinearProgressIndicator(
                value: (_audioService.duration.inSeconds > 0)
                    ? (_audioService.position.inSeconds / _audioService.duration.inSeconds).clamp(0.0, 1.0)
                    : 0.0,
                backgroundColor: Colors.white12,
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF1C40F)),
                minHeight: 2.5,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  child: Row(
                    children: [
                      _buildSongThumbnail(song.imageUrl, song.isLocal, 46),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              song.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Text(
                                  song.artist,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Color(0xFFF1C40F),
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '•  ${_formatDuration(_audioService.position)} / ${_formatDuration(_audioService.duration)}',
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_previous_rounded, color: Colors.white70, size: 28),
                        onPressed: _audioService.playPrevious,
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF1C40F),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            color: const Color(0xFF220A0F),
                            size: 26,
                          ),
                          onPressed: _audioService.togglePlayPause,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_next_rounded, color: Colors.white70, size: 28),
                        onPressed: _audioService.playNext,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
