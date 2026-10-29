
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../services/audio_player_service.dart';
import '../services/ringtone_service.dart';

class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen> {
  final AudioPlayerService _audioService = AudioPlayerService();
  double? _dragValue;

  @override
  void initState() {
    super.initState();
    _audioService.addListener(_onServiceUpdate);
  }

  @override
  void dispose() {
    _audioService.removeListener(_onServiceUpdate);
    super.dispose();
  }

  void _onServiceUpdate() {
    if (mounted) setState(() {});
  }

  String _formatDuration(Duration d) {
    String minutes = d.inMinutes.toString().padLeft(2, '0');
    String seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _showSleepTimerDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF220A0F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Sleep Timer',
                  style: TextStyle(
                    color: Color(0xFFF1C40F),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildTimerTile('15 నిమిషాలు (15 Mins)', 15),
                _buildTimerTile('30 నిమిషాలు (30 Mins)', 30),
                _buildTimerTile('45 నిమిషాలు (45 Mins)', 45),
                _buildTimerTile('60 నిమిషాలు (1 Hour)', 60),
                _buildTimerTile('ఆపివేయి (Turn Off Timer)', 0),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimerTile(String title, int minutes) {
    return ListTile(
      title: Text(title, style: const TextStyle(color: Colors.white, fontSize: 15)),
      trailing: Icon(Icons.alarm, color: Color(0xFFF1C40F), size: 20),
      onTap: () {
        Navigator.pop(context);
        if (minutes > 0) {
          Future.delayed(Duration(minutes: minutes), () {
            _audioService.pause();
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$minutes నిమిషాల తర్వాత మ్యూజిక్ ఆగిపోతుంది.'),
              backgroundColor: const Color(0xFF6A1B29),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('స్లీప్ టైమర్ తీసివేయబడింది.'),
              backgroundColor: const Color(0xFF6A1B29),
            ),
          );
        }
      },
    );
  }

  void _showQueuePlaylistDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1B070A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final playlist = _audioService.playlist;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Current Playlist',
                  style: TextStyle(
                    color: Color(0xFFF1C40F),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: playlist.length,
                    itemBuilder: (context, idx) {
                      final item = playlist[idx];
                      final isCurrent = idx == _audioService.currentIndex;
                      return ListTile(
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: _buildSongThumbnail(item.imageUrl, item.isLocal, 44),
                        ),
                        title: Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isCurrent ? const Color(0xFFF1C40F) : Colors.white,
                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          item.artist,
                          maxLines: 1,
                          style: TextStyle(
                            color: isCurrent ? const Color(0xFFF1C40F).withValues(alpha: 0.8) : Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                        trailing: isCurrent
                            ? Icon(Icons.graphic_eq, color: Color(0xFFF1C40F))
                            : null,
                        onTap: () {
                          Navigator.pop(ctx);
                          _audioService.playSong(item);
                        },
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
  }

  void _shareCurrentSong() {
    final song = _audioService.currentSong;
    if (song != null) {
      SharePlus.instance.share(
        ShareParams(
          text: '🌸 Divya Mandir - దివ్య భక్తి సంగీతం 🌸\n'
              'ఇప్పుడు వినండి: "${song.title}" - ${song.artist}\n'
              'భక్తి గీతాలు, మంత్రాలు మరియు ఆరతుల కోసం దివ్య మందిరం యాప్ ని చూడండి.',
        ),
      );
    }
  }

  Widget _buildSongThumbnail(String? imageUrl, bool isLocal, double size) {
    if (isLocal) {
      return Container(
        width: size,
        height: size,
        color: const Color(0xFF3B1017),
        child: Icon(Icons.music_note, color: Color(0xFFF1C40F), size: 28),
      );
    }

    if (imageUrl != null && imageUrl.isNotEmpty) {
      return Image.network(
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
              color: const Color(0xFF3B1017),
              child: Icon(Icons.temple_hindu, color: Color(0xFFF1C40F), size: 36),
            ),
          );
        },
      );
    }

    return Image.asset(
      'assets/images/app_logo.png',
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (c, e, s) => Container(
        width: size,
        height: size,
        color: const Color(0xFF3B1017),
        child: Icon(Icons.temple_hindu, color: Color(0xFFF1C40F), size: 36),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final song = _audioService.currentSong;
    final isFavorite = song != null && _audioService.isFavorite(song.id);

    final duration = _audioService.duration;
    final position = _audioService.position;
    final currentSec = _dragValue ?? position.inSeconds.toDouble().clamp(0.0, duration.inSeconds.toDouble() > 0 ? duration.inSeconds.toDouble() : 1.0);
    final totalSec = duration.inSeconds > 0 ? duration.inSeconds.toDouble() : 1.0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF2B080F), // Deep rich temple maroon
              Color(0xFF140306), // Midnight charcoal divine black
              Color(0xFF090103),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Bar: Back, "Now Playing", Share, More
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 32),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      'Now Playing',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.share_outlined, color: Colors.white, size: 22),
                          onPressed: _shareCurrentSong,
                        ),
                        IconButton(
                          icon: Icon(Icons.more_vert, color: Colors.white, size: 22),
                          onPressed: _showQueuePlaylistDialog,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 1),

              // Glowing Album Art with Golden Divine Border
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 36.0),
                child: Center(
                  child: Container(
                    width: 290,
                    height: 290,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFFF1C40F).withValues(alpha: 0.5),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFF1C40F).withValues(alpha: 0.25),
                          blurRadius: 30,
                          spreadRadius: 4,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.7),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(22),
                      child: song != null
                          ? _buildSongThumbnail(song.imageUrl, song.isLocal, 290)
                          : Container(
                              color: const Color(0xFF3B1017),
                              child: Icon(Icons.music_note, color: Color(0xFFF1C40F), size: 80),
                            ),
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 1),

              // Title, Artist, & Favorite Heart
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            song?.title ?? 'No Song Selected',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            song?.artist ?? 'Divya Mandir',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? const Color(0xFFE74C3C) : Colors.white70,
                        size: 28,
                      ),
                      onPressed: song != null
                          ? () => _audioService.toggleFavorite(song.id)
                          : null,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Premium Gold Audio Progress Slider
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xFFF1C40F),
                    inactiveTrackColor: Colors.white24,
                    trackHeight: 3.5,
                    thumbColor: const Color(0xFFF1C40F),
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.5),
                    overlayColor: const Color(0xFFF1C40F).withValues(alpha: 0.2),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                  ),
                  child: Slider(
                    min: 0.0,
                    max: totalSec > 0 ? totalSec : 1.0,
                    value: currentSec.clamp(0.0, totalSec),
                    onChanged: (val) {
                      setState(() => _dragValue = val);
                    },
                    onChangeEnd: (val) {
                      _audioService.seek(Duration(seconds: val.toInt()));
                      setState(() => _dragValue = null);
                    },
                  ),
                ),
              ),

              // Time Indicators
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(Duration(seconds: currentSec.toInt())),
                      style: const TextStyle(color: Colors.white60, fontSize: 13),
                    ),
                    Text(
                      _formatDuration(duration),
                      style: const TextStyle(color: Colors.white60, fontSize: 13),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 1),

              // Player Controls (Shuffle, Previous, Play/Pause, Next, Repeat)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Shuffle
                    IconButton(
                      icon: Icon(
                        Icons.shuffle,
                        color: _audioService.isShuffle ? const Color(0xFFF1C40F) : Colors.white54,
                        size: 26,
                      ),
                      onPressed: _audioService.toggleShuffle,
                    ),

                    // Previous
                    IconButton(
                      icon: Icon(Icons.skip_previous_rounded, color: Color(0xFFF1C40F), size: 42),
                      onPressed: _audioService.playPrevious,
                    ),

                    // Center Play/Pause Golden Circle
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1C40F),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFF1C40F).withValues(alpha: 0.45),
                            blurRadius: 18,
                            spreadRadius: 2,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: _audioService.isLoading
                          ? const Center(
                              child: SizedBox(
                                width: 30,
                                height: 30,
                                child: CircularProgressIndicator(
                                  color: Color(0xFF2B080F),
                                  strokeWidth: 3,
                                ),
                              ),
                            )
                          : IconButton(
                              icon: Icon(
                                _audioService.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                color: const Color(0xFF2B080F),
                                size: 44,
                              ),
                              onPressed: _audioService.togglePlayPause,
                            ),
                    ),

                    // Next
                    IconButton(
                      icon: Icon(Icons.skip_next_rounded, color: Color(0xFFF1C40F), size: 42),
                      onPressed: _audioService.playNext,
                    ),

                    // Repeat Mode (off, all, one)
                    IconButton(
                      icon: Icon(
                        _audioService.repeatMode == AudioLoopMode.one
                            ? Icons.repeat_one_rounded
                            : Icons.repeat_rounded,
                        color: _audioService.repeatMode != AudioLoopMode.off
                            ? const Color(0xFFF1C40F)
                            : Colors.white54,
                        size: 26,
                      ),
                      onPressed: _audioService.toggleRepeat,
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 1),

              // Bottom Actions: Ringtone, Download, Lyrics, Playlist, Sleep Timer
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildBottomAction(
                      icon: Icons.ring_volume_rounded,
                      label: 'Ringtone',
                      onTap: () {
                        if (song != null) {
                          RingtoneService.showSetRingtoneSheet(
                            context: context,
                            songId: song.id,
                            songTitle: song.title,
                            audioUrl: song.audioUrl,
                            isLocal: song.isLocal,
                          );
                        }
                      },
                    ),
                    _buildBottomAction(
                      icon: Icons.download_rounded,
                      label: 'Download',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('పాట ఆటో-క్యాష్ అయ్యి ఆఫ్‌లైన్ లో ప్లే అవుతుంది (Auto-Cached).'),
                            backgroundColor: Color(0xFF6A1B29),
                          ),
                        );
                      },
                    ),
                    _buildBottomAction(
                      icon: Icons.article_outlined,
                      label: 'Lyrics',
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: const Color(0xFF220A0F),
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          builder: (ctx) => Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  song?.title ?? 'Lyrics',
                                  style: const TextStyle(
                                    color: Color(0xFFF1C40F),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'ఓం శ్రీ గణేశాయ నమః...\nశ్రీ గోవింద నామాలు...\nసర్వమంగళ మాంగల్యే శివే సర్వార్థ సాధికే\nశరణ్యే త్ర్యంబకే గౌరి నారాయణి నమోస్తుతే 🙏',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.8),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    _buildBottomAction(
                      icon: Icons.queue_music_rounded,
                      label: 'Playlist',
                      onTap: _showQueuePlaylistDialog,
                    ),
                    _buildBottomAction(
                      icon: Icons.timer_outlined,
                      label: 'Sleep Timer',
                      onTap: _showSleepTimerDialog,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white70, size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
